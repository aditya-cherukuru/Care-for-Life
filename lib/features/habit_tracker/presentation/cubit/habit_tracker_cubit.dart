import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:care_for_life/features/habit_tracker/data/models/tracked_habit.dart';
import 'package:care_for_life/features/habit_tracker/data/repositories/habit_tracker_repository.dart';

// State
abstract class HabitTrackerState extends Equatable {
  const HabitTrackerState();
  
  @override
  List<Object?> get props => [];
}

class HabitTrackerInitial extends HabitTrackerState {}

class HabitTrackerLoading extends HabitTrackerState {}

class HabitTrackerLoaded extends HabitTrackerState {
  final List<TrackedHabit> habits;
  final DateTime selectedDate;
  
  const HabitTrackerLoaded({
    required this.habits,
    required this.selectedDate,
  });
  
  @override
  List<Object?> get props => [habits, selectedDate];
  
  HabitTrackerLoaded copyWith({
    List<TrackedHabit>? habits,
    DateTime? selectedDate,
  }) {
    return HabitTrackerLoaded(
      habits: habits ?? this.habits,
      selectedDate: selectedDate ?? this.selectedDate,
    );
  }
}

class HabitTrackerError extends HabitTrackerState {
  final String message;
  
  const HabitTrackerError(this.message);
  
  @override
  List<Object?> get props => [message];
}

// Cubit
class HabitTrackerCubit extends Cubit<HabitTrackerState> {
  final HabitTrackerRepository _repository;
  
  HabitTrackerCubit(this._repository) : super(HabitTrackerInitial());
  
  // Load all habits
  Future<void> loadHabits() async {
    emit(HabitTrackerLoading());
    
    try {
      final habits = await _repository.loadHabits();
      emit(HabitTrackerLoaded(
        habits: habits,
        selectedDate: DateTime.now(),
      ));
    } catch (e) {
      emit(HabitTrackerError('Failed to load habits: ${e.toString()}'));
    }
  }
  
  // Change the selected date
  void changeSelectedDate(DateTime date) {
    if (state is HabitTrackerLoaded) {
      final currentState = state as HabitTrackerLoaded;
      emit(currentState.copyWith(selectedDate: date));
    }
  }
  
  // Get a habit by ID
  TrackedHabit? getHabitById(String id) {
    if (state is HabitTrackerLoaded) {
      final currentState = state as HabitTrackerLoaded;
      try {
        return currentState.habits.firstWhere((habit) => habit.id == id);
      } catch (e) {
        return null;
      }
    }
    return null;
  }
  
  // Create a new habit
  Future<void> createHabit(TrackedHabit habit) async {
    if (state is HabitTrackerLoaded) {
      final currentState = state as HabitTrackerLoaded;
      
      try {
        final newHabit = await _repository.createHabit(habit);
        final updatedHabits = List<TrackedHabit>.from(currentState.habits)..add(newHabit);
        
        emit(currentState.copyWith(habits: updatedHabits));
      } catch (e) {
        emit(HabitTrackerError('Failed to create habit: ${e.toString()}'));
      }
    }
  }
  
  // Update an existing habit
  Future<void> updateHabit(TrackedHabit updatedHabit) async {
    if (state is HabitTrackerLoaded) {
      final currentState = state as HabitTrackerLoaded;
      
      try {
        final success = await _repository.updateHabit(updatedHabit);
        
        if (success) {
          final habitIndex = currentState.habits.indexWhere((h) => h.id == updatedHabit.id);
          
          if (habitIndex != -1) {
            final updatedHabits = List<TrackedHabit>.from(currentState.habits);
            updatedHabits[habitIndex] = updatedHabit;
            
            emit(currentState.copyWith(habits: updatedHabits));
          }
        }
      } catch (e) {
        emit(HabitTrackerError('Failed to update habit: ${e.toString()}'));
      }
    }
  }
  
  // Delete a habit
  Future<void> deleteHabit(String habitId) async {
    if (state is HabitTrackerLoaded) {
      final currentState = state as HabitTrackerLoaded;
      
      try {
        final success = await _repository.deleteHabit(habitId);
        
        if (success) {
          final updatedHabits = currentState.habits.where((h) => h.id != habitId).toList();
          emit(currentState.copyWith(habits: updatedHabits));
        }
      } catch (e) {
        emit(HabitTrackerError('Failed to delete habit: ${e.toString()}'));
      }
    }
  }
  
  // Toggle habit completion for the selected date
  Future<void> toggleHabitCompletion(String habitId) async {
    if (state is HabitTrackerLoaded) {
      final currentState = state as HabitTrackerLoaded;
      final habit = getHabitById(habitId);
      
      if (habit != null) {
        final date = currentState.selectedDate;
        final dateString = _formatDate(date);
        final isCompleted = habit.completedDates.contains(dateString);
        
        try {
          bool success;
          
          if (isCompleted) {
            success = await _repository.uncompleteHabit(habitId, date);
          } else {
            success = await _repository.completeHabit(habitId, date);
          }
          
          if (success) {
            // Reload habits to get the updated state
            await loadHabits();
            
            // Restore the selected date
            if (state is HabitTrackerLoaded) {
              final newState = state as HabitTrackerLoaded;
              emit(newState.copyWith(selectedDate: date));
            }
          }
        } catch (e) {
          emit(HabitTrackerError('Failed to toggle habit completion: ${e.toString()}'));
        }
      }
    }
  }
  
  // Get habits for the selected date
  List<TrackedHabit> getHabitsForSelectedDate() {
    if (state is HabitTrackerLoaded) {
      final currentState = state as HabitTrackerLoaded;
      final date = currentState.selectedDate;
      
      return currentState.habits.where((habit) => habit.shouldCompleteOn(date)).toList();
    }
    
    return [];
  }
  
  // Get habits by category
  Map<String, List<TrackedHabit>> getHabitsByCategory() {
    final Map<String, List<TrackedHabit>> habitsByCategory = {};
    
    if (state is HabitTrackerLoaded) {
      final currentState = state as HabitTrackerLoaded;
      
      for (final habit in currentState.habits) {
        if (!habitsByCategory.containsKey(habit.category)) {
          habitsByCategory[habit.category] = [];
        }
        
        habitsByCategory[habit.category]!.add(habit);
      }
    }
    
    return habitsByCategory;
  }
  
  // Format a date to a string (YYYY-MM-DD)
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}