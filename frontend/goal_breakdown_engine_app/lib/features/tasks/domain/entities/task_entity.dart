import 'package:equatable/equatable.dart';

class TaskEntity extends Equatable {
  const TaskEntity({
    required this.id,
    required this.goalId,
    required this.title,
    this.description,
    required this.dueDate,
    required this.status,
    required this.milestoneIndex,
  });

  final String id;
  final String goalId;
  final String title;
  final String? description;
  final DateTime dueDate;
  final String status;
  final int milestoneIndex;

  bool get isCompleted => status == 'completed';

  @override
  List<Object?> get props =>
      [id, goalId, title, description, dueDate, status, milestoneIndex];
}
