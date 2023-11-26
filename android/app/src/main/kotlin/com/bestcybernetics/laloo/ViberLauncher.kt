package com.bestcybernetics.laloo

import android.content.Context
import android.content.Intent
import android.net.Uri

object ViberLauncher {
    fun launchViberChat(context: Context, phoneNumber: String) {
        val uri = Uri.parse("viber://chat?number=$phoneNumber")
        val intent = Intent(Intent.ACTION_VIEW, uri)
        if (intent.resolveActivity(context.packageManager) != null) {
            println("can launch")
            context.startActivity(intent)
        } else {
            println("cannot launch")
            // Viber not installed on the device
            // You can handle this case if necessary
        }
    }
}
