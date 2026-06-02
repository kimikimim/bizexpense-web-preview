
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../home/presentation/home_page.dart';
import '../statistics/presentation/statistics_page.dart';
import '../tax/presentation/tax_summary_page.dart';
import '../community/presentation/community_page.dart';
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
    const CommunityPage(),   
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
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: '홈',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: '통계',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: '세무',
          ),
          NavigationDestination(
            icon: Icon(Icons.forum_outlined),
            selectedIcon: Icon(Icons.forum),
            label: '커뮤니티',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu),
            selectedIcon: Icon(Icons.menu_open),
            label: '전체',
          ),
        ],
      ),
    );
  }
}
