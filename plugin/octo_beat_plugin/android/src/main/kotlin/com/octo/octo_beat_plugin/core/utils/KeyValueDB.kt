package com.octo.octo_beat_plugin.core.utils

import android.content.Context
import android.content.SharedPreferences
import com.octo.octo_beat_plugin.repository.enum_.Role

/**
 * Created by haytran on 3/22/18.
 */

object KeyValueDB {
    private const val PREF_NAME = "prefs-v2"
    private const val IS_APP_KILLED = "IS_APP_KILLED"

    private fun getPrefs(context: Context): SharedPreferences {
        return context.getSharedPreferences(PREF_NAME, Context.MODE_PRIVATE)
    }

    fun isAppKilled(context: Context): Boolean {
        return getPrefs(context).getBoolean(IS_APP_KILLED, true)
    }
}
