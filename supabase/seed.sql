-- ============================================================
-- CAMINO Transport App — Seed Data
-- ============================================================
-- Run AFTER schema migration in Supabase SQL Editor.
-- ============================================================

-- Helper: create users in auth.users. Each is created via the
-- Supabase Auth admin API. The handle_new_user trigger creates
-- a profile row with requires_password_change = true and
-- requires_name_change = true.
--
-- In production, use Supabase Dashboard > Authentication > Users
-- to create users. For local dev, use the SQL below.

-- Create admin user (password set via Supabase Auth, paste UUID below)
-- Then update profile:
update public.profiles set name = 'Admin User', role = 'admin', phone = '+250781234900', requires_password_change = true, requires_name_change = true where id = (select id from auth.users where email = 'admin@camino.rw');
update public.profiles set name = 'Jean Baptiste', role = 'staff', phone = '+250781234700', school = 'KICS' where id = (select id from auth.users where email = 'staff@camino.rw');
update public.profiles set name = 'Jean Niyonzima', role = 'student', phone = '+250781234501', school = 'Kigali International Community School', grade = 'Grade 10', points = 450, streak_days = 12 where id = (select id from auth.users where email = 'student@camino.rw');
update public.profiles set name = 'Sarah Uwimana', role = 'parent', phone = '+250781234600' where id = (select id from auth.users where email = 'parent@camino.rw');
update public.profiles set name = 'Alex Rukundo', role = 'driver', phone = '+250781234700' where id = (select id from auth.users where email = 'driver@camino.rw');

-- Routes
insert into public.routes (id, name, stops, status) values
  ('00000000-0000-0000-0000-000000000001', 'Route A', '["Gishushu Stop","Amahoro Stadium","Kigali Heights","Kacyiru","Nyabugogo"]'::jsonb, 'active'),
  ('00000000-0000-0000-0000-000000000002', 'Route B', '["Kimironko","Remera","Kicukiro","Airport Road"]'::jsonb, 'active'),
  ('00000000-0000-0000-0000-000000000003', 'Route C', '["Nyamirambo","Muhima","Kiyovu","Kanombe"]'::jsonb, 'active'),
  ('00000000-0000-0000-0000-000000000004', 'Route D', '["Gisozi","Jali","Nduba"]'::jsonb, 'inactive'),
  ('00000000-0000-0000-0000-000000000005', 'Route E', '["Niboye","Kabeza","Rwampara","Busanza"]'::jsonb, 'active')
on conflict (id) do nothing;

-- Buses
insert into public.buses (id, plate_number, capacity, driver_name, driver_phone, route_id, status, current_passengers) values
  ('00000000-0000-0000-0000-000000000011', 'RAC 123 A', 45, 'Alex Rukundo', '+250781234700', '00000000-0000-0000-0000-000000000001', 'active', 32),
  ('00000000-0000-0000-0000-000000000012', 'RAC 456 B', 50, 'Patrick Mugisha', '+250781234701', '00000000-0000-0000-0000-000000000002', 'active', 41),
  ('00000000-0000-0000-0000-000000000013', 'RAC 789 C', 40, 'Diane Nyiraneza', '+250781234702', '00000000-0000-0000-0000-000000000003', 'active', 28),
  ('00000000-0000-0000-0000-000000000014', 'RAC 321 D', 55, 'Jean Claude', '+250781234703', null, 'maintenance', 0),
  ('00000000-0000-0000-0000-000000000015', 'RAC 654 E', 35, 'Marie Louise', '+250781234704', null, 'active', 15)
on conflict (id) do nothing;

-- Schedules
insert into public.schedules (id, bus_id, route_id, date, departure_time, arrival_time, status) values
  ('00000000-0000-0000-0000-000000000021', '00000000-0000-0000-0000-000000000011', '00000000-0000-0000-0000-000000000001', current_date, '06:30', '08:15', 'completed'),
  ('00000000-0000-0000-0000-000000000022', '00000000-0000-0000-0000-000000000012', '00000000-0000-0000-0000-000000000002', current_date, '06:45', '08:30', 'completed'),
  ('00000000-0000-0000-0000-000000000023', '00000000-0000-0000-0000-000000000011', '00000000-0000-0000-0000-000000000001', current_date, '15:30', '17:00', 'scheduled'),
  ('00000000-0000-0000-0000-000000000024', '00000000-0000-0000-0000-000000000012', '00000000-0000-0000-0000-000000000002', current_date, '15:45', '17:15', 'in-progress'),
  ('00000000-0000-0000-0000-000000000025', '00000000-0000-0000-0000-000000000013', '00000000-0000-0000-0000-000000000003', current_date + 1, '06:30', '08:15', 'scheduled')
on conflict (id) do nothing;

