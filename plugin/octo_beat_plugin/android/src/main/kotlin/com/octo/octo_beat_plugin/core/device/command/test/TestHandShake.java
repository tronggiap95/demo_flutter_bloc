package com.octo.octo_beat_plugin.core.device.command.test;//package bluetooth.bridge.dxh.com.android.core.device.command.test;
//
//import android.util.Log;
//
//import org.json.JSONArray;
//
//import bluetooth.bridge.dxh.com.android.core.device.command.HandShakeCmd;
//import bluetooth.bridge.dxh.com.android.core.utils.ByteUtils;
//
//import static bluetooth.bridge.dxh.com.android.core.device.command.CommandUtils.BB_RSP_ERR_API_VER;
//import static bluetooth.bridge.dxh.com.android.core.device.command.CommandUtils.BB_RSP_ERR_FULL_DEVICE;
//import static bluetooth.bridge.dxh.com.android.core.device.command.CommandUtils.BB_RSP_ERR_PACKET_VER;
//import static bluetooth.bridge.dxh.com.android.core.device.command.CommandUtils.BB_RSP_ERR_PARAM;
//import static bluetooth.bridge.dxh.com.android.core.device.command.CommandUtils.BB_RSP_OK;
//
///**
// * Created by caoxuanphong on 12/20/17.
// */
//
//public class TestHandShake {
//    private static final String TAG = "TestHandShake";
//
//    public static void resume() {
//        test_pack_01();
//        test_pack_02();
//        test_pack_03();
//        test_pack_04();
//
//        test_response_01();
//        test_response_02();
//        test_response_03();
//        test_response_04();
//        test_response_05();
//        test_response_06();
//    }
//
//    // Invalid input
//    public static void test_pack_01() {
//        byte[] bytes = HandShakeCmd.pack(null);
//
//        assert (bytes == null);
//        Log.d(TAG, "test_pack_02: " + bytes);
//
//        if (bytes != null) {
//            Log.e(TAG, "test_pack_01 error");
//        } else {
//            Log.d(TAG, "test_pack_01: ok");
//        }
//    }
//
//    public static void test_pack_02() {
//        JSONArray jsonArray = new JSONArray();
//        jsonArray.put(0);
//
//        byte[] bytes = HandShakeCmd.pack(jsonArray);
//
//        Log.d(TAG, "test_pack_02: " + bytes);
//
//        if (bytes != null) {
//            Log.e(TAG, "test_pack_02 error");
//        } else {
//            Log.d(TAG, "test_pack_02: ok");
//        }
//    }
//
//    public static void test_pack_03() {
//        JSONArray jsonArray = new JSONArray();
//        jsonArray.put("Hello");
//
//        byte[] bytes = HandShakeCmd.pack(jsonArray);
//
//        Log.d(TAG, "test_pack_03: " + bytes);
//
//        if (bytes != null) {
//            Log.e(TAG, "test_pack_03 error");
//        } else {
//            Log.d(TAG, "test_pack_03: ok");
//        }
//    }
//
//    public static void test_pack_04() {
//        JSONArray jsonArray = new JSONArray();
//        jsonArray.put(1);
//        jsonArray.put(1);
//        jsonArray.put(1);
//
//        byte[] bytes = HandShakeCmd.pack(jsonArray);
//        Log.d(TAG, "test_pack_04: " + ByteUtils.toHexString(bytes));
//
//        if (bytes == null) {
//            Log.e(TAG, "test_pack_04 error");
//        } else {
//            Log.d(TAG, "test_pack_04: ok");
//        }
//    }
//
//
//    // Time = 0
//    public static void test_response_01() {
////        byte[] bytes = HandShakeCmd.response(BB_RSP_OK, 0);
////        Log.d(TAG, "test_response_01: " + ByteUtils.toHexString(bytes));
////
////        byte[] r = new byte[]{(byte) 0x93, (byte) 0xCD, (byte) 0xC0,
////                0x00, (byte) 0xCD, (byte) 0xE0, 0x00, 0x00};
////
////        if (!ByteUtils.compare2Array(bytes, r)) {
////            Log.e(TAG, "test_response_01");
////        } else {
////            Log.d(TAG, "test_response_01: ok");
////        }
//    }
//
//    public static void test_response_02() {
//        byte[] bytes = HandShakeCmd.response(BB_RSP_ERR_PARAM, 0);
//        Log.d(TAG, "test_response_02: " + ByteUtils.toHexString(bytes));
//
//        byte[] r = new byte[]{(byte) 0x93, (byte) 0xCD, (byte) 0xC0,
//                0x00, (byte) 0xCD, (byte) 0xE0, 0x01, 0x00};
//
//        if (!ByteUtils.compare2Array(bytes, r)) {
//            Log.e(TAG, "test_response_02");
//        } else {
//            Log.d(TAG, "test_response_02: ok");
//        }
//    }
//
//    public static void test_response_03() {
//        byte[] bytes = HandShakeCmd.response(BB_RSP_ERR_PACKET_VER, 0);
//        Log.d(TAG, "test_response_03: " + ByteUtils.toHexString(bytes));
//
//        byte[] r = new byte[]{(byte) 0x93, (byte) 0xCD, (byte) 0xC0, 00, (byte) 0xCD, (byte) 0xE0, 0x03, 00};
//
//        if (!ByteUtils.compare2Array(bytes, r)) {
//            Log.e(TAG, "test_response_03");
//        } else {
//            Log.d(TAG, "test_response_03: ok");
//        }
//    }
//
//    public static void test_response_04() {
//        byte[] bytes = HandShakeCmd.response(BB_RSP_ERR_API_VER, 0);
//        Log.d(TAG, "test_response_04: " + ByteUtils.toHexString(bytes));
//
//        byte[] r = new byte[]{(byte) 0x93, (byte) 0xCD, (byte) 0xC0,
//                00, (byte) 0xCD, (byte) 0xE0, 0x04, 00};
//
//        if (!ByteUtils.compare2Array(bytes, r)) {
//            Log.e(TAG, "test_response_04");
//        } else {
//            Log.d(TAG, "test_response_04: ok");
//        }
//    }
//
//    public static void test_response_05() {
//        byte[] bytes = HandShakeCmd.response(BB_RSP_ERR_FULL_DEVICE, 0);
//        Log.d(TAG, "test_response_05: " + ByteUtils.toHexString(bytes));
//
//        byte[] r = new byte[]{(byte) 0x93, (byte) 0xCD, (byte) 0xC0,
//                00, (byte) 0xCD, (byte) 0xE0, 0x05, 00};
//
//        if (!ByteUtils.compare2Array(bytes, r)) {
//            Log.e(TAG, "test_response_05");
//        } else {
//            Log.d(TAG, "test_response_05: ok");
//        }
//    }
//
//    public static void test_response_06() {
//        byte[] bytes = HandShakeCmd.response(0001, 0);
//        Log.d(TAG, "test_response_06: " + ByteUtils.toHexString(bytes));
//
//        byte[] r = new byte[]{(byte) 0x93, (byte) 0xCD, (byte) 0xC0,
//                00, (byte) 0xCD, (byte) 0xE0, 0x05, 00};
//
//        if (bytes != null) {
//            Log.e(TAG, "test_response_06");
//        } else {
//            Log.d(TAG, "test_response_06: ok");
//        }
//    }
//
//}
