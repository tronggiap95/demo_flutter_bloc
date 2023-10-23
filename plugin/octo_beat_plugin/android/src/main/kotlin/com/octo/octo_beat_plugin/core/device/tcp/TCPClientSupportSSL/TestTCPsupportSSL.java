package com.octo.octo_beat_plugin.core.device.tcp.TCPClientSupportSSL;

import android.content.Context;
import android.util.Log;

public class TestTCPsupportSSL {
    public static void start(Context context){
        final String DEBUG_TAG = "TestTCPsupportSSL";

        TCPSocketSSLManagerListener myListener = new TCPSocketSSLManagerListener() {
            @Override
            public void onConnectDone(int resultCode, int errorCode) {
                Log.d(DEBUG_TAG,"onConnectDone :: resultCode "+ resultCode + " , errorCode " +errorCode+" : "+ Config.errorCodeToString(errorCode));
            }

            @Override
            public void onLostServerConnection() {
                Log.d(DEBUG_TAG,"onLostServerConnection : ");
            }

            @Override
            public void onDidSocketReceive(String message) {
                Log.d(DEBUG_TAG,"onDidSocketReceive : "+ message);
            }
        };
        SSLTCPSocketClient mySSL = new SSLTCPSocketClient();
//        mySSL.setTCPSocketSSLManagerListener(myListener);
//        mySSL.setupConnection(context);
    }


}
