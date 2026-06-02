import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/country_tax_config.dart';

class CountryConfigNotifier extends StateNotifier<CountryTaxConfig> {
  CountryConfigNotifier() : super(_detectDefault()) {
    _loadSaved();
  }

  static CountryTaxConfig _detectDefault() {
    final locale = PlatformDispatcher.instance.locale;
    final code = locale.countryCode ?? 'KR';
    return kCountryConfigs[code] ?? kCountryConfigs['KR']!;
  }

  Future<void> _loadSaved() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('country_code');
    if (code != null && kCountryConfigs.containsKey(code)) {
      state = kCountryConfigs[code]!;
    }
  }

  Future<void> setCountry(String countryCode) async {
    final config = kCountryConfigs[countryCode];
    if (config == null) return;
    state = config;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('country_code', countryCode);
  }
}

final countryConfigProvider =
    StateNotifierProvider<CountryConfigNotifier, CountryTaxConfig>(
  (ref) => CountryConfigNotifier(),
);
