import 'dart:async';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:expense_pro/core/utils/app_logger.dart';
import 'package:expense_pro/features/transactions/data/transaction_repository.dart';
import 'sms_parser_service.dart';

class CardAutoImportService {
  static final CardAutoImportService _instance = CardAutoImportService._();
  factory CardAutoImportService() => _instance;
  CardAutoImportService._();

  final _repo = TransactionRepository();
  bool _isListening = false;

  Future<bool> requestSmsPermission() async {
    final status = await Permission.sms.request();
    return status.isGranted;
  }

  Future<bool> get hasSmsPermission async => await Permission.sms.isGranted;

  Future<void> openNotificationSettings() async {
    
    await openAppSettings();
  }

  Future<bool> processSmsText(String messageBody, {String? sender}) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return false;

    final parsed = SmsParserService.parse(messageBody, sender: sender);
    if (parsed == null) return false;

    try {
      final tx = parsed.toTransactionModel(userId: userId);
      final saved = await _repo.addTransaction(tx);
      if (saved) {
        appLogger.d('SMS 자동 등록: ${parsed.storeName} ${parsed.amount}원');
      }
      return saved;
    } catch (e) {
      appLogger.e('SMS 거래 저장 실패', error: e);
      return false;
    }
  }

  Future<bool> processNotificationText(String title, String body) async {
    final combined = '$title $body';
    return processSmsText(combined);
  }

  bool get isListening => _isListening;

  void setListening(bool value) {
    _isListening = value;
  }
}
