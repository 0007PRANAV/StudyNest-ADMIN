-- StudyNest admin dashboard: one-time SQL to enable all dashboard actions.
-- Run ONCE in Supabase: SQL Editor -> New query -> paste -> Run.
-- Safe to run more than once.

-- 1. Suspension flag used by the Users page.
alter table public.profiles add column if not exists suspended boolean not null default false;

-- 2. Admins may update any profile (name, avatar, role, suspended).
drop policy if exists profiles_admin_update on public.profiles;
create policy profiles_admin_update on public.profiles for update to authenticated
  using (public.is_admin()) with check (public.is_admin());

grant update (name, avatar_path, role, suspended) on public.profiles to authenticated;

-- 3. Admins may delete profile rows from the dashboard.
drop policy if exists profiles_admin_delete on public.profiles;
create policy profiles_admin_delete on public.profiles for delete to authenticated
  using (public.is_admin());
grant delete on public.profiles to authenticated;

-- 4. Admins may read and remove any block.
drop policy if exists blocked_admin_select on public.blocked_users;
create policy blocked_admin_select on public.blocked_users for select to authenticated
  using (public.is_admin());
drop policy if exists blocked_admin_delete on public.blocked_users;
create policy blocked_admin_delete on public.blocked_users for delete to authenticated
  using (public.is_admin());

-- 5. Let an admin change roles, but keep blocking normal users from promoting themselves.
create or replace function public.profiles_guard()
returns trigger language plpgsql set search_path = '' as $$
begin
  if (select auth.uid()) is not null
     and new.role is distinct from old.role
     and not public.is_admin() then
    raise exception 'roles can only be changed by an admin';
  end if;
  return new;
end $$;
drop trigger if exists profiles_role_guard on public.profiles;
create trigger profiles_role_guard before update on public.profiles
  for each row execute function public.profiles_guard();

-- 6. Make sure the owner account is still admin.
update public.profiles set role = 'admin' where id = 'bdd4c035-29a3-47f9-aa01-efedcf3b4d81';

-- Verify
select username, name, role, suspended from public.profiles order by created_at;
