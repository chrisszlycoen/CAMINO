import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../widgets/admin_stats_card.dart';
import '../data/mock_admin_data.dart';
import '../models/admin_models.dart';
import '../../../core/theme/app_colors.dart';

class AdminAnalyticsScreen extends ConsumerStatefulWidget {
  const AdminAnalyticsScreen({super.key});

  @override
  ConsumerState<AdminAnalyticsScreen> createState() => _AdminAnalyticsScreenState();
}

class _AdminAnalyticsScreenState extends ConsumerState<AdminAnalyticsScreen> {
  List<ChartDataPoint>? _weeklyData;
  List<ChartDataPoint>? _routeData;
  List<ChartDataPoint>? _studentDist;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final weekly = await MockAdminData.getWeeklyBoarding();
    final routes = await MockAdminData.getRoutePerformance();
    final dist = await MockAdminData.getStudentDistribution();
    if (mounted) setState(() { _weeklyData = weekly; _routeData = routes; _studentDist = dist; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.backgroundDark : const Color(0xFFF5F5F7);

    return Scaffold(
      backgroundColor: bgColor,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(24),
              children: [
                AdminPageHeader(title: 'Analytics', subtitle: 'Data-driven insights'),
                const SizedBox(height: 24),

                // Summary cards
                LayoutBuilder(
                  builder: (context, constraints) {
                    final count = constraints.maxWidth > 800 ? 4 : 2;
                    return GridView.count(
                      crossAxisCount: count,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 3.2,
                      children: [
                        AdminStatsCard(title: 'Avg Daily Boarding', value: '132', icon: Icons.trending_up, color: AppColors.primary, change: 5.2),
                        AdminStatsCard(title: 'Peak Day', value: 'Fri (158)', icon: Icons.calendar_today, color: AppColors.info),
                        AdminStatsCard(title: 'Busiest Route', value: 'Route B', icon: Icons.route, color: AppColors.warning),
                        AdminStatsCard(title: 'Efficiency Score', value: '87%', icon: Icons.speed, color: AppColors.success, change: 2.1),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Charts grid
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildCard(isDark, 'Boarding Trend (Weekly)', _buildLineChart(isDark))),
                    const SizedBox(width: 24),
                    Expanded(child: _buildCard(isDark, 'Route Performance %', _buildBarChart(isDark))),
                  ],
                ),
                const SizedBox(height: 24),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildCard(isDark, 'Student Distribution', _buildPieChart(isDark))),
                    const SizedBox(width: 24),
                    Expanded(child: _buildCard(isDark, 'Insights & Recommendations', _buildInsights(isDark))),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _buildCard(bool isDark, String title, Widget child) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: isDark ? AppColors.surfaceDark : Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: isDark ? AppColors.borderDark : Colors.grey.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.textPrimaryLight)),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildLineChart(bool isDark) {
    if (_weeklyData == null) return const SizedBox();
    final textColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final maxVal = _weeklyData!.map((d) => d.value).reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: 220,
      child: LineChart(
        LineChartData(
          minX: 0, maxX: _weeklyData!.length - 1,
          minY: 0, maxY: maxVal * 1.2,
          lineTouchData: LineTouchData(enabled: true, touchTooltipData: LineTouchTooltipData(getTooltipItems: (spots) => spots.map((s) => LineTooltipItem('${_weeklyData![s.spotIndex].label}: ${s.y.toInt()}', const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))).toList())),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (val, meta) => val.toInt() < _weeklyData!.length ? Padding(padding: const EdgeInsets.only(top: 8), child: Text(_weeklyData![val.toInt()].label, style: TextStyle(fontSize: 11, color: textColor))) : const SizedBox())),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40, getTitlesWidget: (val, meta) => Text('${val.toInt()}', style: TextStyle(fontSize: 11, color: textColor)))),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: maxVal / 4, getDrawingHorizontalLine: (val) => FlLine(color: isDark ? AppColors.borderDark : Colors.grey.shade200, strokeWidth: 1)),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: _weeklyData!.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.value)).toList(),
              isCurved: true,
              color: AppColors.primary,
              barWidth: 3,
              dotData: FlDotData(show: true, getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(radius: 4, color: AppColors.primary, strokeWidth: 2, strokeColor: Colors.white)),
              belowBarData: BarAreaData(show: true, color: AppColors.primary.withValues(alpha: 0.1)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart(bool isDark) {
    if (_routeData == null) return const SizedBox();
    final textColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return SizedBox(
      height: 220,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 100,
          barTouchData: BarTouchData(enabled: true, touchTooltipData: BarTouchTooltipData(getTooltipItem: (group, groupIndex, rod, rodIndex) => BarTooltipItem('${_routeData![groupIndex].label}\n${rod.toY.toInt()}%', const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (val, meta) => val.toInt() < _routeData!.length ? Padding(padding: const EdgeInsets.only(top: 8), child: Text(_routeData![val.toInt()].label, style: TextStyle(fontSize: 10, color: textColor))) : const SizedBox())),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40, getTitlesWidget: (val, meta) => Text('${val.toInt()}%', style: TextStyle(fontSize: 11, color: textColor)))),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 25, getDrawingHorizontalLine: (val) => FlLine(color: isDark ? AppColors.borderDark : Colors.grey.shade200, strokeWidth: 1)),
          borderData: FlBorderData(show: false),
          barGroups: _routeData!.asMap().entries.map((e) => BarChartGroupData(x: e.key, barRods: [BarChartRodData(toY: e.value.value, color: AppColors.success, width: 28, borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)))])).toList(),
        ),
      ),
    );
  }

  Widget _buildPieChart(bool isDark) {
    if (_studentDist == null) return const SizedBox();
    final colors = [AppColors.primary, AppColors.info, AppColors.warning, AppColors.error];

    return SizedBox(
      height: 220,
      child: Row(
        children: [
          Expanded(
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: _studentDist!.asMap().entries.map((e) => PieChartSectionData(
                  value: e.value.value,
                  title: '${e.value.value.toInt()}',
                  color: colors[e.key % colors.length],
                  radius: 50,
                  titleStyle: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                )).toList(),
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _studentDist!.asMap().entries.map((e) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 12, height: 12, decoration: BoxDecoration(color: colors[e.key % colors.length], shape: BoxShape.circle)),
                  const SizedBox(width: 8),
                  Text('${e.value.label}: ${e.value.value.toInt()}', style: TextStyle(fontSize: 12, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
                ],
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildInsights(bool isDark) {
    final insights = [
      ('Route A has highest efficiency at 92%', Icons.emoji_events, AppColors.warning),
      ('Friday boarding peaks 23% above weekly avg', Icons.trending_up, AppColors.success),
      ('Route C needs schedule optimization', Icons.schedule, AppColors.info),
      ('Student distribution: Secondary dominates', Icons.pie_chart, AppColors.primary),
    ];

    return Column(
      children: insights.map((i) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(color: i.$3.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
              child: Icon(i.$2, color: i.$3, size: 16),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(i.$1, style: TextStyle(fontSize: 13, color: isDark ? Colors.white70 : AppColors.textPrimaryLight))),
          ],
        ),
      )).toList(),
    );
  }
}
