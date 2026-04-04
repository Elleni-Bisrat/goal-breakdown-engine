import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:goal_breakdown_engine_app/features/dashboard/domain/entities/dashboard_stats_entity.dart';
import 'package:goal_breakdown_engine_app/features/goals/domain/entities/goal_entity.dart';
import 'package:goal_breakdown_engine_app/features/goals/domain/repositories/goal_repository.dart';
import 'package:goal_breakdown_engine_app/features/goals/domain/repositories/progress_repository.dart';
import 'package:goal_breakdown_engine_app/features/tasks/domain/entities/task_entity.dart';
import 'package:goal_breakdown_engine_app/features/tasks/domain/repositories/task_repository.dart';

part 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit({
    required ProgressRepository progressRepository,
    required GoalRepository goalRepository,
    required TaskRepository taskRepository,
  }) : _progressRepository = progressRepository,
       _goalRepository = goalRepository,
       _taskRepository = taskRepository,
       super(const DashboardInitial());

  final ProgressRepository _progressRepository;
  final GoalRepository _goalRepository;
  final TaskRepository _taskRepository;

  Future<void> refresh() async {
    emit(const DashboardLoading());
    try {
      final results = await Future.wait([
        _progressRepository.fetchDashboard(),
        _goalRepository.fetchGoals(),
        _taskRepository.fetchTodayTasks(),
      ]);
      final stats = results[0] as DashboardStatsEntity;
      final goals = results[1] as List<GoalEntity>;
      final today = results[2] as List<TaskEntity>;

      final inProgress = goals.isEmpty
          ? 0
          : stats.totalTasks - stats.completedTasks;
      emit(
        DashboardReady(
          stats: stats,
          activeGoalsCount: goals.length,
          tasksInProgress: inProgress.clamp(0, 999),
          completedToday: today.where((t) => t.isCompleted).length,
          overallPercent: stats.progressPercent,
          activeGoalsPreview: goals.take(4).toList(),
          todayTasks: today.take(6).toList(),
        ),
      );
    } on DioException catch (e) {
      emit(DashboardError(_msg(e)));
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }

  static String _msg(DioException e) {
    final d = e.response?.data;
    if (d is Map && d['message'] != null) return d['message'].toString();
    return e.message ?? 'Failed to load dashboard';
  }
}
