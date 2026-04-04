import 'package:equatable/equatable.dart';

class GoalProgressEntity extends Equatable {
  const GoalProgressEntity({
    required this.totalTasks,
    required this.completedTasks,
    required this.progressPercent,
  });

  final int totalTasks;
  final int completedTasks;
  final int progressPercent;

  @override
  List<Object?> get props => [totalTasks, completedTasks, progressPercent];
}
