import 'package:equatable/equatable.dart';

class GoalEntity extends Equatable {
  const GoalEntity({
    required this.id,
    required this.title,
    this.description,
    required this.startDate,
    required this.endDate,
    this.priority = 'medium',
    this.status = 'active',
    this.totalTasks = 0,
    this.totalMilestones = 0,
  });

  final String id;
  final String title;
  final String? description;
  final DateTime startDate;
  final DateTime endDate;
  final String priority;
  final String status;
  final int totalTasks;
  final int totalMilestones;

  int get durationInDays => endDate.difference(startDate).inDays;

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    startDate,
    endDate,
    priority,
    status,
    totalTasks,
    totalMilestones,
  ];
}
