import 'package:equatable/equatable.dart';

sealed class GoalsEvent extends Equatable {
  const GoalsEvent();

  @override
  List<Object?> get props => [];
}

final class GoalsLoadRequested extends GoalsEvent {
  const GoalsLoadRequested();
}

final class GoalCreateRequested extends GoalsEvent {
  const GoalCreateRequested({
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.priority,
  });

  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final String priority; // 'low', 'medium', 'high'

  @override
  List<Object?> get props => [title, description, startDate, endDate, priority];
}

final class GoalDeleteRequested extends GoalsEvent {
  const GoalDeleteRequested(this.goalId);

  final String goalId;

  @override
  List<Object?> get props => [goalId];
}
