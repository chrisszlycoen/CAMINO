import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../widgets/admin_stats_card.dart';
import '../../../data/admin_service_provider.dart';
import '../models/admin_models.dart';
import '../../../core/theme/app_colors.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  DashboardStats? _stats;
  List<ChartDataPoint>? _weeklyData;
  List<ChartDataPoint>? _routeData;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final service = ref.read(supabaseAdminServiceProvider);
    final stats = await service.getDashboardStats();
    final weekly = await service.getWeeklyBoarding();
    final routes = await service.getRoutePerformance();
    if (mounted) {
      setState(() {
        _stats = stats;
        _weeklyData = weekly;
        _routeData = routes;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.backgroundDark : const Color(0xFFF5F5F7);

    return Scaffold(
      backgroundColor: bgColor,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  AdminPageHeader(
                    title: 'Dashboard',
                    subtitle: 'Real-time transport overview',
                  ),
                  const SizedBox(height: 24),
                  _buildStatsGrid(),
                  const SizedBox(height: 24),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildWeeklyChart(isDark)),
                      const SizedBox(width: 24),
                      Expanded(child: _buildRouteChart(isDark)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 2, child: _buildQuickActions(isDark)),
                      const SizedBox(width: 24),
                      Expanded(flex: 3, child: _buildRecentActivity(isDark)),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatsGrid() {
    if (_stats == null) return const SizedBox();
    final s = _stats!;
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 900 ? 4 : (constraints.maxWidth > 600 ? 2 : 1);
        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 3.2,
          children: [
            AdminStatsCard(title: 'Total Students', value: '${s.totalStudents}', icon: Icons.school, color: AppColors.primary, subtitle: '${s.boardedToday} boarded today', change: 8.2),
            AdminStatsCard(title: 'Active Buses', value: '${s.activeBuses}', icon: Icons.directions_bus, color: AppColors.info, subtitle: '${s.totalRoutes} active routes', change: 0),
            AdminStatsCard(title: 'On-Time Rate', value: '${s.onTimeRate.toStringAsFixed(0)}%', icon: Icons.access_time, color: AppColors.success, subtitle: 'Last 7 days', change: 3.5),
            AdminStatsCard(title: 'Pending Alerts', value: '${s.pendingAlerts}', icon: Icons.warning_amber, color: AppColors.error, subtitle: '${s.totalStaff} staff on duty'),
          ],
        );
      },
    );
  }

  Widget _buildWeeklyChart(bool isDark) {
    if (_weeklyData == null) return const SizedBox();
    final maxVal = _weeklyData!.map((d) => d.value).reduce((a, b) => a > b ? a : b);
    final cardBg = isDark ? AppColors.surfaceDark : Colors.white;
    final textColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: isDark ? AppColors.borderDark : Colors.grey.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Weekly Boarding', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.textPrimaryLight)),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxVal * 1.2,
                barTouchData: BarTouchData(enabled: true, touchTooltipData: BarTouchTooltipData(getTooltipItem: (group, groupIndex, rod, rodIndex) => BarTooltipItem('${_weeklyData![groupIndex].label}\n${rod.toY.toInt()}', const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (val, meta) => val.toInt() < _weeklyData!.length ? Padding(padding: const EdgeInsets.only(top: 8), child: Text(_weeklyData![val.toInt()].label, style: TextStyle(fontSize: 11, color: textColor))) : const SizedBox())),
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40, getTitlesWidget: (val, meta) => Text('${val.toInt()}', style: TextStyle(fontSize: 11, color: textColor)))),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: maxVal / 4, getDrawingHorizontalLine: (val) => FlLine(color: isDark ? AppColors.borderDark : Colors.grey.shade200, strokeWidth: 1)),
                borderData: FlBorderData(show: false),
                barGroups: _weeklyData!.asMap().entries.map((e) => BarChartGroupData(x: e.key, barRods: [BarChartRodData(toY: e.value.value, color: AppColors.primary, width: 28, borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)))])).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteChart(bool isDark) {
    if (_routeData == null) return const SizedBox();
    final cardBg = isDark ? AppColors.surfaceDark : Colors.white;
    final textColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: isDark ? AppColors.borderDark : Colors.grey.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Route Performance %', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.textPrimaryLight)),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 100,
                barTouchData: BarTouchData(enabled: true, touchTooltipData: BarTouchTooltipData(getTooltipItem: (group, groupIndex, rod, rodIndex) => BarTooltipItem('${_routeData![groupIndex].label}\n${rod.toY.toInt()}%', const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (val, meta) => val.toInt() < _routeData!.length ? Padding(padding: const EdgeInsets.only(top: 8), child: Text(_routeData![val.toInt()].label, style: TextStyle(fontSize: 11, color: textColor))) : const SizedBox())),
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40, getTitlesWidget: (val, meta) => Text('${val.toInt()}%', style: TextStyle(fontSize: 11, color: textColor)))),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 25, getDrawingHorizontalLine: (val) => FlLine(color: isDark ? AppColors.borderDark : Colors.grey.shade200, strokeWidth: 1)),
                borderData: FlBorderData(show: false),
                barGroups: _routeData!.asMap().entries.map((e) => BarChartGroupData(x: e.key, barRods: [BarChartRodData(toY: e.value.value, color: e.value.value > 0 ? AppColors.success : AppColors.borderDark, width: 28, borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)))])).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(bool isDark) {
    final cardBg = isDark ? AppColors.surfaceDark : Colors.white;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: isDark ? AppColors.borderDark : Colors.grey.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quick Actions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.textPrimaryLight)),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildRecentActivity(bool isDark) {
    final cardBg = isDark ? AppColors.surfaceDark : Colors.white;
    final activities = [
      ('System ready', 'Waiting for data', Icons.check_circle, AppColors.success),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: isDark ? AppColors.borderDark : Colors.grey.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Recent Activity', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.textPrimaryLight)),
          const SizedBox(height: 16),
          ...activities.map((a) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(color: a.$4.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                  child: Icon(a.$3, color: a.$4, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(a.$1, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: isDark ? Colors.white : AppColors.textPrimaryLight)),
                      Text(a.$2, style: TextStyle(fontSize: 11, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
                    ],
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
