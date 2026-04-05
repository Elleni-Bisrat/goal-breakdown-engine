import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goal_breakdown_engine_app/core/theme/app_colors.dart';
import 'package:goal_breakdown_engine_app/features/goals/presentation/bloc/goal_detail_cubit.dart';
import 'package:goal_breakdown_engine_app/features/goals/presentation/bloc/goals_bloc.dart';
import 'package:goal_breakdown_engine_app/features/goals/presentation/bloc/goals_event.dart';

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
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (state is GoalDetailError) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(child: Text(state.message)),
          );
        }
        final s = state as GoalDetailReady;
        final pct = s.progress.progressPercent;

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              s.goal.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              // Progress section
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 110,
                    height: 110,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 110,
                          height: 110,
                          child: CircularProgressIndicator(
                            value: pct / 100,
                            strokeWidth: 10,
                            backgroundColor: Colors.grey.shade200,
                            color: AppColors.primary,
                          ),
                        ),
                        Text(
                          '$pct%',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
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
                            ).withOpacity(0.1),
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

              // Date range
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
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
                      const Icon(Icons.arrow_forward, color: Colors.grey),
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
                    padding: const EdgeInsets.all(16),
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
                  const Text(
                    'Milestones',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  Text(
                    '${s.milestoneGroups.length} milestones',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
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
                        title: Text(g.label),
                        trailing: Icon(
                          open ? Icons.expand_less : Icons.expand_more,
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
                                    leading: Icon(
                                      t.isCompleted
                                          ? Icons.check_circle
                                          : Icons.radio_button_unchecked,
                                      color: t.isCompleted
                                          ? Colors.green
                                          : Colors.grey,
                                      size: 22,
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
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.green.shade800,
                  side: BorderSide(color: Colors.green.shade600),
                ),
                onPressed: () {
                  // TODO: Implement edit functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Edit feature coming soon')),
                  );
                },
                child: const Text('Edit Goal'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red.shade700,
                  side: BorderSide(color: Colors.red.shade400),
                ),
                onPressed: () async {
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Delete goal?'),
                      content: const Text('This cannot be undone.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: Text(
                            'Delete',
                            style: TextStyle(color: Colors.red.shade700),
                          ),
                        ),
                      ],
                    ),
                  );
                  if (ok == true && context.mounted) {
                    context.read<GoalDetailCubit>().deleteGoal();
                  }
                },
                child: const Text('Delete Goal'),
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