-- Alerts
insert into public.alerts (id, title, message, severity, status, created_by, resolved_by, resolved_at) values
  ('00000000-0000-0000-0000-000000000031', 'Bus #12 Engine Issue', 'Bus RAC 123 A reported engine overheating at Gishushu Stop.', 'high', 'active', (select id from auth.users where email = 'admin@camino.rw'), null, null),
  ('00000000-0000-0000-0000-000000000032', 'Route B Traffic Delay', 'Heavy traffic on Route B causing estimated 20 min delay.', 'medium', 'active', (select id from auth.users where email = 'staff@camino.rw'), null, null),
  ('00000000-0000-0000-0000-000000000033', 'Student Left Belongings', 'A backpack was found on Bus #12 after morning route.', 'low', 'resolved', (select id from auth.users where email = 'staff@camino.rw'), (select id from auth.users where email = 'admin@camino.rw'), now() - interval '12 hours')
on conflict (id) do nothing;

-- Student-parent link
insert into public.student_parents (student_id, parent_id)
  select s.id, p.id
  from auth.users s, auth.users p
  where s.email = 'student@camino.rw' and p.email = 'parent@camino.rw'
on conflict (student_id, parent_id) do nothing;

-- Bus assignments (student Jean is on Bus #12 / Route A)
insert into public.bus_assignments (student_id, bus_id, route_id, effective_from, is_active)
  select u.id, '00000000-0000-0000-0000-000000000011', '00000000-0000-0000-0000-000000000001', current_date, true
  from auth.users u where u.email = 'student@camino.rw'
on conflict (student_id, bus_id, effective_from) do nothing;

-- Notifications for the student
insert into public.notifications (profile_id, title, message, category, is_read, created_at)
  select u.id, 'Bus #12 is arriving', 'Your bus will reach Gishushu Stop in 5 mins.', 'bus', false, now()
  from auth.users u where u.email = 'student@camino.rw';

insert into public.notifications (profile_id, title, message, category, is_read, created_at)
  select u.id, 'Payment Received', 'Term 3 transport fee has been received.', 'payment', true, now() - interval '2 days'
  from auth.users u where u.email = 'student@camino.rw';

insert into public.notifications (profile_id, title, message, category, is_read, created_at)
  select u.id, 'Schedule Change', 'Tomorrow''s afternoon trip #13 is delayed by 15 mins.', 'schedule', false, now() - interval '1 day'
  from auth.users u where u.email = 'student@camino.rw';

-- Notifications for the parent
insert into public.notifications (profile_id, title, message, category, is_read, created_at)
  select u.id, 'Jean has boarded the bus', 'Your child Jean Niyonzima has been scanned onto Bus #12.', 'bus', false, now()
  from auth.users u where u.email = 'parent@camino.rw';

insert into public.notifications (profile_id, title, message, category, is_read, created_at)
  select u.id, 'Term 3 Fee Receipt', 'Payment of RWF 45,000 for Term 3 transport has been confirmed.', 'payment', true, now() - interval '2 days'
  from auth.users u where u.email = 'parent@camino.rw';

-- Payments for the student
insert into public.payments (profile_id, title, amount, currency, payment_method, status, paid_at)
  select u.id, 'Term 3 Transport Fee', 45000, 'RWF', 'MTN Mobile Money', 'completed', now() - interval '2 days'
  from auth.users u where u.email = 'student@camino.rw';

insert into public.payments (profile_id, title, amount, currency, payment_method, status, paid_at)
  select u.id, 'Term 2 Transport Fee', 45000, 'RWF', 'MTN Mobile Money', 'completed', now() - interval '6 months'
  from auth.users u where u.email = 'student@camino.rw';

insert into public.payments (profile_id, title, amount, currency, payment_method, status, paid_at)
  select u.id, 'Term 1 Transport Fee', 45000, 'RWF', 'Airtel Money', 'completed', now() - interval '9 months'
  from auth.users u where u.email = 'student@camino.rw';

-- Bus locations (sample tracking points for Bus #12 on Route A today)
insert into public.bus_locations (bus_id, latitude, longitude, timestamp) values
  ('00000000-0000-0000-0000-000000000011', -1.9441, 30.0619, now() - interval '30 minutes'),
  ('00000000-0000-0000-0000-000000000011', -1.9480, 30.0650, now() - interval '25 minutes'),
  ('00000000-0000-0000-0000-000000000011', -1.9520, 30.0680, now() - interval '20 minutes'),
  ('00000000-0000-0000-0000-000000000011', -1.9560, 30.0710, now() - interval '15 minutes'),
  ('00000000-0000-0000-0000-000000000011', -1.9600, 30.0740, now() - interval '10 minutes'),
  ('00000000-0000-0000-0000-000000000011', -1.9441, 30.0619, now() - interval '5 minutes');
