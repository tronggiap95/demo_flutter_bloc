package com.octo.octo_beat_plugin.core.device.parser.bluetooth;

import android.util.Log;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.util.concurrent.ArrayBlockingQueue;
import java.util.concurrent.BlockingQueue;

import com.octo.octo_beat_plugin.core.device._enum.StatusCode;
import com.octo.octo_beat_plugin.core.device.handler.NotifyLowTCPSpeedHandler;
import com.octo.octo_beat_plugin.core.device.model.DXHDevice;
import com.octo.octo_beat_plugin.core.device.parser.ParsePacketErrorListener;
import com.octo.octo_beat_plugin.core.model.Packet;
import com.octo.octo_beat_plugin.core.model.PacketState;
import com.octo.octo_beat_plugin.core.utils.ByteUtils;
import com.octo.octo_beat_plugin.core.utils.CRC16CCITT;
import com.octo.octo_beat_plugin.core.utils.MyLog;
import com.octo.octo_beat_plugin.core.utils.PacketLengthHelper;
import io.reactivex.disposables.Disposable;

/**
 * Created by caoxuanphong on 12/21/17.
 */

public class PacketBLParserImp {
    private static final String TAG = "PacketBLParserImp";
    private String TAG_DEBUG = "";
    private Packet mPacket;
    private BlockingQueue<byte[]> payloads = new ArrayBlockingQueue<byte[]>(100);
    private DXHDevice dxhDevice;
    private ParsePacketErrorListener listener;
    private Disposable timerDisposable;
    private Boolean isSendingLowCapacity = false;

    public PacketBLParserImp(DXHDevice dxhDevice, ParsePacketErrorListener listener) {
        this.dxhDevice = dxhDevice;
        this.listener = listener;
        mPacket = new Packet();
        mPacket.clear();
    }

    public synchronized void parse(byte[] data) {
        parse(data, mPacket);
    }

    public byte[] retrievePacket() throws InterruptedException {
//        Log.d(TAG, "PACKET-SIZE: " + packets.size());
        return payloads.take();
    }

    /**
     * LOW PACKET CAPACITY HANDLER
     * 1: LOW MEMORY
     * 0: HIGH MEMORY
     */
    public void handleLowCapacity() {
        if (dxhDevice != null && dxhDevice.getApiVersion() > 1) {
//            Log.d(TAG, "PACKET-SIZE: " + payloads.size());
            if (payloads.remainingCapacity() < 50 && !isSendingLowCapacity) {
                NotifyLowTCPSpeedHandler.Companion.handle(dxhDevice, 1);
//                Log.d(TAG, "PACKET-SIZE SENDING LOW CAPACITY: " + payloads.size());
                isSendingLowCapacity = true;
            } else if (payloads.remainingCapacity() > 90 && isSendingLowCapacity) {
                NotifyLowTCPSpeedHandler.Companion.handle(dxhDevice, 0);
//                Log.d(TAG, "PACKET-SIZE SENDING HIGH CAPACITY: " + payloads.size());
                isSendingLowCapacity = false;
            }
        }
    }

    private void parse(byte[] data, Packet currentPacket) {
        if (data == null || data.length == 0) {
            mPacket = currentPacket;
            return;
        }

        if (currentPacket == null) {
            mPacket = new Packet();
            mPacket.clear();
        }


        byte[] buffer = data;
        boolean done = false;

        while (!done && (buffer != null && buffer.length > 0)) {
            switch (currentPacket.packetState) {
                case NONE:
                    buffer = readStatus(buffer, currentPacket);
                    break;

                case READING_PAYLOAD_SIZE:
                    buffer = readPayloadSize(buffer, currentPacket);
                    break;

                case READING_PAYLOAD_DATA:
                    buffer = readPayloadData(buffer, currentPacket);
                    break;

                case READING_CRC:
                    buffer = readCRC(buffer, currentPacket);
                    if (currentPacket.receivedCrc16 == 2) {
                        done = true;
                        crcDonehandler(currentPacket);
                    }
                    break;
                default:
                    break;

            }
        }
        parse(buffer, currentPacket);

    }

