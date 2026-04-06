import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:goal_breakdown_engine_app/features/goals/domain/entities/goal_entity.dart';
import 'package:goal_breakdown_engine_app/features/goals/domain/entities/goal_progress_entity.dart';
import 'package:goal_breakdown_engine_app/features/goals/domain/repositories/goal_repository.dart';
import 'package:goal_breakdown_engine_app/features/goals/domain/repositories/progress_repository.dart';
import 'package:goal_breakdown_engine_app/features/tasks/domain/entities/task_entity.dart';
import 'package:goal_breakdown_engine_app/features/tasks/domain/repositories/task_repository.dart';

part 'goal_detail_state.dart';

class GoalDetailCubit extends Cubit<GoalDetailState> {
  GoalDetailCubit({
    required GoalRepository goalRepository,
    required TaskRepository taskRepository,
    required ProgressRepository progressRepository,
  }) : _goalRepository = goalRepository,
       _taskRepository = taskRepository,
       _progressRepository = progressRepository,
       super(const GoalDetailInitial());

  final GoalRepository _goalRepository;
  final TaskRepository _taskRepository;
  final ProgressRepository _progressRepository;

  Future<void> load(String goalId) async {
    emit(const GoalDetailLoading());
    try {
      final goal = await _goalRepository.fetchGoal(goalId);
      final progress = await _progressRepository.fetchGoalProgress(goalId);
      final tasks = await _taskRepository.fetchTasksForGoal(goalId);
      final groups = _groupTasks(tasks);
      emit(
        GoalDetailReady(
          goal: goal,
          progress: progress,
          milestoneGroups: groups,
          expanded: {for (var i = 0; i < groups.length; i++) i},
        ),
      );
    } on DioException catch (e) {
      emit(GoalDetailError(_msg(e)));
    } catch (e) {
      emit(GoalDetailError(e.toString()));
    }
  }

  void toggleMilestone(int index) {
    final s = state;
    if (s is! GoalDetailReady) return;
    final next = Set<int>.from(s.expanded);
    if (next.contains(index)) {
      next.remove(index);
    } else {
      next.add(index);
    }
    emit(s.copyWith(expanded: next));
  }

  Future<void> deleteGoal() async {
    final s = state;
    if (s is! GoalDetailReady) return;
    emit(const GoalDetailLoading());
    try {
      await _goalRepository.deleteGoal(s.goal.id);
      emit(const GoalDetailDeleted());
    } on DioException catch (e) {
      emit(GoalDetailError(_msg(e)));
    } catch (e) {
      emit(GoalDetailError(e.toString()));
    }
  }

  Future<void> updateGoal({
    required String title,
    required String description,
    required DateTime startDate,
    required DateTime endDate,
    required String priority,
  }) async {
    final s = state;
    if (s is! GoalDetailReady) return;
    final updatedGoal = await _goalRepository.updateGoal(s.goal.id, {
      'title': title,
      'description': description,
      'startDate': _formatDate(startDate),
      'endDate': _formatDate(endDate),
      'priority': priority.toLowerCase(),
    });
    emit(s.copyWith(goal: updatedGoal));
  }

  Future<void> toggleTaskStatus(TaskEntity task) async {
    final s = state;
    if (s is! GoalDetailReady) return;
    try {
      final nextStatus = task.isCompleted ? 'pending' : 'completed';
      final updatedTask = await _taskRepository.updateTask(
        task.id,
        status: nextStatus,
      );

      final nextGroups = s.milestoneGroups
          .map(
            (g) => MilestoneGroup(
              index: g.index,
              label: g.label,
              tasks: g.tasks
                  .map((t) => t.id == updatedTask.id ? updatedTask : t)
                  .toList(),
            ),
          )
          .toList();

      final flatTasks = <TaskEntity>[
        for (final g in nextGroups) ...g.tasks,
      ];
      final total = flatTasks.length;
      final completed = flatTasks.where((t) => t.isCompleted).length;
      final percent = total == 0 ? 0 : ((completed / total) * 100).round();

      emit(
        s.copyWith(
          milestoneGroups: nextGroups,
          progress: GoalProgressEntity(
            totalTasks: total,
            completedTasks: completed,
            progressPercent: percent,
          ),
        ),
      );
    } catch (_) {}
  }

  static List<MilestoneGroup> _groupTasks(List<TaskEntity> tasks) {
    final map = <int, List<TaskEntity>>{};
    for (final t in tasks) {
      final k = t.milestoneIndex < 0 ? 0 : t.milestoneIndex;
      map.putIfAbsent(k, () => []).add(t);
    }
    final keys = map.keys.toList()..sort();
    return [
      for (final k in keys)
        MilestoneGroup(index: k, label: 'Milestone ${k + 1}', tasks: map[k]!),
    ];
  }

  static String _msg(DioException e) {
    final d = e.response?.data;
    if (d is Map && d['message'] != null) return d['message'].toString();
    return e.message ?? 'Error';
  }

  static String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

class MilestoneGroup extends Equatable {
  const MilestoneGroup({
    required this.index,
    required this.label,
    required this.tasks,
  });

  final int index;
  final String label;
  final List<TaskEntity> tasks;

  @override
  List<Object?> get props => [index, label, tasks];
}
