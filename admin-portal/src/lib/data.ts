import { getSupabase } from './supabase';
import type {
  AdminUser, AdminBus, AdminRoute, AdminSchedule,
  AdminAlert, DashboardStats, ChartPoint, ProfileRole,
} from './types';

async function apiFetch<T>(url: string, options?: RequestInit): Promise<T> {
  const response = await fetch(url, {
    headers: { 'Content-Type': 'application/json' },
    ...options,
  });
  if (!response.ok) {
    const err = await response.json().catch(() => ({}));
    throw new Error(err.error ?? `Request to ${url} failed`);
  }
  return response.json();
}

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

const supabaseService = {
  async getUsers(): Promise<AdminUser[]> {
    const rows = await apiFetch<any[]>('/api/users');
    return rows.map(mapUser);
  },

  async addUser(u: Omit<AdminUser, 'id'>): Promise<AdminUser> {
    const data = await apiFetch<any>('/api/users', {
      method: 'POST',
      body: JSON.stringify(u),
    });
    return mapUser(data);
  },

  async updateUser(u: AdminUser): Promise<AdminUser> {
    const data = await apiFetch<any>('/api/users', {
      method: 'PUT',
      body: JSON.stringify(u),
    });
    return mapUser(data);
  },

  async deleteUser(id: string): Promise<void> {
    await apiFetch('/api/users', {
      method: 'DELETE',
      body: JSON.stringify({ id }),
    });
  },

  async getBuses(): Promise<AdminBus[]> {
    const rows = await apiFetch<any[]>('/api/buses');
    return rows.map(mapBus);
  },

  async addBus(b: Omit<AdminBus, 'id'>): Promise<AdminBus> {
    const data = await apiFetch<any>('/api/buses', {
      method: 'POST',
      body: JSON.stringify(b),
    });
    return mapBus(data);
  },

  async updateBus(b: AdminBus): Promise<AdminBus> {
    const data = await apiFetch<any>('/api/buses', {
      method: 'PUT',
      body: JSON.stringify(b),
    });
    return mapBus(data);
  },

  async deleteBus(id: string): Promise<void> {
    await apiFetch('/api/buses', {
      method: 'DELETE',
      body: JSON.stringify({ id }),
    });
  },

  async getRoutes(): Promise<AdminRoute[]> {
    const rows = await apiFetch<any[]>('/api/routes');
    return rows.map(mapRoute);
  },

  async addRoute(r: Omit<AdminRoute, 'id'>): Promise<AdminRoute> {
    const data = await apiFetch<any>('/api/routes', {
      method: 'POST',
      body: JSON.stringify(r),
    });
    return mapRoute(data);
  },

  async updateRoute(r: AdminRoute): Promise<AdminRoute> {
    const data = await apiFetch<any>('/api/routes', {
      method: 'PUT',
      body: JSON.stringify(r),
    });
    return mapRoute(data);
  },

  async deleteRoute(id: string): Promise<void> {
    await apiFetch('/api/routes', {
      method: 'DELETE',
      body: JSON.stringify({ id }),
    });
  },

  async getSchedules(): Promise<AdminSchedule[]> {
    const rows = await apiFetch<any[]>('/api/schedules');
    return rows.map(mapSchedule);
  },

  async addSchedule(s: Omit<AdminSchedule, 'id'>): Promise<AdminSchedule> {
    const data = await apiFetch<any>('/api/schedules', {
      method: 'POST',
      body: JSON.stringify(s),
    });
    return mapSchedule(data);
  },

  async updateSchedule(s: AdminSchedule): Promise<AdminSchedule> {
    const data = await apiFetch<any>('/api/schedules', {
      method: 'PUT',
      body: JSON.stringify(s),
    });
    return mapSchedule(data);
  },

  async deleteSchedule(id: string): Promise<void> {
    await apiFetch('/api/schedules', {
      method: 'DELETE',
      body: JSON.stringify({ id }),
    });
  },

  async getAlerts(): Promise<AdminAlert[]> {
    const rows = await apiFetch<any[]>('/api/alerts');
    return rows.map(mapAlert);
  },

  async addAlert(a: Omit<AdminAlert, 'id' | 'createdAt'>): Promise<AdminAlert> {
    const supabase = getSupabase();
    const { data: { user } } = await supabase.auth.getUser();
    const data = await apiFetch<any>('/api/alerts', {
      method: 'POST',
      body: JSON.stringify({ ...a, createdBy: user?.id || null }),
    });
    return mapAlert(data);
  },

  async resolveAlert(id: string, resolvedBy: string): Promise<AdminAlert | undefined> {
    const supabase = getSupabase();
    const { data: { user } } = await supabase.auth.getUser();
    const data = await apiFetch<any>('/api/alerts', {
      method: 'PUT',
      body: JSON.stringify({ id, status: 'resolved', resolvedBy: user?.id || null }),
    });
    return mapAlert(data);
  },

  async getDashboardStats(): Promise<DashboardStats> {
    return apiFetch<DashboardStats>('/api/stats');
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
