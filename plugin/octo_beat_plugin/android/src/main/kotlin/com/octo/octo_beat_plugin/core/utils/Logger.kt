package com.octo.octo_beat_plugin.core.utils

import android.util.Log
import java.io.File
import java.io.FileOutputStream
import java.io.OutputStreamWriter
import java.util.*
object Logger {
    private const val LOG_TAG = "MyRockingApp"

    private var buffer = StringBuffer()
    /** @see [](http://stackoverflow.com/a/8899735)
     */
    private const val ENTRY_MAX_LEN = 4000

    /**
     * @param args If the last argument is an exception than it prints out the stack trace, and there should be no {}
     * or %s placeholder for it.
     */
    fun d(TAG: String?, message: String) {
//        buffer.append(message + "\n \n")
//            try {
//                val myFile = File("/sdcard/mysdfile.txt")
//                myFile.createNewFile()
//                val fOut = FileOutputStream(myFile)
//                val myOutWriter = OutputStreamWriter(fOut)
//                myOutWriter.append(buffer)
//                myOutWriter.close()
//                fOut.close()
//            } catch (e: Exception) {
//                e.printStackTrace()
//            }
    }


    private fun log(priority: Int, ignoreLimit: Boolean, message: String, vararg args: Any) {
        var print: String
        print = if (args != null && args.size > 0 && args[args.size - 1] is Throwable) {
            val truncated = Arrays.copyOf(args, args.size - 1)
            val ex = args[args.size - 1] as Throwable
            """
     ${formatMessage(message, *truncated)}
     ${Log.getStackTraceString(ex)}
     """.trimIndent()
        } else {
            formatMessage(message, *args)
        }
        if (ignoreLimit) {
            while (!print.isEmpty()) {
                val lastNewLine = print.lastIndexOf('\n', ENTRY_MAX_LEN)
                val nextEnd = if (lastNewLine != -1) lastNewLine else Math.min(ENTRY_MAX_LEN, print.length)
                val next = print.substring(0, nextEnd /*exclusive*/)
                Log.println(priority, LOG_TAG, next)
                print = if (lastNewLine != -1) {
                    // Don't print out the \n twice.
                    print.substring(nextEnd + 1)
                } else {
                    print.substring(nextEnd)
                }
            }
        } else {
            Log.println(priority, LOG_TAG, print)
        }
    }

    private fun formatMessage(message: String, vararg args: Any): String {
        val formatted: String
        formatted = try {
            /*
             * {} is used by SLF4J so keep it compatible with that as it's easy to forget to use %s when you are
             * switching back and forth between server and client code.
             */
            String.format(message.replace("\\{\\}".toRegex(), "%s"), *args)
        } catch (ex: Exception) {
            message + Arrays.toString(args)
        }
        return formatted
    }
}