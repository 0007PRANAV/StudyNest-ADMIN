-- StudyNest Complete Schema - All Tables
-- Run this in Supabase SQL Editor to set up the full backend

-- ============================================
-- 1. public.user_data (Cloud Backup)
-- ============================================
create table if not exists public.user_data (
  user_id    uuid not null default auth.uid() references auth.users(id) on delete cascade,
  key        text not null check (char_length(key) between 1 and 120),
  value      jsonb not null check (octet_length(value::text) <= 1000000),
  updated_at timestamptz not null default now(),
  primary key (user_id, key)
);

alter table public.user_data enable row level security;

drop policy if exists "own rows: read"   on public.user_data;
drop policy if exists "own rows: insert" on public.user_data;
drop policy if exists "own rows: update" on public.user_data;
drop policy if exists "own rows: delete" on public.user_data;

create policy "own rows: read"   on public.user_data for select to authenticated using (auth.uid() = user_id);
create policy "own rows: insert" on public.user_data for insert to authenticated with check (auth.uid() = user_id);
create policy "own rows: update" on public.user_data for update to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "own rows: delete" on public.user_data for delete to authenticated using (auth.uid() = user_id);

revoke all on public.user_data from anon;
grant select, insert, update, delete on public.user_data to authenticated;

create or replace function public.user_data_touch() returns trigger language plpgsql set search_path = '' as $$
begin new.updated_at := now(); return new; end $$;
drop trigger if exists user_data_touch_trg on public.user_data;
create trigger user_data_touch_trg before update on public.user_data for each row execute function public.user_data_touch();

create or replace function public.user_data_cap() returns trigger language plpgsql set search_path = '' as $$
begin
  if (select count(*) from public.user_data where user_id = new.user_id) >= 400 then
    raise exception 'Too many backup items for this account';
  end if;
  return new;
end $$;
drop trigger if exists user_data_cap_trg on public.user_data;
create trigger user_data_cap_trg before insert on public.user_data for each row execute function public.user_data_cap();

-- ============================================
-- 2. Admin Tables
-- ============================================

-- blocked_users
create table if not exists public.blocked_users (
  blocker_id   uuid not null references public.profiles (id) on delete cascade,
  blocked_id   uuid not null references public.profiles (id) on delete cascade,
  created_at   timestamptz not null default now(),
  primary key (blocker_id, blocked_id),
  check (blocker_id <> blocked_id)
);
alter table public.blocked_users enable row level security;
drop policy if exists blocked_select on public.blocked_users;
create policy blocked_select on public.blocked_users for select to authenticated using (blocker_id = (select auth.uid()));
drop policy if exists blocked_insert on public.blocked_users;
create policy blocked_insert on public.blocked_users for insert to authenticated with check (blocker_id = (select auth.uid()));
drop policy if exists blocked_delete on public.blocked_users;
create policy blocked_delete on public.blocked_users for delete to authenticated using (blocker_id = (select auth.uid()));
grant select, insert, delete on public.blocked_users to authenticated;

-- reports
create table if not exists public.reports (
  id          uuid primary key default gen_random_uuid(),
  reporter_id uuid not null references public.profiles (id) on delete cascade,
  reported_id uuid not null references public.profiles (id) on delete cascade,
  reason      text not null check (char_length(reason) between 1 and 500),
  status      text not null default 'pending' check (status in ('pending','reviewed','dismissed')),
  created_at  timestamptz not null default now(),
  check (reporter_id <> reported_id)
);
alter table public.reports enable row level security;
drop policy if exists reports_select on public.reports;
create policy reports_select on public.reports for select to authenticated using ((select auth.uid()) in (reporter_id, reported_id) or public.is_admin());
drop policy if exists reports_insert on public.reports;
create policy reports_insert on public.reports for insert to authenticated with check (reporter_id = (select auth.uid()));
drop policy if exists reports_admin_update on public.reports;
create policy reports_admin_update on public.reports for update to authenticated using (public.is_admin()) with check (public.is_admin());
grant select, insert, update on public.reports to authenticated;

-- user_quotas
create table if not exists public.user_quotas (
  user_id      uuid primary key references public.profiles (id) on delete cascade,
  ai_requests  bigint not null default 0,
  ai_requests_reset_at timestamptz not null default now() + interval '1 day',
  storage_mb   bigint not null default 0,
  files_count  bigint not null default 0,
  updated_at   timestamptz not null default now()
);
alter table public.user_quotas enable row level security;
drop policy if exists quota_own on public.user_quotas;
create policy quota_own on public.user_quotas for all to authenticated using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));
drop policy if exists quota_admin on public.user_quotas;
create policy quota_admin on public.user_quotas for select to authenticated using (public.is_admin());
grant select, insert, update, delete on public.user_quotas to authenticated;

-- user_quota_usage
create table if not exists public.user_quota_usage (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null references public.profiles (id) on delete cascade,
  action      text not null,
  amount      bigint not null default 1,
  recorded_at timestamptz not null default now()
);
alter table public.user_quota_usage enable row level security;
drop policy if exists usage_own on public.user_quota_usage;
create policy usage_own on public.user_quota_usage for select to authenticated using (user_id = (select auth.uid()));
drop policy if exists usage_admin on public.user_quota_usage;
create policy usage_admin on public.user_quota_usage for select to authenticated using (public.is_admin());
drop policy if exists usage_insert on public.user_quota_usage;
create policy usage_insert on public.user_quota_usage for insert to authenticated with check (user_id = (select auth.uid()));
grant select, insert on public.user_quota_usage to authenticated;

-- ============================================
-- 3. Promote admin user
-- ============================================
update public.profiles set role = 'admin' where id = 'bdd4c035-29a3-47f9-aa01-efedcf3b4d81';

-- ============================================
-- Verification
-- ============================================
select jsonb_pretty(jsonb_build_object(
  'user_data_exists', to_regclass('public.user_data') is not null,
  'blocked_users_exists', to_regclass('public.blocked_users') is not null,
  'reports_exists', to_regclass('public.reports') is not null,
  'user_quotas_exists', to_regclass('public.user_quotas') is not null,
  'user_quota_usage_exists', to_regclass('public.user_quota_usage') is not null,
  'admin_role', (select role from public.profiles where id = 'bdd4c035-29a3-47f9-aa01-efedcf3b4d81')
)) as schema_check;
