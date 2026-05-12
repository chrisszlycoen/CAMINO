import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/admin_stats_card.dart';
import '../../../data/admin_service_provider.dart';
import '../models/admin_models.dart';
import '../../../core/theme/app_colors.dart';

class AdminRoutesScreen extends ConsumerStatefulWidget {
  const AdminRoutesScreen({super.key});

  @override
  ConsumerState<AdminRoutesScreen> createState() => _AdminRoutesScreenState();
}

class _AdminRoutesScreenState extends ConsumerState<AdminRoutesScreen> {
  List<AdminRoute> _routes = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadRoutes();
  }

  Future<void> _loadRoutes() async {
    setState(() => _loading = true);
    final service = ref.read(supabaseAdminServiceProvider);
    final routes = await service.getRoutes();
    if (mounted) setState(() { _routes = routes; _loading = false; });
  }

  Future<void> _showRouteDialog({AdminRoute? route}) async {
    final nameCtrl = TextEditingController(text: route?.name ?? '');
    String status = route?.status ?? 'active';
    final stopsCtrl = TextEditingController(text: route?.stops.join('\n') ?? '');

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(route != null ? 'Edit Route' : 'Add New Route'),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Route Name', border: OutlineInputBorder())),
                  const SizedBox(height: 12),
                  TextField(controller: stopsCtrl, decoration: const InputDecoration(labelText: 'Stops (one per line)', border: OutlineInputBorder(), hintText: 'Stop 1\nStop 2\nStop 3'), maxLines: 5),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: status,
                    decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
                    items: const [
                      DropdownMenuItem(value: 'active', child: Text('Active')),
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
              onPressed: () => Navigator.pop(ctx, {'name': nameCtrl.text, 'stops': stopsCtrl.text.split('\n').map((s) => s.trim()).where((s) => s.isNotEmpty).toList(), 'status': status}),
              child: Text(route != null ? 'Update' : 'Add Route'),
            ),
          ],
        ),
      ),
    );

    if (result != null) {
      final service = ref.read(supabaseAdminServiceProvider);
      if (route != null) {
        await service.updateRoute(route.copyWith(
          name: result['name'], stops: List<String>.from(result['stops']), status: result['status'],
        ));
      } else {
        await service.addRoute(AdminRoute(
          id: '',
          name: result['name'], stops: List<String>.from(result['stops']), status: result['status'],
        ));
      }
      _loadRoutes();
    }

    nameCtrl.dispose(); stopsCtrl.dispose();
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
            title: 'Route Management',
            subtitle: '${_routes.length} total routes',
            action: ElevatedButton.icon(
              onPressed: () => _showRouteDialog(),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Route'),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), elevation: 0),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                    children: _routes.map((r) {
                      final textColor = isDark ? Colors.white : AppColors.textPrimaryLight;
                      final secondaryColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
                      final cardBg = isDark ? AppColors.surfaceDark : Colors.white;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Container(
                          decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: isDark ? AppColors.borderDark : Colors.grey.shade200)),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 40, height: 40,
                                      decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                                      child: const Icon(Icons.map, color: AppColors.primary, size: 20),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(r.name, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: textColor)),
                                          Text('${r.stops.length} stops • ${r.status}', style: TextStyle(color: secondaryColor, fontSize: 12)),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(color: (r.status == 'active' ? AppColors.success : AppColors.error).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                                      child: Text(r.status[0].toUpperCase() + r.status.substring(1), style: TextStyle(fontSize: 12, color: r.status == 'active' ? AppColors.success : AppColors.error, fontWeight: FontWeight.w600)),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(icon: const Icon(Icons.edit, size: 18), onPressed: () => _showRouteDialog(route: r), color: AppColors.info),
                                    IconButton(icon: const Icon(Icons.delete, size: 18), onPressed: () async {
                                      final confirm = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(title: const Text('Delete Route'), content: Text('Delete ${r.name}?'), actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')), ElevatedButton(onPressed: () => Navigator.pop(ctx, true), style: ElevatedButton.styleFrom(backgroundColor: AppColors.error), child: const Text('Delete'))]));
                                      if (confirm == true) {
                                        final service = ref.read(supabaseAdminServiceProvider);
                                        await service.deleteRoute(r.id);
                                        _loadRoutes();
                                      }
                                    }, color: AppColors.error),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                ...r.stops.asMap().entries.map((entry) {
                                  final isLast = entry.key == r.stops.length - 1;
                                  return Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Column(
                                        children: [
                                          Container(width: 10, height: 10, decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
                                          if (!isLast) Container(width: 2, height: 24, color: isDark ? AppColors.borderDark : Colors.grey.shade300),
                                        ],
                                      ),
                                      const SizedBox(width: 12),
                                      Padding(
                                        padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
                                        child: Text(entry.value, style: TextStyle(color: textColor, fontSize: 14)),
                                      ),
                                    ],
                                  );
                                }),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }
}
