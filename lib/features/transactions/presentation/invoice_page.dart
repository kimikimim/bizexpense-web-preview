import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_pro/l10n/app_localizations.dart';
import '../../../core/utils/invoice_service.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/providers/country_config_provider.dart';
import '../data/vat_invoice_repository.dart';
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

class InvoicePage extends ConsumerStatefulWidget {
  const InvoicePage({super.key});

  @override
  ConsumerState<InvoicePage> createState() => _InvoicePageState();
}

class _InvoicePageState extends ConsumerState<InvoicePage> {
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
        SnackBar(content: Text(AppLocalizations.of(context)!.invoiceMinItem)),
      );
    }
  }

  Future<void> _sendInvoice() async {
    final l10n = AppLocalizations.of(context)!;
    final config = ref.read(countryConfigProvider);
    if (_clientController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.invoiceClientRequired)));
      return;
    }

    List<Map<String, dynamic>> itemsData = [];
    num subtotal = 0;

    for (var item in _items) {
      if (item.name.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.invoiceItemNamesRequired)));
        return;
      }

      // Invoice prices are entered directly in major units (decimals allowed for ME).
      num price = num.tryParse(item.price.text.replaceAll(',', '')) ?? 0;
      int qty = int.tryParse(item.qty.text) ?? 1;
      subtotal += price * qty;

      itemsData.add({
        'name': item.name.text,
        'price': price,
        'qty': qty,
      });
    }

    final num vatAmount = subtotal * config.vatRate;
    final num totalAmount = subtotal + vatAmount;

    setState(() => _isLoading = true);

    try {
      await InvoiceService().generateAndSharePdf(
        clientName: _clientController.text,
        items: itemsData,
        totalAmount: totalAmount,
        config: config,
      );

      // ME: record the issued invoice in the VAT ledger (ZATCA foundation).
      if (config.countryCode != 'KR') {
        await VatInvoiceRepository().saveInvoice(
          config: config,
          buyerName: _clientController.text,
          subtotal: subtotal,
          vatAmount: vatAmount,
          total: totalAmount,
        );
      }
    } catch (e) {
      appLogger.e("invoice error", error: e);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.invoicePdfFailed)));
    }

    if (mounted) setState(() => _isLoading = false);
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
    final l10n = AppLocalizations.of(context)!;
    final config = ref.watch(countryConfigProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l10n.invoiceTitle),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            _buildSectionTitle(l10n.invoiceRecipient),
            _buildInputCard(
              child: TextField(
                controller: _clientController,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: l10n.invoiceClientHint,
                  icon: const Icon(Icons.business_outlined),
                  labelText: l10n.invoiceClientLabel,
                ),
              ),
            ),

            _buildSectionTitle(
              l10n.invoiceItems,
              trailing: TextButton.icon(
                onPressed: _addItem,
                icon: const Icon(Icons.add_circle_outline, size: 18),
                label: Text(l10n.invoiceAddItem),
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
                              labelText: l10n.invoiceItemName('${index + 1}'),
                              hintText: l10n.invoiceItemNameHint,
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
                              tooltip: l10n.delete,
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
                              labelText: l10n.invoiceUnitPrice,
                              suffixText: config.currencySymbol,
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
                              labelText: l10n.invoiceQty,
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
                    Flexible(
                      child: Text(
                        l10n.invoiceShareHint,
                        style: TextStyle(color: isDark ? Colors.grey : Colors.brown, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
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
                  label: _isLoading ? l10n.invoiceGenerating : l10n.invoiceShare,
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
