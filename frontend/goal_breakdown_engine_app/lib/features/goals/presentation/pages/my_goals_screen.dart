import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goal_breakdown_engine_app/app_root.dart';
import 'package:goal_breakdown_engine_app/core/theme/app_colors.dart';
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
                padding: const EdgeInsets.fromLTRB(20, 12, 12, 8),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.settings_outlined),
                    ),
                    const Expanded(
                      child: Text(
                        'My Goals',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
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
                      icon: const Icon(Icons.add, color: AppColors.primary),
                      label: const Text('Create'),
                    ),
                  ],
                ),
              ),
            ),
            BlocConsumer<GoalsBloc, GoalsState>(
              listener: (context, state) {
                if (state is GoalsFailure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 3),
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
                  return const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                // Error state
                if (state is GoalsFailure) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Failed to load goals',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            state.message,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () {
                              context.read<GoalsBloc>().add(
                                const GoalsLoadRequested(),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                            ),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // Loaded state with goals
                if (state is GoalsLoaded) {
                  if (state.goals.isEmpty) {
                    return SliverFillRemaining(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.emoji_events_outlined,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No goals yet',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tap Create to add a goal with timeline and priority',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ),
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
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Material(
                            color: AppColors.goalCard,
                            borderRadius: BorderRadius.circular(24),
                            elevation: 2,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(24),
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
                                padding: const EdgeInsets.all(20),
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
                                            ).withOpacity(0.1),
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
                                    // Progress indicator
                                    if (goal.totalTasks > 0)
                                      Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'Progress',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey.shade600,
                                                ),
                                              ),
                                              Text(
                                                '${goal.totalTasks} tasks',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey.shade600,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          LinearProgressIndicator(
                                            value: goal.totalTasks > 0
                                                ? (goal.totalTasks /
                                                      (goal.totalTasks +
                                                          (goal.totalTasks -
                                                              goal.totalTasks)))
                                                : 0,
                                            backgroundColor:
                                                Colors.grey.shade200,
                                            color: AppColors.primary,
                                            borderRadius: BorderRadius.circular(
                                              4,
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
                                            color: AppColors.primary,
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
