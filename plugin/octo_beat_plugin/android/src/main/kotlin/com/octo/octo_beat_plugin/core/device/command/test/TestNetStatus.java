package com.octo.octo_beat_plugin.core.device.command.test;

import android.util.Log;

import org.json.JSONArray;

import com.octo.octo_beat_plugin.core.device.command.NetStatusCmd;
import com.octo.octo_beat_plugin.core.utils.ByteUtils;

import static com.octo.octo_beat_plugin.core.device._enum.ResponseCode.BB_RSP_ERR_PARAM;
import static com.octo.octo_beat_plugin.core.device._enum.ResponseCode.BB_RSP_ERR_PERMISSION;
import static com.octo.octo_beat_plugin.core.device._enum.ResponseCode.BB_RSP_OK;

/**
 * Created by caoxuanphong on 12/20/17.
 */

public class TestNetStatus {
    private static final String TAG = "TestNetStatus";

    public static void start() {
        test_pack_01();
        test_pack_02();
        test_pack_03();
        test_pack_04();

        test_response_01();
        test_response_02();
        test_response_03();
        test_response_04();
        test_response_05();
        test_response_06();
        test_response_07();
    }

    // Invalid input
    public static void test_pack_01() {
        byte[] bytes = NetStatusCmd.pack(null);

        assert (bytes == null);
        Log.d(TAG, "test_pack_01: " + bytes);

        if (bytes != null) {
            Log.e(TAG, "test_pack_01 error");
        } else {
            Log.d(TAG, "test_pack_01: ok");
        }
    }

    public static void test_pack_02() {
        JSONArray jsonArray = new JSONArray();
        jsonArray.put(0);

        byte[] bytes = NetStatusCmd.pack(jsonArray);

        Log.d(TAG, "test_pack_02: " + bytes);

        if (bytes != null) {
            Log.e(TAG, "test_pack_02 error");
        } else {
            Log.d(TAG, "test_pack_02: ok");
        }
    }

    public static void test_pack_03() {
        JSONArray jsonArray = new JSONArray();
        jsonArray.put("Hello");

        byte[] bytes = NetStatusCmd.pack(jsonArray);

        Log.d(TAG, "test_pack_03: " + bytes);

        if (bytes != null) {
            Log.e(TAG, "test_pack_03 error");
        } else {
            Log.d(TAG, "test_pack_03: ok");
        }
    }

    public static void test_pack_04() {
        JSONArray jsonArray = new JSONArray();
        jsonArray.put(1);
        jsonArray.put(1);
        jsonArray.put(true);

        byte[] bytes = NetStatusCmd.pack(jsonArray);
        Log.d(TAG, "test_pack_04: " + ByteUtils.toHexString(bytes));

        if (bytes == null) {
            Log.e(TAG, "test_pack_04 error");
        } else {
            Log.d(TAG, "test_pack_04: ok");
        }
    }

    // Time = 0
    public static void test_response_01() {
        byte[] bytes = NetStatusCmd.response(BB_RSP_OK.value, true);
        Log.d(TAG, "test_response_01: " + ByteUtils.toHexString(bytes));

        byte[] r = new byte[]{(byte) 0x93, (byte) 0xCD, (byte) 0xC0, 0x01,
                (byte) 0xCD, (byte) 0xE0, 00, (byte) 0xC3};

        if (!ByteUtils.compare2Array(bytes, r)) {
            Log.e(TAG, "test_response_01");
        } else {
            Log.d(TAG, "test_response_01: ok");
        }
    }

    public static void test_response_02() {
        byte[] bytes = NetStatusCmd.response(BB_RSP_OK.value, false);
        Log.d(TAG, "test_response_02: " + ByteUtils.toHexString(bytes));

        byte[] r = new byte[]{(byte) 0x93, (byte) 0xCD, (byte) 0xC0, 0x01,
                (byte) 0xCD, (byte) 0xE0, 00, (byte) 0xC2};

        if (!ByteUtils.compare2Array(bytes, r)) {
            Log.e(TAG, "test_response_02");
        } else {
            Log.d(TAG, "test_response_02: ok");
        }
    }

    public static void test_response_03() {
        byte[] bytes = NetStatusCmd.response(BB_RSP_ERR_PARAM.value, true);
        Log.d(TAG, "test_response_03: " + ByteUtils.toHexString(bytes));

        byte[] r = new byte[]{(byte) 0x92, (byte) 0xCD, (byte) 0xC0, 01, (byte) 0xCD, (byte) 0xE0, 01};

        if (!ByteUtils.compare2Array(bytes, r)) {
            Log.e(TAG, "test_response_03");
        } else {
            Log.d(TAG, "test_response_03: ok");
        }
    }

    public static void test_response_04() {
        byte[] bytes = NetStatusCmd.response(BB_RSP_ERR_PARAM.value, false);
        Log.d(TAG, "test_response_04: " + ByteUtils.toHexString(bytes));

        byte[] r = new byte[]{(byte) 0x92, (byte) 0xCD, (byte) 0xC0, 01, (byte) 0xCD, (byte) 0xE0, 01};

        if (!ByteUtils.compare2Array(bytes, r)) {
            Log.e(TAG, "test_response_04");
        } else {
            Log.d(TAG, "test_response_04: ok");
        }
    }

    public static void test_response_05() {
        byte[] bytes = NetStatusCmd.response(BB_RSP_ERR_PERMISSION.value, true);
        Log.d(TAG, "test_response_05: " + ByteUtils.toHexString(bytes));

        byte[] r = new byte[]{(byte) 0x92, (byte) 0xCD, (byte) 0xC0, 0x01, (byte) 0xCD, (byte) 0xE0, 0x02};

        if (!ByteUtils.compare2Array(bytes, r)) {
            Log.e(TAG, "test_response_05");
        } else {
            Log.d(TAG, "test_response_05: ok");
        }
    }

    public static void test_response_06() {
        byte[] bytes = NetStatusCmd.response(BB_RSP_ERR_PERMISSION.value, false);
        Log.d(TAG, "test_response_06: " + ByteUtils.toHexString(bytes));

        byte[] r = new byte[]{(byte) 0x92, (byte) 0xCD, (byte) 0xC0, 0x01, (byte) 0xCD, (byte) 0xE0, 0x02};

        if (!ByteUtils.compare2Array(bytes, r)) {
            Log.e(TAG, "test_response_06");
        } else {
            Log.d(TAG, "test_response_06: ok");
        }
    }

    public static void test_response_07() {
        byte[] bytes = NetStatusCmd.response(001, false);
        Log.d(TAG, "test_response_07: " + ByteUtils.toHexString(bytes));

        byte[] r = new byte[]{(byte) 0x92, (byte) 0xCD, (byte) 0xC0, 0x01, (byte) 0xCD, (byte) 0xE0, 0x02};

        if (bytes != null) {
            Log.e(TAG, "test_response_07");
        } else {
            Log.d(TAG, "test_response_07: ok");
        }
    }

}
