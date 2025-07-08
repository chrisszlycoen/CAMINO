class Student {
  final String id;
  final String name;
  final String school;
  final String grade;
  final String photoUrl;
  final int points;
  final int streakDays;

  const Student({
    required this.id,
    required this.name,
    required this.school,
    required this.grade,
    required this.photoUrl,
    this.streakDays = 0,
    this.points = 0,
  });
}

class Bus {
  final String id;
  final String routeName;
  final int capacity;
  final int currentPassengers;
  final String status; // 'Ready', 'En Route', 'Arrived'
  final String driverName;

  const Bus({
    required this.id,
    required this.routeName,
    required this.capacity,
    required this.currentPassengers,
    required this.status,
    required this.driverName,
  });
}

class Trip {
  final String id;
  final Bus bus;
  final String date;
  final String time;
  final String fromStop;
  final String toStop;
  final String status;

  const Trip({
    required this.id,
    required this.bus,
    required this.date,
    required this.time,
    required this.fromStop,
    required this.toStop,
    required this.status,
  });
}

