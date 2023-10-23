package com.octo.octo_beat_plugin.core.device.command;

import org.json.JSONArray;
import org.msgpack.core.MessagePack;
import org.msgpack.core.MessagePacker;

import java.io.ByteArrayOutputStream;

import static com.octo.octo_beat_plugin.core.device._enum.RequestCode.BB_REQ_TCP_READ_DATA;
import static com.octo.octo_beat_plugin.core.device._enum.ResponseCode.BB_RSP_OK;

/**
 * Created by caoxuanphong on 12/19/17.
 */

public class ReadReceiveDataCmd {
    private static final String TAG = "ReadReceiveDataCmd";

    public static byte[] response(int response, byte[] data) {
        JSONArray jsonArray = new JSONArray();

        jsonArray.put(BB_REQ_TCP_READ_DATA.value);
        jsonArray.put(response);

        if (response == BB_RSP_OK.value) {
            jsonArray.put(data);
        }

        return pack(jsonArray);
    }

    private static byte[] pack(JSONArray jsonArray) {
        ByteArrayOutputStream out = new ByteArrayOutputStream();
        MessagePacker packer = MessagePack.newDefaultPacker(out);
        try {
            packer.packArrayHeader(jsonArray.length())
                    .packInt(jsonArray.getInt(0))
                    .packInt(jsonArray.getInt(1));

            if (jsonArray.length() == 3) {
                packer.packBinaryHeader(((byte[]) jsonArray.get(2)).length);
                packer.writePayload((byte[]) jsonArray.get(2));
            }

            packer.close();
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }

        return out.toByteArray();
    }
}
