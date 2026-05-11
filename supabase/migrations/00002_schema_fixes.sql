-- ============================================================
-- CAMINO Transport App — Schema Fixes & Additions
-- ============================================================
-- Adds missing columns, tables, and fixes RLS gaps identified
-- during cross-app audit (Flutter + Admin Portal + DB schema).
-- ============================================================

-- 1. ADD MISSING COLUMNS TO PROFILES
-- email was missing (AdminPortal mapUser reads row.email), avatar for
-- student photos, points/streak_days for gamification feature.
alter table public.profiles
  add column if not exists email text,
  add column if not exists avatar_url text,
  add column if not exists points int not null default 0,
  add column if not exists streak_days int not null default 0;

-- Backfill email for existing profiles from auth.users
update public.profiles p
  set email = u.email
  from auth.users u
  where p.id = u.id and p.email is null;

-- 2. NOTIFICATIONS TABLE
-- Used by Flutter for student/parent notification feeds.
create table if not exists public.notifications (
  id          uuid primary key default gen_random_uuid(),
  profile_id  uuid not null references public.profiles(id) on delete cascade,
  title       text not null,
  message     text not null,
  category    text not null check (category in ('bus', 'payment', 'schedule', 'alert', 'system')),
  is_read     boolean not null default false,
  data        jsonb default '{}'::jsonb,
  created_at  timestamptz not null default now()
);

-- 3. PAYMENTS TABLE
-- Supports the parent payments screen that shows history + balance.
create table if not exists public.payments (
  id              uuid primary key default gen_random_uuid(),
  profile_id      uuid not null references public.profiles(id) on delete cascade,
  title           text not null,
  amount          numeric(10, 2) not null,
  currency        text not null default 'RWF',
  payment_method  text,
  status          text not null default 'completed' check (status in ('completed', 'pending', 'failed', 'refunded')),
  paid_at         timestamptz,
  created_at      timestamptz not null default now()
);

-- 4. BUS ASSIGNMENTS TABLE
-- Links students to buses/routes for QR boarding flow and schedule filtering.
create table if not exists public.bus_assignments (
  id              uuid primary key default gen_random_uuid(),
  student_id      uuid not null references public.profiles(id) on delete cascade,
  bus_id          uuid not null references public.buses(id) on delete cascade,
  route_id        uuid references public.routes(id) on delete set null,
  effective_from  date not null default current_date,
  effective_to    date,
  is_active       boolean not null default true,
  unique(student_id, bus_id, effective_from)
);

-- 5. INDEXES
create index if not exists idx_notifications_profile on public.notifications(profile_id);
create index if not exists idx_notifications_unread on public.notifications(profile_id, is_read) where not is_read;
create index if not exists idx_notifications_created on public.notifications(created_at desc);
create index if not exists idx_payments_profile on public.payments(profile_id);
create index if not exists idx_payments_status on public.payments(status);
create index if not exists idx_bus_assignments_student on public.bus_assignments(student_id);
create index if not exists idx_bus_assignments_bus on public.bus_assignments(bus_id);

-- 6. ROW LEVEL SECURITY — NEW TABLES

-- 6a. NOTIFICATIONS
alter table public.notifications enable row level security;

create policy "Users can read own notifications"
  on public.notifications for select
  using (profile_id = auth.uid());

create policy "Users can mark own notifications as read"
  on public.notifications for update
  using (profile_id = auth.uid());

create policy "Staff and admin can send notifications"
  on public.notifications for insert
  with check (exists (
    select 1 from public.profiles where id = auth.uid() and role in ('admin', 'staff')
  ));

create policy "Users can delete own notifications"
  on public.notifications for delete
  using (profile_id = auth.uid());

-- 6b. PAYMENTS
alter table public.payments enable row level security;

create policy "Users can read own payments"
  on public.payments for select
  using (profile_id = auth.uid());

create policy "Admins can read all payments"
  on public.payments for select
  using (exists (
    select 1 from public.profiles where id = auth.uid() and role = 'admin'
  ));

