import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:flutter/services.dart';

class Utilities {
  static Future<List<String>> getDeviceDetails() async {
    String deviceName;
    String deviceVersion;
    String identifier;
    final DeviceInfoPlugin deviceInfoPlugin = new DeviceInfoPlugin();
    try {
      if (Platform.isAndroid) {
        var build = await deviceInfoPlugin.androidInfo;
        deviceName = build.model;
        deviceVersion = build.version.sdkInt.toString();
        identifier = build.androidId; //UUID for Android
      } else if (Platform.isIOS) {
        var data = await deviceInfoPlugin.iosInfo;
        deviceName = data.name;
        deviceVersion = data.systemVersion;
        identifier = data.identifierForVendor; //UUID for iOS
      }
    } on PlatformException {
      print('Failed to get platform version');
    }
    print("deviceName:" + deviceName);
    print("deviceVersion:" + deviceVersion);
    print("identifier:" + identifier);
//if (!mounted) return;
    return [deviceName, deviceVersion, identifier];
  }
}
