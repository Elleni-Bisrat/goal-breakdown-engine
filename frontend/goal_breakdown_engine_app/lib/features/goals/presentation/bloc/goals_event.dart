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
  const GoalCreateRequested({required this.title, required this.priorityLabel});

  final String title;
  /// e.g. High, Medium, Low — mapped to duration on submit.
  final String priorityLabel;

  @override
  List<Object?> get props => [title, priorityLabel];
}

final class GoalDeleteRequested extends GoalsEvent {
  const GoalDeleteRequested(this.goalId);

  final String goalId;

  @override
  List<Object?> get props => [goalId];
}
