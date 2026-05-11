class AdminUser {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? school;
  final String? grade;
  final String? phone;
  final bool isActive;
  final DateTime createdAt;

  const AdminUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.school,
    this.grade,
    this.phone,
    this.isActive = true,
    required this.createdAt,
  });

  AdminUser copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    String? school,
    String? grade,
    String? phone,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return AdminUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      school: school ?? this.school,
      grade: grade ?? this.grade,
      phone: phone ?? this.phone,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'email': email, 'role': role,
    'school': school, 'grade': grade, 'phone': phone,
    'isActive': isActive, 'createdAt': createdAt.toIso8601String(),
  };

  factory AdminUser.fromJson(Map<String, dynamic> json) => AdminUser(
    id: json['id'] as String,
    name: json['name'] as String,
    email: json['email'] as String,
    role: json['role'] as String,
    school: json['school'] as String?,
    grade: json['grade'] as String?,
    phone: json['phone'] as String?,
    isActive: json['isActive'] as bool? ?? true,
    createdAt: DateTime.parse(json['createdAt'] as String),
  );
}

class AdminBus {
  final String id;
  final String plateNumber;
  final int capacity;
  final String driverName;
  final String? driverPhone;
  final String? routeId;
  final String? routeName;
  final String status;
  final int currentPassengers;

  const AdminBus({
    required this.id,
    required this.plateNumber,
    required this.capacity,
    required this.driverName,
    this.driverPhone,
    this.routeId,
    this.routeName,
    this.status = 'active',
    this.currentPassengers = 0,
  });

  AdminBus copyWith({
    String? id,
    String? plateNumber,
    int? capacity,
    String? driverName,
    String? driverPhone,
    String? routeId,
    String? routeName,
    String? status,
    int? currentPassengers,
  }) {
    return AdminBus(
      id: id ?? this.id,
      plateNumber: plateNumber ?? this.plateNumber,
      capacity: capacity ?? this.capacity,
      driverName: driverName ?? this.driverName,
      driverPhone: driverPhone ?? this.driverPhone,
      routeId: routeId ?? this.routeId,
      routeName: routeName ?? this.routeName,
      status: status ?? this.status,
      currentPassengers: currentPassengers ?? this.currentPassengers,
    );
  }
}

class AdminRoute {
  final String id;
  final String name;
  final List<String> stops;
  final String status;

  const AdminRoute({
    required this.id,
    required this.name,
    required this.stops,
    this.status = 'active',
  });

  AdminRoute copyWith({
    String? id,
    String? name,
    List<String>? stops,
    String? status,
  }) {
    return AdminRoute(
      id: id ?? this.id,
      name: name ?? this.name,
      stops: stops ?? this.stops,
      status: status ?? this.status,
    );
  }
}

class AdminSchedule {
  final String id;
  final String busId;
  final String busPlate;
  final String routeId;
  final String routeName;
  final String date;
  final String departureTime;
  final String arrivalTime;
  final String status;

  const AdminSchedule({
    required this.id,
    required this.busId,
    required this.busPlate,
    required this.routeId,
    required this.routeName,
    required this.date,
    required this.departureTime,
    required this.arrivalTime,
    this.status = 'scheduled',
  });

  AdminSchedule copyWith({
    String? id,
    String? busId,
    String? busPlate,
    String? routeId,
    String? routeName,
    String? date,
    String? departureTime,
    String? arrivalTime,
    String? status,
  }) {
    return AdminSchedule(
      id: id ?? this.id,
      busId: busId ?? this.busId,
      busPlate: busPlate ?? this.busPlate,
      routeId: routeId ?? this.routeId,
      routeName: routeName ?? this.routeName,
      date: date ?? this.date,
      departureTime: departureTime ?? this.departureTime,
      arrivalTime: arrivalTime ?? this.arrivalTime,
      status: status ?? this.status,
    );
  }
}

class AdminAlert {
  final String id;
  final String title;
  final String message;
  final String severity;
  final String status;
  final DateTime createdAt;
  final String? resolvedBy;
  final DateTime? resolvedAt;

  const AdminAlert({
    required this.id,
    required this.title,
    required this.message,
    required this.severity,
    this.status = 'active',
    required this.createdAt,
    this.resolvedBy,
    this.resolvedAt,
  });

  AdminAlert copyWith({
    String? id,
    String? title,
    String? message,
    String? severity,
    String? status,
    DateTime? createdAt,
    String? resolvedBy,
    DateTime? resolvedAt,
  }) {
    return AdminAlert(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      severity: severity ?? this.severity,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      resolvedBy: resolvedBy ?? this.resolvedBy,
      resolvedAt: resolvedAt ?? this.resolvedAt,
    );
  }
}

class DashboardStats {
  final int totalStudents;
  final int activeBuses;
  final int totalRoutes;
  final double onTimeRate;
  final int pendingAlerts;
  final int boardedToday;
  final int totalStaff;
  final int linkedParents;

  const DashboardStats({
    this.totalStudents = 0,
    this.activeBuses = 0,
    this.totalRoutes = 0,
    this.onTimeRate = 0,
    this.pendingAlerts = 0,
    this.boardedToday = 0,
    this.totalStaff = 0,
    this.linkedParents = 0,
  });
}

class ChartDataPoint {
  final String label;
  final double value;

  const ChartDataPoint({required this.label, required this.value});
}
