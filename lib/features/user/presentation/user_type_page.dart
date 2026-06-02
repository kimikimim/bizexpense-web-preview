import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:expense_pro/l10n/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:expense_pro/core/utils/app_logger.dart';
import '../../home/presentation/home_page.dart';
import '../../auth/presentation/login_page.dart';
import '../../shell/main_shell_page.dart';   
import '../../../core/widgets/primary_button.dart';

class UserTypePage extends StatefulWidget {
  const UserTypePage({super.key});

  @override
  State<UserTypePage> createState() => _UserTypePageState();
}

class _UserTypePageState extends State<UserTypePage> {
  String? _selectedMainType;
  bool _isSaving = false; 

  Future<void> _saveTypeAndGoHome(String type) async {
    setState(() => _isSaving = true);
    
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_type', type);

      if (user != null) {
        await supabase.from('profiles').upsert({
          'id': user.id,
          'user_type': type, 
          'updated_at': DateTime.now().toIso8601String(),
        });
      }

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainShellPage()),
      );
    } catch (e) {
      appLogger.e("저장 에러: $e", error: e);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.userTypeSaveError)));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _signOut() async {
    await Supabase.instance.client.auth.signOut();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton.icon(
            onPressed: _signOut,
            icon: const Icon(Icons.logout, size: 18, color: Colors.grey),
            label: Text(l10n.settingsLogout, style: const TextStyle(color: Colors.grey)),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: _isSaving
              ? const Center(child: CircularProgressIndicator())
              : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.account_balance_wallet, size: 80, color: Colors.blueGrey),
              const SizedBox(height: 24),
              const Text(
                "BizExpense",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.userTypeSelectPrompt,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              const SizedBox(height: 60),

              _buildTypeCard(
                icon: Icons.person,
                title: l10n.userTypePersonal,
                subtitle: l10n.userTypePersonalSub,
                isSelected: false,
                onTap: () => _saveTypeAndGoHome('personal'),
              ),

              const SizedBox(height: 16),

              _buildTypeCard(
                icon: Icons.store,
                title: l10n.userTypeBusiness,
                subtitle: l10n.userTypeBusinessSub,
                isSelected: _selectedMainType == 'business',
                onTap: () {
                  setState(() {
                    _selectedMainType = _selectedMainType == 'business' ? null : 'business';
                  });
                },
              ),

              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: _selectedMainType == 'business' ? 140 : 0,
                curve: Curves.easeInOut,
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
                    child: Column(
                      children: [
                        _buildSubButton("👤 ${l10n.userTypeIndividual}", () => _saveTypeAndGoHome('business_individual')),
                        const SizedBox(height: 12),
                        _buildSubButton("🏢 ${l10n.userTypeCorporate}", () => _saveTypeAndGoHome('business_corporate')),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeCard({required IconData icon, required String title, required String subtitle, required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blueGrey[50] : Colors.white,
          border: Border.all(color: isSelected ? Colors.blueGrey : Colors.grey.shade400, width: isSelected ? 2 : 1),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [if (!isSelected) BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.blueGrey.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, color: Colors.blueGrey[800], size: 28)),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)), const SizedBox(height: 4), Text(subtitle, style: TextStyle(fontSize: 14, color: Colors.grey[700]))])),
            Icon(isSelected ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_right, color: isSelected ? Colors.blueGrey : Colors.grey[600]),
          ],
        ),
      ),
    );
  }

  Widget _buildSubButton(String text, VoidCallback onTap) {
    return PrimaryButton(
      label: text,
      onPressed: onTap,
    );
  }
}
