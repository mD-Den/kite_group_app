import 'dart:developer';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';

Future<String?> getAndroidId() async {
  var deviceInfo = DeviceInfoPlugin();
  if (Platform.isIOS) {
    var iosDeviceInfo = await deviceInfo.iosInfo;
    return iosDeviceInfo.identifierForVendor;
  } else if (Platform.isAndroid) {
    var androidDeviceInfo = await deviceInfo.androidInfo;
    log('AndroidID --- ${androidDeviceInfo.id}');
    return androidDeviceInfo.id;
  } else {
    return null;
  }
}
