package com.octo.octo_beat_plugin.core.device.parser.tcp;

import android.util.Log;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.util.concurrent.ArrayBlockingQueue;
import java.util.concurrent.BlockingQueue;

import com.octo.octo_beat_plugin.core.device.model.DXHDevice;
import com.octo.octo_beat_plugin.core.device.parser.ParsePacketErrorListener;
import com.octo.octo_beat_plugin.core.model.Packet;
import com.octo.octo_beat_plugin.core.model.PacketState;
import com.octo.octo_beat_plugin.core.utils.ByteUtils;
import com.octo.octo_beat_plugin.core.utils.CRC16CCITT;
import com.octo.octo_beat_plugin.core.utils.PacketLengthHelper;

public class PacketTCPParserImp {
    private static final String TAG = "PacketTCPParserImp";
    private Packet mPacket;
    private BlockingQueue<Packet> packets = new ArrayBlockingQueue<Packet>(100);
    private DXHDevice dxhDevice;
    private ParsePacketErrorListener listener;

    public PacketTCPParserImp(DXHDevice dxhDevice, ParsePacketErrorListener listener) {
        this.dxhDevice = dxhDevice;
        this.listener = listener;
    }

    public void parse(byte[] data) {
        parse(data, mPacket);
    }

    public Packet retrievePacket() throws InterruptedException {
        return packets.take();
    }

    private void parse(byte[] data, Packet currentPacket) {
        if (data == null || data.length == 0) {
//            Log.w(TAG, "parse: payloadData is invalid");
            mPacket = currentPacket;
//            System.out.println("parse: payloadData is invalid");
            return;
        }

        Log.d(TAG, "parse length: " + data.length);
//        Log.d(TAG, "parse data : " + ByteUtils.toHexString(data));
//        System.out.println("data: " + ByteUtils.toHexString(data));

        if (currentPacket == null) {
            currentPacket = new Packet();
            currentPacket.packetState = PacketState.NONE;
        }

        byte[] buffer = data;
        boolean done = false;

        while (!done && (buffer != null && buffer.length > 0)) {
           // System.out.println("state = " + currentPacket.packetState);
            switch (currentPacket.packetState) {
                case NONE:
                    buffer = readStatus(buffer, currentPacket);
 //                   System.out.println("state = " + currentPacket.packetState);
//                    System.out.println("NONE buffer: " + ByteUtils.toHexString(buffer));
                    break;

                case READING_PAYLOAD_SIZE:
                    buffer = readPayloadSize(buffer, currentPacket);
//                    System.out.println("READING_PAYLOAD_SIZE buffer: " + ByteUtils.toHexString(buffer));
                    break;

                case READING_PAYLOAD_DATA:
                    buffer = readPayloadData(buffer, currentPacket);
//                    System.out.println("READING_PAYLOAD_DATA buffer: " + ByteUtils.toHexString(buffer));
                    break;

                case READING_CRC:
                    buffer = readCRC(buffer, currentPacket);
//                    System.out.println("READING_CRC buffer: " + ByteUtils.toHexString(buffer));

                    if (currentPacket.receivedCrc16 == 2) {
                        done = true;
                        try {
                            packets.put((Packet) deepClone(currentPacket));
                        } catch (InterruptedException e) {
                            e.printStackTrace();
                        }
                        currentPacket = null;
                    }

                    break;

                default:
                    break;

            }
        }

        parse(buffer, currentPacket);
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
        int statusCode = buffer[0] & 0xff;
        Log.d(TAG, "readStatus code: " + Integer.toHexString(statusCode));

        packet.status = buffer[0] & 0xff;
        packet.packetState = PacketState.READING_PAYLOAD_SIZE;
        buffer = ByteUtils.subByteArray(buffer, 1, buffer.length - 1);
       // System.out.println("parse - status: " + packet.status);

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

            if ((b & 0x80) == 0x00) {
                byte[] tmp = ByteUtils.subByteArray(packet.payloadSizeBuffer, 0, packet.receivedPayloadSize);
                packet.payloadSize = PacketLengthHelper.decodePacketLength(tmp, packet.receivedPayloadSize & 0xff);
                packet.packetState = PacketState.READING_PAYLOAD_DATA;
                if(packet.payloadSize == 0) {
                    packet.receivedPayloadDataSize = 0;
                    packet.payloadData = new byte[0];
                    packet.packetState = PacketState.READING_CRC;
                }
               // System.out.println("readPayloadSize done - payload size: " + packet.payloadSize);
                Log.d(TAG, "readPayloadSize: " + packet.payloadSize);
                break;
            } else {
               // System.out.println("readPayloadSize not done");
            }
        } while (buffer != null && buffer.length > 0);

        return buffer;
    }


    private byte[] readPayloadData(byte[] buffer, Packet packet) {
       // System.out.println(packet.payloadSize + " - " + packet.receivedPayloadDataSize);
        byte[] b1 = ByteUtils.subByteArray(buffer, 0, packet.payloadSize - packet.receivedPayloadDataSize);

        if (b1 == null) {
           // System.out.println("b1 is null");
            return null;
        }

        System.out.println(packet.payloadSize);
//        System.out.println(ByteUtils.toHexString(b1));
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


//        System.out.println("data receiving: " + packet.payloadSize + "/" + packet.receivedPayloadDataSize);

        if (packet.receivedPayloadDataSize == packet.payloadSize) {
            packet.packetState = PacketState.READING_CRC;
           // System.out.println("parse - received payload data done");
        } else if (packet.receivedPayloadDataSize > packet.payloadSize) {
            assert (true);
          //  System.out.println("receivedPayloadDataSize > receivedPayloadSize" +
//                    ", " + packet.receivedPayloadDataSize +
//                    ", " + packet.payloadSize);
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

//            System.out.println("readCRC read: " + ByteUtils.toHexString(new byte[]{b}));
//            System.out.println("readCRC buffer remain : " + ByteUtils.toHexString(buffer));
            ByteUtils.append(packet.crc16, new byte[]{b}, packet.receivedCrc16);
            packet.receivedCrc16++;

            if (packet.receivedCrc16 == 2) {
                packet.packetState = PacketState.FULLED;
                System.out.println("readCRC - full packet");
                break;
            } else {
                System.out.println("readCRC not done");
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

//        Log.d(TAG, "checkCRC: " + ByteUtils.toHexString(data));
//        Log.d(TAG, "checkCRC: " + ByteUtils.toHexString(status));
//        Log.d(TAG, "checkCRC: " + ByteUtils.toHexString(payloadSize));
//        Log.d(TAG, "checkCRC: " + ByteUtils.toHexString(payloadData));
//        Log.d(TAG, "checkCRC: " + ByteUtils.toHexString(receivedCrc));
//
//        Log.d(TAG, "checkCRC: " + ByteUtils.toHexString(crc));
        return ByteUtils.compare2Array(receivedCrc, crc);
    }
}
