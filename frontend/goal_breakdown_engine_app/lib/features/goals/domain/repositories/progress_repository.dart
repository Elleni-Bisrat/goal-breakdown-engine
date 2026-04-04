import 'package:goal_breakdown_engine_app/features/dashboard/domain/entities/dashboard_stats_entity.dart';
import 'package:goal_breakdown_engine_app/features/goals/domain/entities/goal_progress_entity.dart';

abstract class ProgressRepository {
  Future<DashboardStatsEntity> fetchDashboard();

  Future<GoalProgressEntity> fetchGoalProgress(String goalId);
}
