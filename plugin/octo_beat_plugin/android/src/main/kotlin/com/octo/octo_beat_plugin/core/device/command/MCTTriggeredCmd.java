package com.octo.octo_beat_plugin.core.device.command;

import org.json.JSONArray;
import org.msgpack.core.MessagePack;
import org.msgpack.core.MessagePacker;

import java.io.ByteArrayOutputStream;

import static com.octo.octo_beat_plugin.core.device._enum.RequestCode.BB_REQ_EVENT_TRIGGERED;

/**
 * Created by caoxuanphong on 12/19/17.
 */

public class MCTTriggeredCmd {
    private static final String TAG = "MCTTriggeredCmd";

    public static byte[] response(int response) {
//        HashMap<>
        JSONArray jsonArray = new JSONArray();

        jsonArray.put(BB_REQ_EVENT_TRIGGERED.value);
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