create policy "Parents can read linked children payments"
  on public.payments for select
  using (exists (
    select 1 from public.student_parents sp
    where sp.parent_id = auth.uid() and sp.student_id = payments.profile_id
  ));

create policy "Admins can insert payments"
  on public.payments for insert
  with check (exists (
    select 1 from public.profiles where id = auth.uid() and role = 'admin'
  ));

create policy "Admins can update payments"
  on public.payments for update
  using (exists (
    select 1 from public.profiles where id = auth.uid() and role = 'admin'
  ));

-- 6c. BUS ASSIGNMENTS
alter table public.bus_assignments enable row level security;

create policy "Staff, admin, and drivers can read bus assignments"
  on public.bus_assignments for select
  using (exists (
    select 1 from public.profiles where id = auth.uid() and role in ('admin', 'staff', 'driver')
  ));

create policy "Parents can read own children assignments"
  on public.bus_assignments for select
  using (exists (
    select 1 from public.student_parents sp
    where sp.parent_id = auth.uid() and sp.student_id = bus_assignments.student_id
  ));

create policy "Students can read own assignment"
  on public.bus_assignments for select
  using (student_id = auth.uid());

create policy "Staff and admin can insert assignments"
  on public.bus_assignments for insert
  with check (exists (
    select 1 from public.profiles where id = auth.uid() and role in ('admin', 'staff')
  ));

create policy "Staff and admin can update assignments"
  on public.bus_assignments for update
  using (exists (
    select 1 from public.profiles where id = auth.uid() and role in ('admin', 'staff')
  ));

create policy "Staff and admin can delete assignments"
  on public.bus_assignments for delete
  using (exists (
    select 1 from public.profiles where id = auth.uid() and role in ('admin', 'staff')
  ));

-- 7. FIX — PARENT/STUDENT SCHEDULE RLS POLICY
-- The original policy granted blanket read access to all parents/students
-- without actually filtering to relevant schedules. Now it properly joins
-- through bus_assignments.
drop policy if exists "Parents and students can read relevant schedules" on public.schedules;

create policy "Parents and students can read relevant schedules"
  on public.schedules for select
  using (
    exists (
      select 1 from public.profiles p
      where p.id = auth.uid() and p.role in ('parent', 'student')
      and (
        (p.role = 'student' and exists (
          select 1 from public.bus_assignments ba
          where ba.student_id = p.id and ba.bus_id = schedules.bus_id
          and ba.is_active = true
        ))
        or
        (p.role = 'parent' and exists (
          select 1 from public.student_parents sp
          join public.bus_assignments ba on ba.student_id = sp.student_id
          where sp.parent_id = p.id and ba.bus_id = schedules.bus_id
          and ba.is_active = true
        ))
      )
    )
  );

-- 8. ADD — MISSING DELETE POLICY ON ALERTS
create policy "Admins can delete alerts"
  on public.alerts for delete
  using (exists (
    select 1 from public.profiles where id = auth.uid() and role = 'admin'
  ));

-- 9. ADD — MISSING UPDATE/DELETE POLICIES ON BUS_LOCATIONS
-- Only INSERT was defined; staff/admins should be able to correct bad data.
create policy "Staff and admin can update bus locations"
  on public.bus_locations for update
  using (exists (
    select 1 from public.profiles where id = auth.uid() and role in ('admin', 'staff')
  ));

create policy "Staff and admin can delete bus locations"
  on public.bus_locations for delete
  using (exists (
    select 1 from public.profiles where id = auth.uid() and role in ('admin', 'staff')
  ));

-- 10. ADD NEW TABLES TO REALTIME PUBLICATION
alter publication supabase_realtime add table public.notifications;
alter publication supabase_realtime add table public.bus_assignments;

-- 11. UPDATE — handle_new_user trigger to include email
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = ''
as $$
begin
  insert into public.profiles (id, name, email, role, is_active)
  values (
    new.id,
    coalesce(new.raw_user_meta_data ->> 'name', split_part(new.email, '@', 1)),
    new.email,
    coalesce(new.raw_user_meta_data ->> 'role', 'parent'),
    true
  );
  return new;
end;
$$;
