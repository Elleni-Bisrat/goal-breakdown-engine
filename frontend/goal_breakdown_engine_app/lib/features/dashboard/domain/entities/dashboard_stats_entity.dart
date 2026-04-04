import 'package:equatable/equatable.dart';

class DashboardStatsEntity extends Equatable {
  const DashboardStatsEntity({
    required this.totalTasks,
    required this.completedTasks,
    required this.progressPercent,
  });

  final int totalTasks;
  final int completedTasks;
  final int progressPercent;

  @override
  List<Object?> get props => [totalTasks, completedTasks, progressPercent];
}
