import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:expense_pro/l10n/app_localizations.dart';

import '../../../core/providers/country_config_provider.dart';
import '../data/vat_invoice_repository.dart';

/// ME invoice ledger view (lists rows saved to vat_invoices on issue).
class MyInvoicesPage extends ConsumerStatefulWidget {
  const MyInvoicesPage({super.key});

  @override
  ConsumerState<MyInvoicesPage> createState() => _MyInvoicesPageState();
}

class _MyInvoicesPageState extends ConsumerState<MyInvoicesPage> {
  final _repo = VatInvoiceRepository();
  List<Map<String, dynamic>> _invoices = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final rows = await _repo.getMyInvoices();
    if (!mounted) return;
    setState(() {
      _invoices = rows;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final config = ref.watch(countryConfigProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.invoiceListTitle)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _invoices.isEmpty
              ? _buildEmpty(l10n)
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    itemCount: _invoices.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) => _invoiceCard(_invoices[i], config, l10n),
                  ),
                ),
    );
  }

  Widget _buildEmpty(AppLocalizations l10n) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined, size: 56,
                color: isDark ? Colors.grey[600] : Colors.grey[400]),
            const SizedBox(height: 16),
            Text(l10n.invoiceListEmpty,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(l10n.invoiceListEmptySub,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: isDark ? Colors.grey[400] : Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  Widget _invoiceCard(Map<String, dynamic> inv, dynamic config, AppLocalizations l10n) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final number = inv['invoice_number']?.toString() ?? '';
    final buyer = inv['buyer_name']?.toString() ?? '';
    final status = inv['status']?.toString() ?? 'issued';
    final total = (inv['total'] as num?) ?? 0;
    final vat = (inv['vat_amount'] as num?) ?? 0;
    final dateRaw = inv['invoice_date']?.toString();
    String dateStr = dateRaw ?? '';
    if (dateRaw != null) {
      final d = DateTime.tryParse(dateRaw);
      if (d != null) {
        dateStr = DateFormat.yMMMd(Localizations.localeOf(context).toString()).format(d);
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? Colors.grey[800]! : Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(number, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              _statusChip(status, l10n),
            ],
          ),
          const SizedBox(height: 4),
          Text(buyer, style: TextStyle(fontSize: 13, color: isDark ? Colors.grey[300] : Colors.grey[700])),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(dateStr, style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[500] : Colors.grey[500])),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(config.formatMoney(total),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(l10n.invoiceVatOf(config.formatMoney(vat)),
                      style: TextStyle(fontSize: 11, color: isDark ? Colors.grey[500] : Colors.grey[500])),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusChip(String status, AppLocalizations l10n) {
    final (label, color) = switch (status) {
      'draft' => (l10n.invoiceStatusDraft, Colors.orange),
      'cancelled' => (l10n.invoiceStatusCancelled, Colors.red),
      _ => (l10n.invoiceStatusIssued, Colors.green),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
    );
  }
}
