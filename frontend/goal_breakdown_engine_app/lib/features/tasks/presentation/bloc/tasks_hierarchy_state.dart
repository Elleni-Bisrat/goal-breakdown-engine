part of 'tasks_hierarchy_cubit.dart';

sealed class TasksHierarchyState extends Equatable {
  const TasksHierarchyState();

  @override
  List<Object?> get props => [];
}

final class TasksHierarchyInitial extends TasksHierarchyState {
  const TasksHierarchyInitial();
}

final class TasksHierarchyLoading extends TasksHierarchyState {
  const TasksHierarchyLoading();
}

final class TasksHierarchyReady extends TasksHierarchyState {
  const TasksHierarchyReady({
    required this.bundles,
    required this.expandedGoals,
  });

  final List<GoalTasksBundle> bundles;
  final Set<String> expandedGoals;

  TasksHierarchyReady copyWith({
    List<GoalTasksBundle>? bundles,
    Set<String>? expandedGoals,
  }) {
    return TasksHierarchyReady(
      bundles: bundles ?? this.bundles,
      expandedGoals: expandedGoals ?? this.expandedGoals,
    );
  }

  @override
  List<Object?> get props => [bundles, expandedGoals];
}

final class TasksHierarchyError extends TasksHierarchyState {
  const TasksHierarchyError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
