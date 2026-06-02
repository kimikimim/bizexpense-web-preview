import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/widgets/primary_button.dart';

class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({super.key});

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  final _nameController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _ageController = TextEditingController();
  final _introController = TextEditingController();

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadInitial();
  }

  void _loadInitial() {
    final user = Supabase.instance.client.auth.currentUser;
    final data = (user?.userMetadata ?? {}) as Map<String, dynamic>;

    _nameController.text = (data['name'] ?? '') as String;
    _nicknameController.text = (data['nickname'] ?? '') as String;
    final age = data['age'];
    if (age != null) {
      _ageController.text = age.toString();
    }
    _introController.text = (data['intro'] ?? '') as String;
  }

  Future<void> _save() async {
    if (_isSaving) return;

    final name = _nameController.text.trim();
    final nickname = _nicknameController.text.trim();
    final ageText = _ageController.text.trim();
    final intro = _introController.text.trim();

    int? age;
    if (ageText.isNotEmpty) {
      age = int.tryParse(ageText);
    }

    setState(() => _isSaving = true);

    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(
          data: {
            'name': name,
            'nickname': nickname,
            if (age != null) 'age': age,
            'intro': intro,
          },
        ),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('프로필이 저장되었습니다.')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('저장 중 오류가 발생했습니다: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nicknameController.dispose();
    _ageController.dispose();
    _introController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('프로필 설정'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '기본 정보',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.grey[200] : Colors.grey[800],
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '이름',
                hintText: '실제 이름',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _ageController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: '나이',
                hintText: '예) 35',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            Text(
              '커뮤니티 정보',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.grey[200] : Colors.grey[800],
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nicknameController,
              decoration: const InputDecoration(
                labelText: '커뮤니티 닉네임',
                hintText: '다른 사장님들에게 보일 이름',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '커뮤니티 게시글/댓글에는 이 닉네임만 노출돼요.',
              style: TextStyle(
                fontSize: 11,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _introController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: '한 줄 소개 (선택)',
                hintText: '예) 카페 운영 3년차 사장님입니다.',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: '저장하기',
              isLoading: _isSaving,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}
