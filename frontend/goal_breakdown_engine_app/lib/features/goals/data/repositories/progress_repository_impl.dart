import 'package:dio/dio.dart';
import 'package:goal_breakdown_engine_app/features/dashboard/domain/entities/dashboard_stats_entity.dart';
import 'package:goal_breakdown_engine_app/features/goals/domain/entities/goal_progress_entity.dart';
import 'package:goal_breakdown_engine_app/features/goals/domain/repositories/progress_repository.dart';

class ProgressRepositoryImpl implements ProgressRepository {
  ProgressRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<DashboardStatsEntity> fetchDashboard() async {
    final res = await _dio.get<Map<String, dynamic>>('/progress/dashboard');
    final m = res.data!;
    return DashboardStatsEntity(
      totalTasks: (m['totalTasks'] as num?)?.toInt() ?? 0,
      completedTasks: (m['completedTasks'] as num?)?.toInt() ?? 0,
      progressPercent: (m['progress'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  Future<GoalProgressEntity> fetchGoalProgress(String goalId) async {
    final res = await _dio.get<Map<String, dynamic>>('/progress/$goalId');
    final m = res.data!;
    return GoalProgressEntity(
      totalTasks: (m['totalTasks'] as num?)?.toInt() ?? 0,
      completedTasks: (m['completedTasks'] as num?)?.toInt() ?? 0,
      progressPercent: (m['progress'] as num?)?.toInt() ?? 0,
    );
  }
}
