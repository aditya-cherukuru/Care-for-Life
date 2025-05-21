import 'package:flutter/material.dart';

/// Enum representing the frequency of a habit
enum HabitFrequency {
  daily,
  specificDays,
  everyXDays,
}

/// Model class for a tracked habit
class TrackedHabit {
  /// Unique identifier for the habit
  final String id;
  
  /// Title of the habit
  final String title;
  
  /// Description of the habit
  final String description;
  
  /// Icon data string (Material icon name)
  final String iconData;
  
  /// Color of the habit (stored as an integer)
  final int color;
  
  /// Frequency type of the habit
  final HabitFrequency frequency;
  
  /// Days of the week for the habit (1 = Monday, 7 = Sunday)
  final List<int> weekdays;
  
  /// For habits that repeat every X days
  final int everyXDays;
  
  /// Optional reminder time
  final TimeOfDay? reminderTime;
  
  /// When the habit was created
  final DateTime createdAt;
  
  /// Category of the habit (e.g., Health, Fitness, etc.)
  final String category;
  
  /// Target number of days to complete the habit
  final int targetDays;
  
  /// List of dates when the habit was completed (in YYYY-MM-DD format)
  final List<String> completedDates;
  
  /// Days of the week for reminders (1 = Monday, 7 = Sunday)
  final List<int> reminderDays;

  /// Constructor
  const TrackedHabit({
    required this.id,
    required this.title,
    required this.description,
    required this.iconData,
    required this.color,
    required this.frequency,
    required this.weekdays,
    required this.everyXDays,
    required this.reminderTime,
    required this.createdAt,
    required this.category,
    required this.targetDays,
    required this.completedDates,
    required this.reminderDays,
  });

  /// Create a copy of this habit with optional field updates
  TrackedHabit copyWith({
    String? id,
    String? title,
    String? description,
    String? iconData,
    int? color,
    HabitFrequency? frequency,
    List<int>? weekdays,
    int? everyXDays,
    TimeOfDay? reminderTime,
    DateTime? createdAt,
    String? category,
    int? targetDays,
    List<String>? completedDates,
    List<int>? reminderDays,
  }) {
    return TrackedHabit(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      iconData: iconData ?? this.iconData,
      color: color ?? this.color,
      frequency: frequency ?? this.frequency,
      weekdays: weekdays ?? this.weekdays,
      everyXDays: everyXDays ?? this.everyXDays,
      reminderTime: reminderTime ?? this.reminderTime,
      createdAt: createdAt ?? this.createdAt,
      category: category ?? this.category,
      targetDays: targetDays ?? this.targetDays,
      completedDates: completedDates ?? this.completedDates,
      reminderDays: reminderDays ?? this.reminderDays,
    );
  }

