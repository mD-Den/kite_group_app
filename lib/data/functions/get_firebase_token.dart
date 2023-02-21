import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> getFirebaseToken() async {
  FirebaseMessaging.instance.getToken().then((value) {
    String? token = value;
    log('FirebaseMessaging.getInstance().getToken() --- $token');
  });
}
