import type { AdminUser, AdminBus, AdminRoute, AdminSchedule, AdminAlert, DashboardStats, ChartPoint } from './types';

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

function saveDB(db: DB) {
  localStorage.setItem(DB_KEY, JSON.stringify(db));
}

function delay(ms = 200) { return new Promise(r => setTimeout(r, ms)); }

async function withDB<T>(fn: (db: DB) => T): Promise<T> {
  await delay();
  const db = loadDB();
  const result = fn(db);
  saveDB(db);
  return result;
}

function genId(prefix: string, db: DB): string {
  const num = db.nextId[prefix] || 1;
  db.nextId[prefix] = num + 1;
  return `${prefix.toUpperCase()}-${String(num).padStart(3, '0')}`;
}

export const DataService = {
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
    if (i >= 0) { db.alerts[i] = { ...db.alerts[i], status: 'resolved', resolvedBy, resolvedAt: new Date().toISOString() }; }
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
