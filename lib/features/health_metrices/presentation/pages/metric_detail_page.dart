import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:care_for_life/features/health_metrices/presentation/cubit/health_metrics_cubit.dart';
import 'package:care_for_life/features/health_metrices/data/models/health_metric.dart';
import 'package:care_for_life/features/health_metrices/data/models/metric_entry.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:uuid/uuid.dart';

class MetricDetailPage extends StatefulWidget {
  final String metricId;
  
  const MetricDetailPage({
    Key? key,
    required this.metricId,
  }) : super(key: key);

  @override
  State<MetricDetailPage> createState() => _MetricDetailPageState();
}

class _MetricDetailPageState extends State<MetricDetailPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _timeRange = '30d';
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
        final metric = context.read<HealthMetricsCubit>().getMetricById(widget.metricId);
        
        if (metric == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Metric Details'),
            ),
            body: const Center(
              child: Text('Metric not found'),
            ),
          );
        }
        
        return Scaffold(
          appBar: AppBar(
            title: Text(metric.name),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  _showEditMetricDialog(context, metric);
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  _showDeleteConfirmationDialog(context, metric);
                },
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Overview'),
                Tab(text: 'History'),
                Tab(text: 'Stats'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(context, metric, state),
              _buildHistoryTab(context, metric, state),
              _buildStatsTab(context, metric, state),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              _showAddEntryDialog(context, metric);
            },
            child: const Icon(Icons.add),
            tooltip: 'Add Entry',
          ),
        );
      },
    );
  }
  
  Widget _buildOverviewTab(BuildContext context, HealthMetric metric, HealthMetricsState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: metric.colorValue.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          metric.iconData,
                          color: metric.colorValue,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              metric.name,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              metric.description,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(
                        context,
                        'Unit',
                        metric.unit,
                        Icons.straighten,
                      ),
                      _buildStatItem(
                        context,
                        'Goal',
                        metric.goalType == GoalType.none ? 'None' : metric.goalString,
                        Icons.flag,
                      ),
                      _buildStatItem(
                        context,
                        'Entries',
                        metric.entries.length.toString(),
                        Icons.list_alt,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Latest Value Card
          if (metric.latestEntry != null)
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Latest Value',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                metric.formatValue(
                                  metric.latestEntry!.value,
                                  metric.latestEntry!.secondaryValue,
                                ),
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  color: metric.colorValue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    size: 16,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    DateFormat('EEEE, MMMM d, y').format(metric.latestEntry!.date),
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                              if (metric.latestEntry!.note.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.note,
                                        size: 16,
                                        color: Colors.grey[600],
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          metric.latestEntry!.note,
                                          style: Theme.of(context).textTheme.bodySmall,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (metric.goalType != GoalType.none)
                          Expanded(
                            flex: 2,
                            child: Column(
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: metric.isWithinGoal
                                        ? Colors.green[100]
                                        : Colors.red[100],
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Icon(
                                      metric.isWithinGoal ? Icons.check : Icons.warning,
                                      color: metric.isWithinGoal ? Colors.green : Colors.red,
                                      size: 40,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  metric.isWithinGoal ? 'Goal Met' : 'Goal Not Met',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: metric.isWithinGoal ? Colors.green : Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          
          const SizedBox(height: 24),
          
          // Chart Card
          if (metric.entries.length > 1)
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Trend',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        _buildTimeRangeSelector(),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 200,
                      child: _buildTrendChart(context, metric),
                    ),
                  ],
                ),
              ),
            ),
          
          const SizedBox(height: 24),
          
          // Recent Entries Card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Entries',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      TextButton(
                        onPressed: () {
                          _tabController.animateTo(1); // Switch to History tab
                        },
                        child: const Text('View All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  metric.entries.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              'No entries yet',
                              style: TextStyle(
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        )
                      : Column(
                          children: metric.entries.take(5).map((entry) {
                            return ListTile(
                              leading: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: metric.colorValue.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  metric.iconData,
                                  color: metric.colorValue,
                                ),
                              ),
                              title: Text(
                                metric.formatValue(entry.value, entry.secondaryValue),
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              subtitle: Text(
                                DateFormat('EEEE, MMM d, y').format(entry.date),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.more_vert),
                                onPressed: () {
                                  _showEntryOptionsDialog(context, metric, entry);
                                },
                              ),
                            );
                          }).toList(),
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildHistoryTab(BuildContext context, HealthMetric metric, HealthMetricsState state) {
    if (metric.entries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No entries yet',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add an entry to start tracking',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                _showAddEntryDialog(context, metric);
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Entry'),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: metric.entries.length,
      itemBuilder: (context, index) {
        final entry = metric.entries[index];
        
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('EEEE, MMMM d, y').format(entry.date),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    IconButton(
                      icon: const Icon(Icons.more_vert),
                      onPressed: () {
                        _showEntryOptionsDialog(context, metric, entry);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: metric.colorValue.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          metric.type == MetricType.bloodPressure
                              ? '${entry.value.toInt()}/${entry.secondaryValue?.toInt() ?? 0}'
                              : entry.value.toString(),
                          style: TextStyle(
                            color: metric.colorValue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            metric.formatValue(entry.value, entry.secondaryValue),
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          if (entry.note.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                entry.note,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildStatsTab(BuildContext context, HealthMetric metric, HealthMetricsState state) {
    if (metric.entries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No data available',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add entries to see statistics',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }
    
    // Calculate statistics
    final values = metric.entries.map((e) => e.value).toList();
    final min = values.reduce((a, b) => a < b ? a : b);
    final max = values.reduce((a, b) => a > b ? a : b);
    final avg = values.reduce((a, b) => a + b) / values.length;
    
    // Calculate the most recent change
    double? change;
    String? changeDirection;
    if (metric.entries.length >= 2) {
      final latest = metric.entries[0].value;
      final previous = metric.entries[1].value;
      change = latest - previous;
      changeDirection = change > 0 ? 'up' : (change < 0 ? 'down' : 'stable');
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Stats Card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Summary',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatCard(
                        context,
                        'Minimum',
                        metric.formatValue(min),
                        Icons.arrow_downward,
                        Colors.blue,
                      ),
                      _buildStatCard(
                        context,
                        'Average',
                        metric.formatValue(avg),
                        Icons.horizontal_rule,
                        Colors.orange,
                      ),
                      _buildStatCard(
                        context,
                        'Maximum',
                        metric.formatValue(max),
                        Icons.arrow_upward,
                        Colors.red,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Recent Change Card
          if (change != null)
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recent Change',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: _getChangeColor(changeDirection!).withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _getChangeIcon(changeDirection!),
                            color: _getChangeColor(changeDirection!),
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                change > 0
                                    ? '+${metric.formatValue(change.abs())}'
                                    : (change < 0
                                        ? '-${metric.formatValue(change.abs())}'
                                        : 'No change'),
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: _getChangeColor(changeDirection!),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Since ${DateFormat('MMM d').format(metric.entries[1].date)}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          
          const SizedBox(height: 24),
          
          // Distribution Chart Card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Distribution',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: _buildDistributionChart(context, metric),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Monthly Averages Card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Monthly Averages',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: _buildMonthlyAveragesChart(context, metric),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatItem(BuildContext context, String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.grey[600],
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
  
  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
  
  Widget _buildTimeRangeSelector() {
    return SegmentedButton<String>(
      segments: const [
        ButtonSegment<String>(
          value: '7d',
          label: Text('7d', style: TextStyle(fontSize: 12)),
        ),
        ButtonSegment<String>(
          value: '30d',
          label: Text('7d', style: TextStyle(fontSize: 12)),
        ),
        ButtonSegment<String>(
          value: '90d',
          label: Text('7d', style: TextStyle(fontSize: 12)),
        ),
        ButtonSegment<String>(
          value: 'all',
          label: Text('7d', style: TextStyle(fontSize: 12)),
        ),
      ],
      selected: {_timeRange},
      onSelectionChanged: (Set<String> newSelection) {
        setState(() {
          _timeRange = newSelection.first;
        });
      },
      style: const ButtonStyle(
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity(horizontal: -3, vertical: -3),
      ),
    );
  }
  
  Widget _buildTrendChart(BuildContext context, HealthMetric metric) {
    // Filter entries based on selected time range
    final filteredEntries = _getFilteredEntries(metric);
    
    if (filteredEntries.isEmpty) {
      return Center(
        child: Text(
          'No data available for selected time range',
          style: TextStyle(
            color: Colors.grey[600],
          ),
        ),
      );
    }
    
    // Sort entries by date (oldest first)
    filteredEntries.sort((a, b) => a.date.compareTo(b.date));
    
    // Prepare data points
    final spots = <FlSpot>[];
    for (int i = 0; i < filteredEntries.length; i++) {
      spots.add(FlSpot(i.toDouble(), filteredEntries[i].value));
    }
    
    // Find min and max values for Y axis
    double minY = filteredEntries.map((e) => e.value).reduce((a, b) => a < b ? a : b);
    double maxY = filteredEntries.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    
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
              color: const Color.fromARGB(255, 107, 102, 102),
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
                if (index >= 0 && index < filteredEntries.length && index % (filteredEntries.length ~/ 5 + 1) == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      DateFormat('M/d').format(filteredEntries[index].date),
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
  
  Widget _buildDistributionChart(BuildContext context, HealthMetric metric) {
    // Group values into ranges
    final values = metric.entries.map((e) => e.value).toList();
    final min = values.reduce((a, b) => a < b ? a : b);
    final max = values.reduce((a, b) => a > b ? a : b);
    
    // Create 5 buckets
    final range = max - min;
    final bucketSize = range / 5;
    final buckets = List<int>.filled(5, 0);
    
    for (final value in values) {
      final bucketIndex = ((value - min) / bucketSize).floor();
      final index = bucketIndex >= 5 ? 4 : bucketIndex;
      buckets[index]++;
    }
    
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: buckets.reduce((a, b) => a > b ? a : b).toDouble() * 1.2,
        barTouchData: BarTouchData(
          enabled: false,
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                if (value == 0) return const Text('');
                return Text(
                  value.toInt().toString(),
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
                if (index >= 0 && index < 5) {
                  final lowerBound = min + (bucketSize * index);
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      lowerBound.toStringAsFixed(1),
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
        barGroups: buckets.asMap().entries.map((entry) {
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: entry.value.toDouble(),
                color: metric.colorValue,
                width: 20,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
  
  Widget _buildMonthlyAveragesChart(BuildContext context, HealthMetric metric) {
    // Group entries by month
    final Map<String, List<double>> monthlyValues = {};
    
    for (final entry in metric.entries) {
      final monthKey = DateFormat('yyyy-MM').format(entry.date);
      if (!monthlyValues.containsKey(monthKey)) {
        monthlyValues[monthKey] = [];
      }
      monthlyValues[monthKey]!.add(entry.value);
    }
    
    // Calculate monthly averages
    final Map<String, double> monthlyAverages = {};
    monthlyValues.forEach((month, values) {
      final avg = values.reduce((a, b) => a + b) / values.length;
      monthlyAverages[month] = avg;
    });
    
    // Sort months
    final sortedMonths = monthlyAverages.keys.toList()..sort();
    
    // Limit to last 6 months if there are more
    final displayMonths = sortedMonths.length > 6
        ? sortedMonths.sublist(sortedMonths.length - 6)
        : sortedMonths;
    
    // Prepare data points
    final spots = <FlSpot>[];
    for (int i = 0; i < displayMonths.length; i++) {
      spots.add(FlSpot(i.toDouble(), monthlyAverages[displayMonths[i]]!));
    }
    
    if (spots.isEmpty) {
      return Center(
        child: Text(
          'Not enough data for monthly averages',
          style: TextStyle(
            color: Colors.grey[600],
          ),
        ),
      );
    }
    
    // Find min and max values for Y axis
    final values = monthlyAverages.values.toList();
    double minY = values.reduce((a, b) => a < b ? a : b);
    double maxY = values.reduce((a, b) => a > b ? a : b);
    
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
              color: const Color.fromARGB(255, 132, 123, 123),
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
                if (index >= 0 && index < displayMonths.length) {
                  final parts = displayMonths[index].split('-');
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      DateFormat('MMM').format(DateTime(int.parse(parts[0]), int.parse(parts[1]))),
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
  
  List<MetricEntry> _getFilteredEntries(HealthMetric metric) {
    final now = DateTime.now();
    DateTime startDate;
    
    switch (_timeRange) {
      case '7d':
        startDate = now.subtract(const Duration(days: 7));
        break;
      case '30d':
        startDate = now.subtract(const Duration(days: 30));
        break;
      case '90d':
        startDate = now.subtract(const Duration(days: 90));
        break;
      case 'all':
      default:
        return List<MetricEntry>.from(metric.entries);
    }
    
    return metric.entries.where((entry) {
      return entry.date.isAfter(startDate.subtract(const Duration(days: 1)));
    }).toList();
  }
  
  void _showAddEntryDialog(BuildContext context, HealthMetric metric) {
    showDialog(
      context: context,
      builder: (context) {
        final valueController = TextEditingController();
        final secondaryValueController = TextEditingController();
        final noteController = TextEditingController();
        DateTime selectedDate = DateTime.now();
        
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Add ${metric.name} Entry'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (metric.type == MetricType.bloodPressure)
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: valueController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Systolic',
                                hintText: 'e.g., 120',
                                suffixText: 'mmHg',
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextField(
                              controller: secondaryValueController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Diastolic',
                                hintText: 'e.g., 80',
                                suffixText: 'mmHg',
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      TextField(
                        controller: valueController,
                        keyboardType: metric.type == MetricType.integer
                            ? TextInputType.number
                            : const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: 'Value',
                          hintText: 'e.g., ${metric.type == MetricType.integer ? '10' : '10.5'}',
                          suffixText: metric.unit,
                        ),
                      ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        
                        if (pickedDate != null) {
                          setState(() {
                            selectedDate = pickedDate;
                          });
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Date',
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          DateFormat('EEEE, MMMM d, y').format(selectedDate),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: noteController,
                      decoration: const InputDecoration(
                        labelText: 'Note (Optional)',
                        hintText: 'e.g., After workout',
                      ),
                      maxLines: 2,
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
                    if (valueController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter a value'),
                        ),
                      );
                      return;
                    }
                    
                    if (metric.type == MetricType.bloodPressure && secondaryValueController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter both systolic and diastolic values'),
                        ),
                      );
                      return;
                    }
                    
                    double? value = double.tryParse(valueController.text);
                    double? secondaryValue = metric.type == MetricType.bloodPressure
                        ? double.tryParse(secondaryValueController.text)
                        : null;
                    
                    if (value == null || (metric.type == MetricType.bloodPressure && secondaryValue == null)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter valid numeric values'),
                        ),
                      );
                      return;
                    }
                    
                    final newEntry = MetricEntry(
                      id: const Uuid().v4(),
                      value: value,
                      secondaryValue: secondaryValue,
                      date: selectedDate,
                      note: noteController.text.trim(),
                    );
                    
                    context.read<HealthMetricsCubit>().addMetricEntry(metric.id, newEntry);
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
  
  void _showEditMetricDialog(BuildContext context, HealthMetric metric) {
    showDialog(
      context: context,
      builder: (context) {
        final nameController = TextEditingController(text: metric.name);
        final descriptionController = TextEditingController(text: metric.description);
        final unitController = TextEditingController(text: metric.unit);
        MetricType selectedType = metric.type;
        GoalType selectedGoalType = metric.goalType;
        final goalMinController = TextEditingController(text: metric.goalMin.toString());
        final goalMaxController = TextEditingController(text: metric.goalMax.toString());
        int selectedColor = metric.color;
        String selectedIcon = metric.icon;
        
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit Metric'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Metric Name',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
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
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<MetricType>(
                            value: selectedType,
                            decoration: const InputDecoration(
                              labelText: 'Type',
                            ),
                            items: [
                              const DropdownMenuItem(
                                value: MetricType.integer,
                                child: Text('Integer'),
                              ),
                              const DropdownMenuItem(
                                value: MetricType.decimal,
                                child: Text('Decimal'),
                              ),
                              const DropdownMenuItem(
                                value: MetricType.bloodPressure,
                                child: Text('Blood Pressure'),
                              ),
                              const DropdownMenuItem(
                                value: MetricType.duration,
                                child: Text('Duration'),
                              ),
                              const DropdownMenuItem(
                                value: MetricType.boolean,
                                child: Text('Yes/No'),
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
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: GoalType.none,
                          child: Text('No Goal'),
                        ),
                        const DropdownMenuItem(
                          value: GoalType.minimum,
                          child: Text('Minimum'),
                        ),
                        const DropdownMenuItem(
                          value: GoalType.maximum,
                          child: Text('Maximum'),
                        ),
                        const DropdownMenuItem(
                          value: GoalType.range,
                          child: Text('Range'),
                        ),
                        const DropdownMenuItem(
                          value: GoalType.target,
                          child: Text('Target'),
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
                    
                    final updatedMetric = metric.copyWith(
                      name: nameController.text.trim(),
                      description: descriptionController.text.trim(),
                      unit: unitController.text.trim(),
                      type: selectedType,
                      color: selectedColor,
                      icon: selectedIcon,
                      goalType: selectedGoalType,
                      goalMin: double.tryParse(goalMinController.text) ?? 0,
                      goalMax: double.tryParse(goalMaxController.text) ?? 0,
                    );
                    
                    context.read<HealthMetricsCubit>().updateMetric(updatedMetric);
                    Navigator.pop(context);
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }
  
  void _showEditEntryDialog(BuildContext context, HealthMetric metric, MetricEntry entry) {
    showDialog(
      context: context,
      builder: (context) {
        final valueController = TextEditingController(text: entry.value.toString());
        final secondaryValueController = TextEditingController(
          text: entry.secondaryValue?.toString() ?? '',
        );
        final noteController = TextEditingController(text: entry.note);
        DateTime selectedDate = entry.date;
        
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Edit ${metric.name} Entry'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (metric.type == MetricType.bloodPressure)
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: valueController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Systolic',
                                suffixText: 'mmHg',
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextField(
                              controller: secondaryValueController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Diastolic',
                                suffixText: 'mmHg',
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      TextField(
                        controller: valueController,
                        keyboardType: metric.type == MetricType.integer
                            ? TextInputType.number
                            : const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: 'Value',
                          suffixText: metric.unit,
                        ),
                      ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        
                        if (pickedDate != null) {
                          setState(() {
                            selectedDate = pickedDate;
                          });
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Date',
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          DateFormat('EEEE, MMMM d, y').format(selectedDate),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: noteController,
                      decoration: const InputDecoration(
                        labelText: 'Note (Optional)',
                      ),
                      maxLines: 2,
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
                    if (valueController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter a value'),
                        ),
                      );
                      return;
                    }
                    
                    if (metric.type == MetricType.bloodPressure && secondaryValueController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter both systolic and diastolic values'),
                        ),
                      );
                      return;
                    }
                    
                    double? value = double.tryParse(valueController.text);
                    double? secondaryValue = metric.type == MetricType.bloodPressure
                        ? double.tryParse(secondaryValueController.text)
                        : null;
                    
                    if (value == null || (metric.type == MetricType.bloodPressure && secondaryValue == null)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter valid numeric values'),
                        ),
                      );
                      return;
                    }
                    
                    final updatedEntry = entry.copyWith(
                      value: value,
                      secondaryValue: secondaryValue,
                      date: selectedDate,
                      note: noteController.text.trim(),
                    );
                    
                    context.read<HealthMetricsCubit>().updateMetricEntry(metric.id, updatedEntry);
                    Navigator.pop(context);
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }
  
  void _showEntryOptionsDialog(BuildContext context, HealthMetric metric, MetricEntry entry) {
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text('Entry Options'),
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Entry'),
              onTap: () {
                Navigator.pop(context);
                _showEditEntryDialog(context, metric, entry);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete Entry', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _showDeleteEntryConfirmationDialog(context, metric, entry);
              },
            ),
          ],
        );
      },
    );
  }
  
  void _showDeleteEntryConfirmationDialog(BuildContext context, HealthMetric metric, MetricEntry entry) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Entry'),
          content: Text(
            'Are you sure you want to delete this ${metric.name} entry from ${DateFormat('MMMM d, y').format(entry.date)}?',
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
                context.read<HealthMetricsCubit>().deleteMetricEntry(metric.id, entry.id);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
  
  void _showDeleteConfirmationDialog(BuildContext context, HealthMetric metric) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Metric'),
          content: Text(
            'Are you sure you want to delete "${metric.name}"? This will delete all entries and cannot be undone.',
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
                context.read<HealthMetricsCubit>().deleteMetric(metric.id);
                Navigator.pop(context);
                Navigator.pop(context); // Return to metrics list
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
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
  
  IconData _getChangeIcon(String trend) {
    switch (trend) {
      case 'up':
        return Icons.trending_up;
      case 'down':
        return Icons.trending_down;
      default:
        return Icons.trending_flat;
    }
  }
  
  Color _getChangeColor(String trend) {
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