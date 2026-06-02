import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/card_model.dart';
import '../data/card_repository.dart';

class CardCompanyInfo {
  final String name;
  final String code;
  final Color color;
  final IconData icon;
  const CardCompanyInfo({
    required this.name,
    required this.code,
    required this.color,
    required this.icon,
  });
}

const List<CardCompanyInfo> kCardCompanies = [
  CardCompanyInfo(name: '삼성카드', code: '0301', color: Color(0xFF1428A0), icon: Icons.credit_card),
  CardCompanyInfo(name: 'KB국민카드', code: '0381', color: Color(0xFFFFB700), icon: Icons.credit_card),
  CardCompanyInfo(name: '신한카드', code: '0088', color: Color(0xFF0046FF), icon: Icons.credit_card),
  CardCompanyInfo(name: '현대카드', code: '0329', color: Color(0xFF1A1A1A), icon: Icons.credit_card),
  CardCompanyInfo(name: '롯데카드', code: '0030', color: Color(0xFFE60012), icon: Icons.credit_card),
  CardCompanyInfo(name: '우리카드', code: '0020', color: Color(0xFF006EB9), icon: Icons.credit_card),
  CardCompanyInfo(name: '하나카드', code: '0081', color: Color(0xFF009B77), icon: Icons.credit_card),
  CardCompanyInfo(name: 'BC카드', code: '0361', color: Color(0xFFE31E24), icon: Icons.credit_card),
  CardCompanyInfo(name: 'NH농협카드', code: '0011', color: Color(0xFF00A650), icon: Icons.credit_card),
  CardCompanyInfo(name: '씨티카드', code: '0027', color: Color(0xFF003B7A), icon: Icons.credit_card),
];

class CardRegisterPage extends StatefulWidget {
  const CardRegisterPage({super.key});

  @override
  State<CardRegisterPage> createState() => _CardRegisterPageState();
}

class _CardRegisterPageState extends State<CardRegisterPage> {
  final _repo = CardRepository();
  final _formKey = GlobalKey<FormState>();

  CardCompanyInfo? _selectedCompany;
  final _nicknameCtrl = TextEditingController();
  final _lastFourCtrl = TextEditingController();
  final _loginIdCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;
  int _step = 0; 

  @override
  void dispose() {
    _nicknameCtrl.dispose();
    _lastFourCtrl.dispose();
    _loginIdCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCompany == null) return;

    setState(() => _isLoading = true);

    try {
      
      final nickname = _nicknameCtrl.text.trim().isEmpty
          ? _selectedCompany!.name
          : _nicknameCtrl.text.trim();

      final newCard = await _repo.addCard(CardModel(
        id: '',
        userId: '',
        nickname: nickname,
        companyCode: _selectedCompany!.code,
        companyName: _selectedCompany!.name,
        lastFour: _lastFourCtrl.text.trim().isEmpty ? null : _lastFourCtrl.text.trim(),
        createdAt: DateTime.now(),
      ));

      if (newCard == null) {
        _showError('카드 등록 중 오류가 발생했습니다.');
        return;
      }

      setState(() => _step = 2);

      final connected = await _repo.connectCard(
        cardId: newCard.id,
        loginId: _loginIdCtrl.text.trim(),
        loginPassword: _passwordCtrl.text,
      );

      if (!connected) {
        _showError('카드사 연동에 실패했습니다.\nID/비밀번호를 확인해주세요.');
        return;
      }

      final synced = await _repo.syncTransactions(cardId: newCard.id);

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$nickname 연동 완료! 결제내역 ${synced}건을 가져왔습니다.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    setState(() {
      _isLoading = false;
      _step = 1;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('카드 연동'),
        centerTitle: true,
      ),
      body: _step == 2
          ? _buildLoadingStep()
          : _step == 0
              ? _buildSelectCompanyStep()
              : _buildInputStep(),
    );
  }

  Widget _buildLoadingStep() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 24),
          Text('카드사와 연동 중입니다...', style: TextStyle(fontSize: 16)),
          SizedBox(height: 8),
          Text('결제내역을 가져오고 있어요.\n잠시만 기다려주세요.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildSelectCompanyStep() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text('카드사를 선택해주세요',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.2,
            ),
            itemCount: kCardCompanies.length,
            itemBuilder: (context, index) {
              final company = kCardCompanies[index];
              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedCompany = company;
                    _step = 1;
                    _nicknameCtrl.text = company.name;
                  });
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: company.color.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(12),
                    color: company.color.withOpacity(0.05),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(company.icon, color: company.color, size: 20),
                      const SizedBox(width: 8),
                      Text(company.name,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: company.color)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildInputStep() {
    final company = _selectedCompany!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: company.color.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: company.color.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.credit_card, color: company.color),
                  const SizedBox(width: 12),
                  Text(company.name,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: company.color)),
                  const Spacer(),
                  TextButton(
                    onPressed: () => setState(() => _step = 0),
                    child: const Text('변경'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withOpacity(0.2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.security, color: Colors.blue, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '입력하신 로그인 정보는 저장되지 않습니다.\n금융보안 표준(RSA 암호화)으로 카드사에 직접 연결됩니다.',
                      style: TextStyle(
                          fontSize: 12, color: Colors.blue.shade700),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildField('카드 별명', _nicknameCtrl,
                hint: '예) 내 삼성카드, 법인카드'),
            const SizedBox(height: 16),
            _buildField('카드 끝 4자리 (선택)', _lastFourCtrl,
                hint: '예) 1234',
                keyboardType: TextInputType.number,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(4),
                  FilteringTextInputFormatter.digitsOnly,
                ],
                required: false),
            const SizedBox(height: 16),
            _buildField('${company.name} 로그인 ID', _loginIdCtrl,
                hint: '카드사 홈페이지 아이디'),
            const SizedBox(height: 16),
            _buildPasswordField(),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: company.color,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child:
                            CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('연동하기',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController ctrl, {
    String? hint,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    bool required = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextFormField(
          controller: ctrl,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          validator: required
              ? (v) => (v == null || v.trim().isEmpty) ? '$label을 입력해주세요' : null
              : null,
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('비밀번호', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextFormField(
          controller: _passwordCtrl,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            hintText: '카드사 홈페이지 비밀번호',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            suffixIcon: IconButton(
              icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
          validator: (v) =>
              (v == null || v.isEmpty) ? '비밀번호를 입력해주세요' : null,
        ),
      ],
    );
  }
}
