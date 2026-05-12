import 'package:supabase_flutter/supabase_flutter.dart';
import '../features/admin/models/admin_models.dart';

class SupabaseAdminService {
  final _supabase = Supabase.instance.client;

  Future<List<AdminUser>> getUsers() async {
    final rows = await _supabase
        .from('profiles')
        .select('*')
        .order('created_at', ascending: false);
    return rows.map(_mapUser).toList();
  }

  Future<List<AdminUser>> getUsersByRole(String role) async {
    final rows = await _supabase
        .from('profiles')
        .select('*')
        .eq('role', role)
        .order('created_at', ascending: false);
    return rows.map(_mapUser).toList();
  }

  Future<AdminUser> addUser({
    required String name,
    required String email,
    required String role,
    String? phone,
    String? school,
    String? grade,
  }) async {
    final tempPassword = '${role}_${DateTime.now().millisecondsSinceEpoch}';
    final response = await _supabase.auth.admin.createUser(
      AdminUserAttributes(
        email: email,
        password: tempPassword,
        emailConfirm: true,
        userMetadata: {'name': name, 'role': role},
      ),
    );
    if (response.user == null) {
      throw Exception('Failed to create user');
    }
    final data = await _supabase
        .from('profiles')
        .update({
          'name': name,
          'phone': phone,
          'school': school,
          'grade': grade,
          'is_active': true,
        })
        .eq('id', response.user!.id)
        .select()
        .single();
    return _mapUser(data);
  }

  Future<AdminUser> updateUser(AdminUser user) async {
    final data = await _supabase
        .from('profiles')
        .update({
          'name': user.name,
          'email': user.email,
          'phone': user.phone,
          'role': user.role,
          'school': user.school,
          'grade': user.grade,
          'is_active': user.isActive,
        })
        .eq('id', user.id)
        .select()
        .single();
    return _mapUser(data);
  }

  Future<void> deleteUser(String id) async {
    await _supabase.auth.admin.deleteUser(id);
  }

  Future<List<AdminBus>> getBuses() async {
    final rows = await _supabase
        .from('buses')
        .select('*, routes!left(name)')
        .order('plate_number');
    return rows.map((r) {
      final bus = _mapBus(r);
      return AdminBus(
        id: bus.id,
        plateNumber: bus.plateNumber,
        capacity: bus.capacity,
        driverName: bus.driverName,
        driverPhone: bus.driverPhone,
        routeId: bus.routeId,
        routeName: r['routes'] != null ? r['routes']['name'] as String? : null,
        status: bus.status,
        currentPassengers: bus.currentPassengers,
      );
    }).toList();
  }

  Future<AdminBus> addBus(AdminBus bus) async {
    final data = await _supabase
        .from('buses')
        .insert({
          'plate_number': bus.plateNumber,
          'capacity': bus.capacity,
          'driver_name': bus.driverName,
          'driver_phone': bus.driverPhone,
          'route_id': bus.routeId,
          'status': bus.status,
          'current_passengers': bus.currentPassengers,
        })
        .select()
        .single();
    return _mapBus(data);
  }

  Future<AdminBus> updateBus(AdminBus bus) async {
    final data = await _supabase
        .from('buses')
        .update({
          'plate_number': bus.plateNumber,
          'capacity': bus.capacity,
          'driver_name': bus.driverName,
          'driver_phone': bus.driverPhone,
          'route_id': bus.routeId,
          'status': bus.status,
          'current_passengers': bus.currentPassengers,
        })
        .eq('id', bus.id)
        .select()
        .single();
    return _mapBus(data);
  }

  Future<void> deleteBus(String id) async {
    await _supabase.from('buses').delete().eq('id', id);
  }

  Future<List<AdminRoute>> getRoutes() async {
    final rows = await _supabase
        .from('routes')
        .select('*')
        .order('name');
    return rows.map(_mapRoute).toList();
  }

  Future<AdminRoute> addRoute(AdminRoute route) async {
    final data = await _supabase
        .from('routes')
        .insert({
          'name': route.name,
          'stops': route.stops,
          'status': route.status,
        })
        .select()
        .single();
    return _mapRoute(data);
  }

