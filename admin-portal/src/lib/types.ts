export type ProfileRole = 'admin' | 'staff' | 'parent' | 'student' | 'driver';

export interface AdminUser {
  id: string;
  name: string;
  email: string;
  role: ProfileRole;
  school?: string;
  grade?: string;
  phone?: string;
  isActive: boolean;
  createdAt: string;
}

export interface AdminBus {
  id: string;
  plateNumber: string;
  capacity: number;
  driverName: string;
  driverPhone?: string;
  routeId?: string;
  routeName?: string;
  status: string;
  currentPassengers: number;
}

export interface AdminRoute {
  id: string;
  name: string;
  stops: string[];
  status: string;
}

export interface AdminSchedule {
  id: string;
  busId: string;
  busPlate: string;
  routeId: string;
  routeName: string;
  date: string;
  departureTime: string;
  arrivalTime: string;
  status: string;
}

export interface AdminAlert {
  id: string;
  title: string;
  message: string;
  severity: string;
  status: string;
  createdAt: string;
  resolvedBy?: string;
  resolvedAt?: string;
}

export interface DashboardStats {
  totalStudents: number;
  activeBuses: number;
  totalRoutes: number;
  onTimeRate: number;
  pendingAlerts: number;
  boardedToday: number;
  totalStaff: number;
  linkedParents: number;
}

export interface ChartPoint {
  label: string;
  value: number;
}

export interface AuthUser {
  id: string;
  email: string;
  name: string;
  role: ProfileRole;
  requiresPasswordChange?: boolean;
  requiresNameChange?: boolean;
}
