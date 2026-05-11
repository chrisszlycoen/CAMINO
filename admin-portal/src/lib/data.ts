import { getSupabase } from './supabase';
import { cacheGet, cacheSet } from './supabase-offline';
import type {
  AdminUser, AdminBus, AdminRoute, AdminSchedule,
  AdminAlert, DashboardStats, ChartPoint, ProfileRole,
} from './types';

const SUPABASE_CONFIGURED = !!(process.env.NEXT_PUBLIC_SUPABASE_URL && process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY);
const CACHE_TTL = 60000;

// ──────────────────────────────────────────────
// MOCK DATA SERVICE (fallback)
// ──────────────────────────────────────────────

const DB_KEY = 'camino_admin_data';

interface DB {
  users: AdminUser[];
  buses: AdminBus[];
  routes: AdminRoute[];
  schedules: AdminSchedule[];
  alerts: AdminAlert[];
  nextId: Record<string, number>;
}

function seed(): DB {
  return {
    users: [
      { id: 'USR-001', name: 'Jean Niyonzima', email: 'jean@student.rw', role: 'student', school: 'Kigali International Community School', grade: 'Grade 10', phone: '+250781234501', isActive: true, createdAt: '2026-01-15' },
      { id: 'USR-002', name: 'Mia Thompson', email: 'mia@student.rw', role: 'student', school: 'KICS', grade: 'Grade 4', phone: '+250781234502', isActive: true, createdAt: '2026-01-20' },
      { id: 'USR-003', name: 'Noah Davis', email: 'noah@student.rw', role: 'student', school: 'KICS', grade: 'Grade 5', phone: '+250781234503', isActive: true, createdAt: '2026-02-01' },
      { id: 'USR-004', name: 'Sarah Uwimana', email: 'sarah@parent.rw', role: 'parent', phone: '+250781234600', isActive: true, createdAt: '2026-01-10' },
      { id: 'USR-005', name: 'David Habimana', email: 'david@parent.rw', role: 'parent', phone: '+250781234601', isActive: true, createdAt: '2026-01-12' },
      { id: 'USR-006', name: 'Alex Rukundo', email: 'alex@staff.rw', role: 'staff', phone: '+250781234700', isActive: true, createdAt: '2026-01-05' },
      { id: 'USR-007', name: 'Patrick Mugisha', email: 'patrick@staff.rw', role: 'staff', phone: '+250781234701', isActive: true, createdAt: '2026-01-08' },
      { id: 'USR-008', name: 'Admin System', email: 'admin@camino.rw', role: 'admin', isActive: true, createdAt: '2025-12-01' },
    ],
    buses: [
      { id: 'BUS-001', plateNumber: 'RAC 123 A', capacity: 45, driverName: 'Alex Rukundo', driverPhone: '+250781234700', routeId: 'RTE-001', routeName: 'Route A', status: 'active', currentPassengers: 32 },
      { id: 'BUS-002', plateNumber: 'RAC 456 B', capacity: 50, driverName: 'Patrick Mugisha', driverPhone: '+250781234701', routeId: 'RTE-002', routeName: 'Route B', status: 'active', currentPassengers: 41 },
      { id: 'BUS-003', plateNumber: 'RAC 789 C', capacity: 40, driverName: 'Diane Nyiraneza', driverPhone: '+250781234702', routeId: 'RTE-003', routeName: 'Route C', status: 'active', currentPassengers: 28 },
      { id: 'BUS-004', plateNumber: 'RAC 321 D', capacity: 55, driverName: 'Jean Claude', driverPhone: '+250781234703', status: 'maintenance', currentPassengers: 0 },
      { id: 'BUS-005', plateNumber: 'RAC 654 E', capacity: 35, driverName: 'Marie Louise', driverPhone: '+250781234704', status: 'active', currentPassengers: 15 },
    ],
    routes: [
      { id: 'RTE-001', name: 'Route A', stops: ['Gishushu Stop', 'Amahoro Stadium', 'Kigali Heights', 'Kacyiru', 'Nyabugogo'], status: 'active' },
      { id: 'RTE-002', name: 'Route B', stops: ['Kimironko', 'Remera', 'Kicukiro', 'Airport Road'], status: 'active' },
      { id: 'RTE-003', name: 'Route C', stops: ['Nyamirambo', 'Muhima', 'Kiyovu', 'Kanombe'], status: 'active' },
      { id: 'RTE-004', name: 'Route D', stops: ['Gisozi', 'Jali', 'Nduba'], status: 'inactive' },
      { id: 'RTE-005', name: 'Route E', stops: ['Niboye', 'Kabeza', 'Rwampara', 'Busanza'], status: 'active' },
    ],
    schedules: [
      { id: 'SCH-001', busId: 'BUS-001', busPlate: 'RAC 123 A', routeId: 'RTE-001', routeName: 'Route A', date: '2026-05-11', departureTime: '06:30', arrivalTime: '08:15', status: 'completed' },
      { id: 'SCH-002', busId: 'BUS-002', busPlate: 'RAC 456 B', routeId: 'RTE-002', routeName: 'Route B', date: '2026-05-11', departureTime: '06:45', arrivalTime: '08:30', status: 'completed' },
      { id: 'SCH-003', busId: 'BUS-001', busPlate: 'RAC 123 A', routeId: 'RTE-001', routeName: 'Route A', date: '2026-05-11', departureTime: '15:30', arrivalTime: '17:00', status: 'scheduled' },
      { id: 'SCH-004', busId: 'BUS-002', busPlate: 'RAC 456 B', routeId: 'RTE-002', routeName: 'Route B', date: '2026-05-11', departureTime: '15:45', arrivalTime: '17:15', status: 'in-progress' },
      { id: 'SCH-005', busId: 'BUS-003', busPlate: 'RAC 789 C', routeId: 'RTE-003', routeName: 'Route C', date: '2026-05-12', departureTime: '06:30', arrivalTime: '08:15', status: 'scheduled' },
    ],
    alerts: [
      { id: 'ALR-001', title: 'Bus #12 Engine Issue', message: 'Bus RAC 123 A reported engine overheating at Gishushu Stop.', severity: 'high', status: 'active', createdAt: new Date(Date.now() - 7200000).toISOString() },
      { id: 'ALR-002', title: 'Route B Traffic Delay', message: 'Heavy traffic on Route B causing estimated 20 min delay.', severity: 'medium', status: 'active', createdAt: new Date(Date.now() - 3600000).toISOString() },
      { id: 'ALR-003', title: 'Student Left Belongings', message: 'A backpack was found on Bus #12 after morning route.', severity: 'low', status: 'resolved', createdAt: new Date(Date.now() - 86400000).toISOString(), resolvedBy: 'Admin System', resolvedAt: new Date(Date.now() - 43200000).toISOString() },
    ],
    nextId: { user: 9, bus: 6, route: 6, schedule: 6, alert: 4 },
  };
}

