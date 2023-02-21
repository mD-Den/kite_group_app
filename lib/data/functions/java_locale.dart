import 'dart:developer';

import 'package:flutter/cupertino.dart';

Future<void> javaLocale(BuildContext context) async {
  log('java.util.Locale() --- ${Localizations.localeOf(context).toString()}');
}
