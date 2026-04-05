import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goal_breakdown_engine_app/core/theme/app_colors.dart';
import 'package:goal_breakdown_engine_app/core/widgets/app_empty_state.dart';
import 'package:goal_breakdown_engine_app/features/tasks/presentation/bloc/tasks_hierarchy_cubit.dart';

class MyTasksScreen extends StatelessWidget {
  const MyTasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async => context.read<TasksHierarchyCubit>().load(),
        color: AppColors.primary,
        child: BlocBuilder<TasksHierarchyCubit, TasksHierarchyState>(
          builder: (context, state) {
            if (state is TasksHierarchyLoading ||
                state is TasksHierarchyInitial) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 36,
                      height: 36,
                      child: CircularProgressIndicator(strokeWidth: 3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Loading tasks…',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              );
            }
            if (state is TasksHierarchyError) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.sizeOf(context).height * 0.55,
                    child: AppEmptyState(
                      icon: Icons.cloud_off_outlined,
                      title: 'Couldn’t load tasks',
                      subtitle: state.message,
                      action: FilledButton.icon(
                        onPressed: () =>
                            context.read<TasksHierarchyCubit>().load(),
                        icon: const Icon(Icons.refresh_rounded, size: 20),
                        label: const Text('Retry'),
                      ),
                    ),
                  ),
                ],
              );
            }
            final s = state as TasksHierarchyReady;
            if (s.bundles.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.sizeOf(context).height * 0.65,
                    child: const AppEmptyState(
                      icon: Icons.inbox_outlined,
                      title: 'No goals or tasks yet',
                      subtitle:
                          'Create a goal and open it here to see milestones and tasks.',
                    ),
                  ),
                ],
              );
            }
            return ListView(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: AppColors.goalCard,
                      child: Icon(
                        Icons.person_rounded,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'My Tasks',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                ...s.bundles.map((bundle) {
                  final expanded = s.expandedGoals.contains(bundle.goal.id);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Material(
                          color: AppColors.primary,
                          elevation: 4,
                          shadowColor: AppColors.primary.withValues(alpha: 0.4),
                          surfaceTintColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () => context
                                .read<TasksHierarchyCubit>()
                                .toggleGoal(bundle.goal.id),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 16,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      bundle.goal.title,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                        letterSpacing: -0.2,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    expanded
                                        ? Icons.expand_less_rounded
                                        : Icons.expand_more_rounded,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        AnimatedCrossFade(
                          duration: const Duration(milliseconds: 220),
                          crossFadeState: expanded
                              ? CrossFadeState.showSecond
                              : CrossFadeState.showFirst,
                          sizeCurve: Curves.easeOutCubic,
                          firstChild: const SizedBox(width: double.infinity),
                          secondChild: Padding(
                            padding: const EdgeInsets.only(top: 10, left: 2),
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
                                          style: theme.textTheme.titleSmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.w800,
                                                color: theme
                                                    .colorScheme.onSurface,
                                              ),
                                        ),
                                      ),
                                      ...tasks.map(
                                        (t) => Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 8,
                                          ),
                                          child: Card(
                                            child: ListTile(
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 4,
                                              ),
                                              leading: Checkbox.adaptive(
                                                value: t.isCompleted,
                                                activeColor: AppColors.primary,
                                                onChanged: (_) => context
                                                    .read<
                                                        TasksHierarchyCubit>()
                                                    .toggleTaskComplete(t),
                                              ),
                                              title: Text(
                                                t.title,
                                                style: TextStyle(
                                                  decoration: t.isCompleted
                                                      ? TextDecoration
                                                          .lineThrough
                                                      : null,
                                                  color: t.isCompleted
                                                      ? theme.colorScheme
                                                          .onSurfaceVariant
                                                      : null,
                                                ),
                                              ),
                                              trailing: IconButton(
                                                tooltip: 'Delete task',
                                                icon: Icon(
                                                  Icons.delete_outline_rounded,
                                                  color: theme
                                                      .colorScheme.error
                                                      .withValues(alpha: 0.85),
                                                ),
                                                onPressed: () => context
                                                    .read<
                                                        TasksHierarchyCubit>()
                                                    .deleteTask(t.id),
                                              ),
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
