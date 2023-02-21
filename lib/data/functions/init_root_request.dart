import 'dart:developer';

import 'package:root_access/root_access.dart';

Future<void> initRootRequest() async {
  String? rootStatus0;
  try {
    bool rootStatus = await RootAccess.requestRootAccess;
    if (rootStatus) {
      rootStatus0 = null;
    } else {
      rootStatus0 = 'granted';
    }

    log('Root Status --- $rootStatus0');
  } catch (e) {}
}
