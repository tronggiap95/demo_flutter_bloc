package com.octo.octo_beat_plugin.core.device.command;

import android.util.Log;

import org.json.JSONArray;
import org.msgpack.core.MessagePack;
import org.msgpack.core.MessagePacker;

import java.io.ByteArrayOutputStream;

import static com.octo.octo_beat_plugin.core.device._enum.RequestCode.BB_REQ_HANDSHAKE;
import static com.octo.octo_beat_plugin.core.device._enum.ResponseCode.BB_RSP_ERR_API_VER;
import static com.octo.octo_beat_plugin.core.device._enum.ResponseCode.BB_RSP_ERR_FULL_DEVICE;
import static com.octo.octo_beat_plugin.core.device._enum.ResponseCode.BB_RSP_ERR_NOT_PAIRED;
import static com.octo.octo_beat_plugin.core.device._enum.ResponseCode.BB_RSP_ERR_PACKET_VER;
import static com.octo.octo_beat_plugin.core.device._enum.ResponseCode.BB_RSP_ERR_PARAM;
import static com.octo.octo_beat_plugin.core.device._enum.ResponseCode.BB_RSP_OK;

/**
 * Created by caoxuanphong on 12/19/17.
 */

public class HandShakeCmd {
    private static final String TAG = "HandShakeCmd";

    public static byte[] response(int response, long time, int timezone) {
        if (response != BB_RSP_OK.value &&
                response != BB_RSP_ERR_NOT_PAIRED.value &&
                response != BB_RSP_ERR_PARAM.value &&
                response != BB_RSP_ERR_PACKET_VER.value &&
                response != BB_RSP_ERR_API_VER.value &&
                response != BB_RSP_ERR_FULL_DEVICE.value) {
            Log.e(TAG, "response: invalid response code");
            return null;
        }

        JSONArray jsonArray = new JSONArray();
        jsonArray.put(BB_REQ_HANDSHAKE.value);
        jsonArray.put(response);
        jsonArray.put(time);
        jsonArray.put(timezone);
        jsonArray.put("BLE");

        return pack(jsonArray);
    }

    public static byte[] pack(JSONArray jsonArray) {
        ByteArrayOutputStream out = new ByteArrayOutputStream();
        MessagePacker packer = MessagePack.newDefaultPacker(out);
        try {
            packer.packArrayHeader(jsonArray.length())
                    .packInt(jsonArray.getInt(0))
                    .packInt(jsonArray.getInt(1))
                    .packLong(jsonArray.getLong(2))
                    .packInt(jsonArray.getInt(3))
                    .packString(jsonArray.getString(4));

            packer.close();
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }

        return out.toByteArray();
    }

}
