import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';

import '../../features/transactions/data/transaction_model.dart';
import '../config/country_tax_config.dart';

class ExcelService {
  Future<void> exportToExcel(
    List<TransactionModel> transactions, {
    required CountryTaxConfig config,
  }) async {
    final kr = config.countryCode == 'KR';
    final excel = Excel.createExcel();
    final sheetName = kr ? '거래내역' : 'Transactions';
    excel.rename('Sheet1', sheetName);
    final sheet = excel[sheetName];

    final headers = kr
        ? ['구분', '날짜', '상호명', '금액', '카테고리', '결제수단', '승인번호', '부가세공제', '메모', '영수증']
        : ['Type', 'Date', 'Name', 'Amount', 'Category', 'Method', 'Approval No.', 'VAT Deductible', 'Memo', 'Receipt'];
    sheet.appendRow(headers.map((e) => TextCellValue(e)).toList());

    final dateFormat = DateFormat('yyyy-MM-dd');
    final incomeLabel = kr ? '수입' : 'Income';
    final expenseLabel = kr ? '지출' : 'Expense';

    for (final tx in transactions) {
      final row = <CellValue>[
        TextCellValue(tx.transactionType == 'income' ? incomeLabel : expenseLabel),
        TextCellValue(dateFormat.format(tx.date)),
        TextCellValue(tx.storeName),
        IntCellValue(tx.amount),
        TextCellValue(tx.category ?? ''),
        TextCellValue(tx.method),
        TextCellValue(tx.approvalNumber ?? ''),
        TextCellValue(tx.isTaxDeductible ? 'O' : 'X'),
        TextCellValue(tx.memo ?? ''),
        TextCellValue(tx.receiptUrl != null && tx.receiptUrl!.isNotEmpty ? 'O' : 'X'),
      ];
      sheet.appendRow(row);
    }

    final totalIncome = transactions
        .where((t) => t.transactionType == 'income')
        .fold<int>(0, (sum, t) => sum + t.amount);
    final totalExpense = transactions
        .where((t) => t.transactionType == 'expense')
        .fold<int>(0, (sum, t) => sum + t.amount);
    final profit = totalIncome - totalExpense;

    sheet.appendRow(List<CellValue>.generate(headers.length, (_) => TextCellValue('')));
    sheet.appendRow(List<CellValue>.generate(
      headers.length,
      (i) => i == 0 ? TextCellValue(kr ? '합계' : 'Total') : TextCellValue(''),
    ));

    sheet.appendRow(_buildSummaryRow(label: kr ? '수입 합계' : 'Total Income', amount: totalIncome, headersLength: headers.length));
    sheet.appendRow(_buildSummaryRow(label: kr ? '지출 합계' : 'Total Expense', amount: totalExpense, headersLength: headers.length));
    sheet.appendRow(_buildSummaryRow(label: kr ? '순이익' : 'Net Profit', amount: profit, headersLength: headers.length));

    final fileBytes = excel.encode();
    if (fileBytes == null) return;

    final filePrefix = kr ? '거래내역' : 'transactions';
    final fileName = '${filePrefix}_${DateFormat('yyMMdd_HHmm').format(DateTime.now())}.xlsx';

    final xFile = XFile.fromData(
      Uint8List.fromList(fileBytes),
      mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      name: fileName,
    );

    await Share.shareXFiles(
      [xFile],
      text: kr ? '거래 내역 엑셀 파일입니다.' : 'Transaction Excel file.',
    );
  }

  List<CellValue> _buildSummaryRow({
    required String label,
    required int amount,
    required int headersLength,
  }) {
    final row = <CellValue>[];
    for (int i = 0; i < headersLength; i++) {
      if (i == 0) {
        row.add(TextCellValue(label));
      } else if (i == 3) {
        row.add(IntCellValue(amount));
      } else {
        row.add(TextCellValue(''));
      }
    }
    return row;
  }

  Future<void> exportForAccounting(
    List<TransactionModel> transactions, {
    required CountryTaxConfig config,
  }) async {
    final kr = config.countryCode == 'KR';
    final excel = Excel.createExcel();
    final sheetName = kr ? '세무정산자료' : 'Tax Settlement';
    excel.rename('Sheet1', sheetName);
    final sheet = excel[sheetName];

    final headers = kr
        ? ['거래일자', '공급가액', '부가세액', '합계금액', '거래처명', '카테고리', '결제수단', '승인번호', '비고']
        : ['Date', 'Supply Amount', 'VAT', 'Total', 'Client', 'Category', 'Method', 'Approval No.', 'Note'];
    sheet.appendRow(headers.map((e) => TextCellValue(e)).toList());

    final dateFormat = DateFormat('yyyyMMdd');
    final vatDivisor = 1 + config.vatRate;

    final expenses = transactions.where(
      (t) => t.transactionType == 'expense' && t.isTaxDeductible,
    );

    for (final tx in expenses) {
      final int supplyAmount;
      final int taxAmount;
      if (tx.isVatExempt == true) {
        supplyAmount = tx.amount;
        taxAmount = 0;
      } else {
        supplyAmount = (tx.amount / vatDivisor).round();
        taxAmount = tx.amount - supplyAmount;
      }

      final row = <CellValue>[
        TextCellValue(dateFormat.format(tx.date)),
        IntCellValue(supplyAmount),
        IntCellValue(taxAmount),
        IntCellValue(tx.amount),
        TextCellValue(tx.storeName),
        TextCellValue(tx.category ?? ''),
        TextCellValue(tx.method),
        TextCellValue(tx.approvalNumber ?? ''),
        TextCellValue(tx.memo ?? ''),
      ];
      sheet.appendRow(row);
    }

    final fileBytes = excel.encode();
    if (fileBytes == null) return;

    final filePrefix = kr ? '세무정산자료' : 'tax_settlement';
    final fileName = '${filePrefix}_${DateFormat('yyyyMMdd').format(DateTime.now())}.xlsx';

    final xFile = XFile.fromData(
      Uint8List.fromList(fileBytes),
      mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      name: fileName,
    );

    await Share.shareXFiles(
      [xFile],
      text: kr ? '세무 정산용 엑셀 파일입니다.' : 'Tax settlement Excel file.',
    );
  }
}
