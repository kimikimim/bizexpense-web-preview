import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:expense_pro/l10n/app_localizations.dart';

import '../../../core/widgets/primary_button.dart';
import '../../../core/providers/country_config_provider.dart';
import 'tax_setup_page.dart';
import 'me_tax_setup_page.dart';

class TaxCalendarPage extends ConsumerStatefulWidget {
  const TaxCalendarPage({super.key});

  @override
  ConsumerState<TaxCalendarPage> createState() => _TaxCalendarPageState();
}

class _TaxCalendarPageState extends ConsumerState<TaxCalendarPage> {
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
        SnackBar(content: Text('${AppLocalizations.of(context)!.taxCalLoadError}: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.taxEventDefaultTitle),
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
    final l10n = AppLocalizations.of(context)!;
    final isKorea = ref.read(countryConfigProvider).countryCode == 'KR';

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
                Text(
                  l10n.taxCalEmptyTitle,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.taxCalEmptySub,
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
            label: l10n.taxCalSetupButton,
            onPressed: () async {
              final changed = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (_) => isKorea
                      ? const TaxSetupPage()
                      : const MeTaxSetupPage(),
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

        final localeName = Localizations.localeOf(context).toString();
        final dateStr = DateFormat.MMMMEEEEd(localeName).format(dueDate);
        final badge = _typeLabel(type, AppLocalizations.of(context)!);

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

  _Badge? _typeLabel(String type, AppLocalizations l10n) {
    switch (type) {
      case 'vat':
        return _Badge(l10n.taxBadgeVat, Colors.purple);
      case 'income':
        return _Badge(l10n.taxBadgeIncome, Colors.indigo);
      case 'corporate':
        return _Badge(l10n.taxBadgeCorporate, Colors.indigo);
      case 'local':
        return _Badge(l10n.taxBadgeLocal, Colors.teal);
      case 'car':
        return _Badge(l10n.taxBadgeCar, Colors.orange);
      case 'property':
        return _Badge(l10n.taxBadgeProperty, Colors.brown);
      case 'wht':
        return _Badge(l10n.taxBadgeWht, Colors.blueGrey);
      case 'insure':
        return _Badge(l10n.taxBadgeInsure, Colors.green);
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
