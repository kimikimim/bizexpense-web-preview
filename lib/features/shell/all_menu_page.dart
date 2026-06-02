import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:characters/characters.dart'; 

import '../../core/providers/theme_provider.dart';
import '../../core/utils/excel_service.dart';

import '../transactions/data/transaction_repository.dart';
import '../transactions/data/transaction_model.dart';

import '../statistics/presentation/statistics_page.dart';
import '../tax/presentation/tax_calendar_page.dart';
import '../tax/presentation/tax_summary_page.dart';
import '../recurring/presentation/recurring_list_page.dart';
import '../transactions/presentation/invoice_page.dart';
import '../user/presentation/settings_page.dart';
import '../auth/presentation/login_page.dart';
import '../user/presentation/profile_edit_page.dart';

class AllMenuPage extends ConsumerStatefulWidget {
  const AllMenuPage({super.key});

  @override
  ConsumerState<AllMenuPage> createState() => _AllMenuPageState();
}

class _AllMenuPageState extends ConsumerState<AllMenuPage> {
  final _currency = NumberFormat.currency(locale: 'ko_KR', symbol: '₩');
  bool _isExporting = false;

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('로그아웃'),
        content: const Text('정말 로그아웃 하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              '로그아웃',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await Supabase.instance.client.auth.signOut();

    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  Future<void> _exportExcel({
    required bool forAccounting,
  }) async {
    if (_isExporting) return;
    setState(() => _isExporting = true);

    try {
      final repo = TransactionRepository();
      final List<TransactionModel> txs = await repo.getTransactions();

      if (txs.isEmpty) {
        _showSnackBar('내보낼 데이터가 없습니다.');
      } else {
        final excel = ExcelService();
        if (forAccounting) {
          
          await excel.exportForAccounting(txs);
          _showSnackBar('세무 정산용 엑셀 파일이 생성되었습니다.');
        } else {
          
          await excel.exportToExcel(txs);
          _showSnackBar('엑셀 파일이 생성되었습니다.');
        }
      }
    } catch (e) {
      _showSnackBar('엑셀 내보내기 중 오류가 발생했습니다.');
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeMode = ref.watch(themeProvider);
    final user = Supabase.instance.client.auth.currentUser;

    final displayName = (user?.userMetadata?['name'] as String?) ?? '사장님';
    final email = user?.email ?? '';
    final nickname = (user?.userMetadata?['nickname'] as String?) ?? '';

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          '전체',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          
          _buildProfileHeader(
            isDark: isDark,
            name: displayName,
            email: email,
            nickname: nickname,
          ),

          const SizedBox(height: 16),

          _buildQuickAppsSection(isDark),

          const SizedBox(height: 24),

          _buildSectionTitle('사업 관리'),
          _buildMenuCard(
            isDark: isDark,
            children: [
              _buildMenuTile(
                icon: Icons.bar_chart,
                iconColor: Colors.blue,
                title: '통계 분석',
                subtitle: '매출·지출 트렌드, 카테고리별 분석',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const StatisticsPage(),
                    ),
                  );
                },
              ),
              _buildMenuTile(
                icon: Icons.person_outline,
                iconColor: Colors.blueGrey,
                title: '프로필 설정',
                subtitle: '이름, 나이, 닉네임 관리',
                onTap: () async {
                  final changed = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ProfileEditPage(),
                    ),
                  );

                  if (changed == true && mounted) {
                    setState(() {});
                  }
                },
              ),
              _buildMenuTile(
                icon: Icons.receipt_long,
                iconColor: Colors.purple,
                title: '세무 리포트',
                subtitle: '분기별 부가세·종합소득세 리포트',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const TaxSummaryPage(),
                    ),
                  );
                },
              ),
              _buildMenuTile(
                icon: Icons.calendar_today,
                iconColor: Colors.orange,
                title: '세무 일정',
                subtitle: '부가세 / 종소세 신고 마감일 관리',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const TaxCalendarPage(),
                    ),
                  );
                },
              ),
              _buildMenuTile(
                icon: Icons.repeat,
                iconColor: Colors.teal,
                title: '정기 거래 관리',
                subtitle: '월세·구독료·급여 등 자동 등록 설정',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RecurringListPage(),
                    ),
                  );
                },
              ),
              _buildMenuTile(
                icon: Icons.description_outlined,
                iconColor: Colors.indigo,
                title: '견적서 발행',
                subtitle: '거래처에 보낼 견적서 만들기',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const InvoicePage(),
                    ),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          _buildSectionTitle('데이터 관리'),
          _buildMenuCard(
            isDark: isDark,
            children: [
              _buildMenuTile(
                icon: Icons.file_download,
                iconColor: Colors.green,
                title: '엑셀로 내보내기',
                subtitle: '매출·지출 전체 내역 엑셀 파일 생성',
                trailing: _isExporting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : null,
                onTap: () => _exportExcel(forAccounting: false),
              ),
              _buildMenuTile(
                icon: Icons.table_view,
                iconColor: Colors.lightBlue,
                title: '세무 정산용 엑셀',
                subtitle: '국세청 전자신고용 형식으로 저장',
                trailing: _isExporting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : null,
                onTap: () => _exportExcel(forAccounting: true),
              ),
            ],
          ),

          const SizedBox(height: 24),

          _buildSectionTitle('환경 설정'),
          _buildMenuCard(
            isDark: isDark,
            children: [
              SwitchListTile(
                value: themeMode == ThemeMode.dark,
                onChanged: (value) {
                  ref.read(themeProvider.notifier).toggleTheme(value);
                },
                title: const Text('다크 모드'),
                secondary: Icon(
                  themeMode == ThemeMode.dark
                      ? Icons.dark_mode
                      : Icons.light_mode,
                  color: themeMode == ThemeMode.dark
                      ? Colors.yellow
                      : Colors.grey,
                ),
              ),
              const Divider(height: 0),
              _buildMenuTile(
                icon: Icons.settings,
                iconColor: Colors.grey,
                title: '설정',
                subtitle: '글자 크기, 사업자 정보, 데이터 백업',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SettingsPage(),
                    ),
                  );
                },
              ),
              _buildMenuTile(
                icon: Icons.logout,
                iconColor: Colors.red,
                title: '로그아웃',
                subtitle: '현재 기기에서만 로그아웃',
                isDestructive: true,
                onTap: _logout,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader({
    required bool isDark,
    required String name,
    required String email,
    String? nickname,
  }) {
    final initial = name.isNotEmpty ? name.characters.first : 'B';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.blueGrey[700],
            child: Text(
              initial,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  email.isNotEmpty ? email : '사업 관리 중',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAppsSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('자주 쓰는 메뉴'),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[900] : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
            ),
          ),
          child: GridView.count(
            shrinkWrap: true,
            crossAxisCount: 4,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 0.8,
            children: [
              _buildQuickIcon(
                icon: Icons.bar_chart,
                label: '통계',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const StatisticsPage(),
                    ),
                  );
                },
              ),
              _buildQuickIcon(
                icon: Icons.receipt_long,
                label: '세무\n리포트',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const TaxSummaryPage(),
                    ),
                  );
                },
              ),
              _buildQuickIcon(
                icon: Icons.calendar_today,
                label: '세무\n일정',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const TaxCalendarPage(),
                    ),
                  );
                },
              ),
              _buildQuickIcon(
                icon: Icons.settings_outlined,
                label: '설정',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SettingsPage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickIcon({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blueGrey.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, size: 22),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildMenuCard({
    required bool isDark,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
        ),
      ),
      child: Column(
        children: [
          for (int i = 0; i < children.length; i++) ...[
            if (i != 0) const Divider(height: 0),
            children[i],
          ],
        ],
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
    bool isDestructive = false,
    Widget? trailing,
  }) {
    final textColor = isDestructive ? Colors.red : null;

    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        radius: 18,
        backgroundColor: iconColor.withOpacity(0.12),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: const TextStyle(fontSize: 11),
            )
          : null,
      trailing: trailing ??
          const Icon(
            Icons.chevron_right,
            size: 18,
          ),
    );
  }
}
