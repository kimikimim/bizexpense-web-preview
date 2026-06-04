-- KR project. The community feature was removed from the app; drop the
-- leftover tables and the unused community storage bucket's listing policy.
-- (The empty `community` storage bucket itself must be removed via the
--  Storage API / dashboard — direct deletion from storage tables is blocked.)

drop table if exists public.post_likes cascade;
drop table if exists public.comments cascade;
drop table if exists public.posts cascade;

drop policy if exists "Community Public Access" on storage.objects;
