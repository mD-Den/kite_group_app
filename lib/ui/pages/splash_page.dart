import 'dart:async';
import 'dart:developer';

import 'package:advertising_id/advertising_id.dart';
import 'package:appmetrica_plugin/appmetrica_plugin.dart';
import 'package:battery_info/battery_info_plugin.dart';
import 'package:carrier_info_v3/carrier_info.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kite_group_app/ui/pages/pages.dart';
import 'package:kite_group_app/ui/widgets/custom_loader.dart';

import '../../config/constants.dart';
import '../../data/functions/functions.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  static const String id = '/';

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  String? _advertisingId = '';
  bool? _isLimitAdTrackingEnabled;

  StreamSubscription? _streamSubscription;

  @override
  void initState() {
    initConnectivity();

    AppMetrica.reportEvent('My first AppMetrica event!');

    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);

    super.initState();
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    _streamSubscription?.cancel();
    super.dispose();
  }

  Future<void> initConnectivity() async {
    late ConnectivityResult result;
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      log('$e');
      return;
    }
    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    setState(() {
      _connectionStatus = result;
    });
    if (_connectionStatus == ConnectivityResult.none) {
      showMySnackBar(context);
    } else {
      await initRootRequest();
      await checkSimCard();
      await runRemoteConfig();

      await javaLocale(context);
      log('AppMetrikaAPIKey --- $apiKeyAppMetrica');
      await initPlatformState();
      await getAndroidId();
      await getFirebaseToken();
      String? mobileCountryCode = await CarrierInfo.mobileCountryCode;
      String? mobileNetworkCode = await CarrierInfo.mobileNetworkCode;
      log('mobileCountryCode --- $mobileCountryCode');
      log('mobileNetworkCode --- $mobileNetworkCode');
      log("Battery Health --- ${(await BatteryInfoPlugin().androidBatteryInfo)?.batteryLevel}");
      AppMetrica.reportEventWithJson('Route', "{\"route\":\"products\"}");
      await Navigator.of(context).pushNamed(ProductsPage.id);
    }
  }

  initPlatformState() async {
    String? advertisingId;
    bool? isLimitAdTrackingEnabled;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      advertisingId = await AdvertisingId.id(true);
    } on PlatformException {
      advertisingId = 'Failed to get platform version.';
    }

    try {
      isLimitAdTrackingEnabled = await AdvertisingId.isLimitAdTrackingEnabled;
    } on PlatformException {
      isLimitAdTrackingEnabled = false;
    }
    if (!mounted) return;

    setState(() {
      _advertisingId = advertisingId;
      _isLimitAdTrackingEnabled = isLimitAdTrackingEnabled;
    });

    log('GAID --- $_advertisingId');
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.cyanAccent,
      body: Center(
        child: CustomLoader(
          color: Colors.purple,
        ),
      ),
    );
  }
}
