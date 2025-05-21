import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:care_for_life/features/health_metrices/data/models/health_metric.dart';
import 'package:care_for_life/features/health_metrices/data/models/metric_entry.dart';
import 'package:care_for_life/features/health_metrices/data/repositories/health_metrics_repository.dart';

// State
abstract class HealthMetricsState extends Equatable {
  const HealthMetricsState();
  
  @override
  List<Object?> get props => [];
}

class HealthMetricsInitial extends HealthMetricsState {}

class HealthMetricsLoading extends HealthMetricsState {}

class HealthMetricsLoaded extends HealthMetricsState {
  final List<HealthMetric> metrics;
  final String? selectedMetricId;
  final DateTime startDate;
  final DateTime endDate;
  
  const HealthMetricsLoaded({
    required this.metrics,
    this.selectedMetricId,
    required this.startDate,
    required this.endDate,
  });
  
  @override
  List<Object?> get props => [metrics, selectedMetricId, startDate, endDate];
  
  HealthMetricsLoaded copyWith({
    List<HealthMetric>? metrics,
    String? selectedMetricId,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return HealthMetricsLoaded(
      metrics: metrics ?? this.metrics,
      selectedMetricId: selectedMetricId ?? this.selectedMetricId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
}

class HealthMetricsError extends HealthMetricsState {
  final String message;
  
  const HealthMetricsError(this.message);
  
  @override
  List<Object?> get props => [message];
}

// Cubit
class HealthMetricsCubit extends Cubit<HealthMetricsState> {
  final HealthMetricsRepository _repository;
  
  HealthMetricsCubit(this._repository) : super(HealthMetricsInitial());
  
  // Load all metrics
  Future<void> loadMetrics() async {
    emit(HealthMetricsLoading());
    
    try {
      final metrics = await _repository.loadMetrics();
      
      // Default date range: last 30 days
      final now = DateTime.now();
      final startDate = DateTime(now.year, now.month - 1, now.day);
      final endDate = now;
      
      emit(HealthMetricsLoaded(
        metrics: metrics,
        startDate: startDate,
        endDate: endDate,
      ));
    } catch (e) {
      emit(HealthMetricsError('Failed to load metrics: ${e.toString()}'));
    }
  }
  
  // Select a metric
  void selectMetric(String? metricId) {
    if (state is HealthMetricsLoaded) {
      final currentState = state as HealthMetricsLoaded;
      emit(currentState.copyWith(selectedMetricId: metricId));
    }
  }
  
  // Change the date range
  void changeDateRange(DateTime startDate, DateTime endDate) {
    if (state is HealthMetricsLoaded) {
      final currentState = state as HealthMetricsLoaded;
      emit(currentState.copyWith(
        startDate: startDate,
        endDate: endDate,
      ));
    }
  }
  
  // Get a metric by ID
  HealthMetric? getMetricById(String id) {
    if (state is HealthMetricsLoaded) {
      final currentState = state as HealthMetricsLoaded;
      try {
        return currentState.metrics.firstWhere((metric) => metric.id == id);
      } catch (e) {
        return null;
      }
    }
    return null;
  }
  
  // Create a new metric
  Future<void> createMetric(HealthMetric metric) async {
    if (state is HealthMetricsLoaded) {
      final currentState = state as HealthMetricsLoaded;
      
      try {
        final newMetric = await _repository.createMetric(metric);
        final updatedMetrics = List<HealthMetric>.from(currentState.metrics)..add(newMetric);
        
        emit(currentState.copyWith(metrics: updatedMetrics));
      } catch (e) {
        emit(HealthMetricsError('Failed to create metric: ${e.toString()}'));
      }
    }
  }
  
  // Update an existing metric
  Future<void> updateMetric(HealthMetric updatedMetric) async {
    if (state is HealthMetricsLoaded) {
      final currentState = state as HealthMetricsLoaded;
      
      try {
        final success = await _repository.updateMetric(updatedMetric);
        
        if (success) {
          final metricIndex = currentState.metrics.indexWhere((m) => m.id == updatedMetric.id);
          
          if (metricIndex != -1) {
            final updatedMetrics = List<HealthMetric>.from(currentState.metrics);
            updatedMetrics[metricIndex] = updatedMetric;
            
            emit(currentState.copyWith(metrics: updatedMetrics));
          }
        }
      } catch (e) {
        emit(HealthMetricsError('Failed to update metric: ${e.toString()}'));
      }
    }
  }
  
  // Delete a metric
  Future<void> deleteMetric(String metricId) async {
    if (state is HealthMetricsLoaded) {
      final currentState = state as HealthMetricsLoaded;
      
      try {
        final success = await _repository.deleteMetric(metricId);
        
        if (success) {
          final updatedMetrics = currentState.metrics.where((m) => m.id != metricId).toList();
          emit(currentState.copyWith(metrics: updatedMetrics));
        }
      } catch (e) {
        emit(HealthMetricsError('Failed to delete metric: ${e.toString()}'));
      }
    }
  }
  
  // Add a new entry to a metric
  Future<void> addMetricEntry(String metricId, MetricEntry entry) async {
    if (state is HealthMetricsLoaded) {
      final currentState = state as HealthMetricsLoaded;
      
      try {
        final success = await _repository.addMetricEntry(metricId, entry);
        
        if (success) {
          // Reload metrics to get the updated state
          await loadMetrics();
          
          // Restore the selected metric
          if (state is HealthMetricsLoaded) {
            final newState = state as HealthMetricsLoaded;
            emit(newState.copyWith(
              selectedMetricId: currentState.selectedMetricId,
              startDate: currentState.startDate,
              endDate: currentState.endDate,
            ));
          }
        }
      } catch (e) {
        emit(HealthMetricsError('Failed to add entry: ${e.toString()}'));
      }
    }
  }
  
  // Update an existing entry in a metric
  Future<void> updateMetricEntry(String metricId, MetricEntry updatedEntry) async {
    if (state is HealthMetricsLoaded) {
      final currentState = state as HealthMetricsLoaded;
      
      try {
        final success = await _repository.updateMetricEntry(metricId, updatedEntry);
        
        if (success) {
          // Reload metrics to get the updated state
          await loadMetrics();
          
          // Restore the selected metric
          if (state is HealthMetricsLoaded) {
            final newState = state as HealthMetricsLoaded;
            emit(newState.copyWith(
              selectedMetricId: currentState.selectedMetricId,
              startDate: currentState.startDate,
              endDate: currentState.endDate,
            ));
          }
        }
      } catch (e) {
        emit(HealthMetricsError('Failed to update entry: ${e.toString()}'));
      }
    }
  }
  
  // Delete an entry from a metric
  Future<void> deleteMetricEntry(String metricId, String entryId) async {
    if (state is HealthMetricsLoaded) {
      final currentState = state as HealthMetricsLoaded;
      
      try {
        final success = await _repository.deleteMetricEntry(metricId, entryId);
        
        if (success) {
          // Reload metrics to get the updated state
          await loadMetrics();
          
          // Restore the selected metric
          if (state is HealthMetricsLoaded) {
            final newState = state as HealthMetricsLoaded;
            emit(newState.copyWith(
              selectedMetricId: currentState.selectedMetricId,
              startDate: currentState.startDate,
              endDate: currentState.endDate,
            ));
          }
        }
      } catch (e) {
        emit(HealthMetricsError('Failed to delete entry: ${e.toString()}'));
      }
    }
  }
  
  // Get entries for a metric within the current date range
  List<MetricEntry> getEntriesInCurrentRange(String metricId) {
    if (state is HealthMetricsLoaded) {
      final currentState = state as HealthMetricsLoaded;
      final metric = getMetricById(metricId);
      
      if (metric != null) {
        return metric.entries.where((entry) {
          return entry.date.isAfter(currentState.startDate.subtract(const Duration(days: 1))) && 
                 entry.date.isBefore(currentState.endDate.add(const Duration(days: 1)));
        }).toList();
      }
    }
    
    return [];
  }
  
  // Get metrics by category
  Map<String, List<HealthMetric>> getMetricsByCategory() {
    final Map<String, List<HealthMetric>> metricsByCategory = {
      'Vitals': [],
      'Body': [],
      'Activity': [],
      'Nutrition': [],
      'Other': [],
    };
    
    if (state is HealthMetricsLoaded) {
      final currentState = state as HealthMetricsLoaded;
      
      for (final metric in currentState.metrics) {
        switch (metric.name) {
          case 'Blood Pressure':
          case 'Heart Rate':
          case 'Temperature':
          case 'Oxygen Saturation':
            metricsByCategory['Vitals']!.add(metric);
            break;
          case 'Weight':
          case 'BMI':
          case 'Body Fat':
          case 'Waist Circumference':
            metricsByCategory['Body']!.add(metric);
            break;
          case 'Steps':
          case 'Exercise':
          case 'Sleep':
            metricsByCategory['Activity']!.add(metric);
            break;
          case 'Water':
          case 'Calories':
            metricsByCategory['Nutrition']!.add(metric);
            break;
          default:
            metricsByCategory['Other']!.add(metric);
        }
      }
    }
    
    // Remove empty categories
    metricsByCategory.removeWhere((key, value) => value.isEmpty);
    
    return metricsByCategory;
  }
}