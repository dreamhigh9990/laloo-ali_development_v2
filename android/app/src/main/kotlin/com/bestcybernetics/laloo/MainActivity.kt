package com.bestcybernetics.laloo

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL_NAME = "viber_launcher_channel"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        flutterEngine?.dartExecutor?.binaryMessenger?.let {
            MethodChannel(it, CHANNEL_NAME)
                .setMethodCallHandler { call, result ->
                    if (call.method == "launchViberChat") {
                        val phoneNumber = call.arguments as String
                        ViberLauncher.launchViberChat(this, phoneNumber)
                    } else {
                        result.notImplemented()
                    }
                }
        }
    }
}
