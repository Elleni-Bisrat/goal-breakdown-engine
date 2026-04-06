import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goal_breakdown_engine_app/app_root.dart';
import 'package:goal_breakdown_engine_app/core/settings/settings_sheet.dart';
import 'package:goal_breakdown_engine_app/core/settings/user_display.dart';
import 'package:goal_breakdown_engine_app/core/theme/app_colors.dart';
import 'package:goal_breakdown_engine_app/core/widgets/app_empty_state.dart';
import 'package:goal_breakdown_engine_app/core/widgets/app_surface_card.dart';
import 'package:goal_breakdown_engine_app/core/widgets/theme_toggle_button.dart';
import 'package:goal_breakdown_engine_app/core/settings/app_settings_cubit.dart';
import 'package:goal_breakdown_engine_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:goal_breakdown_engine_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:goal_breakdown_engine_app/features/dashboard/presentation/bloc/dashboard_cubit.dart';
import 'package:goal_breakdown_engine_app/features/goals/presentation/bloc/goal_detail_cubit.dart';
import 'package:goal_breakdown_engine_app/features/goals/presentation/bloc/goals_bloc.dart';
import 'package:goal_breakdown_engine_app/features/goals/presentation/bloc/goals_event.dart';
import 'package:goal_breakdown_engine_app/features/goals/presentation/pages/goal_detail_screen.dart';
import 'package:goal_breakdown_engine_app/features/goals/presentation/widgets/create_goal_dialog.dart';
import 'package:goal_breakdown_engine_app/features/tasks/domain/entities/task_entity.dart';
import 'package:goal_breakdown_engine_app/features/tasks/presentation/pages/task_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _editGoal(BuildContext context, String goalId) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final goal = await context.goalRepository.fetchGoal(goalId);
      if (!context.mounted) return;
      final data = await showEditGoalSheet(context, goal: goal);
      if (data == null || !context.mounted) return;
      await context.goalRepository.updateGoal(goalId, {
        'title': data['title'] as String,
        'description': data['description'] as String,
        'startDate': _formatDate(data['startDate'] as DateTime),
        'endDate': _formatDate(data['endDate'] as DateTime),
        'priority': (data['priority'] as String).toLowerCase(),
      });
      if (!context.mounted) return;
      context.read<DashboardCubit>().refresh();
      context.read<GoalsBloc>().add(const GoalsLoadRequested());
      messenger.showSnackBar(
        const SnackBar(content: Text('Goal updated successfully')),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Failed to update goal: $e')),
      );
    }
  }

  void _openTaskDetail(BuildContext context, TaskEntity task) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => TaskDetailScreen(task: task),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async => context.read<DashboardCubit>().refresh(),
        color: AppColors.primary,
        child: BlocBuilder<DashboardCubit, DashboardState>(
          builder: (context, state) {
            if (state is DashboardLoading || state is DashboardInitial) {
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
                      'Loading your overview…',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              );
            }
            if (state is DashboardError) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.sizeOf(context).height * 0.55,
                    child: AppEmptyState(
                      icon: Icons.cloud_off_outlined,
                      title: 'Couldn’t load overview',
                      subtitle: state.message,
                      action: FilledButton.icon(
                        onPressed: () =>
                            context.read<DashboardCubit>().refresh(),
                        icon: const Icon(Icons.refresh_rounded, size: 20),
                        label: const Text('Try again'),
                      ),
                    ),
                  ),
                ],
              );
            }
            final s = state as DashboardReady;
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              children: [
                BlocBuilder<AppSettingsCubit, AppSettingsState>(
                  builder: (context, settings) {
                    return BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, auth) {
                        final name = UserDisplay.name(settings, auth);
                        return Row(
                          children: [
                            CircleAvatar(
                              radius: 26,
                              backgroundColor: AppColors.goalCard,
                              child: Text(
                                settings.avatarEmoji,
                                style: const TextStyle(fontSize: 26),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name.isNotEmpty ? 'Hi, $name' : 'Hi',
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Let’s crush your goals today',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme
                                          .colorScheme.onSurfaceVariant,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const ThemeToggleIconButton(),
                            IconButton(
                              tooltip: 'Settings',
                              onPressed: () => showAppSettingsSheet(context),
                              icon: const Icon(Icons.settings_outlined),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 24),
                Text(
                  'Overview',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxis = constraints.maxWidth < 340 ? 1 : 2;
                    return GridView.count(
                      crossAxisCount: crossAxis,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: crossAxis == 1 ? 2.4 : 1.35,
                      children: [
                        _StatCard(
                          color: AppColors.purpleStat,
                          value: '${s.activeGoalsCount}',
                          label: 'Goals',
                        ),
                        _StatCard(
                          color: AppColors.orangeStat,
                          value: '${s.tasksInProgress}',
                          label: 'Tasks',
                        ),
                        _StatCard(
                          color: AppColors.greenStat,
                          value: '${s.completedToday}',
                          label: 'Completed',
                        ),
                        _StatCard(
                          color: AppColors.blueStat,
                          value: '${s.overallPercent}%',
                          label: 'Progress',
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 28),
                Text(
                  'Active goals',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                if (s.activeGoalsPreview.isEmpty)
                  AppSurfaceCard(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: AppEmptyState(
                      icon: Icons.flag_outlined,
                      title: 'No active goals',
                      subtitle:
                          'Create a goal from the Goals tab to see it here.',
                    ),
                  )
                else
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth;
                      final crossAxis = width < 640 ? 1 : 2;
                      return GridView.builder(
                        itemCount: s.activeGoalsPreview.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxis,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: crossAxis == 1 ? 3.2 : 1.6,
                        ),
                        itemBuilder: (context, i) {
                          final g = s.activeGoalsPreview[i];
                          return AppSurfaceCard(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => BlocProvider(
                                    create: (_) => GoalDetailCubit(
                                      goalRepository: context.goalRepository,
                                      taskRepository: context.taskRepository,
                                      progressRepository:
                                          context.progressRepository,
                                    )..load(g.id),
                                    child: const GoalDetailScreen(),
                                  ),
                                ),
                              );
                            },
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 4,
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              title: Text(
                                g.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              trailing: IconButton(
                                tooltip: 'Edit goal',
                                onPressed: () => _editGoal(context, g.id),
                                icon: const Icon(Icons.edit_outlined),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Today's tasks",
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text('See all'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (s.todayTasks.isEmpty)
                  AppSurfaceCard(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: AppEmptyState(
                      icon: Icons.task_alt_outlined,
                      title: 'Nothing scheduled today',
                      subtitle: 'You’re all caught up, or add tasks from a goal.',
                    ),
                  )
                else
                  ...s.todayTasks.map(
                    (t) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: AppSurfaceCard(
                        onTap: () => _openTaskDetail(context, t),
                        padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    t.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: t.isCompleted
                                        ? AppColors.greenStat
                                            .withValues(alpha: 0.15)
                                        : AppColors.orangeStat
                                            .withValues(alpha: 0.18),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    t.isCompleted
                                        ? 'COMPLETED'
                                        : 'IN PROGRESS',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.4,
                                      color: t.isCompleted
                                          ? const Color(0xFF2D6A45)
                                          : const Color(0xFFB85C1A),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () => _openTaskDetail(context, t),
                                child: const Text('View Details'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  static String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.color,
    required this.value,
    required this.label,
  });

  final Color color;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: color.withValues(alpha: 0.25),
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              height: 1.05,
              color: color.withValues(alpha: 1),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
