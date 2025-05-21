import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:care_for_life/core/utils/shared_prefs.dart';
import 'package:care_for_life/features/health_metrices/data/models/health_metric.dart';
import 'package:care_for_life/features/health_metrices/data/models/metric_entry.dart';

/// Repository for managing health metrics data
class HealthMetricsRepository {
  static const String _metricsKey = 'health_metrics';
  final Uuid _uuid = const Uuid();

  /// Load all health metrics from storage
  Future<List<HealthMetric>> loadMetrics() async {
    try {
      final metricsJson = SharedPrefs.getString(_metricsKey);
      
      if (metricsJson == null || metricsJson.isEmpty) {
        return _createDefaultMetrics();
      }
      
      final List<dynamic> decodedList = jsonDecode(metricsJson);
      return decodedList
          .map((metricJson) => HealthMetric.fromJson(metricJson))
          .toList();
    } catch (e) {
      // If there's an error loading metrics, return default metrics
      return _createDefaultMetrics();
    }
  }

  /// Save all health metrics to storage
  Future<bool> saveMetrics(List<HealthMetric> metrics) async {
    try {
      final metricsJson = jsonEncode(metrics.map((m) => m.toJson()).toList());
      return await SharedPrefs.saveString(_metricsKey, metricsJson);
    } catch (e) {
      return false;
    }
  }

  /// Get a metric by ID
  Future<HealthMetric?> getMetricById(String id) async {
    final metrics = await loadMetrics();
    try {
      return metrics.firstWhere(
        (metric) => metric.id == id,
      );
    } catch (e) {
      return null;
    }
  }

  /// Create a new health metric
  Future<HealthMetric> createMetric(HealthMetric metric) async {
    final metrics = await loadMetrics();
    
    // Generate a new ID for the metric
    final newMetric = metric.copyWith(id: _uuid.v4());
    
    metrics.add(newMetric);
    await saveMetrics(metrics);
    
    return newMetric;
  }

  /// Update an existing health metric
  Future<bool> updateMetric(HealthMetric updatedMetric) async {
    final metrics = await loadMetrics();
    
    final index = metrics.indexWhere((m) => m.id == updatedMetric.id);
    if (index == -1) {
      return false;
    }
    
    metrics[index] = updatedMetric;
    return await saveMetrics(metrics);
  }

  /// Delete a health metric by ID
  Future<bool> deleteMetric(String id) async {
    final metrics = await loadMetrics();
    
    final initialLength = metrics.length;
    metrics.removeWhere((metric) => metric.id == id);
    
    if (metrics.length == initialLength) {
      return false;
    }
    
    return await saveMetrics(metrics);
  }

  /// Add a new entry to a health metric
  Future<bool> addMetricEntry(String metricId, MetricEntry entry) async {
    final metric = await getMetricById(metricId);
    if (metric == null) {
      return false;
    }
    
    final entries = List<MetricEntry>.from(metric.entries);
    
    // Generate a new ID for the entry if it doesn't have one
    final newEntry = entry.id.isEmpty 
        ? entry.copyWith(id: _uuid.v4()) 
        : entry;
    
    entries.add(newEntry);
    
    // Sort entries by date (newest first)
    entries.sort((a, b) => b.date.compareTo(a.date));
    
    final updatedMetric = metric.copyWith(entries: entries);
    return await updateMetric(updatedMetric);
  }

  /// Update an existing entry in a health metric
  Future<bool> updateMetricEntry(String metricId, MetricEntry updatedEntry) async {
    final metric = await getMetricById(metricId);
    if (metric == null) {
      return false;
    }
    
    final entries = List<MetricEntry>.from(metric.entries);
    
    final index = entries.indexWhere((e) => e.id == updatedEntry.id);
    if (index == -1) {
      return false;
    }
    
    entries[index] = updatedEntry;
    
    // Sort entries by date (newest first)
    entries.sort((a, b) => b.date.compareTo(a.date));
    
    final updatedMetric = metric.copyWith(entries: entries);
    return await updateMetric(updatedMetric);
  }