function loadDB(): DB {
  if (typeof window === 'undefined') return seed();
  const raw = localStorage.getItem(DB_KEY);
  if (raw) try { return JSON.parse(raw); } catch { /* ignore */ }
  const db = seed();
  localStorage.setItem(DB_KEY, JSON.stringify(db));
  return db;
}

function saveDB(db: DB) { localStorage.setItem(DB_KEY, JSON.stringify(db)); }

function delay(ms = 200) { return new Promise(r => setTimeout(r, ms)); }

async function withDB<T>(fn: (db: DB) => T): Promise<T> {
  await delay();
  const db = loadDB();
  const result = fn(db);
  saveDB(db);
  return result;
}

function genId(prefix: string, db: DB): string {
  const key = { USR: 'user', BUS: 'bus', RTE: 'route', SCH: 'schedule', ALR: 'alert' }[prefix] || 'user';
  const num = db.nextId[key] || 1;
  db.nextId[key] = num + 1;
  return `${prefix}-${String(num).padStart(3, '0')}`;
}

const mockService = {
  getUsers: () => withDB(db => [...db.users]),
  addUser: (u: Omit<AdminUser, 'id'>) => withDB(db => { const id = genId('USR', db); const user = { ...u, id }; db.users.push(user); return user; }),
  updateUser: (u: AdminUser) => withDB(db => { const i = db.users.findIndex(x => x.id === u.id); if (i >= 0) db.users[i] = u; return u; }),
  deleteUser: (id: string) => withDB(db => { db.users = db.users.filter(x => x.id !== id); }),

  getBuses: () => withDB(db => [...db.buses]),
  addBus: (b: Omit<AdminBus, 'id'>) => withDB(db => { const id = genId('BUS', db); const bus = { ...b, id }; db.buses.push(bus); return bus; }),
  updateBus: (b: AdminBus) => withDB(db => { const i = db.buses.findIndex(x => x.id === b.id); if (i >= 0) db.buses[i] = b; return b; }),
  deleteBus: (id: string) => withDB(db => { db.buses = db.buses.filter(x => x.id !== id); }),

  getRoutes: () => withDB(db => [...db.routes]),
  addRoute: (r: Omit<AdminRoute, 'id'>) => withDB(db => { const id = genId('RTE', db); const route = { ...r, id }; db.routes.push(route); return route; }),
  updateRoute: (r: AdminRoute) => withDB(db => { const i = db.routes.findIndex(x => x.id === r.id); if (i >= 0) db.routes[i] = r; return r; }),
  deleteRoute: (id: string) => withDB(db => { db.routes = db.routes.filter(x => x.id !== id); }),

  getSchedules: () => withDB(db => [...db.schedules]),
  addSchedule: (s: Omit<AdminSchedule, 'id'>) => withDB(db => { const id = genId('SCH', db); const sch = { ...s, id }; db.schedules.push(sch); return sch; }),
  updateSchedule: (s: AdminSchedule) => withDB(db => { const i = db.schedules.findIndex(x => x.id === s.id); if (i >= 0) db.schedules[i] = s; return s; }),
  deleteSchedule: (id: string) => withDB(db => { db.schedules = db.schedules.filter(x => x.id !== id); }),

  getAlerts: () => withDB(db => [...db.alerts]),
  addAlert: (a: Omit<AdminAlert, 'id' | 'createdAt'>) => withDB(db => { const id = genId('ALR', db); const alert: AdminAlert = { ...a, id, createdAt: new Date().toISOString() }; db.alerts.unshift(alert); return alert; }),
  resolveAlert: (id: string, resolvedBy: string) => withDB(db => {
    const i = db.alerts.findIndex(x => x.id === id);
    if (i >= 0) db.alerts[i] = { ...db.alerts[i], status: 'resolved', resolvedBy, resolvedAt: new Date().toISOString() };
    return db.alerts[i];
  }),

  getDashboardStats: (): Promise<DashboardStats> => withDB(db => ({
    totalStudents: db.users.filter(u => u.role === 'student').length,
    activeBuses: db.buses.filter(b => b.status === 'active').length,
    totalRoutes: db.routes.filter(r => r.status === 'active').length,
    onTimeRate: 87.5,
    pendingAlerts: db.alerts.filter(a => a.status === 'active').length,
    boardedToday: 116,
    totalStaff: db.users.filter(u => u.role === 'staff').length,
    linkedParents: db.users.filter(u => u.role === 'parent').length,
  })),

  getWeeklyData: (): ChartPoint[] => [
    { label: 'Mon', value: 128 }, { label: 'Tue', value: 145 },
    { label: 'Wed', value: 132 }, { label: 'Thu', value: 158 },
    { label: 'Fri', value: 142 }, { label: 'Sat', value: 89 },
    { label: 'Sun', value: 0 },
  ],

  getRoutePerformance: (): ChartPoint[] => [
    { label: 'Route A', value: 92 }, { label: 'Route B', value: 85 },
    { label: 'Route C', value: 78 }, { label: 'Route D', value: 0 },
    { label: 'Route E', value: 88 },
  ],
};

