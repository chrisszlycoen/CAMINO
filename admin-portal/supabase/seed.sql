-- ============================================================
-- CAMINO Transport App — Seed Data
-- ============================================================
-- Run AFTER schema migration in Supabase SQL Editor.
-- Creates demo users in auth.users + profiles + sample data.
-- ============================================================

-- Helper: create a user in auth.users + auto-trigger creates profile
-- We use auth.admin_create_user if available, or direct insert.
-- NOTE: In Supabase dashboard you should create these users manually
-- via Authentication > Users > Invite, or use the management API.
-- The profiles below assume the auth.users IDs match.

-- For local dev, run this AFTER schema and create users with these emails
-- in the Supabase Auth UI:
--   admin@camino.rw / admin123
--   staff@camino.rw / staff123
--   student@camino.rw / student123
--   parent@camino.rw / parent123
--   driver@camino.rw / driver123

-- Once users exist, update their profiles:
update public.profiles set name = 'Admin User', role = 'admin', phone = '+250781234900' where id = (select id from auth.users where email = 'admin@camino.rw');
update public.profiles set name = 'Jean Baptiste', role = 'staff', phone = '+250781234700', school = 'KICS' where id = (select id from auth.users where email = 'staff@camino.rw');
update public.profiles set name = 'Jean Niyonzima', role = 'student', phone = '+250781234501', school = 'Kigali International Community School', grade = 'Grade 10' where id = (select id from auth.users where email = 'student@camino.rw');
update public.profiles set name = 'Sarah Uwimana', role = 'parent', phone = '+250781234600' where id = (select id from auth.users where email = 'parent@camino.rw');
update public.profiles set name = 'Alex Rukundo', role = 'driver', phone = '+250781234700' where id = (select id from auth.users where email = 'driver@camino.rw');

-- Routes
insert into public.routes (id, name, stops, status) values
  ('00000000-0000-0000-0000-000000000001', 'Route A', '["Gishushu Stop","Amahoro Stadium","Kigali Heights","Kacyiru","Nyabugogo"]'::jsonb, 'active'),
  ('00000000-0000-0000-0000-000000000002', 'Route B', '["Kimironko","Remera","Kicukiro","Airport Road"]'::jsonb, 'active'),
  ('00000000-0000-0000-0000-000000000003', 'Route C', '["Nyamirambo","Muhima","Kiyovu","Kanombe"]'::jsonb, 'active'),
  ('00000000-0000-0000-0000-000000000004', 'Route D', '["Gisozi","Jali","Nduba"]'::jsonb, 'inactive'),
  ('00000000-0000-0000-0000-000000000005', 'Route E', '["Niboye","Kabeza","Rwampara","Busanza"]'::jsonb, 'active');

-- Buses (no route_id initially — assign via app)
insert into public.buses (id, plate_number, capacity, driver_name, driver_phone, route_id, status, current_passengers) values
  ('00000000-0000-0000-0000-000000000011', 'RAC 123 A', 45, 'Alex Rukundo', '+250781234700', '00000000-0000-0000-0000-000000000001', 'active', 32),
  ('00000000-0000-0000-0000-000000000012', 'RAC 456 B', 50, 'Patrick Mugisha', '+250781234701', '00000000-0000-0000-0000-000000000002', 'active', 41),
  ('00000000-0000-0000-0000-000000000013', 'RAC 789 C', 40, 'Diane Nyiraneza', '+250781234702', '00000000-0000-0000-0000-000000000003', 'active', 28),
  ('00000000-0000-0000-0000-000000000014', 'RAC 321 D', 55, 'Jean Claude', '+250781234703', null, 'maintenance', 0),
  ('00000000-0000-0000-0000-000000000015', 'RAC 654 E', 35, 'Marie Louise', '+250781234704', null, 'active', 15);

-- Schedules
insert into public.schedules (id, bus_id, route_id, date, departure_time, arrival_time, status) values
  ('00000000-0000-0000-0000-000000000021', '00000000-0000-0000-0000-000000000011', '00000000-0000-0000-0000-000000000001', current_date, '06:30', '08:15', 'completed'),
  ('00000000-0000-0000-0000-000000000022', '00000000-0000-0000-0000-000000000012', '00000000-0000-0000-0000-000000000002', current_date, '06:45', '08:30', 'completed'),
  ('00000000-0000-0000-0000-000000000023', '00000000-0000-0000-0000-000000000011', '00000000-0000-0000-0000-000000000001', current_date, '15:30', '17:00', 'scheduled'),
  ('00000000-0000-0000-0000-000000000024', '00000000-0000-0000-0000-000000000012', '00000000-0000-0000-0000-000000000002', current_date, '15:45', '17:15', 'in-progress'),
  ('00000000-0000-0000-0000-000000000025', '00000000-0000-0000-0000-000000000013', '00000000-0000-0000-0000-000000000003', current_date + 1, '06:30', '08:15', 'scheduled');

-- Alerts
insert into public.alerts (id, title, message, severity, status, created_by, resolved_by, resolved_at) values
  ('00000000-0000-0000-0000-000000000031', 'Bus #12 Engine Issue', 'Bus RAC 123 A reported engine overheating at Gishushu Stop.', 'high', 'active', (select id from auth.users where email = 'admin@camino.rw'), null, null),
  ('00000000-0000-0000-0000-000000000032', 'Route B Traffic Delay', 'Heavy traffic on Route B causing estimated 20 min delay.', 'medium', 'active', (select id from auth.users where email = 'staff@camino.rw'), null, null),
  ('00000000-0000-0000-0000-000000000033', 'Student Left Belongings', 'A backpack was found on Bus #12 after morning route.', 'low', 'resolved', (select id from auth.users where email = 'staff@camino.rw'), (select id from auth.users where email = 'admin@camino.rw'), now() - interval '12 hours');
