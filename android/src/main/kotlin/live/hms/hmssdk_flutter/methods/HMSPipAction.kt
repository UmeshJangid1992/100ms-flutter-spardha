package live.hms.hmssdk_flutter.methods

import android.app.Activity
import android.app.PictureInPictureParams
import android.content.pm.PackageManager
import android.os.Build
import android.util.Rational
import androidx.annotation.RequiresApi
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import live.hms.hmssdk_flutter.HMSErrorLogger
import live.hms.hmssdk_flutter.HMSErrorLogger.Companion.returnError

class HMSPipAction {

    companion object {
        fun pipActions(call: MethodCall, result: MethodChannel.Result, activity : Activity){
            when(call.method){
                "enter_pip_mode"->{
                    if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
                    enterPipMode(call,result,activity)
                }
                "is_pip_active"->{
                    if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
                    result.success(activity.isInPictureInPictureMode)
                }
                "is_pip_available"->{
                    result.success(
                        activity.packageManager.hasSystemFeature(PackageManager.FEATURE_PICTURE_IN_PICTURE)
                    )
                }
                else -> {
                    result.notImplemented()
                }
            }
        }

        @RequiresApi(Build.VERSION_CODES.O)
        private fun enterPipMode(call: MethodCall, result: MethodChannel.Result,activity:Activity){
            val aspectRatio = call.argument<List<Int>>("aspect_ratio") ?: returnError("enterPipMode error aspectRatio is null")
            val autoEnterEnabled = call.argument<Boolean>("auto_enter_pip") ?: returnError("enterPipMode error autoEnterEnabled is null")

            if(aspectRatio != null && autoEnterEnabled != null){
                var params = PictureInPictureParams.Builder().setAspectRatio(Rational((aspectRatio as List<Int>)[0],aspectRatio[1]))

                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                    params = params.setAutoEnterEnabled(autoEnterEnabled as Boolean)
                }

                result.success(
                    activity.enterPictureInPictureMode(params.build())
                )
            }
        }

    }
}