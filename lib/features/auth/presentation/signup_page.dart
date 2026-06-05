import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_pro/core/utils/app_logger.dart';
import 'package:expense_pro/core/providers/country_config_provider.dart';
import 'package:expense_pro/l10n/app_localizations.dart';
import '../../shell/main_shell_page.dart';

class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({super.key});

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  final _pageCtrl = PageController();

  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  final _nameCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _nicknameCtrl = TextEditingController();
  final _introCtrl = TextEditingController();

  String _userType = '';
  bool _isLoading = false;
  bool _obscurePw = true;
  bool _obscureConfirm = true;
  int _currentStep = 0;

  static const _stepCount = 3;

  List<String> _stepTitles(AppLocalizations l) =>
      [l.signupStep1Title, l.signupStep2Title, l.signupStep3Title];
  List<String> _stepSubs(AppLocalizations l) =>
      [l.signupStep1Sub, l.signupStep2Sub, l.signupStep3Sub];

  @override
  void dispose() {
    _pageCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    _nicknameCtrl.dispose();
    _introCtrl.dispose();
    super.dispose();
  }

  void _nextStep() {
    final l = AppLocalizations.of(context)!;
    if (_currentStep == 0) {
      final email = _emailCtrl.text.trim();
      final pw = _passwordCtrl.text.trim();
      final confirm = _confirmCtrl.text.trim();
      if (email.isEmpty || !email.contains('@')) {
        _showSnack(l.validEmailRequired);
        return;
      }
      if (pw.length < 8) {
        _showSnack(l.passwordTooShort);
        return;
      }
      if (!RegExp(r'[a-zA-Z]').hasMatch(pw)) {
        _showSnack(l.passwordNeedsLetter);
        return;
      }
      if (!RegExp(r'[0-9]').hasMatch(pw)) {
        _showSnack(l.passwordNeedsNumber);
        return;
      }
      if (!RegExp(r'[^a-zA-Z0-9]').hasMatch(pw)) {
        _showSnack(l.passwordNeedsSpecial);
        return;
      }
      if (pw != confirm) {
        _showSnack(l.passwordMismatch);
        return;
      }
    } else if (_currentStep == 1) {
      final name = _nameCtrl.text.trim();
      final nickname = _nicknameCtrl.text.trim();
      if (name.isEmpty) {
        _showSnack(l.nameRequired);
        return;
      }
      if (nickname.length < 2) {
        _showSnack(l.usernameTooShort);
        return;
      }
    }

    setState(() => _currentStep++);
    _pageCtrl.animateToPage(
      _currentStep,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  void _prevStep() {
    if (_currentStep == 0) {
      Navigator.pop(context);
      return;
    }
    setState(() => _currentStep--);
    _pageCtrl.animateToPage(
      _currentStep,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _submit() async {
    setState(() => _isLoading = true);
    try {
      final supabase = Supabase.instance.client;

      final res = await supabase.auth.signUp(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text.trim(),
        data: {
          'name': _nameCtrl.text.trim(),
          'nickname': _nicknameCtrl.text.trim(),
          if (_ageCtrl.text.trim().isNotEmpty)
            'age': int.tryParse(_ageCtrl.text.trim()),
          if (_introCtrl.text.trim().isNotEmpty)
            'intro': _introCtrl.text.trim(),
        },
      );

      if (res.user == null) throw Exception('signup failed');

      final prefs = await SharedPreferences.getInstance();
      final countryCode = prefs.getString('country_code') ?? 'KR';

      await supabase.from('profiles').upsert({
        'id': res.user!.id,
        'user_type': _userType,
        'country_code': countryCode,
        'updated_at': DateTime.now().toIso8601String(),
      });

      await prefs.setString('user_type', _userType);

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainShellPage()),
        (route) => false,
      );
    } on AuthException catch (e) {
      _showSnack(_authError(e.message));
    } catch (e) {
      appLogger.e('signup error', error: e);
      if (mounted) _showSnack(AppLocalizations.of(context)!.loginGenericError);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _authError(String raw) {
    final l = AppLocalizations.of(context)!;
    if (raw.contains('already registered')) return l.emailAlreadyRegistered;
    if (raw.contains('invalid email')) return l.invalidEmail;
    if (raw.contains('weak password')) return l.weakPassword;
    return l.signupFailed;
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            
            _buildHeader(isDark),

            _buildStepIndicator(isDark),

            Expanded(
              child: PageView(
                controller: _pageCtrl,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildStep0(isDark),
                  _buildStep1(isDark),
                  _buildStep2(isDark),
                ],
              ),
            ),

            _buildBottomBar(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    final l = AppLocalizations.of(context)!;
    final titles = _stepTitles(l);
    final subs = _stepSubs(l);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: _prevStep,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDark ? Colors.white10 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titles[_currentStep],
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  subs[_currentStep],
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          // Force LTR so "1 / 3" doesn't bidi-reverse to "3 / 1" in Arabic.
          Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
              AppLocalizations.of(context)!
                  .signupStepCounter('${_currentStep + 1}', '${titles.length}'),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey[400],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Row(
        children: List.generate(_stepCount, (i) {
          final active = i <= _currentStep;
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: i < 2 ? 6 : 0),
              height: 4,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                gradient: active ? const LinearGradient(colors: [Color(0xFF1565C0), Color(0xFF1E88E5)]) : null,
                color: active ? null : (isDark ? Colors.white12 : Colors.grey.shade200),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStep0(bool isDark) {
    final l = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          Container(
            width: double.infinity,
            height: 140,
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0D2137), Color(0xFF1565C0)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -20,
                  bottom: -20,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withAlpha(15),
                    ),
                  ),
                ),
                Positioned(
                  right: 30,
                  top: -10,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withAlpha(10),
                    ),
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.lock_person_rounded, size: 40, color: Colors.white),
                      const SizedBox(height: 8),
                      Text(
                        l.signupBannerStep1,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          _inputField(
            controller: _emailCtrl,
            label: l.emailAddress,
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            isDark: isDark,
          ),
          const SizedBox(height: 14),
          _inputField(
            controller: _passwordCtrl,
            label: l.passwordHint,
            icon: Icons.lock_outline,
            obscure: _obscurePw,
            isDark: isDark,
            suffix: IconButton(
              icon: Icon(_obscurePw ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20, color: Colors.grey[400]),
              onPressed: () => setState(() => _obscurePw = !_obscurePw),
            ),
          ),
          const SizedBox(height: 14),
          _inputField(
            controller: _confirmCtrl,
            label: l.confirmPassword,
            icon: Icons.lock_reset_outlined,
            obscure: _obscureConfirm,
            isDark: isDark,
            suffix: IconButton(
              icon: Icon(_obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20, color: Colors.grey[400]),
              onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep1(bool isDark) {
    final l = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 140,
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF43A047)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -20,
                  bottom: -20,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withAlpha(15),
                    ),
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.person_pin_rounded, size: 40, color: Colors.white),
                      const SizedBox(height: 8),
                      Text(
                        l.signupBannerStep2,
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          _sectionLabel(l.basicInfo, isDark),
          const SizedBox(height: 10),
          _inputField(controller: _nameCtrl, label: l.fullName, icon: Icons.badge_outlined, isDark: isDark),
          const SizedBox(height: 14),
          _inputField(
            controller: _ageCtrl,
            label: l.age,
            icon: Icons.cake_outlined,
            keyboardType: TextInputType.number,
            isDark: isDark,
          ),
          const SizedBox(height: 24),

          _sectionLabel(l.profileNicknameSection, isDark),
          const SizedBox(height: 10),
          _inputField(
            controller: _nicknameCtrl,
            label: l.profileNickname,
            icon: Icons.alternate_email_rounded,
            isDark: isDark,
          ),
          const SizedBox(height: 14),
          _inputField(
            controller: _introCtrl,
            label: l.bio,
            icon: Icons.edit_note_rounded,
            maxLines: 2,
            isDark: isDark,
            hint: l.bioHint,
          ),
        ],
      ),
    );
  }

  Widget _buildStep2(bool isDark) {
    final l = AppLocalizations.of(context)!;
    final countryCode = ref.read(countryConfigProvider).countryCode;
    final isME = countryCode != 'KR';

    final List<Map<String, dynamic>> types = isME
        ? [
            {
              'value': 'sole_proprietorship',
              'icon': Icons.store_rounded,
              'title': l.signupTypeSoleProp,
              'sub': l.signupTypeSolePropSub,
              'tag': l.mostPopular,
              'tagColor': const Color(0xFF1E88E5),
              'gradient': const LinearGradient(colors: [Color(0xFF1565C0), Color(0xFF1E88E5)]),
            },
            {
              'value': 'llc',
              'icon': Icons.business_rounded,
              'title': l.signupTypeLlc,
              'sub': l.signupTypeLlcSub,
              'tag': null,
              'tagColor': null,
              'gradient': const LinearGradient(colors: [Color(0xFF4A148C), Color(0xFF7B1FA2)]),
            },
            {
              'value': 'free_zone',
              'icon': Icons.flight_takeoff_rounded,
              'title': l.signupTypeFreeZone,
              'sub': l.signupTypeFreeZoneSub,
              'tag': 'UAE',
              'tagColor': const Color(0xFF00897B),
              'gradient': const LinearGradient(colors: [Color(0xFF00695C), Color(0xFF00897B)]),
            },
            {
              'value': 'personal',
              'icon': Icons.person_rounded,
              'title': l.personal,
              'sub': l.personalSub,
              'tag': null,
              'tagColor': null,
              'gradient': const LinearGradient(colors: [Color(0xFF1B5E20), Color(0xFF43A047)]),
            },
          ]
        : [
            {
              'value': 'business_individual',
              'icon': Icons.store_rounded,
              'title': l.businessIndividual,
              'sub': l.businessIndividualSub,
              'tag': l.mostPopular,
              'tagColor': const Color(0xFF1E88E5),
              'gradient': const LinearGradient(colors: [Color(0xFF1565C0), Color(0xFF1E88E5)]),
            },
            {
              'value': 'business_corporate',
              'icon': Icons.business_rounded,
              'title': l.businessCorporate,
              'sub': l.businessCorporateSub,
              'tag': null,
              'tagColor': null,
              'gradient': const LinearGradient(colors: [Color(0xFF4A148C), Color(0xFF7B1FA2)]),
            },
            {
              'value': 'personal',
              'icon': Icons.person_rounded,
              'title': l.personal,
              'sub': l.personalSub,
              'tag': null,
              'tagColor': null,
              'gradient': const LinearGradient(colors: [Color(0xFF1B5E20), Color(0xFF43A047)]),
            },
          ];

    if (_userType.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() => _userType = types.first['value'] as String);
      });
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      children: [
        Text(
          l.signupChooseType,
          style: TextStyle(
            fontSize: 15,
            height: 1.5,
            color: isDark ? Colors.grey[300] : Colors.grey[700],
          ),
        ),
        const SizedBox(height: 20),
        ...types.map((t) => _buildTypeCard(t, isDark)),
      ],
    );
  }

  Widget _buildTypeCard(Map<String, dynamic> t, bool isDark) {
    final selected = _userType == t['value'];
    final gradient = t['gradient'] as LinearGradient;

    return GestureDetector(
      onTap: () => setState(() => _userType = t['value'] as String),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected
                ? (gradient.colors.first)
                : (isDark ? Colors.white12 : Colors.grey.shade200),
            width: selected ? 2 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: gradient.colors.last.withAlpha(50),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withAlpha(isDark ? 20 : 8),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: selected ? gradient : null,
                  color: selected ? null : (isDark ? Colors.white10 : Colors.grey.shade100),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  t['icon'] as IconData,
                  color: selected ? Colors.white : Colors.grey,
                  size: 26,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          t['title'] as String,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: selected ? gradient.colors.first : null,
                          ),
                        ),
                        if (t['tag'] != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: (t['tagColor'] as Color).withAlpha(25),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              t['tag'] as String,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: t['tagColor'] as Color,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      t['sub'] as String,
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: selected ? gradient : null,
                  border: selected ? null : Border.all(color: isDark ? Colors.white24 : Colors.grey.shade300),
                ),
                child: selected
                    ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar(bool isDark) {
    final l = AppLocalizations.of(context)!;
    final isLast = _currentStep == _stepCount - 1;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF121212) : Colors.white,
        border: Border(top: BorderSide(color: isDark ? Colors.white10 : Colors.grey.shade100)),
      ),
      child: GestureDetector(
        onTap: isLast ? (_isLoading ? null : _submit) : _nextStep,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 54,
          decoration: BoxDecoration(
            gradient: _isLoading
                ? const LinearGradient(colors: [Colors.grey, Colors.grey])
                : const LinearGradient(
                    colors: [Color(0xFF1565C0), Color(0xFF1E88E5)],
                  ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1E88E5).withAlpha(60),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: _isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isLast ? l.complete : l.next,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      isLast ? Icons.check_circle_rounded : Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
    bool isDark = false,
    TextInputType? keyboardType,
    Widget? suffix,
    int maxLines = 1,
    String? hint,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
        prefixIcon: Icon(icon, size: 20, color: Colors.grey[400]),
        suffixIcon: suffix,
        filled: true,
        fillColor: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF5F7FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1E88E5), width: 1.5),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: maxLines > 1 ? 14 : 14),
      ),
    );
  }

  Widget _sectionLabel(String label, bool isDark) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.grey[300] : Colors.grey[700],
        letterSpacing: 0.3,
      ),
    );
  }
}
