import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:expense_pro/core/utils/app_logger.dart';

import '../../transactions/data/transaction_model.dart';
import '../../../core/config/country_tax_config.dart';

class ReceiptService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  static Future<TransactionModel?> analyzeReceipt(
    XFile imageFile, {
    required CountryTaxConfig config,
  }) async {
    try {
      
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      final response = await _supabase.functions.invoke(
        'receipt-ocr',
        body: {
          'imageBase64': base64Image,
        },
      );

      if (response.status != 200) {
        appLogger.w('receipt-ocr 실패: status=${response.status}, data=${response.data}');
        return null;
      }

      final dynamic rawData = response.data;
      final Map<String, dynamic>? jsonResult = switch (rawData) {
        
        String s => jsonDecode(s) as Map<String, dynamic>,
        Map<String, dynamic> m => m,
        Map m => Map<String, dynamic>.from(m),
        _ => null,
      };

      if (jsonResult == null) {
        appLogger.w('receipt-ocr: 예상치 못한 응답 형식: ${rawData.runtimeType}');
        return null;
      }

      appLogger.d('receipt-ocr 결과: $jsonResult');

      final String? rawDate = jsonResult['date']?.toString();
      final DateTime parsedDate =
          rawDate != null ? (DateTime.tryParse(rawDate) ?? DateTime.now()) : DateTime.now();

      // OCR returns the amount printed on the receipt (major units, may have
      // decimals). Store it as integer minor units to match manual entry.
      final dynamic amountRaw = jsonResult['amount'];
      double amountMajor = 0;
      if (amountRaw is num) {
        amountMajor = amountRaw.toDouble();
      } else if (amountRaw != null) {
        amountMajor = double.tryParse(amountRaw.toString()) ?? 0;
      }
      final int amount = config.toMinorUnits(amountMajor);

      final storeName = jsonResult['storeName']?.toString() ?? '상호명 미상';
      final category = jsonResult['category']?.toString() ?? '기타';
      final memo = jsonResult['memo']?.toString() ?? '';
      final type = jsonResult['type']?.toString() ?? 'expense';
      final isPaid =
          (jsonResult['isPaid'] is bool) ? jsonResult['isPaid'] as bool : true;

      return TransactionModel(
        id: const Uuid().v4(),
        userId: 'temp_user',           
        date: parsedDate,
        amount: amount,
        storeName: storeName,
        category: category,
        memo: memo,
        method: '카드',
        receiptUrl: null,              

        cashReceiptType: null,
        accountId: 'Receipt_OCR',
        transactionType: type,
        isPaid: isPaid,
      );
    } catch (e, stack) {
      appLogger.e('receipt-ocr 예외: $e', error: e, stackTrace: stack);
      return null;
    }
  }
}
