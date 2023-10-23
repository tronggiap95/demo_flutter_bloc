package com.octo.octo_beat_plugin.core.device.command;

import org.json.JSONArray;
import org.json.JSONException;

import com.octo.octo_beat_plugin.core.device.model.DXHDevice;
import com.octo.octo_beat_plugin.core.utils.ByteUtils;
import com.octo.octo_beat_plugin.core.utils.CRC16CCITT;
import com.octo.octo_beat_plugin.core.utils.MyLog;
import com.octo.octo_beat_plugin.core.utils.PacketLengthHelper;

import static com.octo.octo_beat_plugin.core.device._enum.RequestCode.INVALID_CMD;

/**
 * Created by caoxuanphong on 12/19/17.
 */

public class CommandUtils {
    private static final String TAG = "CommandUtils";

    public static int getCode(JSONArray jsonArray) {
        try {
            return jsonArray.getInt(0);
        } catch (JSONException e) {
            e.printStackTrace();
            return INVALID_CMD.value;
        } catch (NullPointerException e) {
            e.printStackTrace();
            return INVALID_CMD.value;
        }
    }

    public static byte[] packPacketRequest(byte[] payloadData, DXHDevice dxhDevice) {
        MyLog.log(TAG, "build request: " + ByteUtils.toHexString(payloadData));
        try {
            byte status = 0x00;
            return packPacket(dxhDevice, payloadData, status);
        } catch (Exception ex) {
            ex.printStackTrace();
            return null;
        }
    }


    public static byte[] packPacketResponse(byte[] payloadData, DXHDevice dxhDevice) {
        try {
            MyLog.log(TAG, "build response: " + ByteUtils.toHexString(payloadData));
            byte status = 0x01;
            return packPacket(dxhDevice, payloadData, status);
        } catch (Exception ex) {
            ex.printStackTrace();
            return null;
        }
    }

    public static byte[] packPacketNotify(byte[] payloadData, DXHDevice dxhDevice) {
        MyLog.log(TAG, "build notify: " + ByteUtils.toHexString(payloadData));
        try {
            byte status = 0x02;
            return packPacket(dxhDevice, payloadData, status);
        } catch (Exception ex) {
            ex.printStackTrace();
            return null;
        }
    }

    private static byte[] packPacket(DXHDevice dxhDevice, byte[] payloadData, byte status) {
        byte protoVersion = (byte) (dxhDevice.getProtocolVersion() << 4);
        byte[] buf = new byte[4];

        if (dxhDevice.getProtocolVersion() > 0) {
            byte[] encryptedData = dxhDevice.getSecurity().encrypt(payloadData);

            if (encryptedData != null) {
                int count = PacketLengthHelper.encode_length(encryptedData.length, buf);
                byte[] payloadSize = ByteUtils.subByteArray(buf, 0, count);

                byte[] bb1 = ByteUtils.concatenate(new byte[]{(byte) (status + protoVersion)}, payloadSize);
                byte[] bb2 = ByteUtils.concatenate(bb1, encryptedData);

                byte[] crc = CRC16CCITT.calc(bb2);
                return ByteUtils.concatenate(bb2, crc);
            } else {
                MyLog.log(dxhDevice.getClientId(), "ENCRYPT FAILED");
                return null;
            }
        } else {
            int count = PacketLengthHelper.encode_length(payloadData.length, buf);
            byte[] payloadSize = ByteUtils.subByteArray(buf, 0, count);

            byte[] bb1 = ByteUtils.concatenate(new byte[]{status}, payloadSize);
            byte[] bb2 = ByteUtils.concatenate(bb1, payloadData);

            byte[] crc = CRC16CCITT.calc(bb2);
            return ByteUtils.concatenate(bb2, crc);
        }
    }
}
