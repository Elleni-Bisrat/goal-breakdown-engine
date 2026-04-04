import 'package:goal_breakdown_engine_app/features/tasks/domain/entities/task_entity.dart';

class TaskModel extends TaskEntity {
  const TaskModel({
    required super.id,
    required super.goalId,
    required super.title,
    super.description,
    required super.dueDate,
    required super.status,
    required super.milestoneIndex,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    final gid = json['goalId'];
    String goalIdStr;
    if (gid is String) {
      goalIdStr = gid;
    } else if (gid is Map && gid['_id'] != null) {
      goalIdStr = gid['_id'].toString();
    } else {
      goalIdStr = gid?.toString() ?? '';
    }

    final rawId = json['_id'] ?? json['id'];
    final due = json['dueDate'];
    DateTime dueDate;
    if (due is String) {
      dueDate = DateTime.tryParse(due) ?? DateTime.now();
    } else {
      dueDate = DateTime.now();
    }

    return TaskModel(
      id: rawId is String ? rawId : rawId.toString(),
      goalId: goalIdStr,
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      dueDate: dueDate,
      status: json['status'] as String? ?? 'pending',
      milestoneIndex: (json['milestoneIndex'] is int)
          ? json['milestoneIndex'] as int
          : int.tryParse('${json['milestoneIndex']}') ?? -1,
    );
  }
}
