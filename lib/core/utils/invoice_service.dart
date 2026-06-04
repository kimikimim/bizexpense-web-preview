import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:expense_pro/core/utils/app_logger.dart';
import 'package:expense_pro/core/config/country_tax_config.dart';

class InvoiceService {
  Future<void> generateAndSharePdf({
    required String clientName,
    required List<Map<String, dynamic>> items,
    required int totalAmount,
    required CountryTaxConfig config,
  }) async {
    final pdf = pw.Document();

    // NanumGothic renders Korean + Latin. Arabic glyphs aren't included,
    // so non-KR invoices use English (the Gulf business standard).
    final fontData = await rootBundle.load("assets/fonts/NanumGothic.ttf");
    final ttf = pw.Font.ttf(fontData);
    final currencyFormat = NumberFormat('#,###');
    final isKorea = config.countryCode == 'KR';
    final symbol = config.currencySymbol;

    final L = _InvoiceLabels(isKorea, symbol);

    String myCompany = L.companyUnset;
    String myCeo = '';
    String myBizNum = '';
    String myAddress = '';
    String myCategory = '';

    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId != null) {
        final data = await Supabase.instance.client
            .from('profiles')
            .select()
            .eq('id', userId)
            .maybeSingle();

        if (data != null) {
          myCompany = data['company_name'] ?? L.companyUnset;
          myCeo = data['ceo_name'] ?? '';
          myBizNum = data['business_number'] ?? '';
          myAddress = data['address'] ?? '';
          myCategory = data['industry_category'] ?? '';
        } else {
          appLogger.w("Invoice: profile not found (userId: $userId), using defaults.");
        }
      }
    } catch (e) {
      appLogger.e("Error loading profile: $e", error: e);
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(L.title, style: pw.TextStyle(font: ttf, fontSize: 24, fontWeight: pw.FontWeight.bold)),
                  pw.Text("${L.date}${DateFormat('yyyy-MM-dd').format(DateTime.now())}", style: pw.TextStyle(font: ttf, fontSize: 12)),
                ],
              ),
              pw.SizedBox(height: 30),
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: pw.Container(
                      padding: const pw.EdgeInsets.all(10),
                      decoration: pw.BoxDecoration(border: pw.Border.all()),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(L.recipient(clientName), style: pw.TextStyle(font: ttf, fontSize: 14)),
                          pw.SizedBox(height: 5),
                          pw.Text(L.attn, style: pw.TextStyle(font: ttf, fontSize: 12)),
                          pw.SizedBox(height: 10),
                          pw.Text(L.intro, style: pw.TextStyle(font: ttf, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                  pw.SizedBox(width: 10),
                  pw.Expanded(
                    child: pw.Container(
                      padding: const pw.EdgeInsets.all(10),
                      decoration: pw.BoxDecoration(border: pw.Border.all()),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text("${L.supplier}$myCompany $myCeo", style: pw.TextStyle(font: ttf, fontSize: 14, fontWeight: pw.FontWeight.bold)),
                          pw.Text("${L.regNo}$myBizNum", style: pw.TextStyle(font: ttf, fontSize: 12)),
                          pw.Text("${L.address}$myAddress", style: pw.TextStyle(font: ttf, fontSize: 12)),
                          pw.Text("${L.activity}$myCategory", style: pw.TextStyle(font: ttf, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                context: context,
                border: pw.TableBorder.all(),
                headerStyle: pw.TextStyle(font: ttf, fontWeight: pw.FontWeight.bold),
                cellStyle: pw.TextStyle(font: ttf),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
                headers: L.tableHeaders,
                data: items.map((item) {
                  int price = item['price'];
                  int qty = item['qty'];
                  int supply = price * qty;
                  int tax = (supply * config.vatRate).round();
                  return [
                    item['name'],
                    qty.toString(),
                    currencyFormat.format(price),
                    currencyFormat.format(supply),
                    currencyFormat.format(tax),
                  ];
                }).toList(),
              ),
              pw.SizedBox(height: 20),
              pw.Container(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  L.total(currencyFormat.format(totalAmount)),
                  style: pw.TextStyle(font: ttf, fontSize: 18, fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.SizedBox(height: 50),
              pw.Divider(),
              pw.Center(
                child: pw.Text(L.validity, style: pw.TextStyle(font: ttf, fontSize: 10, color: PdfColors.grey)),
              ),
            ],
          );
        },
      ),
    );

    String safeClientName = clientName.replaceAll(RegExp(r'[\\/:*?"<>|]'), '');
    String fileName = '${L.filePrefix}${safeClientName}_${DateFormat('yyMMdd').format(DateTime.now())}.pdf';

    await Printing.sharePdf(bytes: await pdf.save(), filename: fileName);
  }
}

class _InvoiceLabels {
  final bool kr;
  final String symbol;
  const _InvoiceLabels(this.kr, this.symbol);

  String get title => kr ? '견 적 서 (QUOTATION)' : 'QUOTATION';
  String get date => kr ? '날짜: ' : 'Date: ';
  String recipient(String client) => kr ? '수신: $client 귀하' : 'To: $client';
  String get attn => kr ? '참조: 담당자님' : 'Attn: ';
  String get intro => kr ? '아래와 같이 견적합니다.' : 'We are pleased to quote as follows.';
  String get supplier => kr ? '공급자: ' : 'Supplier: ';
  String get regNo => kr ? '등록번호: ' : 'Tax Reg. No.: ';
  String get address => kr ? '주소: ' : 'Address: ';
  String get activity => kr ? '업태: ' : 'Activity: ';
  String get companyUnset => kr ? '상호명 미입력' : 'Company name not set';
  List<String> get tableHeaders => kr
      ? ['품명', '수량', '단가', '공급가액', '세액']
      : ['Item', 'Qty', 'Unit Price', 'Amount', 'VAT'];
  String total(String amount) =>
      kr ? '총 합계: ₩ $amount (VAT 포함)' : 'Total: $symbol $amount (incl. VAT)';
  String get validity =>
      kr ? '본 견적서는 14일간 유효합니다.' : 'This quotation is valid for 14 days.';
  String get filePrefix => kr ? '견적서_' : 'quote_';
}
