-- ============================================================
-- CAMINO Transport App — Initial Schema
-- ============================================================
-- Run this in Supabase SQL Editor or via `supabase db push`
-- ============================================================

-- 0. Extensions
create extension if not exists "pgcrypto";

-- 1. PROFILES (extends auth.users)
create table public.profiles (
  id          uuid primary key references auth.users(id) on delete cascade,
  name        text not null,
  phone       text,
  role        text not null check (role in ('admin', 'staff', 'parent', 'student', 'driver')),
  school      text,
  grade       text,
  is_active   boolean not null default true,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

-- 2. ROUTES (standalone, referenced by buses & schedules)
create table public.routes (
  id         uuid primary key default gen_random_uuid(),
  name       text not null,
  stops      jsonb not null default '[]'::jsonb,
  status     text not null default 'active' check (status in ('active', 'inactive')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- 3. BUSES (references routes)
create table public.buses (
  id                   uuid primary key default gen_random_uuid(),
  plate_number         text not null unique,
  capacity             int not null,
  driver_name          text not null,
  driver_phone         text,
  route_id             uuid references public.routes(id) on delete set null,
  status               text not null default 'active' check (status in ('active', 'maintenance', 'inactive')),
  current_passengers   int not null default 0,
  latitude             float,
  longitude            float,
  last_location_update timestamptz,
  created_at           timestamptz not null default now(),
  updated_at           timestamptz not null default now()
);

-- 4. SCHEDULES (links buses → routes)
create table public.schedules (
  id             uuid primary key default gen_random_uuid(),
  bus_id         uuid not null references public.buses(id) on delete cascade,
  route_id       uuid not null references public.routes(id) on delete cascade,
  date           date not null,
  departure_time time not null,
  arrival_time   time not null,
  status         text not null default 'scheduled' check (status in ('scheduled', 'in-progress', 'completed', 'cancelled')),
  created_at     timestamptz not null default now(),
  updated_at     timestamptz not null default now()
);

-- 5. ALERTS
create table public.alerts (
  id          uuid primary key default gen_random_uuid(),
  title       text not null,
  message     text not null,
  severity    text not null check (severity in ('high', 'medium', 'low')),
  status      text not null default 'active' check (status in ('active', 'resolved')),
  created_by  uuid references auth.users(id) on delete set null,
  resolved_by uuid references auth.users(id) on delete set null,
  resolved_at timestamptz,
  created_at  timestamptz not null default now()
);

-- 6. STUDENT-PARENT LINKS
create table public.student_parents (
  id          uuid primary key default gen_random_uuid(),
  student_id  uuid not null references public.profiles(id) on delete cascade,
  parent_id   uuid not null references public.profiles(id) on delete cascade,
  unique(student_id, parent_id)
);

-- 7. BUS LOCATIONS (realtime tracking history)
create table public.bus_locations (
  id         bigserial primary key,
  bus_id     uuid not null references public.buses(id) on delete cascade,
  latitude   float not null,
  longitude  float not null,
  timestamp  timestamptz not null default now()
);

-- 8. INDEXES
create index idx_profiles_role on public.profiles(role);
create index idx_buses_status on public.buses(status);
create index idx_buses_route on public.buses(route_id);
create index idx_schedules_date on public.schedules(date);
create index idx_schedules_bus on public.schedules(bus_id);
create index idx_schedules_route on public.schedules(route_id);
create index idx_schedules_status on public.schedules(status);
create index idx_alerts_status on public.alerts(status);
create index idx_alerts_severity on public.alerts(severity);
create index idx_student_parents_student on public.student_parents(student_id);
create index idx_student_parents_parent on public.student_parents(parent_id);
create index idx_bus_locations_bus on public.bus_locations(bus_id);
create index idx_bus_locations_ts on public.bus_locations(timestamp desc);

-- 9. ROW LEVEL SECURITY

-- 9a. PROFILES
alter table public.profiles enable row level security;

create policy "Users can read own profile"
  on public.profiles for select
  using (auth.uid() = id);

create policy "Admins can read all profiles"
  on public.profiles for select
  using (exists (select 1 from public.profiles where id = auth.uid() and role = 'admin'));

create policy "Staff can read all profiles"
  on public.profiles for select
  using (exists (select 1 from public.profiles where id = auth.uid() and role in ('staff', 'admin')));

create policy "Admins can insert profiles"
  on public.profiles for insert
  with check (exists (select 1 from public.profiles where id = auth.uid() and role = 'admin'));

create policy "Users can update own profile"
  on public.profiles for update
  using (auth.uid() = id)
  with check (auth.uid() = id);

create policy "Admins can update any profile"
  on public.profiles for update
  using (exists (select 1 from public.profiles where id = auth.uid() and role = 'admin'));

create policy "Admins can delete profiles"
  on public.profiles for delete
  using (exists (select 1 from public.profiles where id = auth.uid() and role = 'admin'));

-- 9b. BUSES
alter table public.buses enable row level security;

create policy "Staff and admin can read buses"
  on public.buses for select
  using (exists (select 1 from public.profiles where id = auth.uid() and role in ('staff', 'admin', 'driver')));

create policy "Parents and students can read active buses"
  on public.buses for select
  using (exists (select 1 from public.profiles where id = auth.uid() and role in ('parent', 'student'))
         and status = 'active');

create policy "Staff and admin can insert buses"
  on public.buses for insert
  with check (exists (select 1 from public.profiles where id = auth.uid() and role in ('staff', 'admin')));

create policy "Staff and admin can update buses"
  on public.buses for update
  using (exists (select 1 from public.profiles where id = auth.uid() and role in ('staff', 'admin')));

create policy "Staff and admin can delete buses"
  on public.buses for delete
  using (exists (select 1 from public.profiles where id = auth.uid() and role in ('staff', 'admin')));

-- 9c. ROUTES
alter table public.routes enable row level security;

create policy "Everyone can read active routes"
  on public.routes for select
  using (status = 'active' or exists (select 1 from public.profiles where id = auth.uid() and role in ('staff', 'admin')));

create policy "Staff and admin can insert routes"
  on public.routes for insert
  with check (exists (select 1 from public.profiles where id = auth.uid() and role in ('staff', 'admin')));

create policy "Staff and admin can update routes"
  on public.routes for update
  using (exists (select 1 from public.profiles where id = auth.uid() and role in ('staff', 'admin')));

create policy "Staff and admin can delete routes"
  on public.routes for delete
  using (exists (select 1 from public.profiles where id = auth.uid() and role in ('staff', 'admin')));

-- 9d. SCHEDULES
alter table public.schedules enable row level security;

create policy "Staff and admin can read all schedules"
  on public.schedules for select
  using (exists (select 1 from public.profiles where id = auth.uid() and role in ('staff', 'admin', 'driver')));

create policy "Parents and students can read relevant schedules"
  on public.schedules for select
  using (exists (
    select 1 from public.profiles p
    left join public.student_parents sp on (p.role = 'parent' and sp.parent_id = p.id)
    where p.id = auth.uid() and p.role in ('parent', 'student')
  ));

create policy "Staff and admin can insert schedules"
  on public.schedules for insert
  with check (exists (select 1 from public.profiles where id = auth.uid() and role in ('staff', 'admin')));

create policy "Staff and admin can update schedules"
  on public.schedules for update
  using (exists (select 1 from public.profiles where id = auth.uid() and role in ('staff', 'admin')));

create policy "Staff and admin can delete schedules"
  on public.schedules for delete
  using (exists (select 1 from public.profiles where id = auth.uid() and role in ('staff', 'admin')));

-- 9e. ALERTS
alter table public.alerts enable row level security;

create policy "Everyone can read active alerts"
  on public.alerts for select
  using (status = 'active' or exists (select 1 from public.profiles where id = auth.uid() and role in ('staff', 'admin')));

create policy "Staff and admin can insert alerts"
  on public.alerts for insert
  with check (exists (select 1 from public.profiles where id = auth.uid() and role in ('staff', 'admin')));

create policy "Staff and admin can update alerts"
  on public.alerts for update
  using (exists (select 1 from public.profiles where id = auth.uid() and role in ('staff', 'admin')));

-- 9f. STUDENT_PARENTS
alter table public.student_parents enable row level security;

create policy "Admins can read student-parent links"
  on public.student_parents for select
  using (exists (select 1 from public.profiles where id = auth.uid() and role = 'admin'));

create policy "Parents can read own links"
  on public.student_parents for select
  using (parent_id = auth.uid());

create policy "Admins can insert links"
  on public.student_parents for insert
  with check (exists (select 1 from public.profiles where id = auth.uid() and role = 'admin'));

create policy "Admins can delete links"
  on public.student_parents for delete
  using (exists (select 1 from public.profiles where id = auth.uid() and role = 'admin'));

-- 9g. BUS_LOCATIONS
alter table public.bus_locations enable row level security;

create policy "Authenticated users can read bus locations"
  on public.bus_locations for select
  using (auth.role() = 'authenticated');

create policy "Drivers and staff can insert locations"
  on public.bus_locations for insert
  with check (exists (select 1 from public.profiles where id = auth.uid() and role in ('driver', 'staff', 'admin')));

-- 10. REALTIME PUBLICATION
-- Enables WebSocket subscriptions for live updates
alter publication supabase_realtime add table public.buses;
alter publication supabase_realtime add table public.bus_locations;
alter publication supabase_realtime add table public.alerts;
alter publication supabase_realtime add table public.schedules;

-- 11. TRIGGER: auto-create profile on user signup
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = ''
as $$
begin
  insert into public.profiles (id, name, role, is_active)
  values (
    new.id,
    coalesce(new.raw_user_meta_data ->> 'name', split_part(new.email, '@', 1)),
    coalesce(new.raw_user_meta_data ->> 'role', 'parent'),
    true
  );
  return new;
end;
$$;

create or replace trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- 12. TRIGGER: updated_at
create or replace function public.update_updated_at()
returns trigger
language plpgsql
security definer
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger set_profiles_updated_at
  before update on public.profiles
  for each row execute function public.update_updated_at();

create trigger set_buses_updated_at
  before update on public.buses
  for each row execute function public.update_updated_at();

create trigger set_routes_updated_at
  before update on public.routes
  for each row execute function public.update_updated_at();

create trigger set_schedules_updated_at
  before update on public.schedules
  for each row execute function public.update_updated_at();
