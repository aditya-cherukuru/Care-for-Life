import 'package:flutter/material.dart';
import 'package:care_for_life/features/health_metrices/data/models/metric_entry.dart';

/// Types of health metrics
enum MetricType {
  integer,
  decimal,
  bloodPressure,
  duration,
  boolean,
}

/// Types of goals for health metrics
enum GoalType {
  none,
  minimum,
  maximum,
  range,
  target,
}

/// Model class for a health metric
class HealthMetric {
  /// Unique identifier for the metric
  final String id;

  /// Name of the metric
  final String name;

  /// Description of the metric
  final String description;

  /// Unit of measurement (e.g., kg, bpm, mmHg)
  final String unit;

  /// Type of metric
  final MetricType type;

  /// Color of the metric (stored as an integer)
  final int color;

  /// Icon data string (Material icon name)
  final String icon;

  /// Type of goal for this metric
  final GoalType goalType;

  /// Minimum goal value (for range or minimum goals)
  final double goalMin;

  /// Maximum goal value (for range or maximum goals)
  final double goalMax;

  /// List of entries for this metric
  final List<MetricEntry> entries;

  /// Constructor
  const HealthMetric({
    required this.id,
    required this.name,
    required this.description,
    required this.unit,
    required this.type,
    required this.color,
    required this.icon,
    required this.goalType,
    required this.goalMin,
    required this.goalMax,
    required this.entries,
  });

  /// Create a copy of this metric with optional field updates
  HealthMetric copyWith({
    String? id,
    String? name,
    String? description,
    String? unit,
    MetricType? type,
    int? color,
    String? icon,
    GoalType? goalType,
    double? goalMin,
    double? goalMax,
    List<MetricEntry>? entries,
  }) {
    return HealthMetric(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      unit: unit ?? this.unit,
      type: type ?? this.type,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      goalType: goalType ?? this.goalType,
      goalMin: goalMin ?? this.goalMin,
      goalMax: goalMax ?? this.goalMax,
      entries: entries ?? this.entries,
    );
  }

  /// Convert the metric to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'unit': unit,
      'type': type.index,
      'color': color,
      'icon': icon,
      'goalType': goalType.index,
      'goalMin': goalMin,
      'goalMax': goalMax,
      'entries': entries.map((entry) => entry.toJson()).toList(),
    };
  }

  /// Create a metric from a JSON map
  factory HealthMetric.fromJson(Map<String, dynamic> json) {
    return HealthMetric(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      unit: json['unit'],
      type: MetricType.values[json['type']],
      color: json['color'],
      icon: json['icon'],
      goalType: GoalType.values[json['goalType']],
      goalMin: json['goalMin'],
      goalMax: json['goalMax'],
      entries: (json['entries'] as List)
          .map((entryJson) => MetricEntry.fromJson(entryJson))
          .toList(),
    );
  }

  /// Get the color as a Flutter Color object
  Color get colorValue => Color(color);

  /// Get the icon as a Flutter IconData
  IconData get iconData {
    // Map common icon strings to IconData
    switch (icon) {
      case 'monitor_weight':
        return Icons.monitor_weight;
      case 'favorite':
        return Icons.favorite;
      case 'directions_walk':
        return Icons.directions_walk;
      case 'bedtime':
        return Icons.bedtime;
      case 'water_drop':
        return Icons.water_drop;
      case 'restaurant':
        return Icons.restaurant;
      case 'medication':
        return Icons.medication;
      case 'fitness_center':
        return Icons.fitness_center;
      case 'local_hospital':
        return Icons.local_hospital;
      default:
        return Icons.show_chart;
    }
  }

  /// Get the latest entry for this metric
  MetricEntry? get latestEntry {
    if (entries.isEmpty) {
      return null;
    }
    return entries.first; // Entries are sorted by date (newest first)
  }

  /// Get the trend for this metric (up, down, or stable)
  String get trend {
    if (entries.length < 2) {
      return 'stable';
    }

    final latest = entries[0].value;
    final previous = entries[1].value;

    if (latest > previous) {
      return 'up';
    } else if (latest < previous) {
      return 'down';
    } else {
      return 'stable';
    }
  }

  /// Check if the latest value is within the goal range
  bool get isWithinGoal {
    final latest = latestEntry;
    if (latest == null) {
      return false;
    }

    switch (goalType) {
      case GoalType.none:
        return true;
      case GoalType.minimum:
        return latest.value >= goalMin;
      case GoalType.maximum:
        return latest.value <= goalMax;
      case GoalType.range:
        return latest.value >= goalMin && latest.value <= goalMax;
      case GoalType.target:
        // Within 5% of the target
        final target = goalMin;
        final range = target * 0.05;
        return (latest.value >= target - range) && (latest.value <= target + range);
    }
  }

  /// Get a formatted string for the goal
  String get goalString {
    switch (goalType) {
      case GoalType.none:
        return 'No goal set';
      case GoalType.minimum:
        return 'Min: $goalMin $unit';
      case GoalType.maximum:
        return 'Max: $goalMax $unit';
      case GoalType.range:
        return '$goalMin - $goalMax $unit';
      case GoalType.target:
        return 'Target: $goalMin $unit';
    }
  }

  /// Format a value according to the metric type
  String formatValue(double value, [double? secondaryValue]) {
    switch (type) {
      case MetricType.integer:
        return '${value.toInt()} $unit';
      case MetricType.decimal:
        return '${value.toStringAsFixed(1)} $unit';
      case MetricType.bloodPressure:
        if (secondaryValue != null) {
          return '${value.toInt()}/${secondaryValue.toInt()} $unit';
        }
        return '${value.toInt()} $unit';
      case MetricType.duration:
        final hours = value.toInt();
        final minutes = ((value - hours) * 60).toInt();
        return '$hours:${minutes.toString().padLeft(2, '0')} $unit';
      case MetricType.boolean:
        return value > 0 ? 'Yes' : 'No';
    }
  }
}