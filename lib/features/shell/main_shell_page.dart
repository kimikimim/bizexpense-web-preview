
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_pro/l10n/app_localizations.dart';

import '../../core/providers/country_config_provider.dart';
import '../home/presentation/home_page.dart';
import '../statistics/presentation/statistics_page.dart';
import '../tax/presentation/tax_summary_page.dart';

import 'all_menu_page.dart';

class MainShellPage extends ConsumerStatefulWidget {
  const MainShellPage({super.key});

  @override
  ConsumerState<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends ConsumerState<MainShellPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Tax screens are Korea-specific (VAT/income-tax logic); hide for ME.
    final isKorea = ref.watch(countryConfigProvider).countryCode == 'KR';

    final pages = <Widget>[
      const HomePage(),
      const StatisticsPage(),
      if (isKorea) const TaxSummaryPage(),
      AllMenuPage(),
    ];

    final destinations = <NavigationDestination>[
      NavigationDestination(
        icon: const Icon(Icons.home_outlined),
        selectedIcon: const Icon(Icons.home),
        label: l10n.navHome,
      ),
      NavigationDestination(
        icon: const Icon(Icons.bar_chart_outlined),
        selectedIcon: const Icon(Icons.bar_chart),
        label: l10n.navStatistics,
      ),
      if (isKorea)
        NavigationDestination(
          icon: const Icon(Icons.receipt_long_outlined),
          selectedIcon: const Icon(Icons.receipt_long),
          label: l10n.navTax,
        ),
      NavigationDestination(
        icon: const Icon(Icons.menu),
        selectedIcon: const Icon(Icons.menu_open),
        label: l10n.navMenu,
      ),
    ];

    if (_currentIndex >= pages.length) _currentIndex = pages.length - 1;

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        height: 70,
        backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        indicatorColor:
            isDark ? Colors.blueGrey[800] : Colors.blueGrey.withOpacity(0.12),
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: destinations,
      ),
    );
  }
}
