part of 'goal_detail_cubit.dart';

sealed class GoalDetailState extends Equatable {
  const GoalDetailState();

  @override
  List<Object?> get props => [];
}

final class GoalDetailInitial extends GoalDetailState {
  const GoalDetailInitial();
}

final class GoalDetailLoading extends GoalDetailState {
  const GoalDetailLoading();
}

final class GoalDetailReady extends GoalDetailState {
  const GoalDetailReady({
    required this.goal,
    required this.progress,
    required this.milestoneGroups,
    required this.expanded,
  });

  final GoalEntity goal;
  final GoalProgressEntity progress;
  final List<MilestoneGroup> milestoneGroups;
  final Set<int> expanded;

  GoalDetailReady copyWith({
    GoalEntity? goal,
    GoalProgressEntity? progress,
    List<MilestoneGroup>? milestoneGroups,
    Set<int>? expanded,
  }) {
    return GoalDetailReady(
      goal: goal ?? this.goal,
      progress: progress ?? this.progress,
      milestoneGroups: milestoneGroups ?? this.milestoneGroups,
      expanded: expanded ?? this.expanded,
    );
  }

  @override
  List<Object?> get props => [goal, progress, milestoneGroups, expanded];
}

final class GoalDetailDeleted extends GoalDetailState {
  const GoalDetailDeleted();
}

final class GoalDetailError extends GoalDetailState {
  const GoalDetailError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