  /// Delete an entry from a health metric
  Future<bool> deleteMetricEntry(String metricId, String entryId) async {
    final metric = await getMetricById(metricId);
    if (metric == null) {
      return false;
    }
    
    final entries = List<MetricEntry>.from(metric.entries);
    
    final initialLength = entries.length;
    entries.removeWhere((entry) => entry.id == entryId);
    
    if (entries.length == initialLength) {
      return false;
    }
    
    final updatedMetric = metric.copyWith(entries: entries);
    return await updateMetric(updatedMetric);
  }

  /// Get the latest entry for a metric
  Future<MetricEntry?> getLatestEntry(String metricId) async {
    final metric = await getMetricById(metricId);
    if (metric == null || metric.entries.isEmpty) {
      return null;
    }
    
    // Entries are already sorted by date (newest first)
    return metric.entries.first;
  }

  /// Get entries for a metric within a date range
  Future<List<MetricEntry>> getEntriesInRange(
    String metricId, 
    DateTime startDate, 
    DateTime endDate
  ) async {
    final metric = await getMetricById(metricId);
    if (metric == null) {
      return [];
    }
    
    return metric.entries.where((entry) {
      return entry.date.isAfter(startDate) && 
             entry.date.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  /// Create default metrics if none exist
  List<HealthMetric> _createDefaultMetrics() {
    final now = DateTime.now();
    
    return [
      HealthMetric(
        id: _uuid.v4(),
        name: 'Weight',
        description: 'Track your body weight',
        unit: 'kg',
        type: MetricType.decimal,
        color: 0xFF2196F3,
        icon: 'monitor_weight',
        goalType: GoalType.range,
        goalMin: 50.0,
        goalMax: 80.0,
        entries: [
          MetricEntry(
            id: _uuid.v4(),
            value: 70.5,
            date: now.subtract(const Duration(days: 7)),
            note: 'Initial weight',
          ),
        ],
      ),
      HealthMetric(
        id: _uuid.v4(),
        name: 'Blood Pressure',
        description: 'Track your blood pressure',
        unit: 'mmHg',
        type: MetricType.bloodPressure,
        color: 0xFFE91E63,
        icon: 'favorite',
        goalType: GoalType.range,
        goalMin: 90.0,
        goalMax: 120.0,
        entries: [
          MetricEntry(
            id: _uuid.v4(),
            value: 120.0,
            secondaryValue: 80.0,
            date: now.subtract(const Duration(days: 7)),
            note: 'Initial blood pressure',
          ),
        ],
      ),
      HealthMetric(
        id: _uuid.v4(),
        name: 'Heart Rate',
        description: 'Track your heart rate',
        unit: 'bpm',
        type: MetricType.integer,
        color: 0xFF9C27B0,
        icon: 'favorite',
        goalType: GoalType.range,
        goalMin: 60.0,
        goalMax: 100.0,
        entries: [
          MetricEntry(
            id: _uuid.v4(),
            value: 72.0,
            date: now.subtract(const Duration(days: 7)),
            note: 'Initial heart rate',
          ),
        ],
      ),
      HealthMetric(
        id: _uuid.v4(),
        name: 'Steps',
        description: 'Track your daily steps',
        unit: 'steps',
        type: MetricType.integer,
        color: 0xFF4CAF50,
        icon: 'directions_walk',
        goalType: GoalType.minimum,
        goalMin: 10000.0,
        goalMax: 0.0,
        entries: [
          MetricEntry(
            id: _uuid.v4(),
            value: 8500.0,
            date: now.subtract(const Duration(days: 1)),
            note: 'Yesterday\'s steps',
          ),
        ],
      ),
      HealthMetric(
        id: _uuid.v4(),
        name: 'Sleep',
        description: 'Track your sleep duration',
        unit: 'hours',
        type: MetricType.duration,
        color: 0xFF673AB7,
        icon: 'bedtime',
        goalType: GoalType.range,
        goalMin: 7.0,
        goalMax: 9.0,
        entries: [
          MetricEntry(
            id: _uuid.v4(),
            value: 7.5,
            date: now.subtract(const Duration(days: 1)),
            note: 'Last night\'s sleep',
          ),
        ],
      ),
    ];
  }
}