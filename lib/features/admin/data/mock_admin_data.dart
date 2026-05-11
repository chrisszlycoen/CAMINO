import 'dart:math';
import '../models/admin_models.dart';

class MockAdminData {
  static final Random _random = Random();

  static List<AdminUser> _users = [
    AdminUser(id: 'USR-001', name: 'Jean Niyonzima', email: 'jean@student.rw', role: 'student', school: 'Kigali International Community School', grade: 'Grade 10', phone: '+250781234501', createdAt: DateTime(2026, 1, 15)),
    AdminUser(id: 'USR-002', name: 'Mia Thompson', email: 'mia@student.rw', role: 'student', school: 'KICS', grade: 'Grade 4', phone: '+250781234502', createdAt: DateTime(2026, 1, 20)),
    AdminUser(id: 'USR-003', name: 'Noah Davis', email: 'noah@student.rw', role: 'student', school: 'KICS', grade: 'Grade 5', phone: '+250781234503', createdAt: DateTime(2026, 2, 1)),
    AdminUser(id: 'USR-004', name: 'Ava Martinez', email: 'ava@student.rw', role: 'student', school: 'KICS', grade: 'Grade 3', phone: '+250781234504', createdAt: DateTime(2026, 2, 5)),
    AdminUser(id: 'USR-005', name: 'Liam Wilson', email: 'liam@student.rw', role: 'student', school: 'KICS', grade: 'Grade 6', phone: '+250781234505', createdAt: DateTime(2026, 2, 10)),
    AdminUser(id: 'USR-006', name: 'Sarah Uwimana', email: 'sarah@parent.rw', role: 'parent', phone: '+250781234600', createdAt: DateTime(2026, 1, 10)),
    AdminUser(id: 'USR-007', name: 'David Habimana', email: 'david@parent.rw', role: 'parent', phone: '+250781234601', createdAt: DateTime(2026, 1, 12)),
    AdminUser(id: 'USR-008', name: 'Grace Uwase', email: 'grace@parent.rw', role: 'parent', phone: '+250781234602', createdAt: DateTime(2026, 1, 14)),
    AdminUser(id: 'USR-009', name: 'Alex Rukundo', email: 'alex@staff.rw', role: 'staff', phone: '+250781234700', createdAt: DateTime(2026, 1, 5)),
    AdminUser(id: 'USR-010', name: 'Patrick Mugisha', email: 'patrick@staff.rw', role: 'staff', phone: '+250781234701', createdAt: DateTime(2026, 1, 8)),
    AdminUser(id: 'USR-011', name: 'Diane Nyiraneza', email: 'diane@staff.rw', role: 'staff', phone: '+250781234702', createdAt: DateTime(2026, 1, 20)),
    AdminUser(id: 'USR-012', name: 'Admin System', email: 'admin@camino.rw', role: 'admin', createdAt: DateTime(2025, 12, 1)),
  ];

  static List<AdminBus> _buses = [
    AdminBus(id: 'BUS-001', plateNumber: 'RAC 123 A', capacity: 45, driverName: 'Alex Rukundo', driverPhone: '+250781234700', routeId: 'RTE-001', routeName: 'Route A', status: 'active', currentPassengers: 32),
    AdminBus(id: 'BUS-002', plateNumber: 'RAC 456 B', capacity: 50, driverName: 'Patrick Mugisha', driverPhone: '+250781234701', routeId: 'RTE-002', routeName: 'Route B', status: 'active', currentPassengers: 41),
    AdminBus(id: 'BUS-003', plateNumber: 'RAC 789 C', capacity: 40, driverName: 'Diane Nyiraneza', driverPhone: '+250781234702', routeId: 'RTE-003', routeName: 'Route C', status: 'active', currentPassengers: 28),
    AdminBus(id: 'BUS-004', plateNumber: 'RAC 321 D', capacity: 55, driverName: 'Jean Claude', driverPhone: '+250781234703', status: 'maintenance'),
    AdminBus(id: 'BUS-005', plateNumber: 'RAC 654 E', capacity: 35, driverName: 'Marie Louise', driverPhone: '+250781234704', status: 'active', currentPassengers: 15),
  ];

