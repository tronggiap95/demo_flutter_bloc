package com.octo.octo_beat_plugin.core.device.handler;


import android.util.Log;


import org.json.JSONArray;
import org.json.JSONException;


import com.octo.octo_beat_plugin.core.device.DeviceHandlerCallback;
import com.octo.octo_beat_plugin.core.device._enum.ResponseCode;
import com.octo.octo_beat_plugin.core.device.command.CommandUtils;
import com.octo.octo_beat_plugin.core.device.command.HandShakeCmd;
import com.octo.octo_beat_plugin.core.device.model.DXHDevice;
import com.octo.octo_beat_plugin.core.utils.DateTimeUtils;

/**
 * Created by caoxuanphong on 12/20/17.
 */

public class HandShakeHandler {
    private static final String TAG = "HandShakeHandler";
    private HandlerSuccessListener handlerSuccessListener;

    private static boolean parse(JSONArray messagePack) {
        try {
            int packetVersion = messagePack.getInt(1);
            int apiVersion = messagePack.getInt(2);
            String deviceId = messagePack.getString(3);

            Log.d(TAG, "packetVersion: " + packetVersion +
                    ", apiVersion: " + apiVersion +
                    ", deviceId: " + deviceId);

            return true;
        } catch (Exception e) {
            e.printStackTrace();

            return false;
        }
    }

    private void getNtpTime(final DXHDevice dxhDevice, JSONArray messagePack, DeviceHandlerCallback deviceHandlerCallback) {
        DateTimeUtils.getTrueTimeUTCInSecond(time -> {
            if (dxhDevice != null) {
                long localTime = time + DateTimeUtils.getOffsetFromUtc();
                responseOk(dxhDevice, localTime, messagePack, deviceHandlerCallback);
            } else {
                Log.w(TAG, "response time, device is not connected anymore");
            }
        });
    }

    private int getPhoneTimeZoneInMinute() {
        int timezone = DateTimeUtils.getTimezone();
        return timezone * 60;
    }


    public void responseOk(DXHDevice dxhDevice, long time, JSONArray messagePack, DeviceHandlerCallback deviceHandlerCallback) {
        if (deviceHandlerCallback != null) {
            try {
                String clientId = messagePack.getString(3);
                int apiVersion = messagePack.getInt(2);
                dxhDevice.setClientId(clientId);
                dxhDevice.setApiVersion(apiVersion);
                handlerSuccessListener.didHandShakeSuccess();
                dxhDevice.setHandShaked(true);
                if (dxhDevice.getHandShaked()) {
                    deviceHandlerCallback.newConnection(dxhDevice);
                }
                Log.d(TAG, "SUCCESS: BB_CMD_HANDSHAKE");
            } catch (JSONException e) {
                byte[] data = HandShakeCmd.response(ResponseCode.BB_RSP_ERR_PARAM.value, time, getPhoneTimeZoneInMinute());
                byte[] encryptedPacket = CommandUtils.packPacketResponse(data, dxhDevice);
                if(encryptedPacket != null) {
                    dxhDevice.send(encryptedPacket);
                }
                e.printStackTrace();
            }

        }
        byte[] data = HandShakeCmd.response(ResponseCode.BB_RSP_OK.value, time, getPhoneTimeZoneInMinute());
        byte[] encryptedPacket = CommandUtils.packPacketResponse(data, dxhDevice);
        if(encryptedPacket != null) {
            dxhDevice.send(encryptedPacket);
        }
        Log.d(TAG, "handle: BB_RSP_OK");
    }

    public void responseFail(DXHDevice dxhDevice) {
        byte[] data = HandShakeCmd.response(ResponseCode.BB_RSP_ERR_PARAM.value, DateTimeUtils.currentTimeToEpoch(), getPhoneTimeZoneInMinute());
        byte[] encryptedPacket = CommandUtils.packPacketResponse(data, dxhDevice);
        if(encryptedPacket != null) {
            dxhDevice.send(encryptedPacket);
        }
        Log.d(TAG, "handle: BB_RSP_ERR_PARAM");
    }


    public void handle(final DXHDevice dxhDevice,
                       final JSONArray messagePack,
                       DeviceHandlerCallback deviceHandlerCallback,
                       HandlerSuccessListener listener) {
        if (dxhDevice == null || !dxhDevice.isBluetoothConnected()) {
            Log.e(TAG, "handle: null");
            return;
        }

        this.handlerSuccessListener = listener;
        if (!parse(messagePack)) {
            responseFail(dxhDevice);
        }

        getNtpTime(dxhDevice, messagePack, deviceHandlerCallback);
    }

}
