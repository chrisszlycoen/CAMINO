import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/admin_stats_card.dart';
import '../../../data/admin_service_provider.dart';
import '../models/admin_models.dart';
import '../../../core/theme/app_colors.dart';

class AdminSchedulesScreen extends ConsumerStatefulWidget {
  const AdminSchedulesScreen({super.key});

  @override
  ConsumerState<AdminSchedulesScreen> createState() => _AdminSchedulesScreenState();
}

class _AdminSchedulesScreenState extends ConsumerState<AdminSchedulesScreen> {
  List<AdminSchedule> _schedules = [];
  List<AdminSchedule> _filtered = [];
  bool _loading = true;
  String _statusFilter = 'all';
  String _dateFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadSchedules();
  }

  Future<void> _loadSchedules() async {
    setState(() => _loading = true);
    final service = ref.read(supabaseAdminServiceProvider);
    final schedules = await service.getSchedules();
    if (mounted) setState(() { _schedules = schedules; _applyFilter(); _loading = false; });
  }

  void _applyFilter() {
    final today = DateTime.now().toIso8601String().split('T')[0];
    _filtered = _schedules.where((s) {
      if (_statusFilter != 'all' && s.status != _statusFilter) return false;
      if (_dateFilter == 'today' && s.date != today) return false;
      return true;
    }).toList();
  }

  Future<void> _showScheduleDialog({AdminSchedule? schedule}) async {
    final service = ref.read(supabaseAdminServiceProvider);
    final buses = await service.getBuses();
    final routes = await service.getRoutes();
    if (!mounted) return;
    String? busId = schedule?.busId;
    String? busPlate = schedule?.busPlate;
    String? routeId = schedule?.routeId;
    String? routeName = schedule?.routeName;
    final dateCtrl = TextEditingController(text: schedule?.date ?? DateTime.now().toIso8601String().split('T')[0]);
    final depCtrl = TextEditingController(text: schedule?.departureTime ?? '06:30');
    final arrCtrl = TextEditingController(text: schedule?.arrivalTime ?? '08:00');
    String status = schedule?.status ?? 'scheduled';

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(schedule != null ? 'Edit Schedule' : 'New Schedule'),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: busId,
                    decoration: const InputDecoration(labelText: 'Bus', border: OutlineInputBorder()),
                    items: buses.where((b) => b.status == 'active').map((b) => DropdownMenuItem(value: b.id, child: Text('${b.plateNumber} - ${b.driverName}'))).toList(),
                    onChanged: (v) => setDialogState(() { busId = v; busPlate = buses.firstWhere((b) => b.id == v).plateNumber; }),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: routeId,
                    decoration: const InputDecoration(labelText: 'Route', border: OutlineInputBorder()),
                    items: routes.where((r) => r.status == 'active').map((r) => DropdownMenuItem(value: r.id, child: Text(r.name))).toList(),
                    onChanged: (v) => setDialogState(() { routeId = v; routeName = routes.firstWhere((r) => r.id == v).name; }),
                  ),
                  const SizedBox(height: 12),
                  TextField(controller: dateCtrl, decoration: const InputDecoration(labelText: 'Date (YYYY-MM-DD)', border: OutlineInputBorder())),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: TextField(controller: depCtrl, decoration: const InputDecoration(labelText: 'Departure', border: OutlineInputBorder(), hintText: '06:30'))),
                      const SizedBox(width: 12),
                      Expanded(child: TextField(controller: arrCtrl, decoration: const InputDecoration(labelText: 'Arrival', border: OutlineInputBorder(), hintText: '08:00'))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: status,
                    decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
                    items: const [
                      DropdownMenuItem(value: 'scheduled', child: Text('Scheduled')),
                      DropdownMenuItem(value: 'in-progress', child: Text('In Progress')),
                      DropdownMenuItem(value: 'completed', child: Text('Completed')),
                      DropdownMenuItem(value: 'cancelled', child: Text('Cancelled')),
                    ],
                    onChanged: (v) => setDialogState(() => status = v!),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, {'busId': busId, 'busPlate': busPlate, 'routeId': routeId, 'routeName': routeName, 'date': dateCtrl.text, 'departureTime': depCtrl.text, 'arrivalTime': arrCtrl.text, 'status': status}),
              child: Text(schedule != null ? 'Update' : 'Add Schedule'),
            ),
          ],
        ),
      ),
    );

    if (result != null) {
      if (schedule != null) {
        await service.updateSchedule(schedule.copyWith(
          busId: result['busId'], busPlate: result['busPlate'], routeId: result['routeId'],
          routeName: result['routeName'], date: result['date'], departureTime: result['departureTime'],
          arrivalTime: result['arrivalTime'], status: result['status'],
        ));
      } else {
        await service.addSchedule(AdminSchedule(
          id: '',
          busId: result['busId'], busPlate: result['busPlate'], routeId: result['routeId'],
          routeName: result['routeName'], date: result['date'], departureTime: result['departureTime'],
          arrivalTime: result['arrivalTime'], status: result['status'],
        ));
      }
      _loadSchedules();
    }
    dateCtrl.dispose(); depCtrl.dispose(); arrCtrl.dispose();
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'completed': return AppColors.success;
      case 'in-progress': return AppColors.info;
      case 'scheduled': return AppColors.warning;
      case 'cancelled': return AppColors.error;
      default: return AppColors.textSecondaryDark;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.backgroundDark : const Color(0xFFF5F5F7);

    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          AdminPageHeader(
            title: 'Schedule Management',
            subtitle: '${_schedules.length} total schedules',
            action: ElevatedButton.icon(
              onPressed: () => _showScheduleDialog(),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('New Schedule'),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), elevation: 0),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
            child: Row(
              children: [
                DropdownButton<String>(
                  value: _dateFilter,
                  dropdownColor: isDark ? AppColors.surfaceDark : Colors.white,
                  style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimaryLight),
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('All Dates')),
                    DropdownMenuItem(value: 'today', child: Text('Today')),
                  ],
                  onChanged: (v) { setState(() { _dateFilter = v!; _applyFilter(); }); },
                ),
                const SizedBox(width: 12),
                DropdownButton<String>(
                  value: _statusFilter,
                  dropdownColor: isDark ? AppColors.surfaceDark : Colors.white,
                  style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimaryLight),
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('All Status')),
                    DropdownMenuItem(value: 'scheduled', child: Text('Scheduled')),
                    DropdownMenuItem(value: 'in-progress', child: Text('In Progress')),
                    DropdownMenuItem(value: 'completed', child: Text('Completed')),
                    DropdownMenuItem(value: 'cancelled', child: Text('Cancelled')),
                  ],
                  onChanged: (v) { setState(() { _statusFilter = v!; _applyFilter(); }); },
                ),
                const Spacer(),
                Text('${_filtered.length} schedules', style: TextStyle(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceDark : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: isDark ? AppColors.borderDark : Colors.grey.shade200),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              columnSpacing: 24,
                              headingRowColor: WidgetStatePropertyAll(isDark ? AppColors.surfaceDarkElevated : const Color(0xFFF5F5F7)),
                              columns: const [
                                DataColumn(label: Text('Route', style: TextStyle(fontWeight: FontWeight.w700))),
                                DataColumn(label: Text('Bus', style: TextStyle(fontWeight: FontWeight.w700))),
                                DataColumn(label: Text('Date', style: TextStyle(fontWeight: FontWeight.w700))),
                                DataColumn(label: Text('Departure', style: TextStyle(fontWeight: FontWeight.w700))),
                                DataColumn(label: Text('Arrival', style: TextStyle(fontWeight: FontWeight.w700))),
                                DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.w700))),
                                DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.w700))),
                              ],
                              rows: _filtered.map((s) {
                                final textColor = isDark ? Colors.white : AppColors.textPrimaryLight;
                                final secondaryColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
                                return DataRow(cells: [
                                  DataCell(Text(s.routeName, style: TextStyle(fontWeight: FontWeight.w500, color: textColor))),
                                  DataCell(Text(s.busPlate, style: TextStyle(color: textColor))),
                                  DataCell(Text(s.date, style: TextStyle(color: secondaryColor))),
                                  DataCell(Text(s.departureTime, style: TextStyle(fontWeight: FontWeight.w600, color: textColor))),
                                  DataCell(Text(s.arrivalTime, style: TextStyle(color: textColor))),
                                  DataCell(Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: _statusColor(s.status).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)), child: Text(s.status[0].toUpperCase() + s.status.substring(1), style: TextStyle(fontSize: 12, color: _statusColor(s.status), fontWeight: FontWeight.w600)))),
                                  DataCell(Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(icon: const Icon(Icons.edit, size: 18), onPressed: () => _showScheduleDialog(schedule: s), color: AppColors.info),
                                      IconButton(icon: const Icon(Icons.delete, size: 18), onPressed: () async {
                                        final confirm = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(title: const Text('Delete Schedule'), content: Text('Delete ${s.id}?'), actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')), ElevatedButton(onPressed: () => Navigator.pop(ctx, true), style: ElevatedButton.styleFrom(backgroundColor: AppColors.error), child: const Text('Delete'))]));
                                        if (confirm == true) {
                                          final service = ref.read(supabaseAdminServiceProvider);
                                          await service.deleteSchedule(s.id);
                                          _loadSchedules();
                                        }
                                      }, color: AppColors.error),
                                    ],
                                  )),
                                ]);
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
