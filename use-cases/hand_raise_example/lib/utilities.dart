import 'dart:io';

import 'package:hmssdk_flutter/hmssdk_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

class Utilities {
  static Future<bool> getPermissions() async {
    if (Platform.isIOS) return true;
    await Permission.camera.request();
    await Permission.microphone.request();
    await Permission.bluetoothConnect.request();

    while ((await Permission.camera.isDenied)) {
      await Permission.camera.request();
    }
    while ((await Permission.microphone.isDenied)) {
      await Permission.microphone.request();
    }
    while ((await Permission.bluetoothConnect.isDenied)) {
      await Permission.bluetoothConnect.request();
    }
    return true;
  }

  static HMSConfig getHMSConfig() {
    //Temporary authToken can be found on dashboard.
    //To know how to get temporary token, check here: https://www.100ms.live/docs/flutter/v2/guides/token
    String authToken =
        "Enter your token here";
    return HMSConfig(authToken: authToken, userName: "test_username");
  }
}