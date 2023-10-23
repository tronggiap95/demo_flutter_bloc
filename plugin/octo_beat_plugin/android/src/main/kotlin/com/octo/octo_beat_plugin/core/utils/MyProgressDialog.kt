package com.octo.octo_beat_plugin.core.utils

import android.app.ProgressDialog
import android.content.Context
import android.content.DialogInterface
import android.os.Handler
import android.os.Looper
import android.util.Log

class MyProgressDialog {
    companion object {
        private val TAG = "MyProgressDialog"
        private var progressDialog: ProgressDialog? = null

        fun setMessage(message: String) {
            try {
                progressDialog?.setMessage(message)
            } catch (e: Exception) {
                e.printStackTrace()
            }

        }

        fun startProcessing(context: Context, title: String, message: String) {
            progressDialog = ProgressDialog.show(context, title, message, true)
            progressDialog?.setCancelable(true)
        }

        @JvmOverloads
        fun startProcessing(context: Context, message: String = "Processing ...") {
            progressDialog = ProgressDialog.show(context, "", message, true)
        }

        fun startProcessing(context: Context, message: String, listener: DialogInterface.OnCancelListener) {
            Log.i(TAG, "startProcessing: ")
            progressDialog = ProgressDialog.show(context, "", message, true, true, listener)

            Log.i(TAG, "stopProcessing: $progressDialog")
        }

        fun stopProcessing() {
            Log.i(TAG, "stopProcessing: $progressDialog")
            Handler(Looper.getMainLooper()).post {
                try {
                    Log.i(TAG, "run: " + "abc")
                    progressDialog?.dismiss()
                } catch (e: Exception) {
                    e.printStackTrace()
                }
            }
        }
    }
}