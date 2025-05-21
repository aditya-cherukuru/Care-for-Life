import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:care_for_life/features/habit_tracker/presentation/cubit/habit_tracker_cubit.dart';
import 'package:care_for_life/features/habit_tracker/data/models/tracked_habit.dart';
import 'package:care_for_life/app_router.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class HabitTrackerPage extends StatefulWidget {
  const HabitTrackerPage({Key? key}) : super(key: key);

  @override
  State<HabitTrackerPage> createState() => _HabitTrackerPageState();
}

class _HabitTrackerPageState extends State<HabitTrackerPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _showCalendar = false;
  
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
    return BlocBuilder<HabitTrackerCubit, HabitTrackerState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Habit Tracker'),
            actions: [
              IconButton(
                icon: Icon(_showCalendar ? Icons.calendar_today : Icons.date_range),
                onPressed: () {
                  setState(() {
                    _showCalendar = !_showCalendar;
                  });
                },
                tooltip: 'Toggle Calendar',
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Today'),
                Tab(text: 'All Habits'),
              ],
            ),
          ),
          body: Column(
            children: [
              if (_showCalendar) _buildCalendar(context, state),
              _buildDateSelector(context, state),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildTodayTab(context, state),
                    _buildAllHabitsTab(context, state),
                  ],
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              _showAddHabitDialog(context);
            },
            child: const Icon(Icons.add),
            tooltip: 'Add Habit',
          ),
        );
      },
    );
  }
  
  Widget _buildCalendar(BuildContext context, HabitTrackerState state) {
    if (state is HabitTrackerLoaded) {
      return Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TableCalendar(
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
          ),
          headerStyle: HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            titleTextStyle: Theme.of(context).textTheme.titleMedium!,
          ),
        ),
      );
    }
    
    return const SizedBox.shrink();
  }
  
  Widget _buildDateSelector(BuildContext context, HabitTrackerState state) {
    if (state is HabitTrackerLoaded) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () {
                final previousDay = state.selectedDate.subtract(const Duration(days: 1));
                context.read<HabitTrackerCubit>().changeSelectedDate(previousDay);
              },
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  _showCalendar = true;
                });
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    DateFormat('EEEE').format(state.selectedDate),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    DateFormat('MMMM d, y').format(state.selectedDate),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () {
                final nextDay = state.selectedDate.add(const Duration(days: 1));
                context.read<HabitTrackerCubit>().changeSelectedDate(nextDay);
              },
            ),
          ],
        ),
      );
    }
    
    return const SizedBox.shrink();
  }
  
