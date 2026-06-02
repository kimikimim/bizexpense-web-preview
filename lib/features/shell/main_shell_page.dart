
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_pro/l10n/app_localizations.dart';

import '../home/presentation/home_page.dart';
import '../statistics/presentation/statistics_page.dart';
import '../tax/presentation/tax_summary_page.dart';
import '../user/presentation/settings_page.dart';

import 'all_menu_page.dart';

class MainShellPage extends ConsumerStatefulWidget {
  const MainShellPage({super.key});

  @override
  ConsumerState<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends ConsumerState<MainShellPage> {
  int _currentIndex = 0;

  late final List<Widget> _pages = [
    const HomePage(),
    const StatisticsPage(),
    const TaxSummaryPage(),
    AllMenuPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: _pages[_currentIndex],
      
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
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: AppLocalizations.of(context)!.navHome,
          ),
          NavigationDestination(
            icon: const Icon(Icons.bar_chart_outlined),
            selectedIcon: const Icon(Icons.bar_chart),
            label: AppLocalizations.of(context)!.navStatistics,
          ),
          NavigationDestination(
            icon: const Icon(Icons.receipt_long_outlined),
            selectedIcon: const Icon(Icons.receipt_long),
            label: AppLocalizations.of(context)!.navTax,
          ),
          NavigationDestination(
            icon: const Icon(Icons.menu),
            selectedIcon: const Icon(Icons.menu_open),
            label: AppLocalizations.of(context)!.navMenu,
          ),
        ],
      ),
    );
  }
}
