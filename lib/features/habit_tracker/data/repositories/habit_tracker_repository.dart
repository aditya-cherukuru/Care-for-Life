import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:care_for_life/core/utils/shared_prefs.dart';
import 'package:care_for_life/features/habit_tracker/data/models/tracked_habit.dart';

/// Repository for managing habit tracking data
class HabitTrackerRepository {
  static const String _habitsKey = 'tracked_habits';
  final Uuid _uuid = const Uuid();
  
  /// Load all tracked habits from storage
  Future<List<TrackedHabit>> loadHabits() async {
    try {
      final habitsJson = SharedPrefs.getString(_habitsKey);
      
      if (habitsJson == null || habitsJson.isEmpty) {
        return _createDefaultHabits();
      }
      
      final List<dynamic> decodedList = jsonDecode(habitsJson);
      return decodedList
          .map((habitJson) => TrackedHabit.fromJson(habitJson))
          .toList();
    } catch (e) {
      // If there's an error loading habits, return default habits
      return _createDefaultHabits();
    }
  }
  
  /// Save all tracked habits to storage
  Future<bool> saveHabits(List<TrackedHabit> habits) async {
    try {
      final habitsJson = jsonEncode(habits.map((h) => h.toJson()).toList());
      return await SharedPrefs.saveString(_habitsKey, habitsJson);
    } catch (e) {
      return false;
    }
  }
  
  /// Create a new habit
  Future<TrackedHabit> createHabit(TrackedHabit habit) async {
    final habits = await loadHabits();
    
    // Generate a new ID for the habit
    final newHabit = habit.copyWith(id: _uuid.v4());
    
    habits.add(newHabit);
    await saveHabits(habits);
    
    return newHabit;
  }
  
  /// Get a habit by ID
  Future<TrackedHabit?> getHabitById(String id) async {
    final habits = await loadHabits();
    try {
      return habits.firstWhere(
        (habit) => habit.id == id,
      );
    } catch (e) {
      return null;
    }
  }
  
  /// Update an existing habit
  Future<bool> updateHabit(TrackedHabit updatedHabit) async {
    final habits = await loadHabits();
    
    final index = habits.indexWhere((h) => h.id == updatedHabit.id);
    if (index == -1) {
      return false;
    }
    
    habits[index] = updatedHabit;
    return await saveHabits(habits);
  }
  
  /// Delete a habit by ID
  Future<bool> deleteHabit(String id) async {
    final habits = await loadHabits();
    
    final initialLength = habits.length;
    habits.removeWhere((habit) => habit.id == id);
    
    if (habits.length == initialLength) {
      return false;
    }
    
    return await saveHabits(habits);
  }
  
  /// Mark a habit as completed for a specific date
  Future<bool> completeHabit(String habitId, DateTime date) async {
    // First update the habit's completedDates
    final habit = await getHabitById(habitId);
    if (habit == null) {
      return false;
    }
    
    final dateString = _formatDate(date);
    final completedDates = List<String>.from(habit.completedDates);
    
    if (!completedDates.contains(dateString)) {
      completedDates.add(dateString);
      
      final updatedHabit = habit.copyWith(completedDates: completedDates);
      return await updateHabit(updatedHabit);
    }
    
    return true;
  }
  
  /// Mark a habit as not completed for a specific date
  Future<bool> uncompleteHabit(String habitId, DateTime date) async {
    // First update the habit's completedDates
    final habit = await getHabitById(habitId);
    if (habit == null) {
      return false;
    }
    
    final dateString = _formatDate(date);
    final completedDates = List<String>.from(habit.completedDates);
    
    if (completedDates.contains(dateString)) {
      completedDates.remove(dateString);
      
      final updatedHabit = habit.copyWith(completedDates: completedDates);
      return await updateHabit(updatedHabit);
    }
    
    return true;
  }
  
  /// Check if a habit is completed for a specific date
  Future<bool> isHabitCompleted(String habitId, DateTime date) async {
    final habit = await getHabitById(habitId);
    if (habit == null) {
      return false;
    }
    
    final dateString = _formatDate(date);
    return habit.completedDates.contains(dateString);
  }
  
  /// Format a date to a string (YYYY-MM-DD)
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
  
  /// Create default habits if none exist
  List<TrackedHabit> _createDefaultHabits() {
    return [
      TrackedHabit(
        id: _uuid.v4(),
        title: 'Drink Water',
        description: 'Drink at least 8 glasses of water',
        iconData: 'water_drop',
        color: 0xFF2196F3,
        frequency: HabitFrequency.daily,
        weekdays: const [1, 2, 3, 4, 5, 6, 7],
        everyXDays: 1,
        reminderTime: null,
        createdAt: DateTime.now(),
        category: 'Health',
        targetDays: 7,
        completedDates: [],
        reminderDays: const [1, 2, 3, 4, 5, 6, 7],
      ),
      TrackedHabit(
        id: _uuid.v4(),
        title: 'Exercise',
        description: 'At least 30 minutes of physical activity',
        iconData: 'fitness_center',
        color: 0xFFE91E63,
        frequency: HabitFrequency.specificDays,
        weekdays: const [1, 3, 5],
        everyXDays: 1,
        reminderTime: null,
        createdAt: DateTime.now(),
        category: 'Fitness',
        targetDays: 3,
        completedDates: [],
        reminderDays: const [1, 3, 5],
      ),
      TrackedHabit(
        id: _uuid.v4(),
        title: 'Meditate',
        description: '10 minutes of mindfulness meditation',
        iconData: 'self_improvement',
        color: 0xFF9C27B0,
        frequency: HabitFrequency.daily,
        weekdays: const [1, 2, 3, 4, 5, 6, 7],
        everyXDays: 1,
        reminderTime: null,
        createdAt: DateTime.now(),
        category: 'Mindfulness',
        targetDays: 7,
        completedDates: [],
        reminderDays: const [1, 2, 3, 4, 5, 6, 7],
      ),
    ];
  }
}