Widget _buildTodayTab(BuildContext context, HabitTrackerState state) {
  if (state is HabitTrackerLoading) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
  
  if (state is HabitTrackerLoaded) {
    final habitsForToday = context.read<HabitTrackerCubit>().getHabitsForSelectedDate();
    
    if (habitsForToday.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No habits for this day',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add a habit or select a different day',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                _showAddHabitDialog(context);
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Habit'),
            ),
          ],
        ),
      );
    }
    
    // Group habits by category for today's tab
    final habitsByCategory = <String, List<TrackedHabit>>{};
    for (final habit in habitsForToday) {
      if (!habitsByCategory.containsKey(habit.category)) {
        habitsByCategory[habit.category] = [];
      }
      habitsByCategory[habit.category]!.add(habit);
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: habitsByCategory.length,
      itemBuilder: (context, index) {
        final category = habitsByCategory.keys.elementAt(index);
        final habits = habitsByCategory[category]!;
        
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
              itemCount: habits.length,
              itemBuilder: (context, habitIndex) {
                final habit = habits[habitIndex];
                final isCompleted = habit.isCompletedOn(state.selectedDate);
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    onTap: () {
                      AppRouter.navigateToHabitDetail(context, habit.id);
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
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  habit.description,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                                    color: Colors.grey[600],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                // Use LayoutBuilder to ensure the row fits within available space
                                LayoutBuilder(
                                  builder: (context, constraints) {
                                    return Row(
                                      children: [
                                        // Use Flexible for the category to allow it to shrink if needed
                                        Flexible(
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.grey[200],
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              habit.category,
                                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                color: Colors.grey[800],
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Icon(
                                          Icons.local_fire_department,
                                          size: 16,
                                          color: Colors.orange[700],
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Streak: ${habit.currentStreak}',
                                          style: Theme.of(context).textTheme.bodySmall,
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          Checkbox(
                            value: isCompleted,
                            onChanged: (value) {
                              context.read<HabitTrackerCubit>().toggleHabitCompletion(habit.id);
                            },
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
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
  
  if (state is HabitTrackerError) {
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
  
  Widget _buildAllHabitsTab(BuildContext context, HabitTrackerState state) {
    if (state is HabitTrackerLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    if (state is HabitTrackerLoaded) {
      final habitsByCategory = context.read<HabitTrackerCubit>().getHabitsByCategory();
      
      if (habitsByCategory.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.list_alt,
                size: 80,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No habits yet',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Add a habit to get started',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  _showAddHabitDialog(context);
                },
                icon: const Icon(Icons.add),
                label: const Text('Add Habit'),
              ),
            ],
          ),
        );
      }
      
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: habitsByCategory.length,
        itemBuilder: (context, index) {
          final category = habitsByCategory.keys.elementAt(index);
          final habits = habitsByCategory[category]!;
          
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
                itemCount: habits.length,
                itemBuilder: (context, habitIndex) {
                  final habit = habits[habitIndex];
                  
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: InkWell(
                      onTap: () {
                        AppRouter.navigateToHabitDetail(context, habit.id);
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
                                    habit.description,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Flexible(
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.calendar_today,
                                            size: 16,
                                            color: Colors.grey[600],
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            habit.frequencyDescription,
                                            style: Theme.of(context).textTheme.bodySmall,
                                          ),
                                          const SizedBox(width: 12),
                                          Icon(
                                          Icons.local_fire_department,
                                          size: 16,
                                          color: Colors.orange[700],
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Streak: ${habit.currentStreak}',
                                            style: Theme.of(context).textTheme.bodySmall,
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.chevron_right),
                              onPressed: () {
                                AppRouter.navigateToHabitDetail(context, habit.id);
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
    
    if (state is HabitTrackerError) {
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
  
  void _showAddHabitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        final titleController = TextEditingController();
        final descriptionController = TextEditingController();
        String selectedCategory = 'Health';
        HabitFrequency selectedFrequency = HabitFrequency.daily;
        List<int> selectedDays = [1, 2, 3, 4, 5, 6, 7];
        int everyXDays = 1;
        int targetDays = 7;
        int selectedColor = 0xFF2196F3;
        String selectedIcon = 'check_circle';
        
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add New Habit'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Habit Name',
                        hintText: 'e.g., Drink Water',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        hintText: 'e.g., Drink 8 glasses of water',
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
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
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
                    
                    final newHabit = TrackedHabit(
                      id: '',
                      title: titleController.text.trim(),
                      description: descriptionController.text.trim(),
                      iconData: selectedIcon,
                      color: selectedColor,
                      frequency: selectedFrequency,
                      weekdays: selectedDays,
                      everyXDays: everyXDays,
                      reminderTime: null,
                      createdAt: DateTime.now(),
                      category: selectedCategory,
                      targetDays: targetDays,
                      completedDates: [],
                      reminderDays: selectedDays,
                    );
                    
                    context.read<HabitTrackerCubit>().createHabit(newHabit);
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
  
  Widget _buildDayChip(int day, String label, List<int> selectedDays, Function(bool) onSelected) {
    final isSelected = selectedDays.contains(day);
    
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: onSelected,
      backgroundColor: Colors.grey[200],
      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
      checkmarkColor: Theme.of(context).primaryColor,
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
      case 'water_drop':
        iconData = Icons.water_drop;
        break;
      case 'fitness_center':
        iconData = Icons.fitness_center;
        break;
      case 'self_improvement':
        iconData = Icons.self_improvement;
        break;
      case 'book':
        iconData = Icons.book;
        break;
      case 'bedtime':
        iconData = Icons.bedtime;
        break;
      case 'restaurant':
        iconData = Icons.restaurant;
        break;
      default:
        iconData = Icons.check_circle;
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
}