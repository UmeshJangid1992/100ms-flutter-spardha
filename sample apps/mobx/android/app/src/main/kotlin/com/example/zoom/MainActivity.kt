package com.example.mobx

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import live.hms.hmssdk_flutter.Constants

class MainActivity : FlutterActivity() {
    override fun onActivityResult(
        requestCode: Int,
        resultCode: Int,
        data: Intent?,
    ) {
        super.onActivityResult(requestCode, resultCode, data)

        data?.action = Constants.HMSSDK_RECEIVER
        activity.sendBroadcast(data?.putExtra(Constants.METHOD_CALL, Constants.SCREEN_SHARE_REQUEST))
    }
}
