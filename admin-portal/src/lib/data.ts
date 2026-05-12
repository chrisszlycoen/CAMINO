import { getSupabase } from './supabase';
import { cacheGet, cacheSet } from './supabase-offline';
import type {
  AdminUser, AdminBus, AdminRoute, AdminSchedule,
  AdminAlert, DashboardStats, ChartPoint, ProfileRole,
} from './types';

const CACHE_TTL = 60000;

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
    const tempPassword = `${u.role}_${Date.now()}`;
    const { data: authData, error: authError } = await sb.auth.admin.createUser({
      email: u.email,
      password: tempPassword,
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
      stops: r.stops,
      status: r.status || 'active',
    }).select().single();

    if (error) throw error;
    return mapRoute(data);
  },

  async updateRoute(r: AdminRoute): Promise<AdminRoute> {
    const { data, error } = await getSupabase().from('routes').update({
      name: r.name,
      stops: r.stops,
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

export const DataService = supabaseService;
