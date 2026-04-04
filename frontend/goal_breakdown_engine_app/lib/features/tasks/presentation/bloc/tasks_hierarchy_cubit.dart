import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:goal_breakdown_engine_app/features/goals/domain/entities/goal_entity.dart';
import 'package:goal_breakdown_engine_app/features/goals/domain/repositories/goal_repository.dart';
import 'package:goal_breakdown_engine_app/features/tasks/domain/entities/task_entity.dart';
import 'package:goal_breakdown_engine_app/features/tasks/domain/repositories/task_repository.dart';

part 'tasks_hierarchy_state.dart';

class GoalTasksBundle extends Equatable {
  const GoalTasksBundle({required this.goal, required this.tasksByMilestone});

  final GoalEntity goal;

  /// Ordered milestone index -> tasks
  final Map<int, List<TaskEntity>> tasksByMilestone;

  @override
  List<Object?> get props => [goal, tasksByMilestone];
}

class TasksHierarchyCubit extends Cubit<TasksHierarchyState> {
  TasksHierarchyCubit({
    required GoalRepository goalRepository,
    required TaskRepository taskRepository,
  }) : _goalRepository = goalRepository,
       _taskRepository = taskRepository,
       super(const TasksHierarchyInitial());

  final GoalRepository _goalRepository;
  final TaskRepository _taskRepository;

  Future<void> load() async {
    emit(const TasksHierarchyLoading());
    try {
      final goals = await _goalRepository.fetchGoals();
      final bundles = <GoalTasksBundle>[];
      for (final g in goals) {
        final tasks = await _taskRepository.fetchTasksForGoal(g.id);
        final map = <int, List<TaskEntity>>{};
        for (final t in tasks) {
          final k = t.milestoneIndex < 0 ? 0 : t.milestoneIndex;
          map.putIfAbsent(k, () => []).add(t);
        }
        final sortedKeys = map.keys.toList()..sort();
        final ordered = <int, List<TaskEntity>>{
          for (final k in sortedKeys) k: map[k]!,
        };
        bundles.add(GoalTasksBundle(goal: g, tasksByMilestone: ordered));
      }
      emit(
        TasksHierarchyReady(
          bundles: bundles,
          expandedGoals: {for (final b in bundles) b.goal.id},
        ),
      );
    } on DioException catch (e) {
      emit(TasksHierarchyError(_msg(e)));
    } catch (e) {
      emit(TasksHierarchyError(e.toString()));
    }
  }

  void toggleGoal(String goalId) {
    final s = state;
    if (s is! TasksHierarchyReady) return;
    final next = Set<String>.from(s.expandedGoals);
    if (next.contains(goalId)) {
      next.remove(goalId);
    } else {
      next.add(goalId);
    }
    emit(s.copyWith(expandedGoals: next));
  }

  Future<void> toggleTaskComplete(TaskEntity task) async {
    final s = state;
    if (s is! TasksHierarchyReady) return;
    try {
      await _taskRepository.updateTask(
        task.id,
        status: task.isCompleted ? 'pending' : 'completed',
      );
      await load();
    } catch (_) {
      emit(s);
    }
  }

  Future<void> deleteTask(String taskId) async {
    final s = state;
    if (s is! TasksHierarchyReady) return;
    try {
      await _taskRepository.deleteTask(taskId);
      await load();
    } catch (_) {
      emit(s);
    }
  }

  static String _msg(DioException e) {
    final d = e.response?.data;
    if (d is Map && d['message'] != null) return d['message'].toString();
    return e.message ?? 'Error';
  }
}
