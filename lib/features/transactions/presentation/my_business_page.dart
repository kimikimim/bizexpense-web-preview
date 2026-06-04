import 'package:flutter/material.dart';
import '../../../core/widgets/primary_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../auth/presentation/login_page.dart';
import 'package:expense_pro/core/utils/app_logger.dart';
import 'package:expense_pro/l10n/app_localizations.dart';

class MyBusinessPage extends StatefulWidget {
  const MyBusinessPage({super.key});

  @override
  State<MyBusinessPage> createState() => _MyBusinessPageState();
}

class _MyBusinessPageState extends State<MyBusinessPage> {
  
  final _nicknameController = TextEditingController();
  
  final _companyController = TextEditingController();
  final _ceoController = TextEditingController();
  final _bizNumController = TextEditingController();
  final _addressController = TextEditingController();
  final _categoryController = TextEditingController();
  
  bool _isLoading = false;
  final _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _loadMyInfo();
  }

  Future<void> _loadMyInfo() async {
    setState(() => _isLoading = true);
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;
      
      final data = await _supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (data != null) {
        _nicknameController.text = data['nickname'] ?? ''; 
        _companyController.text = data['company_name'] ?? '';
        _ceoController.text = data['ceo_name'] ?? '';
        _bizNumController.text = data['business_number'] ?? '';
        _addressController.text = data['address'] ?? '';
        _categoryController.text = data['industry_category'] ?? '';
      }
    } catch (e) {
      appLogger.e("정보 불러오기 에러: $e", error: e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveMyInfo() async {
    setState(() => _isLoading = true);
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      await _supabase.from('profiles').upsert({
        'id': user.id,
        'nickname': _nicknameController.text, 
        'company_name': _companyController.text,
        'ceo_name': _ceoController.text,
        'business_number': _bizNumController.text,
        'address': _addressController.text,
        'industry_category': _categoryController.text,
        'updated_at': DateTime.now().toIso8601String(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.addTransactionSaved)));
        Navigator.pop(context);
      }
    } catch (e) {
      appLogger.e("save error", error: e);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.myBizSaveFailed('$e'))));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteAccount() async {
    final l10n = AppLocalizations.of(context)!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.myBizWithdraw),
        content: Text(l10n.myBizWithdrawConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel)),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.myBizWithdrawButton, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    try {
      await _supabase.rpc('delete_user');
      await _supabase.auth.signOut();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.myBizWithdrawDone)));
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
          (route) => false,
        );
      }
    } catch (e) {
      appLogger.e("delete account error", error: e);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.myBizError)));
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.myBizTitle)),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.myBizProfileSection, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _nicknameController,
                          decoration: InputDecoration(
                            labelText: l10n.profileNickname,
                            hintText: l10n.myBizNicknameHint,
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.face),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  Text(l10n.myBizInvoiceInfo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 10),
                  _buildTextField(l10n.myBizCompany, _companyController, l10n.myBizCompanyHint),
                  _buildTextField(l10n.myBizCeo, _ceoController, l10n.myBizCeoHint),
                  _buildTextField(l10n.myBizTaxNumber, _bizNumController, l10n.myBizTaxNumberHint),
                  _buildTextField(l10n.myBizAddress, _addressController, l10n.myBizAddressHint),
                  _buildTextField(l10n.myBizActivity, _categoryController, l10n.myBizActivityHint),

                  const SizedBox(height: 30),
                  PrimaryButton(
                    label: l10n.profileSaveButton,
                    onPressed: _saveMyInfo,
                  ),
                  
                  const SizedBox(height: 40),
                  const Divider(),
                  const SizedBox(height: 20),

                  TextButton.icon(
                    onPressed: _deleteAccount,
                    icon: const Icon(Icons.delete_forever, color: Colors.grey),
                    label: Text(l10n.myBizWithdraw, style: const TextStyle(color: Colors.grey)),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, String hint) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
