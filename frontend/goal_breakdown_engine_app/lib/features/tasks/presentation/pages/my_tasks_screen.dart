import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goal_breakdown_engine_app/core/theme/app_colors.dart';
import 'package:goal_breakdown_engine_app/features/tasks/presentation/bloc/tasks_hierarchy_cubit.dart';

class MyTasksScreen extends StatelessWidget {
  const MyTasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async => context.read<TasksHierarchyCubit>().load(),
        child: BlocBuilder<TasksHierarchyCubit, TasksHierarchyState>(
          builder: (context, state) {
            if (state is TasksHierarchyLoading ||
                state is TasksHierarchyInitial) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is TasksHierarchyError) {
              return ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Text(state.message),
                        FilledButton(
                          onPressed: () =>
                              context.read<TasksHierarchyCubit>().load(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }
            final s = state as TasksHierarchyReady;
            if (s.bundles.isEmpty) {
              return ListView(
                children: const [
                  SizedBox(height: 120),
                  Center(child: Text('No goals or tasks yet.')),
                ],
              );
            }
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 22,
                      backgroundColor: AppColors.goalCard,
                      child: Icon(Icons.person, color: AppColors.primary),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'My Tasks',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...s.bundles.map((bundle) {
                  final expanded = s.expandedGoals.contains(bundle.goal.id);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Material(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(16),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () => context
                                .read<TasksHierarchyCubit>()
                                .toggleGoal(bundle.goal.id),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      bundle.goal.title,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    expanded
                                        ? Icons.expand_less
                                        : Icons.expand_more,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        if (expanded)
                          Padding(
                            padding: const EdgeInsets.only(top: 8, left: 4),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                ...bundle.tasksByMilestone.entries.map((e) {
                                  final mIndex = e.key;
                                  final tasks = e.value;
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 8,
                                        ),
                                        child: Text(
                                          'Milestone ${mIndex + 1}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            color: Colors.grey.shade800,
                                          ),
                                        ),
                                      ),
                                      ...tasks.map(
                                        (t) => Card(
                                          margin: const EdgeInsets.only(
                                            bottom: 8,
                                          ),
                                          child: ListTile(
                                            leading: Checkbox(
                                              value: t.isCompleted,
                                              onChanged: (_) => context
                                                  .read<TasksHierarchyCubit>()
                                                  .toggleTaskComplete(t),
                                            ),
                                            title: Text(
                                              t.title,
                                              style: TextStyle(
                                                decoration: t.isCompleted
                                                    ? TextDecoration.lineThrough
                                                    : null,
                                              ),
                                            ),
                                            trailing: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                IconButton(
                                                  icon: const Icon(
                                                    Icons.delete_outline,
                                                  ),
                                                  onPressed: () => context
                                                      .read<
                                                        TasksHierarchyCubit
                                                      >()
                                                      .deleteTask(t.id),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }),
                              ],
                            ),
                          ),
                      ],
                    ),
                  );
                }),
              ],
            );
          },
        ),
      ),
    );
  }
}
