import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:flutter_sim_country_code/flutter_sim_country_code.dart';

Future<String?> checkSimCard() async {
  String platformVersion;
  try {
    platformVersion = (await FlutterSimCountryCode.simCountryCode)!;
  } on PlatformException {
    platformVersion = 'Failed';
  }
  if (platformVersion.length == 2) {
    log('Phone with SIM --- platformVersion: $platformVersion');
    return platformVersion;
  } else {
    log('Phone without SIM');
    return null;
  }
}
