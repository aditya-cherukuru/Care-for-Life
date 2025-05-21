import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:care_for_life/features/health_metrices/presentation/cubit/health_metrics_cubit.dart';
import 'package:care_for_life/features/health_metrices/data/models/health_metric.dart';
import 'package:care_for_life/features/health_metrices/data/models/metric_entry.dart';
import 'package:care_for_life/app_router.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class HealthMetricsPage extends StatefulWidget {
  const HealthMetricsPage({Key? key}) : super(key: key);

  @override
  State<HealthMetricsPage> createState() => _HealthMetricsPageState();
}

class _HealthMetricsPageState extends State<HealthMetricsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HealthMetricsCubit, HealthMetricsState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Health Metrics'),
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Dashboard'),
                Tab(text: 'All Metrics'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildDashboardTab(context, state),
              _buildAllMetricsTab(context, state),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              _showAddMetricDialog(context);
            },
            child: const Icon(Icons.add),
            tooltip: 'Add Metric',
          ),
        );
      },
    );
  }
  
  Widget _buildDashboardTab(BuildContext context, HealthMetricsState state) {
    if (state is HealthMetricsLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    if (state is HealthMetricsLoaded) {
      if (state.metrics.isEmpty) {
        return _buildEmptyState(context);
      }
      
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDateRangeSelector(context, state),
            const SizedBox(height: 16),
            _buildRecentMetricsSection(context, state),
            const SizedBox(height: 24),
            _buildTrendsSection(context, state),
            const SizedBox(height: 24),
            _buildGoalsSection(context, state),
          ],
        ),
      );
    }
    
    if (state is HealthMetricsError) {
      return Center(
        child: Text(
          state.message,
          style: const TextStyle(color: Colors.red),
        ),
      );
    }
    
    return const Center(
      child: Text('Something went wrong'),
    );
  }
  
  Widget _buildAllMetricsTab(BuildContext context, HealthMetricsState state) {
    if (state is HealthMetricsLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    if (state is HealthMetricsLoaded) {
      if (state.metrics.isEmpty) {
        return _buildEmptyState(context);
      }
      
      final metricsByCategory = context.read<HealthMetricsCubit>().getMetricsByCategory();
      
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: metricsByCategory.length,
        itemBuilder: (context, index) {
          final category = metricsByCategory.keys.elementAt(index);
          final metrics = metricsByCategory[category]!;
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 8),
                child: Text(
                  category,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: metrics.length,
                itemBuilder: (context, metricIndex) {
                  final metric = metrics[metricIndex];
                  
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: InkWell(
                      onTap: () {
                        AppRouter.navigateToMetricDetail(context, metric.id);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: metric.colorValue.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                metric.iconData,
                                color: metric.colorValue,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    metric.name,
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    metric.description,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.show_chart,
                                          size: 16,
                                          color: Colors.grey[600],
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          metric.latestEntry != null
                                              ? metric.formatValue(
                                                  metric.latestEntry!.value,
                                                  metric.latestEntry!.secondaryValue,
                                                )
                                              : 'No data',
                                          style: Theme.of(context).textTheme.bodySmall,
                                        ),
                                        const SizedBox(width: 12),
                                        Icon(
                                          Icons.calendar_today,
                                          size: 16,
                                          color: Colors.grey[600],
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          metric.latestEntry != null
                                              ? DateFormat('MMM d').format(metric.latestEntry!.date)
                                              : 'No data',
                                          style: Theme.of(context).textTheme.bodySmall,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.chevron_right),
                              onPressed: () {
                                AppRouter.navigateToMetricDetail(context, metric.id);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          );
        },
      );
    }
    
    if (state is HealthMetricsError) {
      return Center(
        child: Text(
          state.message,
          style: const TextStyle(color: Colors.red),
        ),
      );
    }
    
    return const Center(
      child: Text('Something went wrong'),
    );
  }
  
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.show_chart,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No metrics yet',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add a metric to start tracking',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              _showAddMetricDialog(context);
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Metric'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDateRangeSelector(BuildContext context, HealthMetricsLoaded state) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Date Range',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  '${DateFormat('MMM d, y').format(state.startDate)} - ${DateFormat('MMM d, y').format(state.endDate)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () {
                _showDateRangePicker(context, state);
              },
              child: const Text('Change'),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildRecentMetricsSection(BuildContext context, HealthMetricsLoaded state) {
    // Get the 4 most recently updated metrics
    final recentMetrics = List<HealthMetric>.from(state.metrics)
      ..sort((a, b) {
        final aLatest = a.latestEntry?.date ?? DateTime(1970);
        final bLatest = b.latestEntry?.date ?? DateTime(1970);
        return bLatest.compareTo(aLatest);
      });
    
    final displayMetrics = recentMetrics.take(4).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Metrics',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        // Use LayoutBuilder to ensure we adapt to available width
        LayoutBuilder(
          builder: (context, constraints) {
            // Calculate the optimal child aspect ratio based on available width
            // This ensures cards are properly sized for the content
            final childAspectRatio = constraints.maxWidth > 360 ? 1.5 : 1.3;
            
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: childAspectRatio,
              ),
              itemCount: displayMetrics.length,
              itemBuilder: (context, index) {
                final metric = displayMetrics[index];
                final latestEntry = metric.latestEntry;
                
                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    onTap: () {
                      AppRouter.navigateToMetricDetail(context, metric.id);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: metric.colorValue.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  metric.iconData,
                                  color: metric.colorValue,
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  metric.name,
                                  style: Theme.of(context).textTheme.titleSmall,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          if (latestEntry != null)
                            // Wrap in Flexible to prevent overflow
                            Flexible(
                              child: Text(
                                metric.formatValue(
                                  latestEntry.value,
                                  latestEntry.secondaryValue,
                                ),
                                style: Theme.of(context).textTheme.titleLarge,
                                overflow: TextOverflow.ellipsis,
                              ),
                            )
                          else
                            Text(
                              'No data',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Colors.grey[400],
                              ),
                            ),
                          const SizedBox(height: 4),
                          // Use SingleChildScrollView for the date row to prevent overflow
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                Icon(
                                  _getTrendIcon(metric.trend),
                                  size: 16,
                                  color: _getTrendColor(metric.trend),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  latestEntry != null
                                      ? DateFormat('MMM d').format(latestEntry.date)
                                      : '',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
        ),
      ],
    );
  }
  
  Widget _buildTrendsSection(BuildContext context, HealthMetricsLoaded state) {
    // Find a metric with enough data for a trend chart
    HealthMetric? trendMetric;
    for (final metric in state.metrics) {
      final entries = context.read<HealthMetricsCubit>().getEntriesInCurrentRange(metric.id);
      if (entries.length >= 3) {
        trendMetric = metric;
        break;
      }
    }
    
    if (trendMetric == null) {
      return const SizedBox.shrink();
    }
    
    final entries = context.read<HealthMetricsCubit>().getEntriesInCurrentRange(trendMetric.id);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Trends',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            TextButton(
              onPressed: () {
                AppRouter.navigateToMetricDetail(context, trendMetric!.id);
              },
              child: const Text('View Details'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: trendMetric.colorValue.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        trendMetric.iconData,
                        color: trendMetric.colorValue,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      trendMetric.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: _buildTrendChart(context, trendMetric, entries),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildGoalsSection(BuildContext context, HealthMetricsLoaded state) {
    // Get metrics with goals
    final metricsWithGoals = state.metrics.where((m) => m.goalType != GoalType.none).toList();
    
    if (metricsWithGoals.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Goals',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: metricsWithGoals.length,
          itemBuilder: (context, index) {
            final metric = metricsWithGoals[index];
            final latestEntry = metric.latestEntry;
            
            if (latestEntry == null) {
              return const SizedBox.shrink();
            }
            
            final isWithinGoal = metric.isWithinGoal;
            
            return Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                onTap: () {
                  AppRouter.navigateToMetricDetail(context, metric.id);
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: isWithinGoal ? Colors.green[100] : Colors.red[100],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isWithinGoal ? Icons.check : Icons.warning,
                          color: isWithinGoal ? Colors.green : Colors.red,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              metric.name,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isWithinGoal
                                  ? 'Goal achieved: ${metric.goalString}'
                                  : 'Goal not achieved: ${metric.goalString}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: isWithinGoal ? Colors.green : Colors.red,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Current: ${metric.formatValue(latestEntry.value, latestEntry.secondaryValue)}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
  
  Widget _buildTrendChart(BuildContext context, HealthMetric metric, List<MetricEntry> entries) {
    if (entries.isEmpty) {
      return Center(
        child: Text(
          'No data available',
          style: TextStyle(
            color: Colors.grey[600],
          ),
        ),
      );
    }
    
    // Sort entries by date (oldest first)
    entries.sort((a, b) => a.date.compareTo(b.date));
    
    // Prepare data points
    final spots = <FlSpot>[];
    for (int i = 0; i < entries.length; i++) {
      spots.add(FlSpot(i.toDouble(), entries[i].value));
    }
    
    // Find min and max values for Y axis
    double minY = entries.map((e) => e.value).reduce((a, b) => a < b ? a : b);
    double maxY = entries.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    
    // Add some padding to min and max
    final padding = (maxY - minY) * 0.1;
    minY = minY - padding;
    maxY = maxY + padding;
    
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: (maxY - minY) / 4,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: const Color.fromARGB(255, 119, 113, 113),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toStringAsFixed(1),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                  ),
                );
              },
            ),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < entries.length && index % (entries.length ~/ 5 + 1) == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      DateFormat('M/d').format(entries[index].date),
                      style: const TextStyle(
                        fontSize: 10,
                      ),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: metric.colorValue,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: metric.colorValue,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: metric.colorValue.withOpacity(0.2),
            ),
          ),
        ],
        minY: minY,
        maxY: maxY,
      ),
    );
  }
  
  void _showDateRangePicker(BuildContext context, HealthMetricsLoaded state) async {
    final initialDateRange = DateTimeRange(
      start: state.startDate,
      end: state.endDate,
    );
    
    final pickedRange = await showDateRangePicker(
      context: context,
      initialDateRange: initialDateRange,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (pickedRange != null) {
      context.read<HealthMetricsCubit>().changeDateRange(
        pickedRange.start,
        pickedRange.end,
      );
    }
  }
  
  void _showAddMetricDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        final nameController = TextEditingController();
        final descriptionController = TextEditingController();
        final unitController = TextEditingController();
        MetricType selectedType = MetricType.decimal;
        GoalType selectedGoalType = GoalType.none;
        final goalMinController = TextEditingController(text: '0');
        final goalMaxController = TextEditingController(text: '0');
        int selectedColor = 0xFF2196F3;
        String selectedIcon = 'show_chart';
        
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add New Metric'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Metric Name',
                        hintText: 'e.g., Weight',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        hintText: 'e.g., Track your body weight',
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: unitController,
                            decoration: const InputDecoration(
                              labelText: 'Unit',
                              hintText: 'e.g., kg',
                            ),
                          ),
                        ),
                        const SizedBox(width: 16, height: 40),
                        Expanded(
                          child: DropdownButtonFormField<MetricType>(
                            value: selectedType,
                            decoration: const InputDecoration(
                              labelText: 'Type',
                              contentPadding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
                              border: OutlineInputBorder(),
                            ),
                            isExpanded: true,
                            itemHeight: 60,
                            style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.black87,
                            ),
                            menuMaxHeight: 300,
                            items: [
                              DropdownMenuItem(
                                value: MetricType.integer,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8.0),
                                  child: Text('Integer', style: TextStyle(fontSize: 16.0)),
                                ),
                              ),
                              DropdownMenuItem(
                                value: MetricType.decimal,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8.0),
                                  child: Text('Decimal', style: TextStyle(fontSize: 16.0)),
                                ),
                              ),
                              DropdownMenuItem(
                                value: MetricType.bloodPressure,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8.0),
                                  child: Text('Blood Pressure', style: TextStyle(fontSize: 16.0)),
                                ),
                              ),
                              DropdownMenuItem(
                                value: MetricType.duration,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8.0),
                                  child: Text('Duration', style: TextStyle(fontSize: 16.0)),
                                ),
                              ),
                              DropdownMenuItem(
                                value: MetricType.boolean,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8.0),
                                  child: Text('Yes/No', style: TextStyle(fontSize: 16.0)),
                                ),
                              ),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  selectedType = value;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<GoalType>(
                      value: selectedGoalType,
                      decoration: const InputDecoration(
                        labelText: 'Goal Type',
                        contentPadding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
                        border: OutlineInputBorder(),
                      ),
                      isExpanded: true,
                      itemHeight: 60,
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.black87,
                      ),
                      items: [
                        DropdownMenuItem(
                          value: GoalType.none,
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: Text('No Goal', style: TextStyle(fontSize: 16.0)),
                          ),
                        ),
                        DropdownMenuItem(
                          value: GoalType.minimum,
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: Text('Minimum', style: TextStyle(fontSize: 16.0)),
                          ),
                        ),
                        DropdownMenuItem(
                          value: GoalType.maximum,
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: Text('Maximum', style: TextStyle(fontSize: 16.0)),
                          ),
                        ),
                        DropdownMenuItem(
                          value: GoalType.range,
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: Text('Range', style: TextStyle(fontSize: 16.0)),
                          ),
                        ),
                        DropdownMenuItem(
                          value: GoalType.target,
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: Text('Target', style: TextStyle(fontSize: 16.0)),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            selectedGoalType = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    if (selectedGoalType != GoalType.none)
                      Row(
                        children: [
                          if (selectedGoalType == GoalType.minimum ||
                              selectedGoalType == GoalType.range ||
                              selectedGoalType == GoalType.target)
                            Expanded(
                              child: TextField(
                                controller: goalMinController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: selectedGoalType == GoalType.target
                                      ? 'Target'
                                      : 'Minimum',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
                                ),
                              ),
                            ),
                          if (selectedGoalType == GoalType.range)
                            const SizedBox(width: 16),
                          if (selectedGoalType == GoalType.maximum ||
                              selectedGoalType == GoalType.range)
                            Expanded(
                              child: TextField(
                                controller: goalMaxController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Maximum',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
                                ),
                              ),
                            ),
                        ],
                      ),
                    const SizedBox(height: 16),
                    const Text('Color:'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        _buildColorChip(0xFF2196F3, selectedColor, (color) {
                          setState(() {
                            selectedColor = color;
                          });
                        }),
                        _buildColorChip(0xFFE91E63, selectedColor, (color) {
                          setState(() {
                            selectedColor = color;
                          });
                        }),
                        _buildColorChip(0xFF9C27B0, selectedColor, (color) {
                          setState(() {
                            selectedColor = color;
                          });
                        }),
                        _buildColorChip(0xFF4CAF50, selectedColor, (color) {
                          setState(() {
                            selectedColor = color;
                          });
                        }),
                        _buildColorChip(0xFFFF9800, selectedColor, (color) {
                          setState(() {
                            selectedColor = color;
                          });
                        }),
                        _buildColorChip(0xFF607D8B, selectedColor, (color) {
                          setState(() {
                            selectedColor = color;
                          });
                        }),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text('Icon:'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        _buildIconChip('show_chart', selectedIcon, (icon) {
                          setState(() {
                            selectedIcon = icon;
                          });
                        }),
                        _buildIconChip('monitor_weight', selectedIcon, (icon) {
                          setState(() {
                            selectedIcon = icon;
                          });
                        }),
                        _buildIconChip('favorite', selectedIcon, (icon) {
                          setState(() {
                            selectedIcon = icon;
                          });
                        }),
                        _buildIconChip('directions_walk', selectedIcon, (icon) {
                          setState(() {
                            selectedIcon = icon;
                          });
                        }),
                        _buildIconChip('bedtime', selectedIcon, (icon) {
                          setState(() {
                            selectedIcon = icon;
                          });
                        }),
                        _buildIconChip('water_drop', selectedIcon, (icon) {
                          setState(() {
                            selectedIcon = icon;
                          });
                        }),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (nameController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter a metric name'),
                        ),
                      );
                      return;
                    }
                    
                    if (unitController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter a unit'),
                        ),
                      );
                      return;
                    }
                    
                    final newMetric = HealthMetric(
                      id: '',
                      name: nameController.text.trim(),
                      description: descriptionController.text.trim(),
                      unit: unitController.text.trim(),
                      type: selectedType,
                      color: selectedColor,
                      icon: selectedIcon,
                      goalType: selectedGoalType,
                      goalMin: double.tryParse(goalMinController.text) ?? 0,
                      goalMax: double.tryParse(goalMaxController.text) ?? 0,
                      entries: [],
                    );
                    
                    context.read<HealthMetricsCubit>().createMetric(newMetric);
                    Navigator.pop(context);
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }
  
  Widget _buildColorChip(int color, int selectedColor, Function(int) onSelected) {
    final isSelected = color == selectedColor;
    
    return GestureDetector(
      onTap: () => onSelected(color),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Color(color),
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.black : Colors.transparent,
            width: 2,
          ),
        ),
        child: isSelected
            ? const Icon(
                Icons.check,
                color: Colors.white,
              )
            : null,
      ),
    );
  }
  
  Widget _buildIconChip(String icon, String selectedIcon, Function(String) onSelected) {
    final isSelected = icon == selectedIcon;
    IconData iconData;
    
    switch (icon) {
      case 'show_chart':
        iconData = Icons.show_chart;
        break;
      case 'monitor_weight':
        iconData = Icons.monitor_weight;
        break;
      case 'favorite':
        iconData = Icons.favorite;
        break;
      case 'directions_walk':
        iconData = Icons.directions_walk;
        break;
      case 'bedtime':
        iconData = Icons.bedtime;
        break;
      case 'water_drop':
        iconData = Icons.water_drop;
        break;
      default:
        iconData = Icons.show_chart;
    }
    
    return GestureDetector(
      onTap: () => onSelected(icon),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.2) : Colors.grey[200],
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
            width: 2,
          ),
        ),
        child: Icon(
          iconData,
          color: isSelected ? Theme.of(context).primaryColor : Colors.grey[600],
        ),
      ),
    );
  }
  
  IconData _getTrendIcon(String trend) {
    switch (trend) {
      case 'up':
        return Icons.trending_up;
      case 'down':
        return Icons.trending_down;
      default:
        return Icons.trending_flat;
    }
  }
  
  Color _getTrendColor(String trend) {
    switch (trend) {
      case 'up':
        return Colors.green;
      case 'down':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }
}