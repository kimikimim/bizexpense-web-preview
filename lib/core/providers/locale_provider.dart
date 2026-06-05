import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// User-selected UI language, independent of the account's country/region.
///
/// `null` means "follow the region's default language" (countryConfig.languageCode).
/// A Korean owner operating in the UAE can therefore keep Korean UI while their
/// account lives in the Middle East project.
class LocaleNotifier extends StateNotifier<String?> {
  LocaleNotifier({String? initial}) : super(initial);

  static const supported = ['ko', 'en', 'ar'];

  Future<void> setLanguage(String? code) async {
    state = code;
    final prefs = await SharedPreferences.getInstance();
    if (code == null) {
      await prefs.remove('app_language');
    } else {
      await prefs.setString('app_language', code);
    }
  }
}

final localeProvider =
    StateNotifierProvider<LocaleNotifier, String?>((ref) => LocaleNotifier());
