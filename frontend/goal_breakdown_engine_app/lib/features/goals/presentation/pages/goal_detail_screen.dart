import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goal_breakdown_engine_app/core/theme/app_colors.dart';
import 'package:goal_breakdown_engine_app/core/widgets/app_empty_state.dart';
import 'package:goal_breakdown_engine_app/features/goals/presentation/bloc/goal_detail_cubit.dart';
import 'package:goal_breakdown_engine_app/features/goals/presentation/bloc/goals_bloc.dart';
import 'package:goal_breakdown_engine_app/features/goals/presentation/bloc/goals_event.dart';
import 'package:goal_breakdown_engine_app/features/goals/presentation/widgets/create_goal_dialog.dart';

class GoalDetailScreen extends StatelessWidget {
  const GoalDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GoalDetailCubit, GoalDetailState>(
      listener: (context, state) {
        if (state is GoalDetailDeleted) {
          context.read<GoalsBloc>().add(const GoalsLoadRequested());
          Navigator.of(context).pop();
        }
      },
      builder: (context, state) {
        if (state is GoalDetailLoading || state is GoalDetailInitial) {
          final theme = Theme.of(context);
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(strokeWidth: 3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Loading goal…',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        if (state is GoalDetailError) {
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            body: AppEmptyState(
              icon: Icons.warning_amber_rounded,
              title: 'Something went wrong',
              subtitle: state.message,
              action: FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Go back'),
              ),
            ),
          );
        }
        final s = state as GoalDetailReady;
        final pct = s.progress.progressPercent.clamp(0, 100);

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              s.goal.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 36),
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 112,
                    height: 112,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 112,
                          height: 112,
                          child: CircularProgressIndicator(
                            value: pct / 100,
                            strokeWidth: 9,
                            strokeCap: StrokeCap.round,
                            backgroundColor: AppColors.goalCard,
                            color: AppColors.primary,
                          ),
                        ),
                        Text(
                          '$pct%',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w800),
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
                          _getDurationLabel(s.goal.startDate, s.goal.endDate),
                          style: TextStyle(
                            height: 1.4,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${s.progress.completedTasks}/${s.progress.totalTasks} tasks done',
                          style: TextStyle(color: Colors.grey.shade800),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getPriorityColor(
                              s.goal.priority,
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Priority: ${s.goal.priority.toUpperCase()}',
                            style: TextStyle(
                              fontSize: 12,
                              color: _getPriorityColor(s.goal.priority),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Start Date',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatDate(s.goal.startDate),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'End Date',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatDate(s.goal.endDate),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Description
              if (s.goal.description != null && s.goal.description!.isNotEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Description',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(s.goal.description!),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 28),

              // Milestones section
              Row(
                children: [
                  Text(
                    'Milestones',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${s.milestoneGroups.length} milestones',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              ...s.milestoneGroups.asMap().entries.map((entry) {
                final i = entry.key;
                final g = entry.value;
                final open = s.expanded.contains(i);
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Column(
                    children: [
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        title: Text(
                          g.label,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        trailing: Icon(
                          open
                              ? Icons.expand_less_rounded
                              : Icons.expand_more_rounded,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        onTap: () =>
                            context.read<GoalDetailCubit>().toggleMilestone(i),
                      ),
                      if (open)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                          child: Column(
                            children: g.tasks
                                .map(
                                  (t) => ListTile(
                                    dense: true,
                                    contentPadding: EdgeInsets.zero,
                                    leading: IconButton(
                                      onPressed: () => context
                                          .read<GoalDetailCubit>()
                                          .toggleTaskStatus(t),
                                      icon: Icon(
                                        t.isCompleted
                                            ? Icons.check_circle
                                            : Icons.radio_button_unchecked,
                                        color: t.isCompleted
                                            ? Colors.green
                                            : Colors.grey,
                                        size: 22,
                                      ),
                                    ),
                                    title: Text(
                                      t.title,
                                      style: TextStyle(
                                        decoration: t.isCompleted
                                            ? TextDecoration.lineThrough
                                            : null,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 16),

              // Action buttons
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.green.shade800,
                  side: BorderSide(
                    color: Colors.green.shade600.withValues(alpha: 0.65),
                  ),
                ),
                icon: const Icon(Icons.edit_outlined, size: 20),
                onPressed: () async {
                  final data = await showEditGoalSheet(context, goal: s.goal);
                  if (data == null || !context.mounted) return;
                  await context.read<GoalDetailCubit>().updateGoal(
                    title: data['title'] as String,
                    description: data['description'] as String,
                    startDate: data['startDate'] as DateTime,
                    endDate: data['endDate'] as DateTime,
                    priority: data['priority'] as String,
                  );
                  if (context.mounted) {
                    context.read<GoalsBloc>().add(const GoalsLoadRequested());
                  }
                },
                label: const Text('Edit Goal'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                  side: BorderSide(
                    color: Theme.of(
                      context,
                    ).colorScheme.error.withValues(alpha: 0.45),
                  ),
                ),
                icon: const Icon(Icons.delete_outline_rounded, size: 20),
                onPressed: () async {
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      icon: Icon(
                        Icons.delete_forever_outlined,
                        color: Theme.of(ctx).colorScheme.error,
                        size: 32,
                      ),
                      title: const Text('Delete goal?'),
                      content: const Text('This cannot be undone.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Cancel'),
                        ),
                        FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: Theme.of(ctx).colorScheme.error,
                          ),
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );
                  if (ok == true && context.mounted) {
                    context.read<GoalDetailCubit>().deleteGoal();
                  }
                },
                label: const Text('Delete Goal'),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getDurationLabel(DateTime startDate, DateTime endDate) {
    final duration = endDate.difference(startDate).inDays;
    final months = (duration / 30).ceil().clamp(1, 36);
    return '~$months month${months == 1 ? '' : 's'} estimated';
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