    private void crcDonehandler(Packet currentPacket) {
        if (timerDisposable != null) {
            timerDisposable.dispose();
        }

        byte[] b1 = new byte[]{(byte) currentPacket.statusData};
        byte[] b2 = ByteUtils.subByteArray(currentPacket.payloadSizeBuffer,
                0,
                currentPacket.receivedPayloadSize);
        byte[] b3 = currentPacket.payloadData;
        byte[] b4 = currentPacket.crc16;

        if (checkCRC(b1, b2, b3, b4)) {
            try {
                dxhDevice.setProtocolVersion(currentPacket.protocolVersion);
                if (currentPacket.protocolVersion > 0) {
                    byte[] dencryptedData = dxhDevice.getSecurity().decrypt(currentPacket.payloadData);
                    if (dencryptedData != null) {
                        try {
                            payloads.put(dencryptedData);
                        } catch (InterruptedException e) {
                            e.printStackTrace();
                        }
                    } else {
                        listener.receivedPacketIncorrectCRC(dxhDevice);
                    }
                } else {
                    payloads.put(currentPacket.payloadData);
                }
                MyLog.log(dxhDevice.getClientId(), "------COMING PACKET-----\n" + currentPacket);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        } else {
            if (listener != null) {
                listener.receivedPacketIncorrectCRC(dxhDevice);
            }
        }
        currentPacket.clear();
    }

    /**
     * This method makes a "deep clone" of any Java object it is given.
     */
    public static Object deepClone(Object object) {
        try {
            ByteArrayOutputStream baos = new ByteArrayOutputStream();
            ObjectOutputStream oos = new ObjectOutputStream(baos);
            oos.writeObject(object);
            ByteArrayInputStream bais = new ByteArrayInputStream(baos.toByteArray());
            ObjectInputStream ois = new ObjectInputStream(bais);
            return ois.readObject();
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    private byte[] readStatus(byte[] buffer, Packet packet) {
        int statusCode = buffer[0] & 0x0f;
        if (!StatusCode.isValid(statusCode)) {
            if (listener != null) {
                listener.receivedInvalidStatusCode(dxhDevice);
            }

            return null;
        }

        if (statusCode == StatusCode.Ignore.value) {
            buffer = ByteUtils.subByteArray(buffer, 1, buffer.length - 1);
            return buffer;
        }

        packet.statusData = buffer[0];
        packet.status = buffer[0] & 0x0f;
        packet.protocolVersion = (buffer[0] & 0xf0) >> 4;
        packet.packetState = PacketState.READING_PAYLOAD_SIZE;
        buffer = ByteUtils.subByteArray(buffer, 1, buffer.length - 1);
        return buffer;
    }

    private byte[] readPayloadSize(byte[] buffer, Packet packet) {
        do {
            byte b = ByteUtils.subByteArray(buffer, 0, 1)[0];
            buffer = ByteUtils.subByteArray(buffer, 1, buffer.length - 1);
            if (packet.payloadSizeBuffer == null) {
                packet.payloadSizeBuffer = new byte[4];
            }

            ByteUtils.append(packet.payloadSizeBuffer, new byte[]{b}, packet.receivedPayloadSize);
            packet.receivedPayloadSize++;

            if ((b & 0x80) == 0x00) {// last bit
                byte[] tmp = ByteUtils.subByteArray(packet.payloadSizeBuffer, 0, packet.receivedPayloadSize);
                packet.payloadSize = PacketLengthHelper.decodePacketLength(tmp, packet.receivedPayloadSize & 0xff);
                packet.packetState = PacketState.READING_PAYLOAD_DATA;

                if (packet.payloadSize > Packet.MAX_PACKET_LENGTH_IN_BYTES) {
                    if (listener != null) {
                        listener.receivedInvalidPacketLength(dxhDevice);
                    }
                }

                break;
            } else if (packet.receivedPayloadSize == 4) {
                if (listener != null) {
                    listener.receivedInvalidPacketLength(dxhDevice);
                }

                break;
            } else {
                // System.out.println("readPayloadSize not done");
            }
        } while (buffer != null && buffer.length > 0);

        return buffer;
    }

    private byte[] readPayloadData(byte[] buffer, Packet packet) {
        byte[] b1 = ByteUtils.subByteArray(buffer, 0, packet.payloadSize - packet.receivedPayloadDataSize);

        if (b1 == null) {
            return null;
        }

        if (packet.payloadData == null) {
            packet.payloadData = b1;
        } else {
            packet.payloadData = ByteUtils.concatenate(packet.payloadData, b1);
        }

        buffer = ByteUtils.subByteArray(buffer, b1.length, buffer.length - b1.length);


        // b1 size == | < buffer size,
        if (buffer == null || buffer.length <= packet.payloadSize) {
            packet.receivedPayloadDataSize += b1.length;
        } else { // read full
            packet.receivedPayloadDataSize += (packet.payloadSize - packet.receivedPayloadDataSize);
        }

        if (packet.receivedPayloadDataSize == packet.payloadSize) {
            packet.packetState = PacketState.READING_CRC;
        } else if (packet.receivedPayloadDataSize > packet.payloadSize) {
//            assert (true);
        }

        return buffer;
    }

    private byte[] readCRC(byte[] buffer, Packet packet) {
        if (packet.crc16 == null) {
            packet.crc16 = new byte[2];
        }

        do {
            byte b = ByteUtils.subByteArray(buffer, 0, 1)[0];
            buffer = ByteUtils.subByteArray(buffer, 1, buffer.length - 1);

            ByteUtils.append(packet.crc16, new byte[]{b}, packet.receivedCrc16);
            packet.receivedCrc16++;

            if (packet.receivedCrc16 == 2) {
                packet.packetState = PacketState.FULLED;
                break;
            } else {
                //  System.out.println("readCRC not done");
            }

        } while (buffer != null && buffer.length > 0);

        return buffer;
    }

    private boolean checkCRC(byte[] status,
                             byte[] payloadSize,
                             byte[] payloadData,
                             byte[] receivedCrc) {
        byte[] tmp = ByteUtils.concatenate(status, payloadSize);
        byte[] data = ByteUtils.concatenate(tmp, payloadData);
        byte[] crc = CRC16CCITT.calc(data);

        return ByteUtils.compare2Array(receivedCrc, crc);
    }

    public void disposeTimeOut() {
        if (timerDisposable != null) {
            timerDisposable.dispose();
        }
    }
}
