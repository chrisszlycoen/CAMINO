import '../shared/models/models.dart';

class MockData {
  static const currentUser = Student(
    id: 'RW-STU-104',
    name: 'Jean N.',
    school: 'Kigali International Community School',
    grade: 'Grade 10',
    photoUrl: 'assets/images/placeholder_avatar.png',
    points: 450,
    streakDays: 12,
  );

  static const activeBus = Bus(
    id: 'Bus #12',
    routeName: 'Route A',
    capacity: 45,
    currentPassengers: 32,
    status: 'Ready',
    driverName: 'Alex R.',
  );

  static const nextTrip = Trip(
    id: 'TRP-001',
    bus: activeBus,
    date: 'Oct 25, 2026',
    time: '09:15 AM',
    fromStop: 'Gishushu Stop',
    toStop: 'REMERA',
    status: 'Ready to Board',
  );

  static const futureTrip = Trip(
    id: 'TRP-002',
    bus: activeBus,
    date: 'Oct 25, 2026',
    time: '04:15 PM',
    fromStop: 'REMERA',
    toStop: 'KACYIRU',
    status: 'Scheduled',
  );

  static final allStudents = [
    currentUser,
    const Student(id: 'RW-STU-105', name: 'Mia Thompson', school: 'KICS', grade: 'Grade 4', photoUrl: ''),
    const Student(id: 'RW-STU-106', name: 'Noah Davis', school: 'KICS', grade: 'Grade 5', photoUrl: ''),
    const Student(id: 'RW-STU-107', name: 'Ava Martinez', school: 'KICS', grade: 'Grade 3', photoUrl: ''),
    const Student(id: 'RW-STU-108', name: 'Liam Wilson', school: 'KICS', grade: 'Grade 6', photoUrl: ''),
  ];

  static const notifications = <CaminoNotification>[
    CaminoNotification(
      id: 'notif_bus_arriving',
      title: 'Bus #12 is arriving',
      message: 'Your bus will reach Gishushu Stop in 5 mins.',
      timeLabel: 'Just now',
      category: 'bus',
      isUnread: true,
    ),
    CaminoNotification(
      id: 'notif_payment_received',
      title: 'Payment Received',
      message: 'Term 3 transport fee has been received.',
      timeLabel: '2 days ago',
      category: 'payment',
    ),
    CaminoNotification(
      id: 'notif_schedule_change',
      title: 'Schedule Change',
      message: 'Tomorrow\'s afternoon trip #13 is delayed by 15 mins.',
      timeLabel: 'Oct 23',
      category: 'schedule',
    ),
  ];
}
