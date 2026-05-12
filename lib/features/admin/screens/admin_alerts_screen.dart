import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/admin_stats_card.dart';
import '../../../data/admin_service_provider.dart';
import '../models/admin_models.dart';
import '../../../core/theme/app_colors.dart';

class AdminAlertsScreen extends ConsumerStatefulWidget {
  const AdminAlertsScreen({super.key});

  @override
  ConsumerState<AdminAlertsScreen> createState() => _AdminAlertsScreenState();
}

class _AdminAlertsScreenState extends ConsumerState<AdminAlertsScreen> {
  List<AdminAlert> _alerts = [];
  List<AdminAlert> _filtered = [];
  bool _loading = true;
  String _filter = 'all';

  @override
  void initState() {
    super.initState();
    _loadAlerts();
  }

  Future<void> _loadAlerts() async {
    setState(() => _loading = true);
    final service = ref.read(supabaseAdminServiceProvider);
    final alerts = await service.getAlerts();
    if (mounted) setState(() { _alerts = alerts; _applyFilter(); _loading = false; });
  }

  void _applyFilter() {
    _filtered = _alerts.where((a) {
      if (_filter == 'active') return a.status == 'active';
      if (_filter == 'resolved') return a.status == 'resolved';
      return true;
    }).toList();
  }

  Future<void> _showCreateAlertDialog() async {
    final titleCtrl = TextEditingController();
    final msgCtrl = TextEditingController();
    String severity = 'medium';

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Create Emergency Alert'),
          content: SizedBox(
            width: 500,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Alert Title', border: OutlineInputBorder())),
                const SizedBox(height: 12),
                TextField(controller: msgCtrl, decoration: const InputDecoration(labelText: 'Message', border: OutlineInputBorder()), maxLines: 3),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: severity,
                  decoration: const InputDecoration(labelText: 'Severity', border: OutlineInputBorder()),
                  items: const [
                    DropdownMenuItem(value: 'low', child: Text('Low')),
                    DropdownMenuItem(value: 'medium', child: Text('Medium')),
                    DropdownMenuItem(value: 'high', child: Text('High')),
                    DropdownMenuItem(value: 'critical', child: Text('Critical')),
                  ],
                  onChanged: (v) => setDialogState(() => severity = v!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, {'title': titleCtrl.text, 'message': msgCtrl.text, 'severity': severity}),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white),
              child: const Text('Create Alert'),
            ),
          ],
        ),
      ),
    );

    if (result != null) {
      final service = ref.read(supabaseAdminServiceProvider);
      await service.addAlert(AdminAlert(
        id: '',
        title: result['title'], message: result['message'], severity: result['severity'],
        status: 'active', createdAt: DateTime.now(),
      ));
      _loadAlerts();
    }
    titleCtrl.dispose(); msgCtrl.dispose();
  }

  Color _severityColor(String severity) {
    switch (severity) {
      case 'low': return AppColors.info;
      case 'medium': return AppColors.warning;
      case 'high': return AppColors.error;
      case 'critical': return Colors.red.shade900;
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
            title: 'Emergency Alerts',
            subtitle: '${_alerts.where((a) => a.status == 'active').length} active alerts',
            action: ElevatedButton.icon(
              onPressed: _showCreateAlertDialog,
              icon: const Icon(Icons.add_alert, size: 18),
              label: const Text('Create Alert'),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), elevation: 0),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
            child: Row(
              children: [
                DropdownButton<String>(
                  value: _filter,
                  dropdownColor: isDark ? AppColors.surfaceDark : Colors.white,
                  style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimaryLight),
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('All Alerts')),
                    DropdownMenuItem(value: 'active', child: Text('Active')),
                    DropdownMenuItem(value: 'resolved', child: Text('Resolved')),
                  ],
                  onChanged: (v) { setState(() { _filter = v!; _applyFilter(); }); },
                ),
                const Spacer(),
                Text('${_filtered.length} alerts', style: TextStyle(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    children: _filtered.map((a) {
                      final textColor = isDark ? Colors.white : AppColors.textPrimaryLight;
                      final secondaryColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
                      final sc = _severityColor(a.severity);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.surfaceDark : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: a.status == 'active' ? sc.withValues(alpha: 0.3) : (isDark ? AppColors.borderDark : Colors.grey.shade200),
                              width: a.status == 'active' ? 1.5 : 1,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(color: sc.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                                      child: Text(a.severity.toUpperCase(), style: TextStyle(fontSize: 11, color: sc, fontWeight: FontWeight.w700, letterSpacing: 1)),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(color: (a.status == 'active' ? AppColors.error : AppColors.success).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                                      child: Text(a.status.toUpperCase(), style: TextStyle(fontSize: 11, color: a.status == 'active' ? AppColors.error : AppColors.success, fontWeight: FontWeight.w700, letterSpacing: 1)),
                                    ),
                                    const Spacer(),
                                    Text(_formatTime(a.createdAt), style: TextStyle(color: secondaryColor, fontSize: 12)),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(a.title, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: textColor)),
                                const SizedBox(height: 4),
                                Text(a.message, style: TextStyle(color: secondaryColor)),
                                if (a.status == 'resolved' && a.resolvedBy != null) ...[
                                  const SizedBox(height: 8),
                                  Text('Resolved by ${a.resolvedBy}', style: TextStyle(color: AppColors.success, fontSize: 12, fontWeight: FontWeight.w500)),
                                ],
                                if (a.status == 'active') ...[
                                  const SizedBox(height: 12),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton.icon(
                                      onPressed: () async {
                                        final service = ref.read(supabaseAdminServiceProvider);
                                        await service.resolveAlert(a.id, 'Admin User');
                                        _loadAlerts();
                                      },
                                      icon: const Icon(Icons.check_circle, size: 16),
                                      label: const Text('Resolve'),
                                      style: TextButton.styleFrom(foregroundColor: AppColors.success),
                                    ),
                                  ),
                                ],
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

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
