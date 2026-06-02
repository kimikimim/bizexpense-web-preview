import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../features/user/presentation/user_type_page.dart';
import '../features/auth/presentation/login_page.dart';
import '../features/onboarding/presentation/country_select_page.dart';

import '../core/providers/theme_provider.dart';
import '../core/providers/font_size_provider.dart';
import '../core/providers/country_config_provider.dart';
import '../core/config/country_tax_config.dart';

import '../features/shell/main_shell_page.dart';
import '../features/cards/services/native_channel_service.dart';
import '../core/theme/app_typography.dart';
import 'package:expense_pro/l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();

  await dotenv.load(fileName: ".env");

  final prefs = await SharedPreferences.getInstance();
  final savedCountry = prefs.getString('country_code') ?? 'KR';
  final isME = savedCountry != 'KR';

  await Supabase.initialize(
    url: isME
        ? dotenv.env['SUPABASE_ME_URL']!
        : dotenv.env['SUPABASE_KR_URL']!,
    anonKey: isME
        ? dotenv.env['SUPABASE_ME_ANON_KEY']!
        : dotenv.env['SUPABASE_KR_ANON_KEY']!,
  );

  NativeChannelService().init();

  if (prefs.getBool('isDark') == null) {
    await prefs.setBool('isDark', false);
  }

  final userType = prefs.getString('user_type');
  final session = Supabase.instance.client.auth.currentSession;

  Widget startPage;
  if (!kCountryConfigs.containsKey(savedCountry) || prefs.getString('country_code') == null) {
    startPage = const CountrySelectPage();
  } else if (session == null) {
    startPage = const LoginPage();
  } else if (userType == null) {
    startPage = const UserTypePage();
  } else {
    startPage = const MainShellPage();
  }

  runApp(
    ProviderScope(
      child: MyApp(startPage: startPage),
    ),
  );
}

class MyApp extends ConsumerWidget {
  final Widget startPage;

  const MyApp({super.key, required this.startPage});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final fontSizeLevel = ref.watch(fontSizeProvider);
    final double textScale = getFontScale(fontSizeLevel);
    final countryConfig = ref.watch(countryConfigProvider);
    final locale = Locale(countryConfig.languageCode);

    return MaterialApp(
      title: 'BizExpense',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        useMaterial3: true,
        brightness: Brightness.light,
        fontFamily: 'NanumGothic',
        textTheme: buildAppTextTheme(isDark: false),
        scaffoldBackgroundColor: Colors.grey[100],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          titleTextStyle: TextStyle(
            fontFamily: 'NanumGothic',
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.blueGrey,
        useMaterial3: true,
        brightness: Brightness.dark,
        fontFamily: 'NanumGothic',
        textTheme: buildAppTextTheme(isDark: true),
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E),
          foregroundColor: Colors.white,
          elevation: 0,
          titleTextStyle: TextStyle(
            fontFamily: 'NanumGothic',
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        cardColor: const Color(0xFF1E1E1E),
        dialogBackgroundColor: const Color(0xFF1E1E1E),
      ),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(textScale),
          ),
          child: child!,
        );
      },
      home: startPage,
    );
  }
}
