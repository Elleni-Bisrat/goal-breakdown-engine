part of 'dashboard_cubit.dart';

sealed class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

final class DashboardInitial extends DashboardState {
  const DashboardInitial();
}

final class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

final class DashboardReady extends DashboardState {
  const DashboardReady({
    required this.stats,
    required this.activeGoalsCount,
    required this.tasksInProgress,
    required this.completedToday,
    required this.overallPercent,
    required this.activeGoalsPreview,
    required this.todayTasks,
  });

  final DashboardStatsEntity stats;
  final int activeGoalsCount;
  final int tasksInProgress;
  final int completedToday;
  final int overallPercent;
  final List<GoalEntity> activeGoalsPreview;
  final List<TaskEntity> todayTasks;

  @override
  List<Object?> get props => [
    stats,
    activeGoalsCount,
    tasksInProgress,
    completedToday,
    overallPercent,
    activeGoalsPreview,
    todayTasks,
  ];
}

final class DashboardError extends DashboardState {
  const DashboardError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