  Future<AdminRoute> updateRoute(AdminRoute route) async {
    final data = await _supabase
        .from('routes')
        .update({
          'name': route.name,
          'stops': route.stops,
          'status': route.status,
        })
        .eq('id', route.id)
        .select()
        .single();
    return _mapRoute(data);
  }

  Future<void> deleteRoute(String id) async {
    await _supabase.from('routes').delete().eq('id', id);
  }

  Future<List<AdminSchedule>> getSchedules() async {
    final rows = await _supabase
        .from('schedules')
        .select('*, buses!inner(plate_number), routes!inner(name)')
        .order('date', ascending: false);
    return rows.map((r) {
      final s = _mapSchedule(r);
      return AdminSchedule(
        id: s.id,
        busId: s.busId,
        busPlate: r['buses']?['plate_number'] as String? ?? '',
        routeId: s.routeId,
        routeName: r['routes']?['name'] as String? ?? '',
        date: s.date,
        departureTime: s.departureTime,
        arrivalTime: s.arrivalTime,
        status: s.status,
      );
    }).toList();
  }

  Future<AdminSchedule> addSchedule(AdminSchedule schedule) async {
    final data = await _supabase
        .from('schedules')
        .insert({
          'bus_id': schedule.busId,
          'route_id': schedule.routeId,
          'date': schedule.date,
          'departure_time': schedule.departureTime,
          'arrival_time': schedule.arrivalTime,
          'status': schedule.status,
        })
        .select()
        .single();
    return _mapSchedule(data);
  }

  Future<AdminSchedule> updateSchedule(AdminSchedule schedule) async {
    final data = await _supabase
        .from('schedules')
        .update({
          'bus_id': schedule.busId,
          'route_id': schedule.routeId,
          'date': schedule.date,
          'departure_time': schedule.departureTime,
          'arrival_time': schedule.arrivalTime,
          'status': schedule.status,
        })
        .eq('id', schedule.id)
        .select()
        .single();
    return _mapSchedule(data);
  }

  Future<void> deleteSchedule(String id) async {
    await _supabase.from('schedules').delete().eq('id', id);
  }

  Future<List<AdminAlert>> getAlerts() async {
    final rows = await _supabase
        .from('alerts')
        .select('*')
        .order('created_at', ascending: false);
    return rows.map(_mapAlert).toList();
  }

  Future<AdminAlert> addAlert(AdminAlert alert) async {
    final user = _supabase.auth.currentUser;
    final data = await _supabase
        .from('alerts')
        .insert({
          'title': alert.title,
          'message': alert.message,
          'severity': alert.severity,
          'status': 'active',
          'created_by': user?.id,
        })
        .select()
        .single();
    return _mapAlert(data);
  }

  Future<AdminAlert> resolveAlert(String id, String resolvedBy) async {
    final user = _supabase.auth.currentUser;
    final data = await _supabase
        .from('alerts')
        .update({
          'status': 'resolved',
          'resolved_by': user?.id,
          'resolved_at': DateTime.now().toIso8601String(),
        })
        .eq('id', id)
        .select()
        .single();
    final alert = _mapAlert(data);
    return alert.copyWith(resolvedBy: resolvedBy);
  }

  Future<DashboardStats> getDashboardStats() async {
    final results = await Future.wait([
      _supabase.from('profiles').select('id').eq('role', 'student'),
      _supabase.from('buses').select('id').eq('status', 'active'),
      _supabase.from('routes').select('id').eq('status', 'active'),
      _supabase.from('alerts').select('id').eq('status', 'active'),
      _supabase.from('profiles').select('id').eq('role', 'staff'),
      _supabase.from('profiles').select('id').eq('role', 'parent'),
    ]);

    return DashboardStats(
      totalStudents: (results[0] as List).length,
      activeBuses: (results[1] as List).length,
      totalRoutes: (results[2] as List).length,
      pendingAlerts: (results[3] as List).length,
      totalStaff: (results[4] as List).length,
      linkedParents: (results[5] as List).length,
      onTimeRate: 87.5,
      boardedToday: 116,
    );
  }