// ──────────────────────────────────────────────
// SUPABASE DATA SERVICE
// ──────────────────────────────────────────────

function mapUser(row: any): AdminUser {
  return {
    id: row.id,
    name: row.name || '',
    email: row.email || '',
    role: row.role as ProfileRole,
    phone: row.phone || undefined,
    school: row.school || undefined,
    grade: row.grade || undefined,
    isActive: row.is_active ?? true,
    createdAt: row.created_at || new Date().toISOString(),
  };
}

function mapBus(row: any): AdminBus {
  return {
    id: row.id,
    plateNumber: row.plate_number || '',
    capacity: row.capacity || 0,
    driverName: row.driver_name || '',
    driverPhone: row.driver_phone || undefined,
    routeId: row.route_id || undefined,
    routeName: row.route_name || undefined,
    status: row.status || 'inactive',
    currentPassengers: row.current_passengers ?? 0,
  };
}

function mapRoute(row: any): AdminRoute {
  return {
    id: row.id,
    name: row.name || '',
    stops: Array.isArray(row.stops) ? row.stops : (typeof row.stops === 'string' ? JSON.parse(row.stops) : []),
    status: row.status || 'inactive',
  };
}

function mapSchedule(row: any): AdminSchedule {
  return {
    id: row.id,
    busId: row.bus_id || '',
    busPlate: row.bus_plate || '',
    routeId: row.route_id || '',
    routeName: row.route_name || '',
    date: row.date || '',
    departureTime: row.departure_time || '',
    arrivalTime: row.arrival_time || '',
    status: row.status || 'scheduled',
  };
}