  /// Convert the habit to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'iconData': iconData,
      'color': color,
      'frequency': frequency.index,
      'weekdays': weekdays,
      'everyXDays': everyXDays,
      'reminderTime': reminderTime != null
          ? '${reminderTime!.hour}:${reminderTime!.minute}'
          : null,
      'createdAt': createdAt.toIso8601String(),
      'category': category,
      'targetDays': targetDays,
      'completedDates': completedDates,
      'reminderDays': reminderDays,
    };
  }

  /// Create a habit from a JSON map
  factory TrackedHabit.fromJson(Map<String, dynamic> json) {
    TimeOfDay? reminderTime;
    if (json['reminderTime'] != null) {
      final parts = (json['reminderTime'] as String).split(':');
      reminderTime = TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    }

    return TrackedHabit(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      iconData: json['iconData'],
      color: json['color'],
      frequency: HabitFrequency.values[json['frequency']],
      weekdays: List<int>.from(json['weekdays']),
      everyXDays: json['everyXDays'],
      reminderTime: reminderTime,
      createdAt: DateTime.parse(json['createdAt']),
      category: json['category'],
      targetDays: json['targetDays'],
      completedDates: List<String>.from(json['completedDates']),
      reminderDays: List<int>.from(json['reminderDays']),
    );
  }

  /// Get the color as a Flutter Color object
  Color get colorValue => Color(color);

  /// Get the icon as a Flutter IconData
  IconData get icon {
    // Map common icon strings to IconData
    switch (iconData) {
      case 'water_drop':
        return Icons.water_drop;
      case 'fitness_center':
        return Icons.fitness_center;
      case 'self_improvement':
        return Icons.self_improvement;
      case 'book':
        return Icons.book;
      case 'bedtime':
        return Icons.bedtime;
      case 'restaurant':
        return Icons.restaurant;
      case 'smoking_rooms':
        return Icons.smoking_rooms;
      case 'local_bar':
        return Icons.local_bar;
      case 'medication':
        return Icons.medication;
      case 'directions_run':
        return Icons.directions_run;
      case 'emoji_food_beverage':
        return Icons.emoji_food_beverage;
      case 'spa':
        return Icons.spa;
      default:
        return Icons.check_circle;
    }
  }

  /// Check if the habit is completed for a specific date
  bool isCompletedOn(DateTime date) {
    final dateString = _formatDate(date);
    return completedDates.contains(dateString);
  }

  /// Check if the habit should be completed on a specific date
  bool shouldCompleteOn(DateTime date) {
    // If the habit is set for specific days of the week
    if (frequency == HabitFrequency.specificDays) {
      final weekday = date.weekday; // 1 = Monday, 7 = Sunday
      return weekdays.contains(weekday);
    }
    
    // If the habit is daily
    if (frequency == HabitFrequency.daily) {
      return true;
    }
    
    // If the habit is every X days
    if (frequency == HabitFrequency.everyXDays && everyXDays > 0) {
      final daysSinceCreation = date.difference(createdAt).inDays;
      return daysSinceCreation % everyXDays == 0;
    }
    
    return false;
  }

  /// Get the current streak for this habit
  int get currentStreak {
    if (completedDates.isEmpty) {
      return 0;
    }
    
    // Get today's date
    final today = DateTime.now();
    final todayString = _formatDate(today);
    
    // Check if the habit is completed today
    final isCompletedToday = completedDates.contains(todayString);
    
    // If the habit is not completed today and it should be, streak is broken
    if (!isCompletedToday && shouldCompleteOn(today)) {
      return 0;
    }
    
    // Calculate streak
    int streak = 0;
    DateTime currentDate = today;
    
    // Go back in time to find the streak
    while (true) {
      // Only count days when the habit should be completed
      if (shouldCompleteOn(currentDate)) {
        final dateString = _formatDate(currentDate);
        final isCompleted = completedDates.contains(dateString);
        
        // If we find a day that should have been completed but wasn't, the streak is broken
        if (!isCompleted) {
          break;
        }
        
        streak++;
      }
      
      // Move to the previous day
      currentDate = currentDate.subtract(const Duration(days: 1));
      
      // Limit the streak calculation to the last 365 days to avoid infinite loops
      if (today.difference(currentDate).inDays > 365) {
        break;
      }
    }
    
    return streak;
  }

  /// Get the completion rate for the last 30 days
  double get completionRate {
    // Get the start date (either habit creation date or 30 days ago, whichever is more recent)
    final today = DateTime.now();
    final thirtyDaysAgo = today.subtract(const Duration(days: 30));
    final startDate = createdAt.isAfter(thirtyDaysAgo) 
        ? createdAt 
        : thirtyDaysAgo;
    
    // Count the days the habit should have been completed
    int totalDays = 0;
    int completedDays = 0;
    
    for (var i = 0; i <= today.difference(startDate).inDays; i++) {
      final date = startDate.add(Duration(days: i));
      
      if (shouldCompleteOn(date)) {
        totalDays++;
        
        final dateString = _formatDate(date);
        if (completedDates.contains(dateString)) {
          completedDays++;
        }
      }
    }
    
    return totalDays > 0 ? completedDays / totalDays : 0.0;
  }

  /// Get the progress towards the target days
  double get progress {
    return completedDates.length / targetDays;
  }

  /// Format a date to a string (YYYY-MM-DD)
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Get a human-readable frequency description
  String get frequencyDescription {
    switch (frequency) {
      case HabitFrequency.daily:
        return 'Every day';
      case HabitFrequency.specificDays:
        final days = weekdays.map((day) {
          switch (day) {
            case 1: return 'Mon';
            case 2: return 'Tue';
            case 3: return 'Wed';
            case 4: return 'Thu';
            case 5: return 'Fri';
            case 6: return 'Sat';
            case 7: return 'Sun';
            default: return '';
          }
        }).join(', ');
        return 'Every $days';
      case HabitFrequency.everyXDays:
        return everyXDays == 1 
            ? 'Every day' 
            : 'Every $everyXDays days';
    }
  }
}