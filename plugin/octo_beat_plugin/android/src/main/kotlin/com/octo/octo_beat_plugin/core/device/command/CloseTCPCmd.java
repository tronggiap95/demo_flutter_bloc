package com.octo.octo_beat_plugin.core.device.command;

import android.util.Log;

import org.json.JSONArray;
import org.msgpack.core.MessagePack;
import org.msgpack.core.MessagePacker;

import java.io.ByteArrayOutputStream;

import static com.octo.octo_beat_plugin.core.device._enum.RequestCode.BB_REQ_TCP_CLOSE_CONN;
import static com.octo.octo_beat_plugin.core.device._enum.ResponseCode.BB_RSP_ERR_PARAM;
import static com.octo.octo_beat_plugin.core.device._enum.ResponseCode.BB_RSP_ERR_PERMISSION;
import static com.octo.octo_beat_plugin.core.device._enum.ResponseCode.BB_RSP_OK;

/**
 * Created by caoxuanphong on 12/19/17.
 */

public class CloseTCPCmd {
    private static final String TAG = "HandShakeCmd";

    public static byte[] response(int response) {
        if (response != BB_RSP_OK.value &&
                response != BB_RSP_ERR_PARAM.value &&
                response != BB_RSP_ERR_PERMISSION.value) {
            Log.e(TAG, "response: invalid response code");
            return null;
        }

        JSONArray jsonArray = new JSONArray();

        jsonArray.put(BB_REQ_TCP_CLOSE_CONN.value);
        jsonArray.put(response);

        return pack(jsonArray);
    }

    private static byte[] pack(JSONArray jsonArray) {
        ByteArrayOutputStream out = new ByteArrayOutputStream();
        MessagePacker packer = MessagePack.newDefaultPacker(out);
        try {
            packer.packArrayHeader(jsonArray.length())
                    .packInt(jsonArray.getInt(0))
                    .packInt(jsonArray.getInt(1));
            packer.close();
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }

        return out.toByteArray();
    }

}
