import 'package:shared_preferences/shared_preferences.dart';

class LocalDataStore {
  static Future<SharedPreferences> get _instance async =>
      _prefsInstance ?? await SharedPreferences.getInstance();
  static SharedPreferences? _prefsInstance;

  static Future<SharedPreferences?> init() async {
    _prefsInstance = await _instance;
    return _prefsInstance;
  }

  final String _kUrl = 'URL';
  final String _kNewRoute = 'NEW_ROUTE';
  final String _kNeedThirdScreen = 'NEED_THIRD_SCREEN';

  void setNeedThirdScreen(bool needThirdScreen) {
    _prefsInstance?.setBool(_kNeedThirdScreen, needThirdScreen);
  }

  bool getNeedThirdScreen() {
    return _prefsInstance?.getBool(_kNeedThirdScreen) ?? true;
  }

  void setNewRoute(String newRoute) {
    _prefsInstance?.setString(_kNewRoute, newRoute);
  }

  String getNewRoute() {
    return _prefsInstance?.getString(_kNewRoute) ?? '';
  }

  void removeNewRoute() {
    _prefsInstance?.remove('NEW_ROUTE');
  }

  void setUrl(String url) {
    _prefsInstance?.setString(_kUrl, url);
  }

  String getUrl() {
    return _prefsInstance?.getString(_kUrl) ?? '';
  }
}
