import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/admin_stats_card.dart';
import '../data/mock_admin_data.dart';
import '../models/admin_models.dart';
import '../../../core/theme/app_colors.dart';

class AdminBusesScreen extends ConsumerStatefulWidget {
  const AdminBusesScreen({super.key});

  @override
  ConsumerState<AdminBusesScreen> createState() => _AdminBusesScreenState();
}

class _AdminBusesScreenState extends ConsumerState<AdminBusesScreen> {
  List<AdminBus> _buses = [];
  List<AdminBus> _filtered = [];
  bool _loading = true;
  String _searchQuery = '';
  String _statusFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadBuses();
  }

  Future<void> _loadBuses() async {
    setState(() => _loading = true);
    final buses = await MockAdminData.getBuses();
    if (mounted) setState(() { _buses = buses; _applyFilter(); _loading = false; });
  }

  void _applyFilter() {
    _filtered = _buses.where((b) {
      if (_statusFilter != 'all' && b.status != _statusFilter) return false;
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        return b.plateNumber.toLowerCase().contains(q) || b.driverName.toLowerCase().contains(q) || b.id.toLowerCase().contains(q);
      }
      return true;
    }).toList();
  }

  Future<void> _showBusDialog({AdminBus? bus}) async {
    final plateCtrl = TextEditingController(text: bus?.plateNumber ?? '');
    final driverCtrl = TextEditingController(text: bus?.driverName ?? '');
    final phoneCtrl = TextEditingController(text: bus?.driverPhone ?? '');
    final capCtrl = TextEditingController(text: bus?.capacity.toString() ?? '45');
    final routes = await MockAdminData.getRoutes();
    String? routeId = bus?.routeId;
    String? routeName = bus?.routeName;
    String status = bus?.status ?? 'active';

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(bus != null ? 'Edit Bus' : 'Add New Bus'),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: plateCtrl, decoration: const InputDecoration(labelText: 'Plate Number', border: OutlineInputBorder())),
                  const SizedBox(height: 12),
                  TextField(controller: driverCtrl, decoration: const InputDecoration(labelText: 'Driver Name', border: OutlineInputBorder())),
                  const SizedBox(height: 12),
                  TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Driver Phone', border: OutlineInputBorder()), keyboardType: TextInputType.phone),
                  const SizedBox(height: 12),
                  TextField(controller: capCtrl, decoration: const InputDecoration(labelText: 'Capacity', border: OutlineInputBorder()), keyboardType: TextInputType.number),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: routeId,
                    decoration: const InputDecoration(labelText: 'Assigned Route', border: OutlineInputBorder()),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('None')),
                      ...routes.map((r) => DropdownMenuItem(value: r.id, child: Text(r.name))),
                    ],
                    onChanged: (v) => setDialogState(() { routeId = v; routeName = routes.firstWhere((r) => r.id == v).name; }),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: status,
                    decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
                    items: const [
                      DropdownMenuItem(value: 'active', child: Text('Active')),
                      DropdownMenuItem(value: 'maintenance', child: Text('Maintenance')),
                      DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
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
              onPressed: () => Navigator.pop(ctx, {'plateNumber': plateCtrl.text, 'driverName': driverCtrl.text, 'driverPhone': phoneCtrl.text, 'capacity': int.tryParse(capCtrl.text) ?? 45, 'routeId': routeId, 'routeName': routeName, 'status': status}),
              child: Text(bus != null ? 'Update' : 'Add Bus'),
            ),
          ],
        ),
      ),
    );

    if (result != null) {
      if (bus != null) {
        await MockAdminData.updateBus(bus.copyWith(
          plateNumber: result['plateNumber'], driverName: result['driverName'], driverPhone: result['driverPhone'],
          capacity: result['capacity'], routeId: result['routeId'], routeName: result['routeName'], status: result['status'],
        ));
      } else {
        await MockAdminData.addBus(AdminBus(
          id: MockAdminData.generateId('BUS'),
          plateNumber: result['plateNumber'], driverName: result['driverName'], driverPhone: result['driverPhone'],
          capacity: result['capacity'], routeId: result['routeId'], routeName: result['routeName'], status: result['status'],
        ));
      }
      _loadBuses();
    }

    plateCtrl.dispose(); driverCtrl.dispose(); phoneCtrl.dispose(); capCtrl.dispose();
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'active': return AppColors.success;
      case 'maintenance': return AppColors.warning;
      case 'inactive': return AppColors.error;
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
            title: 'Bus Management',
            subtitle: '${_buses.length} total buses',
            action: ElevatedButton.icon(
              onPressed: () => _showBusDialog(),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Bus'),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), elevation: 0),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
            child: Row(
              children: [
                SizedBox(
                  width: 280,
                  child: TextField(
                    onChanged: (v) { setState(() { _searchQuery = v; _applyFilter(); }); },
                    decoration: InputDecoration(
                      hintText: 'Search by plate, driver...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      filled: true,
                      fillColor: isDark ? AppColors.surfaceDark : Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    ),
                    style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimaryLight),
                  ),
                ),
                const SizedBox(width: 12),
                DropdownButton<String>(
                  value: _statusFilter,
                  dropdownColor: isDark ? AppColors.surfaceDark : Colors.white,
                  style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimaryLight),
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('All Status')),
                    DropdownMenuItem(value: 'active', child: Text('Active')),
                    DropdownMenuItem(value: 'maintenance', child: Text('Maintenance')),
                    DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
                  ],
                  onChanged: (v) { setState(() { _statusFilter = v!; _applyFilter(); }); },
                ),
                const Spacer(),
                Text('${_filtered.length} buses', style: TextStyle(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
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
                                DataColumn(label: Text('Plate #', style: TextStyle(fontWeight: FontWeight.w700))),
                                DataColumn(label: Text('Driver', style: TextStyle(fontWeight: FontWeight.w700))),
                                DataColumn(label: Text('Capacity', style: TextStyle(fontWeight: FontWeight.w700))),
                                DataColumn(label: Text('Route', style: TextStyle(fontWeight: FontWeight.w700))),
                                DataColumn(label: Text('Passengers', style: TextStyle(fontWeight: FontWeight.w700))),
                                DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.w700))),
                                DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.w700))),
                              ],
                              rows: _filtered.map((b) {
                                final textColor = isDark ? Colors.white : AppColors.textPrimaryLight;
                                final secondaryColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
                                return DataRow(cells: [
                                  DataCell(Text(b.plateNumber, style: TextStyle(fontWeight: FontWeight.w600, color: textColor))),
                                  DataCell(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    Text(b.driverName, style: TextStyle(color: textColor)),
                                    if (b.driverPhone != null) Text(b.driverPhone!, style: TextStyle(color: secondaryColor, fontSize: 11)),
                                  ])),
                                  DataCell(Text('${b.capacity}', style: TextStyle(color: textColor))),
                                  DataCell(Text(b.routeName ?? 'Unassigned', style: TextStyle(color: b.routeName != null ? textColor : secondaryColor))),
                                  DataCell(Text('${b.currentPassengers}/${b.capacity}', style: TextStyle(color: textColor))),
                                  DataCell(Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: _statusColor(b.status).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)), child: Text(b.status[0].toUpperCase() + b.status.substring(1), style: TextStyle(fontSize: 12, color: _statusColor(b.status), fontWeight: FontWeight.w600)))),
                                  DataCell(Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(icon: const Icon(Icons.edit, size: 18), onPressed: () => _showBusDialog(bus: b), color: AppColors.info),
                                      IconButton(icon: const Icon(Icons.delete, size: 18), onPressed: () async {
                                        final confirm = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(title: const Text('Delete Bus'), content: Text('Delete ${b.plateNumber}?'), actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')), ElevatedButton(onPressed: () => Navigator.pop(ctx, true), style: ElevatedButton.styleFrom(backgroundColor: AppColors.error), child: const Text('Delete'))]));
                                        if (confirm == true) { await MockAdminData.deleteBus(b.id); _loadBuses(); }
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
