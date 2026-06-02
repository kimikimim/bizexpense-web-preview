import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/widgets/primary_button.dart';
import 'tax_setup_page.dart';

class TaxCalendarPage extends StatefulWidget {
  const TaxCalendarPage({super.key});

  @override
  State<TaxCalendarPage> createState() => _TaxCalendarPageState();
}

class _TaxCalendarPageState extends State<TaxCalendarPage> {
  final _client = Supabase.instance.client;

  bool _isLoading = true;
  List<Map<String, dynamic>> _events = [];

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() => _isLoading = true);

    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        setState(() {
          _events = [];
          _isLoading = false;
        });
        return;
      }

      final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

      final res = await _client
          .from('tax_events')
          .select()
          .eq('user_id', userId)              
          .gte('due_date', todayStr)          
          .order('due_date', ascending: true);

      setState(() {
        _events = (res as List).cast<Map<String, dynamic>>();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('세무 일정을 불러오지 못했어요: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('세무 일정'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _events.isEmpty
              ? _buildEmptyView()
              : _buildListView(),
    );
  }

  Widget _buildEmptyView() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(height: 20),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.event_busy,
                  size: 56,
                  color: isDark ? Colors.grey[600] : Colors.grey[400],
                ),
                const SizedBox(height: 16),
                const Text(
                  '예정된 일정이 없습니다.',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  '사업자 유형과 과세 유형을 설정하면\n'
                  '부가세 / 종소세 신고일을 자동으로 알려드려요.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          PrimaryButton(
            label: '세무 일정 설정하러 가기',
            onPressed: () async {
              final changed = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (_) => const TaxSetupPage(),
                ),
              );

              if (changed == true) {
                _loadEvents();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildListView() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      itemCount: _events.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final e = _events[index];
        final dueDate = DateTime.parse(e['due_date'].toString());
        final title = e['title'] as String? ?? '';
        final type = e['type'] as String? ?? '';
        final isPaid = e['is_paid'] as bool? ?? false;

        final dateStr = DateFormat('M월 d일 (E)', 'ko_KR').format(dueDate);
        final badge = _typeLabel(type);

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isPaid
                  ? Colors.green.withOpacity(0.6)
                  : Colors.grey.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dateStr,
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        if (badge != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: badge.color.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              badge.label,
                              style: TextStyle(
                                fontSize: 11,
                                color: badge.color,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        if (isPaid)
                          const Icon(
                            Icons.check_circle,
                            size: 16,
                            color: Colors.green,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  _Badge? _typeLabel(String type) {
    switch (type) {
      case 'vat':
        return _Badge('부가세', Colors.purple);
      case 'income':
        return _Badge('소득세/법인세', Colors.indigo);
      case 'local':
        return _Badge('지방세', Colors.teal);
      case 'car':
        return _Badge('자동차세', Colors.orange);
      case 'property':
        return _Badge('재산세', Colors.brown);
      case 'wht':
        return _Badge('원천세', Colors.blueGrey);
      case 'insure':
        return _Badge('4대보험', Colors.green);
      default:
        return null;
    }
  }
}

class _Badge {
  final String label;
  final Color color;
  _Badge(this.label, this.color);
}