  Future<List<ChartDataPoint>> getWeeklyBoarding() async {
    return [
      ChartDataPoint(label: 'Mon', value: 128),
      ChartDataPoint(label: 'Tue', value: 145),
      ChartDataPoint(label: 'Wed', value: 132),
      ChartDataPoint(label: 'Thu', value: 158),
      ChartDataPoint(label: 'Fri', value: 142),
      ChartDataPoint(label: 'Sat', value: 89),
      ChartDataPoint(label: 'Sun', value: 0),
    ];
  }

  Future<List<ChartDataPoint>> getRoutePerformance() async {
    return [
      ChartDataPoint(label: 'Route A', value: 92),
      ChartDataPoint(label: 'Route B', value: 85),
      ChartDataPoint(label: 'Route C', value: 78),
      ChartDataPoint(label: 'Route D', value: 0),
      ChartDataPoint(label: 'Route E', value: 88),
    ];
  }

  Future<List<ChartDataPoint>> getStudentDistribution() async {
    return [
      ChartDataPoint(label: 'Primary', value: 45),
      ChartDataPoint(label: 'Secondary', value: 68),
      ChartDataPoint(label: 'TVET', value: 23),
      ChartDataPoint(label: 'Special Needs', value: 8),
    ];
  }

  AdminUser _mapUser(Map<String, dynamic> row) {
    return AdminUser(
      id: row['id'] as String,
      name: row['name'] as String? ?? '',
      email: row['email'] as String? ?? '',
      role: row['role'] as String? ?? 'student',
      phone: row['phone'] as String?,
      school: row['school'] as String?,
      grade: row['grade'] as String?,
      isActive: row['is_active'] as bool? ?? true,
      createdAt: row['created_at'] != null
          ? DateTime.parse(row['created_at'] as String)
          : DateTime.now(),
    );
  }

  AdminBus _mapBus(Map<String, dynamic> row) {
    return AdminBus(
      id: row['id'] as String,
      plateNumber: row['plate_number'] as String? ?? '',
      capacity: row['capacity'] as int? ?? 0,
      driverName: row['driver_name'] as String? ?? '',
      driverPhone: row['driver_phone'] as String?,
      routeId: row['route_id'] as String?,
      routeName: null,
      status: row['status'] as String? ?? 'inactive',
      currentPassengers: row['current_passengers'] as int? ?? 0,
    );
  }

  AdminRoute _mapRoute(Map<String, dynamic> row) {
    return AdminRoute(
      id: row['id'] as String,
      name: row['name'] as String? ?? '',
      stops: (row['stops'] as List<dynamic>?)?.cast<String>() ?? [],
      status: row['status'] as String? ?? 'inactive',
    );
  }

  AdminSchedule _mapSchedule(Map<String, dynamic> row) {
    return AdminSchedule(
      id: row['id'] as String,
      busId: row['bus_id'] as String? ?? '',
      busPlate: '',
      routeId: row['route_id'] as String? ?? '',
      routeName: '',
      date: row['date'] as String? ?? '',
      departureTime: row['departure_time'] as String? ?? '',
      arrivalTime: row['arrival_time'] as String? ?? '',
      status: row['status'] as String? ?? 'scheduled',
    );
  }

  AdminAlert _mapAlert(Map<String, dynamic> row) {
    return AdminAlert(
      id: row['id'] as String,
      title: row['title'] as String? ?? '',
      message: row['message'] as String? ?? '',
      severity: row['severity'] as String? ?? 'low',
      status: row['status'] as String? ?? 'active',
      createdAt: row['created_at'] != null
          ? DateTime.parse(row['created_at'] as String)
          : DateTime.now(),
      resolvedBy: row['resolved_by_name'] as String?,
      resolvedAt: row['resolved_at'] != null
          ? DateTime.parse(row['resolved_at'] as String)
          : null,
    );
  }
}
