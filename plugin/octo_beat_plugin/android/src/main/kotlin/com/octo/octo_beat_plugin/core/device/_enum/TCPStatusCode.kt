package com.octo.octo_beat_plugin.core.device._enum

enum class TCPStatusCode(var value: Int) {
    Command(0x00),
    Response(0x01),
    Notification(0x02),
    ACK(0x03),
    KA_DEV(0x04),
    KA_SER(0x05);

    companion object {
        fun getTCPStatusCode(value: Int): TCPStatusCode? {
            val statusCodes = TCPStatusCode.values()

            for (statusCode in statusCodes) {
                if (value == statusCode.value) {
                    return statusCode
                }
            }

            return null
        }

        fun isValid(status: Int): Boolean {
            val statusCodes = StatusCode.values()

            for (statusCode in statusCodes) {
                if (status == statusCode.value) {
                    return true
                }
            }

            return false
        }
    }

}