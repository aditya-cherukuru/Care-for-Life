import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:care_for_life/features/habit_tracker/presentation/cubit/habit_tracker_cubit.dart';
import 'package:care_for_life/features/habit_tracker/data/models/tracked_habit.dart';
import 'package:care_for_life/app_router.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:table_calendar/table_calendar.dart';

class HabitDetailPage extends StatefulWidget {
  final String habitId;
  
  const HabitDetailPage({
    Key? key,
    required this.habitId,
  }) : super(key: key);

  @override
  State<HabitDetailPage> createState() => _HabitDetailPageState();
}

class _HabitDetailPageState extends State<HabitDetailPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _timeRange = '7d';
  
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
    return BlocBuilder<HabitTrackerCubit, HabitTrackerState>(
      builder: (context, state) {
        final habit = context.read<HabitTrackerCubit>().getHabitById(widget.habitId);
        
        if (habit == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Habit Details'),
            ),
            body: const Center(
              child: Text('Habit not found'),
            ),
          );
        }
        
        return Scaffold(
          appBar: AppBar(
            title: Text(habit.title),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  _showEditHabitDialog(context, habit);
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  _showDeleteConfirmationDialog(context, habit);
                },
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Overview'),
                Tab(text: 'Calendar'),
                Tab(text: 'Stats'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(context, habit, state),
              _buildCalendarTab(context, habit, state),
              _buildStatsTab(context, habit),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildOverviewTab(BuildContext context, TrackedHabit habit, HabitTrackerState state) {
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
                          color: habit.colorValue.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          habit.icon,
                          color: habit.colorValue,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              habit.title,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              habit.description,
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
                  // Wrap in SingleChildScrollView to prevent overflow on small screens
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          context,
                          'Category',
                          habit.category,
                          Icons.category,
                        ),
                        const SizedBox(width: 24),
                        _buildStatItem(
                          context,
                          'Frequency',
                          habit.frequencyDescription,
                          Icons.calendar_today,
                        ),
                        const SizedBox(width: 24),
                        _buildStatItem(
                          context,
                          'Created',
                          DateFormat('MMM d, y').format(habit.createdAt),
                          Icons.access_time,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Progress Card
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
                    'Progress',
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
                              '${(habit.progress * 100).toInt()}% Complete',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: habit.progress,
                              backgroundColor: Colors.grey[200],
                              valueColor: AlwaysStoppedAnimation<Color>(habit.colorValue),
                              minHeight: 8,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${habit.completedDates.length} / ${habit.targetDays} days',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: habit.colorValue.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '${habit.currentStreak}',
                                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                        color: habit.colorValue,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Streak',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: habit.colorValue,
                                      ),
                                    ),
                                  ],
                                ),
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
          
          // Today Card
          if (state is HabitTrackerLoaded)
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
                      'Today',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                DateFormat('EEEE, MMMM d').format(DateTime.now()),
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                habit.shouldCompleteOn(DateTime.now())
                                    ? 'You should complete this habit today'
                                    : 'This habit is not scheduled for today',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: habit.shouldCompleteOn(DateTime.now())
                                      ? Colors.black
                                      : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (habit.shouldCompleteOn(DateTime.now()))
                          Switch(
                            value: habit.isCompletedOn(DateTime.now()),
                            onChanged: (value) {
                              context.read<HabitTrackerCubit>().toggleHabitCompletion(habit.id);
                            },
                            activeColor: habit.colorValue,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          
          const SizedBox(height: 24),
          
          // Recent Activity Card
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
                    'Recent Activity',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  habit.completedDates.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              'No activity yet',
                              style: TextStyle(
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        )
                      : Column(
                          children: _getRecentCompletions(habit).map((dateString) {
                            final date = DateTime.parse(dateString);
                            return ListTile(
                              leading: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: habit.colorValue.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.check,
                                  color: habit.colorValue,
                                ),
                              ),
                              title: Text(
                                'Completed',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              subtitle: Text(
                                DateFormat('EEEE, MMMM d, y').format(date),
                                style: Theme.of(context).textTheme.bodySmall,
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
  
  Widget _buildCalendarTab(BuildContext context, TrackedHabit habit, HabitTrackerState state) {
    if (state is HabitTrackerLoaded) {
      return Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: state.selectedDate,
            selectedDayPredicate: (day) {
              return isSameDay(state.selectedDate, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              context.read<HabitTrackerCubit>().changeSelectedDate(selectedDay);
            },
            calendarStyle: CalendarStyle(
              selectedDecoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              markerDecoration: BoxDecoration(
                color: habit.colorValue,
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: Theme.of(context).textTheme.titleMedium!,
            ),
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                final dateString = _formatDate(date);
                final isCompleted = habit.completedDates.contains(dateString);
                final shouldComplete = habit.shouldCompleteOn(date);
                
                if (isCompleted) {
                  return Positioned(
                    bottom: 1,
                    right: 1,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: habit.colorValue,
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                } else if (shouldComplete && date.isBefore(DateTime.now())) {
                  return Positioned(
                    bottom: 1,
                    right: 1,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                }
                
                return null;
              },
            ),
          ),
          const Divider(),
          // Wrap in SingleChildScrollView to prevent overflow
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: habit.colorValue,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                const Text('Completed'),
                const SizedBox(width: 16),
                Container(
                  width: 16,
                  height: 16,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                const Text('Missed'),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: _buildSelectedDayDetails(context, habit, state),
          ),
        ],
      );
    }
    
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
  
  Widget _buildSelectedDayDetails(BuildContext context, TrackedHabit habit, HabitTrackerLoaded state) {
    final selectedDate = state.selectedDate;
    final dateString = _formatDate(selectedDate);
    final isCompleted = habit.completedDates.contains(dateString);
    final shouldComplete = habit.shouldCompleteOn(selectedDate);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DateFormat('EEEE, MMMM d, y').format(selectedDate),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
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
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: habit.colorValue.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          habit.icon,
                          color: habit.colorValue,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              habit.title,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              shouldComplete
                                  ? 'This habit is scheduled for this day'
                                  : 'This habit is not scheduled for this day',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: shouldComplete ? Colors.black : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Status',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      if (shouldComplete)
                        Chip(
                          label: Text(
                            isCompleted ? 'Completed' : 'Not Completed',
                            style: TextStyle(
                              color: isCompleted ? Colors.white : Colors.black,
                            ),
                          ),
                          backgroundColor: isCompleted ? Colors.green : Colors.grey[300],
                        )
                      else
                        const Chip(
                          label: Text('Not Scheduled'),
                          backgroundColor: Colors.grey,
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (shouldComplete && selectedDate.isBefore(DateTime.now().add(const Duration(days: 1))))
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          context.read<HabitTrackerCubit>().toggleHabitCompletion(habit.id);
                        },
                        icon: Icon(isCompleted ? Icons.close : Icons.check),
                        label: Text(isCompleted ? 'Mark as Not Completed' : 'Mark as Completed'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isCompleted ? Colors.red : Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatsTab(BuildContext context, TrackedHabit habit) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Completion Rate Card
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
                        'Completion Rate',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      _buildTimeRangeSelector(),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: _buildCompletionChart(habit),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Stats Cards - Use a GridView instead of Row for better responsiveness
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildStatCard(
                context,
                'Current Streak',
                '${habit.currentStreak} days',
                Icons.local_fire_department,
                Colors.orange,
              ),
              _buildStatCard(
                context,
                'Completion Rate',
                '${(habit.completionRate * 100).toInt()}%',
                Icons.bar_chart,
                Colors.blue,
              ),
              _buildStatCard(
                context,
                'Total Completions',
                '${habit.completedDates.length}',
                Icons.check_circle,
                Colors.green,
              ),
              _buildStatCard(
                context,
                'Days Tracked',
                '${DateTime.now().difference(habit.createdAt).inDays + 1}',
                Icons.calendar_month,
                Colors.purple,
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Weekly Pattern Card
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
                    'Weekly Pattern',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  // Use SingleChildScrollView for horizontal scrolling on small screens
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildWeekdayCompletion(context, habit, 1, 'M'),
                        const SizedBox(width: 8),
                        _buildWeekdayCompletion(context, habit, 2, 'T'),
                        const SizedBox(width: 8),
                        _buildWeekdayCompletion(context, habit, 3, 'W'),
                        const SizedBox(width: 8),
                        _buildWeekdayCompletion(context, habit, 4, 'T'),
                        const SizedBox(width: 8),
                        _buildWeekdayCompletion(context, habit, 5, 'F'),
                        const SizedBox(width: 8),
                        _buildWeekdayCompletion(context, habit, 6, 'S'),
                        const SizedBox(width: 8),
                        _buildWeekdayCompletion(context, habit, 7, 'S'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Add bottom padding to ensure content isn't cut off
          const SizedBox(height: 24),
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
    return Card(
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
                Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTimeRangeSelector() {
    return SegmentedButton<String>(
      segments: const [
        ButtonSegment<String>(
          value: '7d',
          label: Text('7d'),
        ),
        ButtonSegment<String>(
          value: '30d',
          label: Text('30d'),
        ),
        ButtonSegment<String>(
          value: '90d',
          label: Text('90d'),
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
      ),
    );
  }
  
  Widget _buildCompletionChart(TrackedHabit habit) {
    final chartData = _prepareChartData(habit);
    
    if (chartData.isEmpty) {
      return Center(
        child: Text(
          'No data available',
          style: TextStyle(
            color: Colors.grey[600],
          ),
        ),
      );
    }
    
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 0.2,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: const Color.fromARGB(255, 96, 90, 90),
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
                  '${(value * 100).toInt()}%',
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
                if (value.toInt() % (_timeRange == '7d' ? 1 : _timeRange == '30d' ? 5 : 15) == 0 && 
                    value.toInt() < chartData.length) {
                  final date = DateTime.now().subtract(
                    Duration(days: int.parse(_timeRange.substring(0, _timeRange.length - 1)) - 1 - value.toInt()),
                  );
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      DateFormat(_timeRange == '7d' ? 'E' : 'd/M').format(date),
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
            spots: chartData.asMap().entries.map((entry) {
              return FlSpot(entry.key.toDouble(), entry.value);
            }).toList(),
            isCurved: true,
            color: habit.colorValue,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: habit.colorValue,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: habit.colorValue.withOpacity(0.2),
            ),
          ),
        ],
        minY: 0,
        maxY: 1,
      ),
    );
  }
  
  List<double> _prepareChartData(TrackedHabit habit) {
    if (habit.completedDates.isEmpty) return [];
    
    final days = int.parse(_timeRange.substring(0, _timeRange.length - 1));
    final chartData = List<double>.filled(days, 0);
    
    // Fill in the chart data
    final now = DateTime.now();
    for (int i = 0; i < days; i++) {
      final date = now.subtract(Duration(days: days - 1 - i));
      final dateString = _formatDate(date);
      
      if (habit.shouldCompleteOn(date)) {
        chartData[i] = habit.completedDates.contains(dateString) ? 1.0 : 0.0;
      } else {
        // If the habit is not scheduled for this day, use the previous value or 0
        chartData[i] = i > 0 ? chartData[i - 1] : 0.0;
      }
    }
    
    return chartData;
  }
  
  Widget _buildWeekdayCompletion(BuildContext context, TrackedHabit habit, int weekday, String label) {
    // Calculate completion rate for this weekday
    int totalDays = 0;
    int completedDays = 0;
    
    final now = DateTime.now();
    final startDate = habit.createdAt;
    
    for (var i = 0; i <= now.difference(startDate).inDays; i++) {
      final date = startDate.add(Duration(days: i));
      
      if (date.weekday == weekday && habit.shouldCompleteOn(date)) {
        totalDays++;
        
        final dateString = _formatDate(date);
        if (habit.completedDates.contains(dateString)) {
          completedDays++;
        }
      }
    }
    
    final completionRate = totalDays > 0 ? completedDays / totalDays : 0.0;
    final isScheduled = habit.frequency == HabitFrequency.daily || 
                        (habit.frequency == HabitFrequency.specificDays && habit.weekdays.contains(weekday));
    
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isScheduled 
                ? habit.colorValue.withOpacity(0.2)
                : Colors.grey[200],
            shape: BoxShape.circle,
            border: Border.all(
              color: isScheduled ? habit.colorValue : Colors.grey,
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isScheduled ? habit.colorValue : Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${(completionRate * 100).toInt()}%',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: isScheduled ? Colors.black : Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
  
  Widget _buildDayChip(int day, String label, List<int> selectedDays, Function(bool) onSelected) {
    final isSelected = selectedDays.contains(day);
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: onSelected,
      backgroundColor: Colors.grey[200],
      checkmarkColor: Colors.white,
    );
  }
  
  Widget _buildColorChip(int color, int selectedColor, Function(int) onSelected) {
    final isSelected = color == selectedColor;
    return GestureDetector(
      onTap: () => onSelected(color),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Color(color),
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.white : Colors.transparent,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 2,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
      ),
    );
  }
  
  Widget _buildIconChip(String iconName, String selectedIcon, Function(String) onSelected) {
    final isSelected = iconName == selectedIcon;
    return GestureDetector(
      onTap: () => onSelected(iconName),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.withOpacity(0.2) : Colors.grey[200],
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.transparent,
            width: 2,
          ),
        ),
        child: Icon(
          IconData(
            // Convert string icon names to their corresponding codepoints
            iconName == 'water_drop'
                ? 0xe798 // water_drop icon codepoint
                : iconName == 'fitness_center'
                    ? 0xe284 // fitness_center icon codepoint
                    : iconName == 'self_improvement'
                        ? 0xea78 // self_improvement icon codepoint
                        : iconName == 'book'
                            ? 0xe865 // book icon codepoint
                            : iconName == 'bedtime'
                                ? 0xe1a4 // bedtime icon codepoint
                                : 0xe56c, // restaurant icon codepoint
            fontFamily: 'MaterialIcons',
          ),
          color: isSelected ? Colors.blue : Colors.grey[600],
          size: 20,
        ),
      ),
    );
  }
  
  List<String> _getRecentCompletions(TrackedHabit habit) {
    if (habit.completedDates.isEmpty) return [];
    
    final sortedDates = List<String>.from(habit.completedDates)
      ..sort((a, b) => b.compareTo(a));
    
    return sortedDates.take(5).toList();
  }
  
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
  
  void _showEditHabitDialog(BuildContext context, TrackedHabit habit) {
    showDialog(
      context: context,
      builder: (context) {
        final titleController = TextEditingController(text: habit.title);
        final descriptionController = TextEditingController(text: habit.description);
        String selectedCategory = habit.category;
        HabitFrequency selectedFrequency = habit.frequency;
        List<int> selectedDays = List<int>.from(habit.weekdays);
        int everyXDays = habit.everyXDays;
        int targetDays = habit.targetDays;
        int selectedColor = habit.color;
        String selectedIcon = habit.iconData;
        
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              // Use Dialog instead of AlertDialog for more control over size
              child: Container(
                constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Edit Habit',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextField(
                                controller: titleController,
                                decoration: const InputDecoration(
                                  labelText: 'Habit Name',
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
                              DropdownButtonFormField<String>(
                                value: selectedCategory,
                                decoration: const InputDecoration(
                                  labelText: 'Category',
                                ),
                                items: [
                                  'Health',
                                  'Fitness',
                                  'Mindfulness',
                                  'Productivity',
                                  'Learning',
                                  'Other',
                                ]
                                    .map((category) => DropdownMenuItem(
                                          value: category,
                                          child: Text(category),
                                        ))
                                    .toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      selectedCategory = value;
                                    });
                                  }
                                },
                              ),
                              const SizedBox(height: 16),
                              DropdownButtonFormField<HabitFrequency>(
                                value: selectedFrequency,
                                decoration: const InputDecoration(
                                  labelText: 'Frequency',
                                ),
                                items: [
                                  const DropdownMenuItem(
                                    value: HabitFrequency.daily,
                                    child: Text('Daily'),
                                  ),
                                  const DropdownMenuItem(
                                    value: HabitFrequency.specificDays,
                                    child: Text('Specific Days'),
                                  ),
                                  const DropdownMenuItem(
                                    value: HabitFrequency.everyXDays,
                                    child: Text('Every X Days'),
                                  ),
                                ],
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      selectedFrequency = value;
                                    });
                                  }
                                },
                              ),
                              const SizedBox(height: 16),
                              if (selectedFrequency == HabitFrequency.specificDays)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Select Days:'),
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 8,
                                      children: [
                                        _buildDayChip(1, 'M', selectedDays, (selected) {
                                          setState(() {
                                            if (selected) {
                                              selectedDays.add(1);
                                            } else {
                                              selectedDays.remove(1);
                                            }
                                          });
                                        }),
                                        _buildDayChip(2, 'T', selectedDays, (selected) {
                                          setState(() {
                                            if (selected) {
                                              selectedDays.add(2);
                                            } else {
                                              selectedDays.remove(2);
                                            }
                                          });
                                        }),
                                        _buildDayChip(3, 'W', selectedDays, (selected) {
                                          setState(() {
                                            if (selected) {
                                              selectedDays.add(3);
                                            } else {
                                              selectedDays.remove(3);
                                            }
                                          });
                                        }),
                                        _buildDayChip(4, 'T', selectedDays, (selected) {
                                          setState(() {
                                            if (selected) {
                                              selectedDays.add(4);
                                            } else {
                                              selectedDays.remove(4);
                                            }
                                          });
                                        }),
                                        _buildDayChip(5, 'F', selectedDays, (selected) {
                                          setState(() {
                                            if (selected) {
                                              selectedDays.add(5);
                                            } else {
                                              selectedDays.remove(5);
                                            }
                                          });
                                        }),
                                        _buildDayChip(6, 'S', selectedDays, (selected) {
                                          setState(() {
                                            if (selected) {
                                              selectedDays.add(6);
                                            } else {
                                              selectedDays.remove(6);
                                            }
                                          });
                                        }),
                                        _buildDayChip(7, 'S', selectedDays, (selected) {
                                          setState(() {
                                            if (selected) {
                                              selectedDays.add(7);
                                            } else {
                                              selectedDays.remove(7);
                                            }
                                          });
                                        }),
                                      ],
                                    ),
                                  ],
                                ),
                              if (selectedFrequency == HabitFrequency.everyXDays)
                                Row(
                                  children: [
                                    const Text('Every'),
                                    const SizedBox(width: 8),
                                    SizedBox(
                                      width: 50,
                                      child: TextField(
                                        keyboardType: TextInputType.number,
                                        decoration: const InputDecoration(
                                          contentPadding: EdgeInsets.symmetric(horizontal: 8),
                                        ),
                                        textAlign: TextAlign.center,
                                        onChanged: (value) {
                                          setState(() {
                                            everyXDays = int.tryParse(value) ?? 1;
                                          });
                                        },
                                        controller: TextEditingController(text: everyXDays.toString()),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text('days'),
                                  ],
                                ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  const Text('Target: '),
                                  const SizedBox(width: 8),
                                  SizedBox(
                                    width: 50,
                                    child: TextField(
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(
                                        contentPadding: EdgeInsets.symmetric(horizontal: 8),
                                      ),
                                      textAlign: TextAlign.center,
                                      onChanged: (value) {
                                        setState(() {
                                          targetDays = int.tryParse(value) ?? 7;
                                        });
                                      },
                                      controller: TextEditingController(text: targetDays.toString()),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text('days'),
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
                                  _buildIconChip('water_drop', selectedIcon, (icon) {
                                    setState(() {
                                      selectedIcon = icon;
                                    });
                                  }),
                                  _buildIconChip('fitness_center', selectedIcon, (icon) {
                                    setState(() {
                                      selectedIcon = icon;
                                    });
                                  }),
                                  _buildIconChip('self_improvement', selectedIcon, (icon) {
                                    setState(() {
                                      selectedIcon = icon;
                                    });
                                  }),
                                  _buildIconChip('book', selectedIcon, (icon) {
                                    setState(() {
                                      selectedIcon = icon;
                                    });
                                  }),
                                  _buildIconChip('bedtime', selectedIcon, (icon) {
                                    setState(() {
                                      selectedIcon = icon;
                                    });
                                  }),
                                  _buildIconChip('restaurant', selectedIcon, (icon) {
                                    setState(() {
                                      selectedIcon = icon;
                                    });
                                  }),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              if (titleController.text.trim().isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Please enter a habit name'),
                                  ),
                                );
                                return;
                              }
                              
                              if (selectedFrequency == HabitFrequency.specificDays && selectedDays.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Please select at least one day'),
                                  ),
                                );
                                return;
                              }
                              
                              final updatedHabit = habit.copyWith(
                                title: titleController.text.trim(),
                                description: descriptionController.text.trim(),
                                iconData: selectedIcon,
                                color: selectedColor,
                                frequency: selectedFrequency,
                                weekdays: selectedDays,
                                reminderDays: selectedDays,
                                everyXDays: everyXDays,
                                category: selectedCategory,
                                targetDays: targetDays,
                              );
                              
                              context.read<HabitTrackerCubit>().updateHabit(updatedHabit);
                              Navigator.pop(context);
                            },
                            child: const Text('Save'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
  
  void _showDeleteConfirmationDialog(BuildContext context, TrackedHabit habit) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Habit'),
          content: Text('Are you sure you want to delete "${habit.title}"? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<HabitTrackerCubit>().deleteHabit(habit.id);
                Navigator.pop(context);
                Navigator.pop(context); // Return to habits list
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
}