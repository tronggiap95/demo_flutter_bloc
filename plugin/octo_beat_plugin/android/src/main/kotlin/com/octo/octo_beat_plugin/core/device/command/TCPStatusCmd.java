package com.octo.octo_beat_plugin.core.device.command;

import org.json.JSONArray;
import org.json.JSONException;
import org.msgpack.core.MessagePack;
import org.msgpack.core.MessagePacker;

import java.io.ByteArrayOutputStream;
import java.io.IOException;

import static com.octo.octo_beat_plugin.core.device._enum.RequestCode.BB_REQ_TCP_GET_CONN_STATUS;
import static com.octo.octo_beat_plugin.core.device._enum.ResponseCode.BB_RSP_OK;

/**
 * Created by caoxuanphong on 12/19/17.
 */

public class TCPStatusCmd {
    private static final String TAG = "HandShakeCmd";

    public static byte[] response(int response, boolean isConnected, String ip, int port, boolean isSSLEnabled) {
        JSONArray jsonArray = new JSONArray();

        jsonArray.put(BB_REQ_TCP_GET_CONN_STATUS.value);
        jsonArray.put(response);

        if (response == BB_RSP_OK.value) {
            jsonArray.put(isConnected);
            jsonArray.put(ip);
            jsonArray.put(port);
            jsonArray.put(isSSLEnabled);
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

            if (jsonArray.length() == 6) {
                packer.packBoolean(jsonArray.getBoolean(2));
                packer.packString(jsonArray.getString(3));
                packer.packInt(jsonArray.getInt(4));
                packer.packBoolean(jsonArray.getBoolean(5));
            }

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
