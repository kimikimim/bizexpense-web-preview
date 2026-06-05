import 'dart:convert';

/// Builds the ZATCA (Saudi e-invoicing / Fatoorah) Phase-1 QR payload for a
/// simplified tax invoice.
///
/// The QR encodes 5 mandatory fields as TLV (Tag-Length-Value) bytes, then
/// Base64. Phase 1 ("generation") requires exactly these five tags:
///   1 Seller name, 2 VAT reg. number, 3 timestamp (ISO-8601),
///   4 invoice total incl. VAT, 5 VAT total.
///
/// NOTE: Phase 2 additionally requires a cryptographic stamp + hash and ZATCA
/// platform integration — out of scope here.
String zatcaQrPayload({
  required String sellerName,
  required String vatNumber,
  required DateTime timestamp,
  required num totalWithVat,
  required num vatTotal,
}) {
  final fields = <int, String>{
    1: sellerName,
    2: vatNumber,
    // ISO 8601 in UTC without milliseconds, e.g. 2024-01-05T12:30:00Z
    3: '${timestamp.toUtc().toIso8601String().split('.').first}Z',
    4: totalWithVat.toStringAsFixed(2),
    5: vatTotal.toStringAsFixed(2),
  };

  final bytes = <int>[];
  fields.forEach((tag, value) {
    final v = utf8.encode(value);
    bytes
      ..add(tag) // tag
      ..add(v.length) // length (values are < 256 bytes)
      ..addAll(v); // value
  });

  return base64Encode(bytes);
}
