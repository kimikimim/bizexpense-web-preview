-- ME (Middle East) project only.
-- The Flutter repositories always send these columns, but the ME schema
-- lacked them, which would have failed every transaction/recurring insert
-- with "column does not exist".

alter table public.transactions
  add column if not exists cash_receipt_type text;

alter table public.recurring_transactions
  add column if not exists type text,
  add column if not exists is_tax_deductible boolean;
