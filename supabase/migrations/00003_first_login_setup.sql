-- ============================================================
-- CAMINO Transport App — First-Login Name & Password Enforcement
-- ============================================================
-- Forces admin users to change their name and password on first
-- login before accessing any other page. Works for both mobile
-- (Flutter) and web (Admin Portal).
-- ============================================================

-- 1. ADD FLAGS TO PROFILES
alter table public.profiles
  add column if not exists requires_password_change boolean not null default true,
  add column if not exists requires_name_change boolean not null default true;

-- 2. UPDATE — handle_new_user trigger to set flags
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = ''
as $$
begin
  insert into public.profiles (id, name, email, role, is_active, requires_password_change, requires_name_change)
  values (
    new.id,
    coalesce(new.raw_user_meta_data ->> 'name', split_part(new.email, '@', 1)),
    new.email,
    coalesce(new.raw_user_meta_data ->> 'role', 'parent'),
    true,
    true,
    true
  );
  return new;
end;
$$;

-- 3. POLICY — admin can update own requires_* flags (needed for first-login flow)
create policy "Users can update own requires_* flags"
  on public.profiles for update
  using (auth.uid() = id)
  with check (auth.uid() = id);
