import 'package:shared_preferences/shared_preferences.dart';

class OnboardingPrefs {
  static const _key = 'onboarding_complete';

  Future<bool> isComplete() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(_key) ?? false;
  }

  Future<void> setComplete() async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_key, true);
  }
}
