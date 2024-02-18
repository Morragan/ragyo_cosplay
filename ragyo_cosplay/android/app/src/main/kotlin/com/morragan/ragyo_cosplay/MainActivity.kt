package com.morragan.ragyo_cosplay

import android.annotation.SuppressLint
import android.bluetooth.BluetoothManager
import android.content.Context
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
//    private val CHANNEL = "bluetooth-set-device-name"
//
//    @SuppressLint("MissingPermission")
//    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
//        super.configureFlutterEngine(flutterEngine)
//        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
//            if (call.method == "setBTDeviceName") {
//                try {
//                    val manager = context.getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager
//                    Settings.System.putString(contentResolver, Settings.System.DEVICE_NAME)
//                    manager.adapter.setName(call.argument("name"))
//                    result.success(true)
//                } catch(error: Error) {
//                    result.success(false)
//                }
//            } else {
//                result.notImplemented()
//            }
//        }
//    }
}
