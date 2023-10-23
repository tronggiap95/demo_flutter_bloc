package com.octo.octo_beat_plugin.core.device._enum;

import java.util.HashMap;
import java.util.Map;

public enum NotifyCode {

    // Bluetooth
    BB_NT_ECG_DATA(0xB000),
    BB_NT_DEVICE_STATUS(0xB001),

    // Internet Bridging
    BB_NT_NETSTAT_UPDATE(0xB100),
    BB_NT_TCP_TX_DATA(0xB200),
    BB_NT_TCP_RX_DATA_RDY(0xB201),
    BB_NT_TCP_CONN_LOST(0xB202),
    BB_NT_TCP_TX_SPEED(0xB203),
    BB_NT_TCP_CONN_OPEN_REPORT(0xB204);

    public int value;
    private static Map<Integer, NotifyCode> map;

    NotifyCode(int value) {
        this.value = value;
    }

    private static void initMap() {
        map = new HashMap<>();
        for (NotifyCode cmd : NotifyCode.values()) {
            map.put(cmd.value, cmd);
        }
    }

    public static NotifyCode get(int value) {
        if (map == null) {
            initMap();
        }

        return map.get(value);
    }
}
