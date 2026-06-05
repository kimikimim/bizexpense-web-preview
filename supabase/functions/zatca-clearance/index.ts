// ZATCA (Saudi e-invoicing / Fatoorah) Phase 2 — server-side integration point.
//
// This is a SCAFFOLD, not a compliant implementation. Phase 2 must run on the
// server (private keys / CSIDs never touch the client) and requires:
//
//   1. Onboarding (per taxpayer, one-time):
//        - generate an ECDSA (secp256k1) key pair
//        - build a CSR with the ZATCA-required subject/extensions
//        - POST /compliance with the OTP from the Fatoora portal → Compliance CSID
//        - run the compliance checks, then POST /production/csids → Production CSID
//        - store the CSID + private key securely (Vault / KMS), per user
//
//   2. Per invoice:
//        - build UBL 2.1 XML (with ZATCA extensions)
//        - canonicalize (C14N) and SHA-256 hash; chain the previous invoice hash (PIH)
//        - ECDSA-sign → embed the UBL signature + cryptographic stamp
//        - build the Phase-2 QR (9 TLV tags incl. XML hash, signature, public key, cert)
//        - B2B: POST /invoices/clearance (synchronous approval before sending)
//          B2C: POST /invoices/reporting (within 24h)
//        - persist returned clearance/reporting status, signed XML, hash → vat_invoices
//
// Use ZATCA's SDK + sandbox to validate. Hand-rolling the crypto/XML is the
// usual source of rejection — prefer the official SDK or certified middleware.

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

serve(async (req) => {
  if (req.method !== "POST") {
    return new Response("Method not allowed", { status: 405 });
  }

  // const payload = await req.json(); // { invoiceId, ... }

  return new Response(
    JSON.stringify({
      status: "not_implemented",
      phase: 2,
      message:
        "ZATCA clearance not yet integrated. Complete onboarding (CSID), UBL/XML signing and the clearance/reporting API server-side before enabling.",
    }),
    { status: 501, headers: { "Content-Type": "application/json" } },
  );
});
