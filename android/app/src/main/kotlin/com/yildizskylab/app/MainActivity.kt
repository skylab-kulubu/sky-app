package com.yildizskylab.app

import io.flutter.embedding.android.FlutterActivity
import android.content.Intent
import android.os.Bundle

class MainActivity : FlutterActivity() {
    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
    }
}