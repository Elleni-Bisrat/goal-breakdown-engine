import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goal_breakdown_engine_app/core/theme/app_colors.dart';
import 'package:goal_breakdown_engine_app/features/goals/presentation/bloc/goal_detail_cubit.dart';
import 'package:goal_breakdown_engine_app/features/goals/presentation/bloc/goals_bloc.dart';
import 'package:goal_breakdown_engine_app/features/goals/presentation/bloc/goals_event.dart';

class GoalDetailScreen extends StatelessWidget {
  const GoalDetailScreen({super.key});

  String _estimateLabel(int durationDays) {
    final months = (durationDays / 30).ceil().clamp(1, 36);
    return '~$months month${months == 1 ? '' : 's'} estimated';
  }

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
                    child: Text(
                      '${_estimateLabel(s.goal.duration)}\n'
                      '${s.progress.completedTasks}/${s.progress.totalTasks} tasks done',
                      style: TextStyle(
                        height: 1.4,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              const Text(
                'Milestones',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                        title: Text('${g.label} · Week ${i + 1}'),
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
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Task generation is handled on the server after goal creation.',
                      ),
                    ),
                  );
                },
                child: const Text('Generate Tasks'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.green.shade800,
                  side: BorderSide(color: Colors.green.shade600),
                ),
                onPressed: () {},
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
}
