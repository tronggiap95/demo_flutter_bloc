package com.octo.octo_beat_plugin.core.device._enum;

import java.util.HashMap;
import java.util.Map;

public enum ResponseCode {
    //Common
    BB_RSP_OK(0xe000),
    BB_RSP_ERR_PARAM(0xe001),
    BB_RSP_ERR_PERMISSION(0xe002),
    BB_RSP_ERR_OPERATION(0xe003),

    // Request specific
    BB_RSP_ERR_PACKET_VER(0xe050),
    BB_RSP_ERR_API_VER(0xe051),
    BB_RSP_ERR_FULL_DEVICE(0xe052),
    BB_RSP_ERR_NO_NETWORK(0xe053),
    BB_RSP_ERR_NOT_PAIRED(0xe054),
    BB_RSP_ERR_BT_CLASSIC_DENIED(0xe055),
    BB_RSP_ERR_CONN_TIMEOUT(0xe100),
    BB_RSP_ERR_CONN_CLOSED(0xe101),
    BB_RSP_ERR_CONN_OPENED(0xe102);

    public int value;
    private static Map<Integer, ResponseCode> map;

    ResponseCode(int value) {
        this.value = value;
    }

    private static void initMap() {
        map = new HashMap<>();
        for (ResponseCode cmd : ResponseCode.values()) {
            map.put(cmd.value, cmd);
        }
    }

    public static ResponseCode get(int value) {
        if (map == null) {
            initMap();
        }

        return map.get(value);
    }
}
