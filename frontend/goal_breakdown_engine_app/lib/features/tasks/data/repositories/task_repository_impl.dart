import 'package:dio/dio.dart';
import 'package:goal_breakdown_engine_app/features/tasks/data/models/task_model.dart';
import 'package:goal_breakdown_engine_app/features/tasks/domain/entities/task_entity.dart';
import 'package:goal_breakdown_engine_app/features/tasks/domain/repositories/task_repository.dart';

class TaskRepositoryImpl implements TaskRepository {
  TaskRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<void> deleteTask(String id) async {
    await _dio.delete<dynamic>('/tasks/$id');
  }

  @override
  Future<List<TaskEntity>> fetchTasksForGoal(String goalId) async {
    final res = await _dio.get<List<dynamic>>('/tasks/$goalId');
    final list = res.data ?? [];
    return list
        .map((e) => TaskModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<TaskEntity>> fetchTodayTasks() async {
    final res = await _dio.get<List<dynamic>>('/tasks/today');
    final list = res.data ?? [];
    return list
        .map((e) => TaskModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<TaskEntity> updateTask(
    String id, {
    String? title,
    String? description,
    DateTime? dueDate,
    String? status,
  }) async {
    final body = <String, dynamic>{
      'title': ?title,
      'description': ?description,
      if (dueDate != null) 'dueDate': dueDate.toIso8601String(),
      'status': ?status,
    };
    final res = await _dio.put<Map<String, dynamic>>('/tasks/$id', data: body);
    return TaskModel.fromJson(res.data!);
  }
}
