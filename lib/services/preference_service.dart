import 'package:shared_preferences/shared_preferences.dart';

class PreferenceService {
  SharedPreferences? _prefs;

  Future<void> initialize() async =>
      _prefs = await SharedPreferences.getInstance();

  bool get skipIntroduction => _prefs!.getBool('skipIntroduction') ?? false;

  set skipIntroduction(bool value) => _prefs!.setBool('skipIntroduction', value);
}