  static List<AdminRoute> _routes = [
    AdminRoute(id: 'RTE-001', name: 'Route A', stops: ['Gishushu Stop', 'Amahoro Stadium', 'Kigali Heights', 'Kacyiru', 'Nyabugogo'], status: 'active'),
    AdminRoute(id: 'RTE-002', name: 'Route B', stops: ['Kimironko', 'Remera', 'Kicukiro', 'Airport Road'], status: 'active'),
    AdminRoute(id: 'RTE-003', name: 'Route C', stops: ['Nyamirambo', 'Muhima', 'Kiyovu', 'Kanombe'], status: 'active'),
    AdminRoute(id: 'RTE-004', name: 'Route D', stops: ['Gisozi', 'Jali', 'Nduba'], status: 'inactive'),
    AdminRoute(id: 'RTE-005', name: 'Route E', stops: ['Niboye', 'Kabeza', 'Rwampara', 'Busanza'], status: 'active'),
  ];

  static List<AdminSchedule> _schedules = [
    AdminSchedule(id: 'SCH-001', busId: 'BUS-001', busPlate: 'RAC 123 A', routeId: 'RTE-001', routeName: 'Route A', date: '2026-05-11', departureTime: '06:30', arrivalTime: '08:15', status: 'completed'),
    AdminSchedule(id: 'SCH-002', busId: 'BUS-002', busPlate: 'RAC 456 B', routeId: 'RTE-002', routeName: 'Route B', date: '2026-05-11', departureTime: '06:45', arrivalTime: '08:30', status: 'completed'),
    AdminSchedule(id: 'SCH-003', busId: 'BUS-003', busPlate: 'RAC 789 C', routeId: 'RTE-003', routeName: 'Route C', date: '2026-05-11', departureTime: '07:00', arrivalTime: '08:45', status: 'completed'),
    AdminSchedule(id: 'SCH-004', busId: 'BUS-001', busPlate: 'RAC 123 A', routeId: 'RTE-001', routeName: 'Route A', date: '2026-05-11', departureTime: '15:30', arrivalTime: '17:00', status: 'scheduled'),
    AdminSchedule(id: 'SCH-005', busId: 'BUS-002', busPlate: 'RAC 456 B', routeId: 'RTE-002', routeName: 'Route B', date: '2026-05-11', departureTime: '15:45', arrivalTime: '17:15', status: 'in-progress'),
    AdminSchedule(id: 'SCH-006', busId: 'BUS-005', busPlate: 'RAC 654 E', routeId: 'RTE-005', routeName: 'Route E', date: '2026-05-11', departureTime: '16:00', arrivalTime: '17:30', status: 'scheduled'),
    AdminSchedule(id: 'SCH-007', busId: 'BUS-003', busPlate: 'RAC 789 C', routeId: 'RTE-003', routeName: 'Route C', date: '2026-05-12', departureTime: '06:30', arrivalTime: '08:15', status: 'scheduled'),
    AdminSchedule(id: 'SCH-008', busId: 'BUS-005', busPlate: 'RAC 654 E', routeId: 'RTE-005', routeName: 'Route E', date: '2026-05-12', departureTime: '07:00', arrivalTime: '08:30', status: 'scheduled'),
  ];

  static List<AdminAlert> _alerts = [
    AdminAlert(id: 'ALR-001', title: 'Bus #12 Engine Issue', message: 'Bus RAC 123 A reported engine overheating at Gishushu Stop.', severity: 'high', status: 'active', createdAt: DateTime.now().subtract(const Duration(hours: 2))),
    AdminAlert(id: 'ALR-002', title: 'Route B Traffic Delay', message: 'Heavy traffic on Route B causing estimated 20 min delay.', severity: 'medium', status: 'active', createdAt: DateTime.now().subtract(const Duration(hours: 1))),
    AdminAlert(id: 'ALR-003', title: 'Student Left Belongings', message: 'A backpack was found on Bus #12 after morning route.', severity: 'low', status: 'resolved', createdAt: DateTime.now().subtract(const Duration(days: 1)), resolvedBy: 'Admin System', resolvedAt: DateTime.now().subtract(const Duration(hours: 12))),
    AdminAlert(id: 'ALR-004', title: 'Road Construction Alert', message: 'Roadworks on KG 14 Ave affecting Route C schedule.', severity: 'medium', status: 'active', createdAt: DateTime.now().subtract(const Duration(minutes: 30))),
  ];

