package com.octo.octo_beat_plugin.core.device.tcp.TCPClientSupportSSL;

public class Config {
    /********* Global information variable **********/
    public static String currentUsername = "";
    public static String userID;
    public static String iceServerAddress;

    public static final int CONNECT_SERVER_SUCCESS = 1;
    public static final int CONNECT_SERVER_FAIL = 2;
    public static final int LOGIN_SUCCESS = 3;
    public static final int LOGIN_USER_ALREADY_LOGIN = 4;
    public static final int LOGIN_WRONG_USERNAME_OR_PASSWORD = 5;
    public static final int ERROR_NO_INTERNET_CONNECTION = 6;
    public static final int ERROR_SERVER_UNREACHABLE = 7;
    public static final int ERROR_SERVER_CERTIFICATE_INCORRECT = 8;

    public static final String TCP_SERVER_ADDRESS = "fiot.vn";
    //public static final String TCP_SERVER_ADDRESS = "216.117.130.23";
    public static final int TCP_SERVER_PORT = 8911;
    //public static final int TCP_SERVER_PORT = 9997;
    public static final int LOGIN_TIMEOUT_MILISECOND = 10000;
    public static final int KEEP_ALIVE_INTERVAL_MILISECOND = 10000;

    public static String errorCodeToString(int error) {
        String errorStr = "";

        switch (error) {
            case ERROR_NO_INTERNET_CONNECTION:
                errorStr = "No Internet Connection";
                break;
            case ERROR_SERVER_CERTIFICATE_INCORRECT:
                errorStr = "Server's SSL certificate was incorrect";
                break;
            case ERROR_SERVER_UNREACHABLE:
                errorStr = "Server was unreachable";
                break;
        }

        return errorStr;
    }
}
