package com.octo.octo_beat_plugin.core.utils;

import android.util.Log;

import org.json.JSONArray;
import org.json.JSONException;
import org.msgpack.core.MessagePack;
import org.msgpack.core.MessageUnpacker;
import org.msgpack.value.Value;

import java.io.IOException;

/**
 * Created by caoxuanphong on 12/19/17.
 */

public class MessagePackHelper {
    private static final String TAG = "MessagePackHelper";

    public static JSONArray unpack(byte[] data) {
        MessageUnpacker unPacker = MessagePack.newDefaultUnpacker(data);

        try {
            while (unPacker.hasNext()) {
                Value v = null;
                try {
                    v = unPacker.unpackValue();
                } catch (Exception e) {
                    e.printStackTrace();
                    return null;
                }

                return new JSONArray(v.toJson());
            }
        } catch (IOException e) {
            e.printStackTrace();
        } catch (JSONException e) {
            e.printStackTrace();
        }

        return null;
    }

    public static Value unpackRaw(byte[] data) {
        MessageUnpacker unPacker = MessagePack.newDefaultUnpacker(data);

        try {
            while (unPacker.hasNext()) {
                Value v = unPacker.unpackValue();
                return v;
            }
        } catch (IOException e) {
            e.printStackTrace();
        }

        return null;
    }

}
