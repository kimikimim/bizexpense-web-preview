import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:expense_pro/core/utils/app_logger.dart';
import 'package:expense_pro/features/transactions/data/transaction_model.dart';
import 'package:expense_pro/features/transactions/data/transaction_repository.dart';
import 'sms_parser_service.dart';

enum CardCsvFormat {
  samsung,    
  kb,         
  shinhan,    
  hyundai,    
  lotte,      
  woori,      
  hana,       
  nh,         
  auto,       
}

class CsvImportResult {
  final int imported;
  final int skipped;
  final int failed;
  final List<String> errors;

  const CsvImportResult({
    required this.imported,
    required this.skipped,
    required this.failed,
    required this.errors,
  });
}

class CsvImportService {
  final _repo = TransactionRepository();

  Future<CsvImportResult?> pickAndImport({
    CardCsvFormat format = CardCsvFormat.auto,
  }) async {
    
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv', 'xls', 'xlsx', 'txt'],
    );

    if (result == null || result.files.isEmpty) return null;

    final file = result.files.first;
    String content;
    if (kIsWeb) {
      final bytes = file.bytes;
      if (bytes == null) return null;
      content = utf8.decode(bytes);
    } else {
      final path = file.path;
      if (path == null) return null;
      content = await File(path).readAsString();
    }

    final detectedFormat = format == CardCsvFormat.auto
        ? _detectFormat(content)
        : format;

    return _parseAndSave(content, detectedFormat);
  }

  CardCsvFormat _detectFormat(String content) {
    if (content.contains('삼성카드') || content.contains('SAMSUNG')) return CardCsvFormat.samsung;
    if (content.contains('국민카드') || content.contains('KB')) return CardCsvFormat.kb;
    if (content.contains('신한') || content.contains('SHINHAN')) return CardCsvFormat.shinhan;
    if (content.contains('현대카드') || content.contains('HYUNDAI')) return CardCsvFormat.hyundai;
    if (content.contains('롯데카드') || content.contains('LOTTE')) return CardCsvFormat.lotte;
    if (content.contains('우리카드') || content.contains('WOORI')) return CardCsvFormat.woori;
    if (content.contains('하나카드') || content.contains('HANA')) return CardCsvFormat.hana;
    if (content.contains('농협') || content.contains('NH')) return CardCsvFormat.nh;
    return CardCsvFormat.auto;
  }

  Future<CsvImportResult> _parseAndSave(String content, CardCsvFormat format) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      return const CsvImportResult(imported: 0, skipped: 0, failed: 1, errors: ['로그인이 필요합니다.']);
    }

    final lines = content.split('\n').where((l) => l.trim().isNotEmpty).toList();
    int imported = 0, skipped = 0, failed = 0;
    final errors = <String>[];

    for (int i = 1; i < lines.length; i++) { 
      try {
        final tx = _parseLine(lines[i], format, userId);
        if (tx == null) { skipped++; continue; }

        final saved = await _repo.addTransaction(tx);
        if (saved) imported++; else failed++;
      } catch (e) {
        failed++;
        errors.add('Line ${i + 1}: $e');
        appLogger.e('CSV 파싱 오류 line ${i + 1}', error: e);
      }
    }

    return CsvImportResult(imported: imported, skipped: skipped, failed: failed, errors: errors);
  }

  TransactionModel? _parseLine(String line, CardCsvFormat format, String userId) {
    final cols = _splitCsv(line);
    if (cols.isEmpty) return null;

    String? dateStr, storeName, amountStr, cardName;

    switch (format) {
      case CardCsvFormat.samsung:
        
        if (cols.length < 3) return null;
        dateStr = cols[0].trim();
        storeName = cols[1].trim();
        amountStr = cols[2].replaceAll(RegExp(r'[^0-9]'), '');
        cardName = '삼성카드';
        break;
      case CardCsvFormat.kb:
        
        if (cols.length < 3) return null;
        dateStr = cols[0].trim();
        storeName = cols[1].trim();
        amountStr = cols[2].replaceAll(RegExp(r'[^0-9]'), '');
        cardName = 'KB국민카드';
        break;
      case CardCsvFormat.shinhan:
        if (cols.length < 3) return null;
        dateStr = cols[0].trim();
        storeName = cols[1].trim();
        amountStr = cols[2].replaceAll(RegExp(r'[^0-9]'), '');
        cardName = '신한카드';
        break;
      default:
        
        if (cols.length < 3) return null;
        dateStr = cols[0].trim();
        storeName = cols[1].trim();
        amountStr = cols[2].replaceAll(RegExp(r'[^0-9]'), '');
        cardName = '카드';
    }

    final amount = int.tryParse(amountStr ?? '') ?? 0;
    if (amount <= 0 || storeName == null || storeName.isEmpty) return null;

    final date = _parseDate(dateStr ?? '') ?? DateTime.now();

    return TransactionModel(
      id: '',
      userId: userId,
      date: date,
      amount: amount,
      storeName: storeName,
      transactionType: 'expense',
      accountId: 'CSV_IMPORT',
      isPaid: true,
      category: SmsParserService.guessCategory(storeName),
      method: cardName ?? '카드',
      isTaxDeductible: true,
      memo: 'CSV 가져오기',
    );
  }

  DateTime? _parseDate(String raw) {
    
    final cleaned = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleaned.length == 8) {
      return DateTime.tryParse(
          '${cleaned.substring(0, 4)}-${cleaned.substring(4, 6)}-${cleaned.substring(6, 8)}');
    }
    if (cleaned.length == 6) {
      
      return DateTime.tryParse(
          '20${cleaned.substring(0, 2)}-${cleaned.substring(2, 4)}-${cleaned.substring(4, 6)}');
    }
    return DateTime.tryParse(raw);
  }

  List<String> _splitCsv(String line) {
    final result = <String>[];
    bool inQuotes = false;
    final current = StringBuffer();

    for (int i = 0; i < line.length; i++) {
      final char = line[i];
      if (char == '"') {
        inQuotes = !inQuotes;
      } else if ((char == ',' || char == '\t') && !inQuotes) {
        result.add(current.toString());
        current.clear();
      } else {
        current.write(char);
      }
    }
    result.add(current.toString());
    return result;
  }
}