function mapAlert(row: any): AdminAlert {
  return {
    id: row.id,
    title: row.title || '',
    message: row.message || '',
    severity: row.severity || 'low',
    status: row.status || 'active',
    createdAt: row.created_at || new Date().toISOString(),
    resolvedBy: row.resolved_by_name || undefined,
    resolvedAt: row.resolved_at || undefined,
  };
}

async function sbQuery<T>(
  fn: () => Promise<{ data: T | null; error: any }>,
  cacheKey?: string,
): Promise<T> {
  if (cacheKey) {
    const cached = await cacheGet<T>(cacheKey, CACHE_TTL);
    if (cached !== null) return cached;
  }
  const { data, error } = await fn();
  if (error) throw error;
  if (!data) throw new Error('No data returned');
  if (cacheKey) cacheSet(cacheKey, data);
  return data;
}

const supabaseService = {
  async getUsers(): Promise<AdminUser[]> {
    const rows = await sbQuery<any[]>(
      () => getSupabase().from('profiles').select('*').order('created_at', { ascending: false }),
      'users',
    );
    return rows.map(mapUser);
  },

  async addUser(u: Omit<AdminUser, 'id'>): Promise<AdminUser> {
    const sb = getSupabase();
    const { data: authData, error: authError } = await sb.auth.admin.createUser({
      email: u.email,
      password: 'demo123',
      email_confirm: true,
      user_metadata: { name: u.name, role: u.role },
    });
    if (authError) throw authError;
    if (!authData.user) throw new Error('Failed to create user');

    const { data, error } = await sb.from('profiles').upsert({
      id: authData.user.id,
      name: u.name,
      phone: u.phone || null,
      role: u.role,
      school: u.school || null,
      grade: u.grade || null,
      is_active: u.isActive ?? true,
    }).select().single();

    if (error) throw error;
    return mapUser(data);
  },

  async updateUser(u: AdminUser): Promise<AdminUser> {
    const { data, error } = await getSupabase().from('profiles').update({
      name: u.name,
      phone: u.phone || null,
      role: u.role,
      school: u.school || null,
      grade: u.grade || null,
      is_active: u.isActive,
    }).eq('id', u.id).select().single();

    if (error) throw error;
    return mapUser(data);
  },

  async deleteUser(id: string): Promise<void> {
    const { error } = await getSupabase().auth.admin.deleteUser(id);
    if (error) throw error;
  },

  async getBuses(): Promise<AdminBus[]> {
    const rows = await sbQuery<any[]>(
      () => getSupabase().from('buses').select('*, routes!left(name)').order('plate_number'),
      'buses',
    );
    return rows.map((r: any) => ({
      ...mapBus(r),
      routeName: r.routes?.name || r.route_name || undefined,
    }));
  },

  async addBus(b: Omit<AdminBus, 'id'>): Promise<AdminBus> {
    const { data, error } = await getSupabase().from('buses').insert({
      plate_number: b.plateNumber,
      capacity: b.capacity,
      driver_name: b.driverName,
      driver_phone: b.driverPhone || null,
      route_id: b.routeId || null,
      status: b.status || 'active',
      current_passengers: (b as any).currentPassengers ?? 0,
    }).select().single();

    if (error) throw error;
    return mapBus(data);
  },

  async updateBus(b: AdminBus): Promise<AdminBus> {
    const { data, error } = await getSupabase().from('buses').update({
      plate_number: b.plateNumber,
      capacity: b.capacity,
      driver_name: b.driverName,
      driver_phone: b.driverPhone || null,
      route_id: b.routeId || null,
      status: b.status,
      current_passengers: b.currentPassengers,
    }).eq('id', b.id).select().single();

    if (error) throw error;
    return mapBus(data);
  },

  async deleteBus(id: string): Promise<void> {
    const { error } = await getSupabase().from('buses').delete().eq('id', id);
    if (error) throw error;
  },

  async getRoutes(): Promise<AdminRoute[]> {
    const rows = await sbQuery<any[]>(
      () => getSupabase().from('routes').select('*').order('name'),
      'routes',
    );
    return rows.map(mapRoute);
  },

  async addRoute(r: Omit<AdminRoute, 'id'>): Promise<AdminRoute> {
    const { data, error } = await getSupabase().from('routes').insert({
      name: r.name,
      stops: JSON.stringify(r.stops),
      status: r.status || 'active',
    }).select().single();

    if (error) throw error;
    return mapRoute(data);
  },

  async updateRoute(r: AdminRoute): Promise<AdminRoute> {
    const { data, error } = await getSupabase().from('routes').update({
      name: r.name,
      stops: JSON.stringify(r.stops),
      status: r.status,
    }).eq('id', r.id).select().single();

    if (error) throw error;
    return mapRoute(data);
  },

  async deleteRoute(id: string): Promise<void> {
    const { error } = await getSupabase().from('routes').delete().eq('id', id);
    if (error) throw error;
  },

  async getSchedules(): Promise<AdminSchedule[]> {
    const rows = await sbQuery<any[]>(
      () => getSupabase().from('schedules').select('*, buses!inner(plate_number), routes!inner(name)').order('date', { ascending: false }),
      'schedules',
    );
    return rows.map((r: any) => ({
      ...mapSchedule(r),
      busPlate: r.buses?.plate_number || r.bus_plate || '',
      routeName: r.routes?.name || r.route_name || '',
    }));
  },

  async addSchedule(s: Omit<AdminSchedule, 'id'>): Promise<AdminSchedule> {
    const { data, error } = await getSupabase().from('schedules').insert({
      bus_id: s.busId,
      route_id: s.routeId,
      date: s.date,
      departure_time: s.departureTime,
      arrival_time: s.arrivalTime,
      status: s.status || 'scheduled',
    }).select().single();

    if (error) throw error;
    return mapSchedule(data);
  },

  async updateSchedule(s: AdminSchedule): Promise<AdminSchedule> {
    const { data, error } = await getSupabase().from('schedules').update({
      bus_id: s.busId,
      route_id: s.routeId,
      date: s.date,
      departure_time: s.departureTime,
      arrival_time: s.arrivalTime,
      status: s.status,
    }).eq('id', s.id).select().single();

    if (error) throw error;
    return mapSchedule(data);
  },

  async deleteSchedule(id: string): Promise<void> {
    const { error } = await getSupabase().from('schedules').delete().eq('id', id);
    if (error) throw error;
  },

  async getAlerts(): Promise<AdminAlert[]> {
    const rows = await sbQuery<any[]>(
      () => getSupabase().from('alerts').select('*').order('created_at', { ascending: false }),
      'alerts',
    );
    return rows.map(mapAlert);
  },

  async addAlert(a: Omit<AdminAlert, 'id' | 'createdAt'>): Promise<AdminAlert> {
    const supabase = getSupabase();
    const { data: { user } } = await supabase.auth.getUser();
    const { data, error } = await supabase.from('alerts').insert({
      title: a.title,
      message: a.message,
      severity: a.severity,
      status: 'active',
      created_by: user?.id || null,
    }).select().single();

    if (error) throw error;
    return mapAlert(data);
  },

  async resolveAlert(id: string, resolvedBy: string): Promise<AdminAlert | undefined> {
    const supabase = getSupabase();
    const { data: { user } } = await supabase.auth.getUser();
    const { data, error } = await supabase.from('alerts').update({
      status: 'resolved',
      resolved_by: user?.id || null,
      resolved_at: new Date().toISOString(),
    }).eq('id', id).select().single();

    if (error) throw error;
    const alert = mapAlert(data);
    alert.resolvedBy = resolvedBy;
    return alert;
  },

  async getDashboardStats(): Promise<DashboardStats> {
    const cacheKey = 'dashboard_stats';
    const cached = await cacheGet<DashboardStats>(cacheKey, CACHE_TTL);
    if (cached !== null) return cached;

    const supabase = getSupabase();
    const [
      { count: totalStudents },
      { count: activeBuses },
      { count: totalRoutes },
      { count: pendingAlerts },
      { count: totalStaff },
      { count: linkedParents },
    ] = await Promise.all([
      supabase.from('profiles').select('*', { count: 'exact', head: true }).eq('role', 'student'),
      supabase.from('buses').select('*', { count: 'exact', head: true }).eq('status', 'active'),
      supabase.from('routes').select('*', { count: 'exact', head: true }).eq('status', 'active'),
      supabase.from('alerts').select('*', { count: 'exact', head: true }).eq('status', 'active'),
      supabase.from('profiles').select('*', { count: 'exact', head: true }).eq('role', 'staff'),
      supabase.from('profiles').select('*', { count: 'exact', head: true }).eq('role', 'parent'),
    ]);

    const stats: DashboardStats = {
      totalStudents: totalStudents ?? 0,
      activeBuses: activeBuses ?? 0,
      totalRoutes: totalRoutes ?? 0,
      onTimeRate: 87.5,
      pendingAlerts: pendingAlerts ?? 0,
      boardedToday: 116,
      totalStaff: totalStaff ?? 0,
      linkedParents: linkedParents ?? 0,
    };

    cacheSet(cacheKey, stats);
    return stats;
  },

  getWeeklyData(): ChartPoint[] {
    return [
      { label: 'Mon', value: 128 }, { label: 'Tue', value: 145 },
      { label: 'Wed', value: 132 }, { label: 'Thu', value: 158 },
      { label: 'Fri', value: 142 }, { label: 'Sat', value: 89 },
      { label: 'Sun', value: 0 },
    ];
  },

  getRoutePerformance(): ChartPoint[] {
    return [
      { label: 'Route A', value: 92 }, { label: 'Route B', value: 85 },
      { label: 'Route C', value: 78 }, { label: 'Route D', value: 0 },
      { label: 'Route E', value: 88 },
    ];
  },
};

// ──────────────────────────────────────────────
// EXPORT: auto-select mock or supabase
// ──────────────────────────────────────────────

export const DataService = SUPABASE_CONFIGURED ? supabaseService : mockService;
