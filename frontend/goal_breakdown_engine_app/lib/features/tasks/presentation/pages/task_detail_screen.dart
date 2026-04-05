import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:goal_breakdown_engine_app/app_root.dart';
import 'package:goal_breakdown_engine_app/core/theme/app_colors.dart';
import 'package:goal_breakdown_engine_app/features/tasks/domain/entities/task_entity.dart';

/// Task detail with a progress ring driven by **goal task completion** (real API data).
class TaskDetailScreen extends StatefulWidget {
  const TaskDetailScreen({super.key, required this.task});

  final TaskEntity task;

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  List<TaskEntity>? _goalTasks;
  bool _loading = true;
  String? _error;
  bool _toggling = false;

  TaskEntity get _t => widget.task;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await context.taskRepository.fetchTasksForGoal(_t.goalId);
      if (!mounted) return;
      setState(() {
        _goalTasks = list;
        _loading = false;
      });
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.message ?? 'Failed to load tasks';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  int get _completed {
    final list = _goalTasks;
    if (list == null || list.isEmpty) return _t.isCompleted ? 1 : 0;
    return list.where((x) => x.isCompleted).length;
  }

  int get _total {
    final list = _goalTasks;
    if (list == null || list.isEmpty) return 1;
    return list.length;
  }

  /// 0–100 for the ring: share of tasks completed in this goal.
  int get _progressPercent {
    if (_total <= 0) return 0;
    return ((_completed / _total) * 100).round().clamp(0, 100);
  }

  TaskEntity? get _liveTask {
    final list = _goalTasks;
    if (list == null) return null;
    for (final x in list) {
      if (x.id == _t.id) return x;
    }
    return null;
  }

  Future<void> _toggleComplete() async {
    final live = _liveTask ?? _t;
    final next = live.isCompleted ? 'pending' : 'completed';
    setState(() => _toggling = true);
    try {
      await context.taskRepository.updateTask(
        live.id,
        status: next,
      );
      if (!mounted) return;
      await _load();
      if (!mounted) return;
      setState(() => _toggling = false);
    } catch (e) {
      if (!mounted) return;
      setState(() => _toggling = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pct = _progressPercent;
    final live = _liveTask ?? _t;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Task'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Text(
            live.title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          if (live.description != null && live.description!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              live.description!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.35,
              ),
            ),
          ],
          const SizedBox(height: 28),
          if (_loading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_error != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                _error!,
                style: TextStyle(color: theme.colorScheme.error),
              ),
            )
          else ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 120,
                        height: 120,
                        child: CircularProgressIndicator(
                          value: pct / 100,
                          strokeWidth: 10,
                          strokeCap: StrokeCap.round,
                          backgroundColor: theme.colorScheme.surfaceContainerHighest,
                          color: AppColors.primary,
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$pct%',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            'goal tasks',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$_completed of $_total tasks done in this goal',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        live.isCompleted
                            ? 'This task is completed.'
                            : 'This task is still pending.',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _toggling ? null : _toggleComplete,
              icon: _toggling
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(
                      live.isCompleted
                          ? Icons.undo_rounded
                          : Icons.check_circle_outline,
                    ),
              label: Text(
                live.isCompleted ? 'Mark as pending' : 'Mark as completed',
              ),
            ),
          ],
        ],
      ),
    );
  }
}
