import 'package:dio/dio.dart';
import 'package:goal_breakdown_engine_app/features/goals/data/models/goal_model.dart';
import 'package:goal_breakdown_engine_app/features/goals/domain/entities/goal_entity.dart';
import 'package:goal_breakdown_engine_app/features/goals/domain/repositories/goal_repository.dart';

class GoalRepositoryImpl implements GoalRepository {
  GoalRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<GoalEntity> createGoal({
    required String title,
    String? description,
    required int duration,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/goals',
      data: {'title': title, 'description': description, 'duration': duration},
    );
    return GoalModel.fromJson(res.data!);
  }

  @override
  Future<void> deleteGoal(String id) async {
    await _dio.delete<dynamic>('/goals/$id');
  }

  @override
  Future<GoalEntity> fetchGoal(String id) async {
    final res = await _dio.get<Map<String, dynamic>>('/goals/$id');
    return GoalModel.fromJson(res.data!);
  }

  @override
  Future<List<GoalEntity>> fetchGoals() async {
    final res = await _dio.get<List<dynamic>>('/goals');
    final list = res.data ?? [];
    return list
        .map((e) => GoalModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<GoalEntity> updateGoal(String id, Map<String, dynamic> patch) async {
    final res = await _dio.put<Map<String, dynamic>>('/goals/$id', data: patch);
    return GoalModel.fromJson(res.data!);
  }
}
