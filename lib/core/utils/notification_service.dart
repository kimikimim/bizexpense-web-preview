import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:intl/intl.dart';

class NotificationService {
  static final _notifications = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    
    await _notifications.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );
  }

  static Future<void> scheduleTaxNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    
    final scheduledTime = DateTime(
      scheduledDate.year, 
      scheduledDate.month, 
      scheduledDate.day, 
      9, 0, 0
    );
    
    if (scheduledTime.isBefore(DateTime.now())) return;

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'tax_channel', '세금 알림',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  static Future<void> scheduleReceiptReminder({
    required int id,
    required int daysAgo,
    required int count,
  }) async {
    await _notifications.zonedSchedule(
      id,
      "영수증 등록 알림",
      "$daysAgo일 전 거래 $count건에 영수증이 없어요. 빠르게 등록해주세요!",
      tz.TZDateTime.from(
        DateTime.now().add(const Duration(days: 1)).copyWith(hour: 20, minute: 0),
        tz.local,
      ),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'receipt_channel', '영수증 알림',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  static Future<void> scheduleMonthlyExpenseReminder({
    required int id,
  }) async {
    final now = DateTime.now();
    final nextMonth = DateTime(now.year, now.month + 1, 1, 9, 0);
    
    await _notifications.zonedSchedule(
      id,
      "정기 경비 입력",
      "이번 달 정기 경비를 확인하고 입력해주세요!",
      tz.TZDateTime.from(nextMonth, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'expense_channel', '경비 알림',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  static Future<void> scheduleBudgetExceededNotification({
    required int id,
    required String category,
    required int budget,
    required int spent,
  }) async {
    await _notifications.zonedSchedule(
      id,
      "예산 초과 알림",
      "$category 카테고리의 예산(${NumberFormat.currency(locale: 'ko_KR', symbol: '₩').format(budget)})을 초과했습니다. 현재 지출: ${NumberFormat.currency(locale: 'ko_KR', symbol: '₩').format(spent)}",
      tz.TZDateTime.from(
        DateTime.now().add(const Duration(hours: 1)),
        tz.local,
      ),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'budget_channel', '예산 알림',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  static Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }
}
