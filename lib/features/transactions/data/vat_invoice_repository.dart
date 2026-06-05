import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:expense_pro/core/utils/app_logger.dart';
import '../../../core/config/country_tax_config.dart';

/// Persists issued invoices to the ME-only `vat_invoices` ledger.
///
/// This is the foundation for ZATCA: every invoice gets a sequential number,
/// a UUID and a stored VAT breakdown. The cryptographic stamp / clearance
/// (Phase 2) is filled in later by a server-side signing service — the
/// `zatca_hash` / status fields are placeholders until then.
class VatInvoiceRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Saves an invoice and returns its generated invoice number, or null on failure.
  /// Amounts are major units; stored as integer minor units for consistency.
  Future<String?> saveInvoice({
    required CountryTaxConfig config,
    required String buyerName,
    String? buyerVatNumber,
    required num subtotal,
    required num vatAmount,
    required num total,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return null;

      final invoiceNumber = await _nextInvoiceNumber(userId);
      final uuid = const Uuid().v4();

      await _supabase.from('vat_invoices').insert({
        'user_id': userId,
        'invoice_number': invoiceNumber,
        'invoice_date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
        'buyer_name': buyerName,
        'buyer_vat_number': buyerVatNumber,
        'country_code': config.countryCode,
        'currency_code': config.currencyCode,
        'subtotal': config.toMinorUnits(subtotal),
        'vat_amount': config.toMinorUnits(vatAmount),
        'total': config.toMinorUnits(total),
        'status': 'issued',
        'zatca_uuid': uuid,
        // zatca_hash stays null until a Phase-2 signing service fills it.
      });

      return invoiceNumber;
    } catch (e) {
      appLogger.e('saveInvoice error', error: e);
      return null;
    }
  }

  Future<String> _nextInvoiceNumber(String userId) async {
    final year = DateTime.now().year;
    int seq = 1;
    try {
      final rows = await _supabase
          .from('vat_invoices')
          .select('id')
          .eq('user_id', userId);
      seq = (rows as List).length + 1;
    } catch (_) {}
    return 'INV-$year-${seq.toString().padLeft(4, '0')}';
  }
}
