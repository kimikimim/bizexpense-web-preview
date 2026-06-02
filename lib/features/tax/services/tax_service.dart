import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class TaxService {
  final SupabaseClient _supabase = Supabase.instance.client;

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
