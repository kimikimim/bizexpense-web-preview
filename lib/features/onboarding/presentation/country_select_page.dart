import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';

import '../../../core/config/country_tax_config.dart';
import '../../../core/providers/country_config_provider.dart';
import '../../auth/presentation/login_page.dart';

class CountrySelectPage extends ConsumerStatefulWidget {
  const CountrySelectPage({super.key});

  @override
  ConsumerState<CountrySelectPage> createState() => _CountrySelectPageState();
}

class _CountrySelectPageState extends ConsumerState<CountrySelectPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  String? _detectedCode;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();
    _detectLocale();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  void _detectLocale() {
    final locale = PlatformDispatcher.instance.locale;
    final code = locale.countryCode ?? '';
    if (kCountryConfigs.containsKey(code)) {
      setState(() => _detectedCode = code);
    }
  }

  Future<void> _select(String countryCode) async {
    await ref.read(countryConfigProvider.notifier).setCountry(countryCode);
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.42,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0D2137), Color(0xFF1565C0), Color(0xFF1E88E5)],
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.62,
            child: Container(
              color: isDark ? const Color(0xFF121212) : Colors.white,
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 36),
                FadeTransition(
                  opacity: _fadeAnim,
                  child: _buildHeader(),
                ),
                const SizedBox(height: 28),
                Expanded(
                  child: SlideTransition(
                    position: _slideAnim,
                    child: FadeTransition(
                      opacity: _fadeAnim,
                      child: _buildCountryList(isDark),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(30),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withAlpha(60), width: 1.5),
          ),
          child: const Icon(Icons.public_rounded, size: 38, color: Colors.white),
        ),
        const SizedBox(height: 16),
        const Text(
          'BizExpense',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Choose your country',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withAlpha(180),
          ),
        ),
      ],
    );
  }

  Widget _buildCountryList(bool isDark) {
    final countries = kCountryConfigs.values.toList();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 60 : 20),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
            child: Text(
              'Select your region',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF191F28),
              ),
            ),
          ),
          if (_detectedCode != null) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
              child: Text(
                'Detected: ${kCountryConfigs[_detectedCode]!.flagEmoji} ${kCountryConfigs[_detectedCode]!.countryName}',
                style: TextStyle(
                  fontSize: 12,
                  color: const Color(0xFF3182F6),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
          const SizedBox(height: 8),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: countries.length,
            separatorBuilder: (_, __) => Divider(
              height: 1,
              indent: 20,
              endIndent: 20,
              color: isDark ? Colors.white10 : Colors.grey.shade100,
            ),
            itemBuilder: (context, i) {
              final c = countries[i];
              final isDetected = c.countryCode == _detectedCode;
              return InkWell(
                onTap: () => _select(c.countryCode),
                borderRadius: BorderRadius.vertical(
                  top: i == 0 ? const Radius.circular(24) : Radius.zero,
                  bottom: i == countries.length - 1
                      ? const Radius.circular(24)
                      : Radius.zero,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Row(
                    children: [
                      Text(c.flagEmoji, style: const TextStyle(fontSize: 28)),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              c.countryName,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF191F28),
                              ),
                            ),
                            Text(
                              '${c.nativeName} · ${c.vatTerminology} ${(c.vatRate * 100).toStringAsFixed(0)}%',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? Colors.grey[400]
                                    : const Color(0xFF8B95A1),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isDetected)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3182F6).withAlpha(25),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Detected',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF3182F6),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      else
                        Icon(
                          Icons.chevron_right_rounded,
                          size: 20,
                          color: Colors.grey[400],
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
