package com.octo.octo_beat_plugin.core.device.command;

import org.json.JSONArray;
import org.json.JSONException;
import org.msgpack.core.MessagePack;
import org.msgpack.core.MessagePacker;

import java.io.ByteArrayOutputStream;
import java.io.IOException;

import static com.octo.octo_beat_plugin.core.device._enum.NotifyCode.BB_NT_TCP_RX_DATA_RDY;

/**
 * Created by caoxuanphong on 12/19/17.
 */

public class NotifyTCPReceiveDataCmd {
    private static final String TAG = "NotifyTCPReceiveDataCmd";

    public static byte[] response(int connectionId, int length) {
        JSONArray jsonArray = new JSONArray();

        jsonArray.put(BB_NT_TCP_RX_DATA_RDY.value);
        jsonArray.put(connectionId);
        jsonArray.put(length);

        return pack(jsonArray);
    }

    private static byte[] pack(JSONArray jsonArray) {
        ByteArrayOutputStream out = new ByteArrayOutputStream();
        MessagePacker packer = MessagePack.newDefaultPacker(out);
        try {
            packer.packArrayHeader(jsonArray.length())
                    .packInt(jsonArray.getInt(0))
                    .packInt(jsonArray.getInt(1))
                    .packInt(jsonArray.getInt(2));
            packer.close();
        } catch (IOException e) {
            e.printStackTrace();
            return null;
        } catch (JSONException e) {
            e.printStackTrace();
            return null;
        }

        return out.toByteArray();
    }
}
