package com.octo.octo_beat_plugin.plugin.connection

import java.util.ArrayList

interface OctoBeatConnectionCallback {
    fun onFoundOctoBeat(devices: ArrayList<Map<String, String>>)
    fun onConnectedOctoBeat(device: Map<String, String>)
    fun onConnectFailOctoBeat()
}