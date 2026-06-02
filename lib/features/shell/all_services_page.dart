import 'package:flutter/material.dart';

import '../statistics/presentation/statistics_page.dart';
import '../tax/presentation/tax_calendar_page.dart';
import '../tax/presentation/tax_summary_page.dart';
import '../tax/presentation/tax_tips_page.dart';
import '../tax/presentation/tax_faq_page.dart';
import '../transactions/presentation/my_business_page.dart';
import '../recurring/presentation/recurring_list_page.dart';
import '../transactions/presentation/invoice_page.dart';
import '../community/presentation/community_page.dart';
import '../user/presentation/settings_page.dart';

class AllServicesPage extends StatelessWidget {
  const AllServicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('전체'),
        actions: [
          
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
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
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          _buildSectionTitle(context, '사업 리포트'),
          _buildServiceTile(
            context,
            icon: Icons.insights,
            color: Colors.teal,
            title: '내 사업 한눈에 보기',
            subtitle: '매출·지출·순이익을 한 번에',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const MyBusinessPage(),
                ),
              );
            },
          ),
          _buildServiceTile(
            context,
            icon: Icons.bar_chart,
            color: Colors.blue,
            title: '통계 분석',
            subtitle: '카테고리·월별 트렌드 보기',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const StatisticsPage(),
                ),
              );
            },
          ),
          _buildServiceTile(
            context,
            icon: Icons.receipt_long,
            color: Colors.purple,
            title: '세무 리포트',
            subtitle: '부가세·지출 리포트 모아보기',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const TaxSummaryPage(),
                ),
              );
            },
          ),

          const SizedBox(height: 16),
          _buildSectionTitle(context, '세무'),

          _buildServiceTile(
            context,
            icon: Icons.calendar_today,
            color: Colors.orange,
            title: '세무 일정',
            subtitle: '신고·납부 기한 놓치지 않기',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const TaxCalendarPage(),
                ),
              );
            },
          ),
          _buildServiceTile(
            context,
            icon: Icons.tips_and_updates,
            color: Colors.green,
            title: '사장님 절세 족보',
            subtitle: '업종별 필수 절세 팁 모음',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const TaxTipsPage(),
                ),
              );
            },
          ),
          _buildServiceTile(
            context,
            icon: Icons.help_outline,
            color: Colors.indigo,
            title: '세무 자주 묻는 질문',
            subtitle: '부가세·종소세·4대보험 Q&A',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const TaxFaqPage(),
                ),
              );
            },
          ),

          const SizedBox(height: 16),
          _buildSectionTitle(context, '관리'),

          _buildServiceTile(
            context,
            icon: Icons.repeat,
            color: Colors.teal,
            title: '정기 거래 관리',
            subtitle: '월세·구독비 자동 등록 설정',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const RecurringListPage(),
                ),
              );
            },
          ),
          _buildServiceTile(
            context,
            icon: Icons.description_outlined,
            color: Colors.deepPurple,
            title: '견적서 발행',
            subtitle: '고객에게 바로 보낼 견적서 만들기',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const InvoicePage(),
                ),
              );
            },
          ),

          const SizedBox(height: 16),
          _buildSectionTitle(context, '커뮤니티'),

          _buildServiceTile(
            context,
            icon: Icons.forum,
            color: Colors.deepPurpleAccent,
            title: '사장님 커뮤니티',
            subtitle: '다른 사장님들과 정보 나누기',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CommunityPage(),
                ),
              );
            },
          ),

          const SizedBox(height: 32),
          Center(
            child: Text(
              '자주 쓰는 기능은 홈에서 바로 쓸 수 있게\n점점 더 정리해 드릴게요 :)',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                height: 1.4,
                color: isDark ? Colors.grey[500] : Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
    );
  }

  Widget _buildServiceTile(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[900] : Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        color:
                            isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 14),
            ],
          ),
        ),
      ),
    );
  }
}
