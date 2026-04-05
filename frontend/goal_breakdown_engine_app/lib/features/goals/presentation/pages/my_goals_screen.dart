import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goal_breakdown_engine_app/app_root.dart';
import 'package:goal_breakdown_engine_app/core/theme/app_colors.dart';
import 'package:goal_breakdown_engine_app/core/widgets/app_empty_state.dart';
import 'package:goal_breakdown_engine_app/features/goals/presentation/bloc/goal_detail_cubit.dart';
import 'package:goal_breakdown_engine_app/features/goals/presentation/bloc/goals_bloc.dart';
import 'package:goal_breakdown_engine_app/features/goals/presentation/bloc/goals_event.dart';
import 'package:goal_breakdown_engine_app/features/goals/domain/entities/goal_entity.dart';
import 'package:goal_breakdown_engine_app/features/goals/presentation/bloc/goals_state.dart';
import 'package:goal_breakdown_engine_app/features/goals/presentation/pages/goal_detail_screen.dart';
import 'package:goal_breakdown_engine_app/features/goals/presentation/widgets/create_goal_dialog.dart';

class MyGoalsScreen extends StatelessWidget {
  const MyGoalsScreen({super.key});

  Future<void> _onRefresh(BuildContext context) async {
    context.read<GoalsBloc>().add(const GoalsLoadRequested());
    await context.read<GoalsBloc>().stream.firstWhere(
          (s) => s is GoalsLoaded || s is GoalsFailure,
        );
  }

  void _openDetail(BuildContext context, String goalId) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider(
          create: (context) => GoalDetailCubit(
            goalRepository: context.goalRepository,
            taskRepository: context.taskRepository,
            progressRepository: context.progressRepository,
          )..load(goalId),
          child: const GoalDetailScreen(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Do not nest [Scaffold] here: [MainShell] already has a [Scaffold] with
    // [IndexedStack]. An inner [Scaffold] often lays out with zero body height,
    // which makes this tab look completely blank.
    return SizedBox.expand(
      child: ColoredBox(
        color: AppColors.background,
        child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {},
                    tooltip: 'Settings',
                    icon: const Icon(Icons.settings_outlined),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          'My Goals',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Create goals, set dates & priority, then track tasks.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () async {
                      final data = await showCreateGoalSheet(context);
                      if (data == null || !context.mounted) return;

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
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: BlocConsumer<GoalsBloc, GoalsState>(
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
                },
                builder: (context, state) {
                  if (state is GoalsLoading || state is GoalsInitial) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 16),
                          Text(
                            'Loading goals…',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is GoalsFailure) {
                    return RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: () => _onRefresh(context),
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        children: [
                          SizedBox(
                            height: MediaQuery.sizeOf(context).height * 0.55,
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
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is GoalsLoaded) {
                    if (state.goals.isEmpty) {
                      return RefreshIndicator(
                        color: AppColors.primary,
                        onRefresh: () => _onRefresh(context),
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            SizedBox(
                              height: MediaQuery.sizeOf(context).height * 0.55,
                              child: const AppEmptyState(
                                icon: Icons.emoji_events_outlined,
                                title: 'No goals yet',
                                subtitle:
                                    'Tap Create to add a goal with timeline and priority.',
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: () => _onRefresh(context),
                      child: ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                        itemCount: state.goals.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final goal = state.goals[index];
                          return _GoalCard(
                            goal: goal,
                            onOpen: () => _openDetail(context, goal.id),
                            onViewDetails: () => _openDetail(context, goal.id),
                            formatDate: _formatDate,
                            priorityColor: _getPriorityColor,
                          );
                        },
                      ),
                    );
                  }

                  return Center(
                    child: Text(
                      'Unknown state',
                      style: theme.textTheme.bodyLarge,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
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

class _GoalCard extends StatelessWidget {
  const _GoalCard({
    required this.goal,
    required this.onOpen,
    required this.onViewDetails,
    required this.formatDate,
    required this.priorityColor,
  });

  final GoalEntity goal;
  final VoidCallback onOpen;
  final VoidCallback onViewDetails;
  final String Function(DateTime) formatDate;
  final Color Function(String) priorityColor;

  @override
  Widget build(BuildContext context) {
    final pColor = priorityColor(goal.priority);

    return Material(
      color: AppColors.goalCard,
      elevation: 2,
      shadowColor: AppColors.primary.withValues(alpha: 0.2),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                      color: pColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      goal.priority.toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: pColor,
                      ),
                    ),
                  ),
                ],
              ),
              if (goal.description != null &&
                  goal.description!.isNotEmpty) ...[
                const SizedBox(height: 8),
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
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.calendar_today,
                      size: 14, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    '${formatDate(goal.startDate)} - ${formatDate(goal.endDate)}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.timer, size: 14, color: Colors.grey.shade600),
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
              if (goal.totalTasks > 0) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.checklist_rounded,
                        size: 18, color: Colors.grey.shade600),
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
              ],
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton(
                  onPressed: onViewDetails,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(color: AppColors.primary.withValues(alpha: 0.45)),
                  ),
                  child: const Text('View Details'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
