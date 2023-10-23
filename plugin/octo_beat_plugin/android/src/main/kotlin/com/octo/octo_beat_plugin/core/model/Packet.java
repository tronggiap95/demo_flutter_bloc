package com.octo.octo_beat_plugin.core.model;

import android.util.Log;

import java.io.Serializable;
import java.util.Arrays;

import com.octo.octo_beat_plugin.core.model.PacketState;
import com.octo.octo_beat_plugin.core.utils.ByteUtils;
import com.octo.octo_beat_plugin.core.utils.CRC16CCITT;
import com.octo.octo_beat_plugin.core.utils.PacketLengthHelper;

/**
 * Created by caoxuanphong on 12/18/17.
 */

public class Packet implements Serializable {
    private static String TAG = "Packet";
    public static final int MAX_PACKET_LENGTH_IN_BYTES = 3 * 1024;
    public byte statusData;
    public int status = -1;
    public int protocolVersion = 0;

    public byte[] payloadSizeBuffer;
    public int receivedPayloadSize;
    public int payloadSize;

    public byte[] payloadData;
    public int receivedPayloadDataSize;

    public byte[] crc16;
    public int receivedCrc16;

    public PacketState packetState;

    public byte[] buildOriginalPacket() {
        int size = 1 + receivedPayloadSize + receivedPayloadDataSize + receivedCrc16;
        Log.d(TAG, "size: " + size);
        byte[] packet = new byte[size];
        packet[0] = (byte) status;
        for (int i = 0; i < receivedPayloadSize; i++) {
            packet[i + 1] = payloadSizeBuffer[i];
        }
        ByteUtils.append(packet, payloadData, receivedPayloadSize + 1);
        ByteUtils.append(packet, crc16, receivedPayloadSize + receivedPayloadDataSize + 1);
        return packet;
    }

    public byte[] buildPacket() {
        byte status = (byte) this.status;
        byte[] buf = new byte[4];

        int count = PacketLengthHelper.encode_length(payloadData.length, buf);
        byte[] payloadSize = ByteUtils.subByteArray(buf, 0, count);

        byte[] bb1 = ByteUtils.concatenate(new byte[]{status}, payloadSize);
        byte[] bb2 = ByteUtils.concatenate(bb1, payloadData);

        byte[] crc = CRC16CCITT.calc(bb2);
        return ByteUtils.concatenate(bb2, crc);
    }

    public void clear() {
        statusData = -1;
        status = -1;
        protocolVersion = 0;

        payloadSizeBuffer = null;
        receivedPayloadSize = 0;
        payloadSize = 0;

        payloadData = null;
        receivedPayloadDataSize = 0;

        crc16 = null;
        receivedCrc16 = 0;

        packetState = PacketState.NONE;
    }

    @Override
    public String toString() {
        return "Packet{" +
                "\nstatusData=" + statusData +
                ",\n status=" + status +
                ",\n protocolVersion=" + protocolVersion +
                ",\n payloadSizeBuffer=" + ByteUtils.toHexString(payloadSizeBuffer) +
                ",\n receivedPayloadSize=" + receivedPayloadSize +
                ",\n payloadSize=" + payloadSize +
                ",\n payloadData=" + ByteUtils.toHexString(payloadData) +
                ",\n receivedPayloadDataSize=" + receivedPayloadDataSize +
                ",\n crc16=" + ByteUtils.toHexString(crc16) +
                ",\n receivedCrc16=" + receivedCrc16 +
                ",\n packetState=" + packetState +
                '}';
    }
}
