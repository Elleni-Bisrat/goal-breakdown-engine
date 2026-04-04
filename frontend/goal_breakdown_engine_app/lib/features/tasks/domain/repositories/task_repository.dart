import 'package:goal_breakdown_engine_app/features/tasks/domain/entities/task_entity.dart';

abstract class TaskRepository {
  Future<List<TaskEntity>> fetchTasksForGoal(String goalId);

  Future<List<TaskEntity>> fetchTodayTasks();

  Future<TaskEntity> updateTask(
    String id, {
    String? title,
    String? description,
    DateTime? dueDate,
    String? status,
  });

  Future<void> deleteTask(String id);
}
