import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/country_tax_config.dart';

class CountryConfigNotifier extends StateNotifier<CountryTaxConfig> {
  CountryConfigNotifier({String initialCountry = 'KR'})
      : super(kCountryConfigs[initialCountry] ?? kCountryConfigs['KR']!) {
    _syncWithDb();
  }

  // Sync DB → local only when no local preference saved yet (e.g. fresh install logged in via another device).
  Future<void> _syncWithDb() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString('country_code') != null) return;

    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) return;

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
