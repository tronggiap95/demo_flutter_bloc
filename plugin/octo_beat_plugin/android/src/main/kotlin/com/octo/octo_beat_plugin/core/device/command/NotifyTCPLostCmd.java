package com.octo.octo_beat_plugin.core.device.command;

import org.json.JSONArray;
import org.msgpack.core.MessagePack;
import org.msgpack.core.MessagePacker;

import java.io.ByteArrayOutputStream;

import static com.octo.octo_beat_plugin.core.device._enum.NotifyCode.BB_NT_TCP_CONN_LOST;

/**
 * Created by caoxuanphong on 12/19/17.
 */

public class NotifyTCPLostCmd {
    private static final String TAG = "NotifyTCPLostCmd";

    public static byte[] response(int connectionId) {
        JSONArray jsonArray = new JSONArray();

        jsonArray.put(BB_NT_TCP_CONN_LOST.value);
        jsonArray.put(connectionId);
        return pack(jsonArray);
    }

    public static byte[] pack(JSONArray jsonArray) {
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
