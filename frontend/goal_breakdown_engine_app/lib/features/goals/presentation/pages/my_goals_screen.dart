import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goal_breakdown_engine_app/app_root.dart';
import 'package:goal_breakdown_engine_app/core/theme/app_colors.dart';
import 'package:goal_breakdown_engine_app/core/widgets/app_empty_state.dart';
import 'package:goal_breakdown_engine_app/features/goals/presentation/bloc/goal_detail_cubit.dart';
import 'package:goal_breakdown_engine_app/features/goals/presentation/bloc/goals_bloc.dart';
import 'package:goal_breakdown_engine_app/features/goals/presentation/bloc/goals_event.dart';
import 'package:goal_breakdown_engine_app/features/goals/presentation/bloc/goals_state.dart';
import 'package:goal_breakdown_engine_app/features/goals/presentation/pages/goal_detail_screen.dart';
import 'package:goal_breakdown_engine_app/features/goals/presentation/widgets/create_goal_dialog.dart';

class MyGoalsScreen extends StatelessWidget {
  const MyGoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          context.read<GoalsBloc>().add(const GoalsLoadRequested());
        },
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 8, 4),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {},
                          tooltip: 'Settings',
                          style: IconButton.styleFrom(
                            foregroundColor:
                                Theme.of(context).colorScheme.onSurface,
                          ),
                          icon: const Icon(Icons.tune_rounded),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                'My Goals',
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.5,
                                      color: AppColors.primary,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Center(
                                child: Container(
                                  width: 48,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(999),
                                    gradient: const LinearGradient(
                                      colors: [
                                        AppColors.primary,
                                        AppColors.secondary,
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () async {
                            final data = await showCreateGoalSheet(context);
                            if (data == null || !context.mounted) return;

                            debugPrint('Creating goal with data: $data');

                            context.read<GoalsBloc>().add(
                              GoalCreateRequested(
                                title: data['title'] as String,
                                description: data['description'] as String,
                                startDate: data['startDate'] as DateTime,
                                endDate: data['endDate'] as DateTime,
                                priority: data['priority'] as String,
                              ),
                            );
                          },
                          icon: const Icon(Icons.add_rounded),
                          label: const Text('Create'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            textStyle:
                                const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            BlocConsumer<GoalsBloc, GoalsState>(
              listener: (context, state) {
                if (state is GoalsFailure) {
                  final cs = Theme.of(context).colorScheme;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: cs.error,
                      duration: const Duration(seconds: 4),
                    ),
                  );
                }
                if (state is GoalsLoaded && state.goals.isNotEmpty) {
                  // Successfully loaded goals
                  debugPrint('Loaded ${state.goals.length} goals');
                }
              },
              builder: (context, state) {
                // Loading state
                if (state is GoalsLoading || state is GoalsInitial) {
                  return SliverFillRemaining(
                    child: Center(
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
                            'Loading goals…',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // Error state
                if (state is GoalsFailure) {
                  return SliverFillRemaining(
                    child: AppEmptyState(
                      icon: Icons.error_outline_rounded,
                      title: 'Failed to load goals',
                      subtitle: state.message,
                      action: FilledButton.icon(
                        onPressed: () {
                          context.read<GoalsBloc>().add(
                            const GoalsLoadRequested(),
                          );
                        },
                        icon: const Icon(Icons.refresh_rounded, size: 20),
                        label: const Text('Retry'),
                      ),
                    ),
                  );
                }

                // Loaded state with goals
                if (state is GoalsLoaded) {
                  if (state.goals.isEmpty) {
                    return const SliverFillRemaining(
                      child: AppEmptyState(
                        icon: Icons.emoji_events_outlined,
                        title: 'No goals yet',
                        subtitle:
                            'Tap Create to add a goal with timeline and priority.',
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final goal = state.goals[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: Material(
                            color: AppColors.goalCard,
                            borderRadius: BorderRadius.circular(20),
                            elevation: 0,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: AppColors.primary.withValues(alpha: 0.08),
                              ),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => BlocProvider(
                                      create: (context) => GoalDetailCubit(
                                        goalRepository: context.goalRepository,
                                        taskRepository: context.taskRepository,
                                        progressRepository:
                                            context.progressRepository,
                                      )..load(goal.id),
                                      child: const GoalDetailScreen(),
                                    ),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Title and priority badge
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            goal.title,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _getPriorityColor(
                                              goal.priority,
                                            ).withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Text(
                                            goal.priority.toUpperCase(),
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: _getPriorityColor(
                                                goal.priority,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    // Description
                                    if (goal.description != null &&
                                        goal.description!.isNotEmpty)
                                      Text(
                                        goal.description!,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.shade700,
                                          height: 1.3,
                                        ),
                                      ),
                                    const SizedBox(height: 12),
                                    // Date range and duration
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_today,
                                          size: 14,
                                          color: Colors.grey.shade600,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${_formatDate(goal.startDate)} - ${_formatDate(goal.endDate)}',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Icon(
                                          Icons.timer,
                                          size: 14,
                                          color: Colors.grey.shade600,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${goal.durationInDays} days',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    if (goal.totalTasks > 0)
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.checklist_rounded,
                                            size: 18,
                                            color: Colors.grey.shade600,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              '${goal.totalTasks} tasks in this goal',
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.grey.shade700,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    const SizedBox(height: 16),
                                    // View details button
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: OutlinedButton(
                                        onPressed: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute<void>(
                                              builder: (_) => BlocProvider(
                                                create: (context) =>
                                                    GoalDetailCubit(
                                                      goalRepository: context
                                                          .goalRepository,
                                                      taskRepository: context
                                                          .taskRepository,
                                                      progressRepository: context
                                                          .progressRepository,
                                                    )..load(goal.id),
                                                child: const GoalDetailScreen(),
                                              ),
                                            ),
                                          );
                                        },
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: AppColors.primary,
                                          side: BorderSide(
                                            color: AppColors.primary
                                                .withValues(alpha: 0.45),
                                          ),
                                        ),
                                        child: const Text('View Details'),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }, childCount: state.goals.length),
                    ),
                  );
                }

                return const SliverToBoxAdapter(child: SizedBox.shrink());
              },
            ),
          ],
        ),
      ),
    );
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