  static Future<List<AdminUser>> getUsers() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_users);
  }

  static Future<List<AdminUser>> getUsersByRole(String role) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _users.where((u) => u.role == role).toList();
  }

  static Future<AdminUser> addUser(AdminUser user) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _users.add(user);
    return user;
  }

  static Future<AdminUser> updateUser(AdminUser user) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _users.indexWhere((u) => u.id == user.id);
    if (index != -1) _users[index] = user;
    return user;
  }

  static Future<void> deleteUser(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _users.removeWhere((u) => u.id == id);
  }

  static Future<List<AdminBus>> getBuses() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_buses);
  }

  static Future<AdminBus> addBus(AdminBus bus) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _buses.add(bus);
    return bus;
  }

  static Future<AdminBus> updateBus(AdminBus bus) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _buses.indexWhere((b) => b.id == bus.id);
    if (index != -1) _buses[index] = bus;
    return bus;
  }

  static Future<void> deleteBus(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _buses.removeWhere((b) => b.id == id);
  }

  static Future<List<AdminRoute>> getRoutes() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_routes);
  }

  static Future<AdminRoute> addRoute(AdminRoute route) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _routes.add(route);
    return route;
  }

  static Future<AdminRoute> updateRoute(AdminRoute route) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _routes.indexWhere((r) => r.id == route.id);
    if (index != -1) _routes[index] = route;
    return route;
  }

  static Future<void> deleteRoute(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _routes.removeWhere((r) => r.id == id);
  }

  static Future<List<AdminSchedule>> getSchedules() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_schedules);
  }

  static Future<AdminSchedule> addSchedule(AdminSchedule schedule) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _schedules.add(schedule);
    return schedule;
  }

  static Future<AdminSchedule> updateSchedule(AdminSchedule schedule) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _schedules.indexWhere((s) => s.id == schedule.id);
    if (index != -1) _schedules[index] = schedule;
    return schedule;
  }

  static Future<void> deleteSchedule(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _schedules.removeWhere((s) => s.id == id);
  }

  static Future<List<AdminAlert>> getAlerts() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_alerts);
  }

  static Future<AdminAlert> addAlert(AdminAlert alert) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _alerts.insert(0, alert);
    return alert;
  }

  static Future<AdminAlert> resolveAlert(String id, String resolvedBy) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _alerts.indexWhere((a) => a.id == id);
    if (index != -1) {
      _alerts[index] = _alerts[index].copyWith(
        status: 'resolved',
        resolvedBy: resolvedBy,
        resolvedAt: DateTime.now(),
      );
    }
    return _alerts[index];
  }

  static Future<DashboardStats> getDashboardStats() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return DashboardStats(
      totalStudents: _users.where((u) => u.role == 'student').length,
      activeBuses: _buses.where((b) => b.status == 'active').length,
      totalRoutes: _routes.where((r) => r.status == 'active').length,
      onTimeRate: 87.5,
      pendingAlerts: _alerts.where((a) => a.status == 'active').length,
      boardedToday: 116,
      totalStaff: _users.where((u) => u.role == 'staff').length,
      linkedParents: _users.where((u) => u.role == 'parent').length,
    );
  }

  static Future<List<ChartDataPoint>> getWeeklyBoarding() async {
    await Future.delayed(const Duration(milliseconds: 200));
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

  static Future<List<ChartDataPoint>> getRoutePerformance() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return [
      ChartDataPoint(label: 'Route A', value: 92),
      ChartDataPoint(label: 'Route B', value: 85),
      ChartDataPoint(label: 'Route C', value: 78),
      ChartDataPoint(label: 'Route D', value: 0),
      ChartDataPoint(label: 'Route E', value: 88),
    ];
  }

  static Future<List<ChartDataPoint>> getStudentDistribution() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return [
      ChartDataPoint(label: 'Primary', value: 45),
      ChartDataPoint(label: 'Secondary', value: 68),
      ChartDataPoint(label: 'TVET', value: 23),
      ChartDataPoint(label: 'Special Needs', value: 8),
    ];
  }

  static String generateId(String prefix) {
    final num = _random.nextInt(9000) + 1000;
    return '$prefix-$num';
  }
}
