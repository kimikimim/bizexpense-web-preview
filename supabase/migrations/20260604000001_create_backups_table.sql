-- Cloud backup history used by BackupService.autoBackup() / getBackupHistory().
-- Missing table caused 404 on /rest/v1/backups. Applied to both KR and ME projects.

create table if not exists public.backups (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  backup_data text not null,
  backup_date timestamptz not null default now(),
  transaction_count integer not null default 0,
  created_at timestamptz not null default now()
);

alter table public.backups enable row level security;

create policy "Users can manage own backups" on public.backups
  for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create index if not exists backups_user_id_date_idx
  on public.backups (user_id, backup_date desc);
