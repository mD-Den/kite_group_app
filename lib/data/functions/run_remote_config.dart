import 'dart:developer';

import 'package:firebase_remote_config/firebase_remote_config.dart';

Future<void> runRemoteConfig() async {
  final remoteConfig = FirebaseRemoteConfig.instance;
  await remoteConfig.setConfigSettings(RemoteConfigSettings(
    fetchTimeout: const Duration(minutes: 1),
    minimumFetchInterval: const Duration(hours: 1),
  ));

  await remoteConfig.fetchAndActivate();

  String color = remoteConfig.getString('color');

  bool needThirdScreen = remoteConfig.getBool('third_screen');

  log('Remote config --- color: $color');
  log('Remote config --- needThirdScreen: $needThirdScreen');
}
