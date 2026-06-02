import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart'; 
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:expense_pro/core/utils/app_logger.dart';

class InvoiceService {
  Future<void> generateAndSharePdf({
    required String clientName,
    required List<Map<String, dynamic>> items,
    required int totalAmount,
  }) async {
    final pdf = pw.Document();
    
    final fontData = await rootBundle.load("assets/fonts/NanumGothic.ttf");
    final ttf = pw.Font.ttf(fontData);
    final currencyFormat = NumberFormat('#,###');

    String myCompany = '상호명 미입력';
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
          myCompany = data['company_name'] ?? '상호명 미입력';
          myCeo = data['ceo_name'] ?? '';
          myBizNum = data['business_number'] ?? '';
          myAddress = data['address'] ?? '';
          myCategory = data['industry_category'] ?? '';
        } else {
          
          appLogger.w("Warning: 프로필 데이터를 찾을 수 없습니다 (userId: $userId). 견적서에 기본값이 사용됩니다.");
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
                  pw.Text("견 적 서 (QUOTATION)", style: pw.TextStyle(font: ttf, fontSize: 24, fontWeight: pw.FontWeight.bold)),
                  pw.Text("날짜: ${DateFormat('yyyy-MM-dd').format(DateTime.now())}", style: pw.TextStyle(font: ttf, fontSize: 12)),
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
                          pw.Text("수신: $clientName 귀하", style: pw.TextStyle(font: ttf, fontSize: 14)),
                          pw.SizedBox(height: 5),
                          pw.Text("참조: 담당자님", style: pw.TextStyle(font: ttf, fontSize: 12)),
                          pw.SizedBox(height: 10),
                          pw.Text("아래와 같이 견적합니다.", style: pw.TextStyle(font: ttf, fontSize: 12)),
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
                          pw.Text("공급자: $myCompany $myCeo", style: pw.TextStyle(font: ttf, fontSize: 14, fontWeight: pw.FontWeight.bold)),
                          pw.Text("등록번호: $myBizNum", style: pw.TextStyle(font: ttf, fontSize: 12)),
                          pw.Text("주소: $myAddress", style: pw.TextStyle(font: ttf, fontSize: 12)),
                          pw.Text("업태: $myCategory", style: pw.TextStyle(font: ttf, fontSize: 12)),
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
                headers: ['품명', '수량', '단가', '공급가액', '세액'],
                data: items.map((item) {
                  int price = item['price'];
                  int qty = item['qty'];
                  int supply = price * qty;
                  int tax = (supply * 0.1).round();
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
                  "총 합계: ₩ ${currencyFormat.format(totalAmount)} (VAT 포함)",
                  style: pw.TextStyle(font: ttf, fontSize: 18, fontWeight: pw.FontWeight.bold),
                ),
              ),
              
              pw.SizedBox(height: 50),
              pw.Divider(),
              pw.Center(
                child: pw.Text("본 견적서는 14일간 유효합니다.", style: pw.TextStyle(font: ttf, fontSize: 10, color: PdfColors.grey)),
              ),
            ],
          );
        },
      ),
    );

    String safeClientName = clientName.replaceAll(RegExp(r'[\\/:*?"<>|]'), ''); 
    String fileName = '견적서_${safeClientName}_${DateFormat('yyMMdd').format(DateTime.now())}.pdf';

    await Printing.sharePdf(
      bytes: await pdf.save(), 
      filename: fileName 
    );
  }
}
