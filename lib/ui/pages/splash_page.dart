import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:advertising_id/advertising_id.dart';
import 'package:appmetrica_plugin/appmetrica_plugin.dart';
import 'package:battery_info/battery_info_plugin.dart';
import 'package:carrier_info_v3/carrier_info.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sim_country_code/flutter_sim_country_code.dart';
import 'package:kite_group_app/config/constants.dart';
import 'package:kite_group_app/data/local_data_store/local_data_store.dart';
import 'package:kite_group_app/ui/pages/pages.dart';
import 'package:kite_group_app/ui/widgets/custom_loader.dart';
import 'package:root_access/root_access.dart';

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

  final LocalDataStore _store = LocalDataStore();

  String? _advertisingId = '';
  bool? _isLimitAdTrackingEnabled;

  String? _rootStatus;

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
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      log('$e');
      return;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          margin: EdgeInsets.only(
              bottom: MediaQuery.of(context).size.height - 100,
              right: 20,
              left: 20),
          duration: const Duration(
            seconds: 5,
          ),
          content: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                15,
              ),
            ),
            child: const Padding(
              padding: EdgeInsets.all(0.0),
              child: Center(
                child: Text(
                  'Нет интернет сединения',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ),
            ),
          )));
    } else {
      await initRootRequest();
      await checkSimCard();
      await getLinkFromRemoteConfig();

      await _javaLocale();
      log('AppMetrikaAPIKey --- $apiKeyAppMetrica');
      await initPlatformState();
      await _getAndroidId();
      await _getFirebaseToken();
      String? mobileCountryCode = await CarrierInfo.mobileCountryCode;
      String? mobileNetworkCode = await CarrierInfo.mobileNetworkCode;
      log('mobileCountryCode --- $mobileCountryCode');
      log('mobileNetworkCode --- $mobileNetworkCode');
      log("Battery Health: ${(await BatteryInfoPlugin().androidBatteryInfo)?.batteryLevel}");
      if (_store.getNewRoute() != '') {
        _store.setNewRoute('');
        _store.setUrl(website_0);
        AppMetrica.reportEventWithJson('Route', "{\"route\":\"web_view\"}");
        Navigator.of(context).pushNamed(WebViewPage.id);
      } else {
        AppMetrica.reportEventWithJson('Route', "{\"route\":\"products\"}");
        await Navigator.of(context).pushNamed(ProductsPage.id);
      }
    }
  }

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

  Future<void> getLinkFromRemoteConfig() async {
    final remoteConfig = FirebaseRemoteConfig.instance;
    await remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(minutes: 1),
      minimumFetchInterval: const Duration(hours: 1),
    ));

    await remoteConfig.fetchAndActivate();

    String color = remoteConfig.getString('color');

    log('Remote config --- color: $color');
  }

  Future<void> initRootRequest() async {
    try {
      bool rootStatus = await RootAccess.requestRootAccess;
      if (rootStatus) {
        setState(() {
          _rootStatus = null;
        });
      } else {
        setState(() {
          _rootStatus = 'granted';
        });
      }

      log('Root Status --- $_rootStatus');
    } catch (e) {}
  }

  Future<void> _javaLocale() async {
    log('java.util.Locale() --- ${Localizations.localeOf(context).toString()}');
  }

  Future<void> _getFirebaseToken() async {
    FirebaseMessaging.instance.getToken().then((value) {
      String? token = value;
      log('FirebaseMessaging.getInstance().getToken() --- $token');
    });
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

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _advertisingId = advertisingId;
      _isLimitAdTrackingEnabled = isLimitAdTrackingEnabled;
    });

    log('GAID --- $_advertisingId');
  }

  Future<String?> _getAndroidId() async {
    var deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) {
      // import 'dart:io'
      var iosDeviceInfo = await deviceInfo.iosInfo;
      return iosDeviceInfo.identifierForVendor; // unique ID on iOS
    } else if (Platform.isAndroid) {
      var androidDeviceInfo = await deviceInfo.androidInfo;
      log('AndroidID --- ${androidDeviceInfo.id}');
      return androidDeviceInfo.id; // unique ID on Android
    } else {
      return null;
    }
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
