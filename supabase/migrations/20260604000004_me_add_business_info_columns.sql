-- ME project only.
-- MyBusinessPage (shared app code) upserts these business-info columns to
-- profiles, and the quotation PDF reads them. ME was missing them, so saving
-- business info would fail with "column does not exist".

alter table public.profiles
  add column if not exists company_name text,
  add column if not exists ceo_name text,
  add column if not exists business_number text,
  add column if not exists address text,
  add column if not exists industry_category text;
