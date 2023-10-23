package com.octo.octo_beat_plugin.core.device._enum;

import java.util.HashMap;
import java.util.Map;

public enum RequestCode {
    INVALID_CMD(0xcccc),

    // REQUEST CODE
    // Common
    BB_REQ_HANDSHAKE(0xC000),
    BB_REQ_SWITCH_BT_MODE(0xC001),

    // Bluetooth
    BB_REQ_START_STREAMING_ECG(0xC011),
    BB_REQ_STOP_STREAMING_ECG(0xC012),
    BB_REQ_SM_COMMAND(0xC013),
    BB_REQ_EVENT_TRIGGERED(0xC014),
    BB_REQ_EVENT_CONFIRMED(0xC015),
    BB_REQ_GET_TIME(0xC004),

    // Internet Bridging
    BB_REQ_GET_NETSTAT(0xC100),
    BB_REQ_TCP_OPEN_CONN(0xC200),
    BB_REQ_TCP_CLOSE_CONN(0xC201),
    BB_REQ_TCP_GET_CONN_STATUS(0xC202),
    BB_REQ_TCP_READ_DATA(0xC203),
    BB_REQ_SSL_SET_CA_CERT(0xC300),
    BB_REQ_SSL_SET_DEVICE_CERT(0xC301),
    BB_REQ_SSL_SET_DEVICE_PKEY(0xC302),
    BB_REQ_SSL_CONN_CONFIG(0xC303),

    // old protocol
    BB_CMD_ECG_PARAM_CONFIG(0xc002);



    public int value;
    private static Map<Integer, RequestCode> map;

    RequestCode(int value) {
        this.value = value;
    }

    private static void initMap() {
        map = new HashMap<>();
        for (RequestCode cmd : RequestCode.values()) {
            map.put(cmd.value, cmd);
        }
    }

    public static RequestCode get(int value) {
        if (map == null) {
            initMap();
        }

        return map.get(value);
    }
}
