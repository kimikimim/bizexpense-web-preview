import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:expense_pro/core/utils/app_logger.dart';
import 'package:expense_pro/l10n/app_localizations.dart';
import '../../user/presentation/user_type_page.dart';
import 'signup_page.dart';
import '../../shell/main_shell_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _isKorea = true;
  late AnimationController _animCtrl;
  late Animation<Offset> _slideAnim;
  late Animation<double> _fadeAnim;

  static const _gradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0D2137), Color(0xFF1565C0), Color(0xFF1E88E5)],
  );

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _fadeAnim = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();
    _loadRegion();
  }

  Future<void> _loadRegion() async {
    final prefs = await SharedPreferences.getInstance();
    final isKorea = (prefs.getString('country_code') ?? 'KR') == 'KR';
    if (mounted) setState(() => _isKorea = isKorea);
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text.trim();
    final l10n = AppLocalizations.of(context)!;
    if (email.isEmpty || password.isEmpty) {
      _showError(l10n.loginEmailRequired);
      return;
    }
    setState(() => _isLoading = true);
    try {
      final res = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (mounted && res.user != null) await _redirect(res.user!.id);
    } on AuthException {
      _showError(l10n.loginError);
    } catch (e) {
      appLogger.e('login error', error: e);
      _showError(l10n.loginGenericError);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _redirect(String userId) async {
    try {
      final data = await Supabase.instance.client
          .from('profiles')
          .select('user_type')
          .eq('id', userId)
          .maybeSingle();
      if (!mounted) return;
      if (data?['user_type'] != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_type', data!['user_type']);
        if (!mounted) return;
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainShellPage()));
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const UserTypePage()));
      }
    } catch (e) {
      appLogger.e('프로필 조회 오류', error: e);
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const UserTypePage()));
    }
  }

  Future<void> _oauthLogin(OAuthProvider provider) async {
    try {
      await Supabase.instance.client.auth.signInWithOAuth(
        provider,
        redirectTo: 'io.supabase.flutter://login-callback/',
      );
    } catch (e) {
      appLogger.e('oauth login error', error: e);
      if (mounted) _showError(AppLocalizations.of(context)!.loginOAuthError);
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          
          Container(
            height: size.height * 0.48,
            decoration: const BoxDecoration(gradient: _gradient),
          ),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: size.height * 0.55,
            child: Container(color: isDark ? const Color(0xFF121212) : Colors.white),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  SizedBox(height: size.height * 0.06),

                  _buildBrand(),

                  SizedBox(height: size.height * 0.05),

                  FadeTransition(
                    opacity: _fadeAnim,
                    child: SlideTransition(
                      position: _slideAnim,
                      child: _buildLoginCard(isDark),
                    ),
                  ),

                  const SizedBox(height: 24),

                  FadeTransition(
                    opacity: _fadeAnim,
                    child: _buildSocialButtons(),
                  ),

                  const SizedBox(height: 20),

                  FadeTransition(
                    opacity: _fadeAnim,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.noAccount,
                          style: TextStyle(color: Colors.grey[500], fontSize: 14),
                        ),
                        TextButton(
                          style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 6)),
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const SignupPage()),
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.signUp,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E88E5),
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrand() {
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
          child: const Icon(Icons.account_balance_wallet_rounded, size: 38, color: Colors.white),
        ),
        const SizedBox(height: 16),
        const Text(
          'BizExpense',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          AppLocalizations.of(context)!.appTagline,
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withAlpha(180),
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(28),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.login,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            AppLocalizations.of(context)!.loginSubtitle,
            style: TextStyle(fontSize: 13, color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),

          _buildField(
            controller: _emailCtrl,
            label: AppLocalizations.of(context)!.email,
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            isDark: isDark,
          ),
          const SizedBox(height: 14),

          _buildField(
            controller: _passwordCtrl,
            label: AppLocalizations.of(context)!.password,
            icon: Icons.lock_outline,
            obscure: _obscurePassword,
            isDark: isDark,
            onSubmitted: (_) => _signIn(),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                size: 20,
                color: Colors.grey[400],
              ),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
          const SizedBox(height: 24),

          _buildGradientButton(
            label: _isLoading
                ? AppLocalizations.of(context)!.loginLoading
                : AppLocalizations.of(context)!.login,
            isLoading: _isLoading,
            onTap: _signIn,
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
    bool isDark = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
    ValueChanged<String>? onSubmitted,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      onSubmitted: onSubmitted,
      style: const TextStyle(fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20, color: Colors.grey[400]),
        suffixIcon: suffixIcon,
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildGradientButton({
    required String label,
    required VoidCallback onTap,
    bool isLoading = false,
  }) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          gradient: isLoading
              ? const LinearGradient(colors: [Colors.grey, Colors.grey])
              : const LinearGradient(
                  colors: [Color(0xFF1565C0), Color(0xFF1E88E5)],
                ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: isLoading
              ? []
              : [
                  BoxShadow(
                    color: const Color(0xFF1E88E5).withAlpha(80),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        alignment: Alignment.center,
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                ),
              ),
      ),
    );
  }

  Widget _buildSocialButtons() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        // Korea-only: Kakao
        if (_isKorea) ...[
          _buildSocialButton(
            label: l10n.loginWithKakao,
            icon: Icons.chat_bubble_rounded,
            bgColor: const Color(0xFFFEE500),
            fgColor: const Color(0xFF3A1D1D),
            onTap: () => _oauthLogin(OAuthProvider.kakao),
          ),
          const SizedBox(height: 10),
        ],
        // All regions: Google
        _buildSocialButton(
          label: l10n.loginWithGoogle,
          icon: Icons.g_mobiledata_rounded,
          bgColor: Colors.white,
          fgColor: const Color(0xFF1F1F1F),
          border: true,
          onTap: () => _oauthLogin(OAuthProvider.google),
        ),
        const SizedBox(height: 10),
        // All regions: Apple
        _buildSocialButton(
          label: l10n.loginWithApple,
          icon: Icons.apple,
          bgColor: Colors.black,
          fgColor: Colors.white,
          onTap: () => _oauthLogin(OAuthProvider.apple),
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required String label,
    required IconData icon,
    required Color bgColor,
    required Color fgColor,
    required VoidCallback onTap,
    bool border = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: border ? Border.all(color: const Color(0xFFE0E0E0)) : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(12),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: fgColor, size: 22),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                color: fgColor,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
