import 'package:flutter/services.dart';
import 'package:expense_pro/core/utils/app_logger.dart';
import 'card_auto_import_service.dart';

class NativeChannelService {
  static final NativeChannelService _instance = NativeChannelService._();
  factory NativeChannelService() => _instance;
  NativeChannelService._();

  static const _smsChannel = MethodChannel('com.example.expense_pro/sms');
  static const _notificationChannel =
      MethodChannel('com.example.expense_pro/notification_data');
  static const _controlChannel =
      MethodChannel('com.example.expense_pro/notification');

  final _autoImport = CardAutoImportService();
  bool _initialized = false;

  void init() {
    if (_initialized) return;
    _initialized = true;

    _smsChannel.setMethodCallHandler((call) async {
      if (call.method == 'onCardSms') {
        final args = Map<String, dynamic>.from(call.arguments as Map);
        final body = args['body'] as String? ?? '';
        final sender = args['sender'] as String?;
        appLogger.d('SMS 수신: $sender → $body');
        await _autoImport.processSmsText(body, sender: sender);
      }
    });

    _notificationChannel.setMethodCallHandler((call) async {
      if (call.method == 'onCardNotification') {
        final args = Map<String, dynamic>.from(call.arguments as Map);
        final title = args['title'] as String? ?? '';
        final body = args['body'] as String? ?? '';
        appLogger.d('카드 알림 수신: $title / $body');
        await _autoImport.processNotificationText(title, body);
      }
    });

    appLogger.d('NativeChannelService 초기화 완료');
  }

  Future<bool> isNotificationPermissionGranted() async {
    try {
      final result =
          await _controlChannel.invokeMethod<bool>('isNotificationPermissionGranted');
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<void> openNotificationSettings() async {
    try {
      await _controlChannel.invokeMethod('openNotificationSettings');
    } catch (e) {
      appLogger.e('알림 설정 열기 실패', error: e);
    }
  }
}
