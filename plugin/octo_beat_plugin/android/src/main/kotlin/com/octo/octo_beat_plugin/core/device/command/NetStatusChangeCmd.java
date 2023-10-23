package com.octo.octo_beat_plugin.core.device.command;

import org.json.JSONArray;
import org.msgpack.core.MessagePack;
import org.msgpack.core.MessagePacker;

import java.io.ByteArrayOutputStream;

import static com.octo.octo_beat_plugin.core.device._enum.NotifyCode.BB_NT_NETSTAT_UPDATE;

/**
 * Created by caoxuanphong on 12/19/17.
 */

public class NetStatusChangeCmd {
    private static final String TAG = "NetStatusChangeCmd";

    public static byte[] response(boolean available) {
        JSONArray jsonArray = new JSONArray();

        jsonArray.put(BB_NT_NETSTAT_UPDATE.value);
        jsonArray.put(available);
        return pack(jsonArray);
    }

    public static byte[] pack(JSONArray jsonArray) {
        ByteArrayOutputStream out = new ByteArrayOutputStream();
        MessagePacker packer = MessagePack.newDefaultPacker(out);
        try {
            packer.packArrayHeader(jsonArray.length())
                    .packInt(jsonArray.getInt(0))
                    .packBoolean(jsonArray.getBoolean(1));
            packer.close();
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }

        return out.toByteArray();
    }

}
