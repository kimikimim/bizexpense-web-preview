import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../tax/services/tax_service.dart';
import '../../tax/presentation/tax_calendar_page.dart';

class UpcomingTaxBanner extends StatefulWidget {
  const UpcomingTaxBanner({super.key});

  @override
  State<UpcomingTaxBanner> createState() => _UpcomingTaxBannerState();
}

class _UpcomingTaxBannerState extends State<UpcomingTaxBanner> {
  final TaxService _taxService = TaxService();

  Map<String, dynamic>? _event; 
  bool _isLoading = true;
  bool _hasError = false;

  static const double _bannerRadius = 18.0;
  static const double _bannerHeight = 82.0; 

  @override
  void initState() {
    super.initState();
    _loadNextEvent();
  }

  Future<void> _loadNextEvent() async {
    try {
      final next = await _taxService.getNextUpcomingEvent();
      if (!mounted) return;
      setState(() {
        _event = next;
        _isLoading = false;
        _hasError = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const SizedBox.shrink();
    if (_hasError || _event == null) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dueDate = DateTime.parse(_event!['due_date'] as String);
    final now = DateTime.now();
    final diff =
        dueDate.difference(DateTime(now.year, now.month, now.day)).inDays;

    String ddayLabel;
    if (diff == 0) {
      ddayLabel = 'D-day';
    } else if (diff > 0) {
      ddayLabel = 'D-$diff';
    } else {
      ddayLabel = 'D+${diff.abs()}';
    }

    final title = _event!['title'] as String? ?? '세무 일정';
    final dateLabel = DateFormat('M월 d일 (E)', 'ko_KR').format(dueDate);

    final Color cardColor =
        isDark ? const Color(0xFF30343A) : const Color(0xFFF3F4F6);
    final Color borderColor = isDark
        ? Colors.orange.withOpacity(0.4)
        : Colors.orange.withOpacity(0.35);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
      child: SizedBox(
        height: _bannerHeight, 
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const TaxCalendarPage(),
              ),
            );
          },
          borderRadius: BorderRadius.circular(_bannerRadius),
          child: Container(
            height: double.infinity, 
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(_bannerRadius),
              border: Border.all(color: borderColor, width: 1),
            ),
            child: Row(
              children: [
                
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: Colors.orange.withOpacity(isDark ? 0.22 : 0.18),
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.orange,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center, 
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dateLabel,
                        style: TextStyle(
                          fontSize: 13,
                          color:
                              isDark ? Colors.grey[400] : Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    ddayLabel,
                    style: TextStyle(
                      color:
                          isDark ? Colors.orange[200] : Colors.orange[800],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
