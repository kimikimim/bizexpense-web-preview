import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
    final localCode = prefs.getString('country_code');
    if (localCode != null && kCountryConfigs.containsKey(localCode)) {
      state = kCountryConfigs[localCode]!;
      return;
    }

    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid != null) {
      final row = await Supabase.instance.client
          .from('profiles')
          .select('country_code')
          .eq('id', uid)
          .maybeSingle();
      final dbCode = row?['country_code'] as String?;
      if (dbCode != null && kCountryConfigs.containsKey(dbCode)) {
        state = kCountryConfigs[dbCode]!;
        await prefs.setString('country_code', dbCode);
      }
    }
  }

  Future<void> setCountry(String countryCode) async {
    final config = kCountryConfigs[countryCode];
    if (config == null) return;
    state = config;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('country_code', countryCode);

    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid != null) {
      await Supabase.instance.client
          .from('profiles')
          .update({'country_code': countryCode})
          .eq('id', uid);
    }
  }
}

final countryConfigProvider =
    StateNotifierProvider<CountryConfigNotifier, CountryTaxConfig>(
  (ref) => CountryConfigNotifier(),
);
