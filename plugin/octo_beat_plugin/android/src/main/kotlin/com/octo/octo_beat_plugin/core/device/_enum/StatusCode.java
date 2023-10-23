package com.octo.octo_beat_plugin.core.device._enum;

public enum StatusCode {
    Command(0x00),
    Response(0x01),
    NotificationWithoutACK(0x02),
    KeepAlive(0x03),
    NotificationWithACK(0x04),
    ACK(0x05),
    Ignore(0x2b);

    public int value;

    StatusCode(int value) {
        this.value = value;
    }

    public static boolean isValid(int status) {
        StatusCode[] statusCodes = StatusCode.values();

        for (StatusCode statusCode : statusCodes) {
            if (status == statusCode.value) {
                return true;
            }
        }

        return false;
    }

}
