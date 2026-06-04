import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:expense_pro/l10n/app_localizations.dart';

class TaxService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ── Middle East: VAT (+ corporate tax) schedule generation ──
  String _fmtDate(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

  /// VAT return due date for a period ending in [periodEndMonth] of [year].
  /// UAE: 28th of the following month. KSA: last day of the following month.
  DateTime _vatDueDate(String countryCode, int year, int periodEndMonth) {
    if (countryCode == 'SA') {
      return DateTime(year, periodEndMonth + 2, 0); // last day of next month
    }
    return DateTime(year, periodEndMonth + 1, 28); // UAE default
  }

  Future<void> saveMeProfileAndGenerateEvents({
    required AppLocalizations l10n,
    required String localeName,
    required String countryCode,
    required bool vatRegistered,
    required String filingFrequency, // 'monthly' | 'quarterly'
    required bool corporate,
    String? vatNumber,
    bool hasEmployees = false,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    await _supabase.from('tax_profiles').upsert({
      'user_id': userId,
      'vat_registered': vatRegistered,
      'filing_frequency': filingFrequency,
      'vat_registration_number': vatNumber,
      'has_employees': hasEmployees,
    });

    await _supabase.from('tax_events').delete().eq('user_id', userId);

    final events = <Map<String, dynamic>>[];
    final currentYear = DateTime.now().year;

    for (int i = 0; i < 3; i++) {
      final year = currentYear + i;

      if (vatRegistered) {
        if (filingFrequency == 'monthly') {
          for (int m = 1; m <= 12; m++) {
            final due = _vatDueDate(countryCode, year, m);
            final period = DateFormat.yMMM(localeName).format(DateTime(year, m));
            events.add(_createEvent(userId, l10n.taxEventVat(period), 'vat', _fmtDate(due)));
          }
        } else {
          const quarterEndMonths = [3, 6, 9, 12];
          for (int q = 0; q < 4; q++) {
            final due = _vatDueDate(countryCode, year, quarterEndMonths[q]);
            final period = l10n.meTaxQuarterLabel('${q + 1}', '$year');
            events.add(_createEvent(userId, l10n.taxEventVat(period), 'vat', _fmtDate(due)));
          }
        }
      }

      if (corporate) {
        // UAE Corporate Tax: due 9 months after a Dec-31 financial year end.
        final due = DateTime(year + 1, 9, 30);
        events.add(_createEvent(userId, l10n.taxEventCorporate('$year'), 'corporate', _fmtDate(due)));
      }
    }

    if (events.isNotEmpty) {
      await _supabase.from('tax_events').insert(events);
    }
  }

  Future<void> saveProfileAndGenerateEvents({
    required String businessType,
    required String vatType,
    required bool hasEmployees,
    required bool hasVehicle,
    required bool hasProperty,
    required bool hasLicense,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    await _supabase.from('tax_profiles').upsert({
      'user_id': userId,
      'business_type': businessType,
      'vat_type': vatType,
      'has_employees': hasEmployees,
      'has_vehicle': hasVehicle,
      'has_property': hasProperty,
      'has_license': hasLicense,
      
    });

    await _supabase.from('tax_events').delete().eq('user_id', userId);

    final List<Map<String, dynamic>> newEvents = [];
    final int currentYear = DateTime.now().year;

    for (int i = 0; i < 3; i++) {
      final int year = currentYear + i;

      if (vatType == 'general') {
        
        newEvents.add(_createEvent(userId, '1기 부가세 예정고지 납부', 'vat', '$year-04-25'));
        newEvents.add(_createEvent(userId, '1기 부가세 확정신고', 'vat', '$year-07-25'));
        newEvents.add(_createEvent(userId, '2기 부가세 예정고지 납부', 'vat', '$year-10-25'));
        newEvents.add(
          _createEvent(userId, '2기 부가세 확정신고', 'vat', '${year + 1}-01-25'),
        );
      } else if (vatType == 'simplified') {
        
        newEvents.add(
          _createEvent(userId, '부가세 확정신고 (간이)', 'vat', '${year + 1}-01-25'),
        );
        newEvents.add(
          _createEvent(userId, '1기 예정신고 (간이·세금계산서 발급 사업자)', 'vat', '$year-07-25'),
        );
      }

      if (businessType == 'individual') {
        newEvents.add(
          _createEvent(userId, '종합소득세 신고', 'income', '$year-05-31'),
        );
      } else {
        newEvents.add(
          _createEvent(userId, '법인세 신고', 'income', '$year-03-31'),
        );
        newEvents.add(
          _createEvent(userId, '법인세 중간예납', 'income', '$year-08-31'),
        );
      }

      if (hasLicense) {
        newEvents.add(
          _createEvent(userId, '등록면허세(면허분) 납부', 'local', '$year-01-31'),
        );
      }

      if (hasVehicle) {
        newEvents.add(
          _createEvent(userId, '1기 자동차세 납부', 'car', '$year-06-30'),
        );
        newEvents.add(
          _createEvent(userId, '2기 자동차세 납부', 'car', '$year-12-31'),
        );
      }

      if (hasProperty) {
        newEvents.add(
          _createEvent(userId, '주민세(사업소분) 신고납부', 'local', '$year-08-31'),
        );
        newEvents.add(
          _createEvent(userId, '재산세(건물분) 납부', 'property', '$year-07-31'),
        );
        newEvents.add(
          _createEvent(userId, '재산세(토지분) 납부', 'property', '$year-09-30'),
        );
      }

      if (hasEmployees) {
        for (int month = 1; month <= 12; month++) {
          
          final DateTime nextMonth10 = DateTime(year, month + 1, 10);
          final String dueDateStr =
              DateFormat('yyyy-MM-dd').format(nextMonth10);

          newEvents.add(
            _createEvent(userId, '$month월분 원천세 납부', 'wht', dueDateStr),
          );
          newEvents.add(
            _createEvent(userId, '$month월분 4대보험 납부', 'insure', dueDateStr),
          );
        }
      }
    }

    if (newEvents.isNotEmpty) {
      await _supabase.from('tax_events').insert(newEvents);
    }
  }

  Future<Map<String, dynamic>?> loadProfile() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return null;
      final data = await _supabase
          .from('tax_profiles')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      return data;
    } catch (e) {
      
      return null;
    }
  }

  Future<Map<String, dynamic>?> getNextUpcomingEvent() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return null;
      final String today =
          DateFormat('yyyy-MM-dd').format(DateTime.now());

      final List<dynamic> rows = await _supabase
          .from('tax_events')
          .select()
          .eq('user_id', userId)
          .gte('due_date', today) 
          .order('due_date', ascending: true)
          .limit(1);

      if (rows.isEmpty) {
        return null;
      }
      return rows.first as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  Map<String, dynamic> _createEvent(
    String uid,
    String title,
    String type,
    String date,
  ) {
    return {
      'user_id': uid,
      'title': title,
      'type': type,
      'due_date': date,
      'amount': 0,
      'is_paid': false,
    };
  }
}
