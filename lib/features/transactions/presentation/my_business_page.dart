import 'package:flutter/material.dart';
import '../../../core/widgets/primary_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../auth/presentation/login_page.dart';
import 'package:expense_pro/core/utils/app_logger.dart';

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
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("저장되었습니다!")));
        Navigator.pop(context);
      }
    } catch (e) {
      appLogger.e("저장 에러: $e", error: e);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("저장 실패: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteAccount() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("회원 탈퇴"),
        content: const Text("정말 탈퇴하시겠습니까?\n모든 데이터가 즉시 삭제되며 복구할 수 없습니다."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("취소")),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("탈퇴하기", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
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
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("탈퇴가 완료되었습니다.")));
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
          (route) => false,
        );
      }
    } catch (e) {
      appLogger.e("탈퇴 에러: $e", error: e);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("오류가 발생했습니다.")));
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("내 정보 설정")),
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
                        const Text("🗣️ 커뮤니티용 프로필", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _nicknameController,
                          decoration: const InputDecoration(
                            labelText: "닉네임",
                            hintText: "예: 김사장, 대박나자",
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.face),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  const Text("🧾 견적서/청구서용 정보", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 10),
                  _buildTextField("상호명 (법인명)", _companyController, "예: BizExpense"),
                  _buildTextField("대표자 성명", _ceoController, "예: 홍길동"),
                  _buildTextField("사업자등록번호", _bizNumController, "예: 123-45-67890"),
                  _buildTextField("사업장 주소", _addressController, "예: 서울시 강남구..."),
                  _buildTextField("업태 / 종목", _categoryController, "예: 서비스 / 소프트웨어 개발"),

                  const SizedBox(height: 30),
                  PrimaryButton(
                    label: "저장하기",
                    onPressed: _saveMyInfo,
                  ),
                  
                  const SizedBox(height: 40),
                  const Divider(),
                  const SizedBox(height: 20),

                  TextButton.icon(
                    onPressed: _deleteAccount,
                    icon: const Icon(Icons.delete_forever, color: Colors.grey),
                    label: const Text("회원 탈퇴", style: TextStyle(color: Colors.grey)),
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
