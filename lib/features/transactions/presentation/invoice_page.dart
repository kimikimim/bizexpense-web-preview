import 'package:flutter/material.dart';
import '../../../core/utils/invoice_service.dart';
import '../../../core/widgets/primary_button.dart';
import 'package:expense_pro/core/utils/app_logger.dart';

class InvoiceItemInput {
  final TextEditingController name;
  final TextEditingController price;
  final TextEditingController qty;

  InvoiceItemInput()
      : name = TextEditingController(),
        price = TextEditingController(),
        qty = TextEditingController(text: '1'); 

  void dispose() {
    name.dispose();
    price.dispose();
    qty.dispose();
  }
}

class InvoicePage extends StatefulWidget {
  const InvoicePage({super.key});

  @override
  State<InvoicePage> createState() => _InvoicePageState();
}

class _InvoicePageState extends State<InvoicePage> {
  final _clientController = TextEditingController();
  final List<InvoiceItemInput> _items = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _addItem(); 
  }

  @override
  void dispose() {
    _clientController.dispose();
    for (var item in _items) {
      item.dispose();
    }
    super.dispose();
  }

  void _addItem() {
    setState(() {
      _items.add(InvoiceItemInput());
    });
  }

  void _removeItem(int index) {
    if (_items.length > 1) {
      setState(() {
        _items[index].dispose();
        _items.removeAt(index);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("최소 1개의 품목은 있어야 합니다.")),
      );
    }
  }

  Future<void> _sendInvoice() async {
    if (_clientController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("거래처명을 입력해주세요.")));
      return;
    }

    List<Map<String, dynamic>> itemsData = [];
    int totalAmount = 0;

    for (var item in _items) {
      if (item.name.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("품목명을 모두 입력해주세요.")));
        return;
      }

      int price = int.tryParse(item.price.text.replaceAll(',', '')) ?? 0;
      int qty = int.tryParse(item.qty.text) ?? 1;
      int lineTotal = (price * qty * 1.1).round();
      totalAmount += lineTotal;

      itemsData.add({
        'name': item.name.text,
        'price': price,
        'qty': qty,
      });
    }

    setState(() => _isLoading = true);

    try {
      await InvoiceService().generateAndSharePdf(
        clientName: _clientController.text,
        items: itemsData,
        totalAmount: totalAmount,
      );
    } catch (e) {
      appLogger.e("견적서 에러: $e", error: e);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("PDF 생성 실패")));
    }

    setState(() => _isLoading = false);
  }

  Widget _buildSectionTitle(String title, {Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 24, 4, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Theme.of(context).hintColor)),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _buildInputCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("3초 견적서 보내기"),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            _buildSectionTitle("받는 분 (거래처)"),
            _buildInputCard(
              child: TextField(
                controller: _clientController,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: "예: (주)한국상사",
                  icon: Icon(Icons.business_outlined),
                  labelText: "거래처명",
                ),
              ),
            ),

            _buildSectionTitle(
              "품목 내용",
              trailing: TextButton.icon(
                onPressed: _addItem,
                icon: const Icon(Icons.add_circle_outline, size: 18),
                label: const Text("항목 추가"),
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  foregroundColor: Colors.indigoAccent,
                ),
              ),
            ),

            ..._items.asMap().entries.map((entry) {
              int index = entry.key;
              InvoiceItemInput item = entry.value;
              
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Theme.of(context).dividerColor),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: item.name,
                            decoration: InputDecoration(
                              labelText: "품목명 ${index + 1}",
                              hintText: "예: 디자인 개발",
                              isDense: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Theme.of(context).dividerColor),
                              ),
                            ),
                          ),
                        ),
                        if (_items.length > 1)
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: IconButton(
                              icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                              onPressed: () => _removeItem(index),
                              tooltip: "삭제",
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: item.price,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: "단가",
                              suffixText: "원",
                              isDense: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Theme.of(context).dividerColor),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 1,
                          child: TextField(
                            controller: item.qty,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              labelText: "수량",
                              isDense: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Theme.of(context).dividerColor),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
            
            const SizedBox(height: 30),

            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[800] : Colors.yellow[50],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isDark ? Colors.grey : Colors.amber.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lightbulb_outline, size: 16, color: isDark ? Colors.grey : Colors.amber[800]),
                    const SizedBox(width: 6),
                    Text(
                      "팩스로 보내려면? 공유창에서 [모바일 팩스] 앱 선택",
                      style: TextStyle(color: isDark ? Colors.grey : Colors.brown, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            Center(
              child: SizedBox(
                width: 260, 
                child: PrimaryButton(
                  label: _isLoading ? "  생성 중..." : "PDF 공유 / 팩스 전송",
                  icon: _isLoading ? null : Icons.send_rounded,
                  isLoading: _isLoading,
                  onPressed: _sendInvoice,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
