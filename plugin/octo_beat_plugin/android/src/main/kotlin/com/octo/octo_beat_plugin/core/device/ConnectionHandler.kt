package com.octo.octo_beat_plugin.core.device

import android.content.Context
import android.util.Log
import com.octo.octo_beat_plugin.core.device.model.DXHDevice
import com.octo.octo_beat_plugin.core.modes.BLEModeManager
import com.octo.octo_beat_plugin.core.utils.FiotBluetoothUtils
import com.lib.terminalio.TIOConnection
import com.lib.terminalio.TIOManager
import com.lib.terminalio.TIOPeripheral
import io.reactivex.Observable
import io.reactivex.disposables.CompositeDisposable
import io.reactivex.disposables.Disposable
import io.reactivex.schedulers.Schedulers
import java.util.concurrent.TimeUnit

class ConnectionHandler(var dxhDevice: DXHDevice?) {
    companion object {
        const val TAG_CONNECTION_HANDLER = "CONNECTION_HANDLER"
    }

    private var dispobag: CompositeDisposable? = null
    private var delayCount: Long = 0
    private var period = 30L
    private var waitTimes: Int = 0

    fun setWaitTimes(waitTimes: Int): ConnectionHandler {
        this.waitTimes = waitTimes
        return this
    }

    fun setDelayCount(delayCount: Long): ConnectionHandler {
        this.delayCount = delayCount
        return this
    }

    fun setPeriod(period: Long): ConnectionHandler {
        this.period = period
        return this
    }


    fun startReconnecting(context: Context, bleModeManager: BLEModeManager) {
        Log.d(
            TAG_CONNECTION_HANDLER,
            "${dxhDevice?.clientId}:START RECONNECT..."
        )
        disposeTask()
        dispobag = CompositeDisposable()
        val disposable = Observable.interval(delayCount, period, TimeUnit.SECONDS)
            .observeOn(Schedulers.io())
            .subscribeOn(Schedulers.io())
            .subscribe({
                if (FiotBluetoothUtils.isBluetoothEnabled(context) && !dxhDevice!!.isBluetoothConnected) {
                    Log.d(
                        TAG_CONNECTION_HANDLER,
                        "${dxhDevice?.clientId}: ${dxhDevice!!.hashCode()} ${this.hashCode()} ${!dxhDevice!!.isBluetoothConnected} TIMES: $it"
                    )
                    val address = dxhDevice?.bluetoothMacAddress
                    val peripheral = TIOManager.getInstance().createPeripheral(address)
                    peripheral?.setShallBeSaved(false)
                    bleModeManager.requestConnectToDevice(peripheral!!)
                }
            }, {
                Log.d(TAG_CONNECTION_HANDLER, "${dxhDevice?.clientId} FAIL TO CONNECT...")
            })
        dispobag?.add(disposable)
    }

    fun disposeTask() {
        dispobag?.dispose()
    }

}