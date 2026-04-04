import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goal_breakdown_engine_app/app_root.dart';
import 'package:goal_breakdown_engine_app/core/theme/app_colors.dart';
import 'package:goal_breakdown_engine_app/features/dashboard/presentation/bloc/dashboard_cubit.dart';
import 'package:goal_breakdown_engine_app/features/goals/presentation/bloc/goal_detail_cubit.dart';
import 'package:goal_breakdown_engine_app/features/goals/presentation/pages/goal_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async => context.read<DashboardCubit>().refresh(),
        child: BlocBuilder<DashboardCubit, DashboardState>(
          builder: (context, state) {
            if (state is DashboardLoading || state is DashboardInitial) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is DashboardError) {
              return ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Text(state.message),
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: () =>
                              context.read<DashboardCubit>().refresh(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }
            final s = state as DashboardReady;
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 26,
                      backgroundColor: AppColors.goalCard,
                      child: Icon(Icons.person, color: AppColors.primary),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hello, Judith Smith',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          Text(
                            'Let’s crush your goals today',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.notifications_outlined),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                Text(
                  'Overview',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.35,
                  children: [
                    _StatCard(
                      color: AppColors.purpleStat,
                      value: '${s.activeGoalsCount}',
                      label: 'Active goals',
                    ),
                    _StatCard(
                      color: AppColors.orangeStat,
                      value: '${s.tasksInProgress}',
                      label: 'In progress',
                    ),
                    _StatCard(
                      color: AppColors.greenStat,
                      value: '${s.completedToday}',
                      label: 'Completed today',
                    ),
                    _StatCard(
                      color: AppColors.blueStat,
                      value: '${s.overallPercent}%',
                      label: 'Overall',
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Active goals',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ...s.activeGoalsPreview.map(
                  (g) => Card(
                    child: ListTile(
                      title: Text(
                        g.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => BlocProvider(
                              create: (_) => GoalDetailCubit(
                                goalRepository: context.goalRepository,
                                taskRepository: context.taskRepository,
                                progressRepository: context.progressRepository,
                              )..load(g.id),
                              child: const GoalDetailScreen(),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Today's tasks",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(onPressed: () {}, child: const Text('See all')),
                  ],
                ),
                const SizedBox(height: 8),
                ...s.todayTasks.map(
                  (t) => Card(
                    child: ListTile(
                      title: Text(
                        t.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: t.isCompleted
                              ? Colors.green.shade50
                              : Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          t.isCompleted ? 'COMPLETED' : 'PENDING',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: t.isCompleted
                                ? Colors.green.shade800
                                : Colors.orange.shade900,
                          ),
                        ),
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(20),
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
              color: color.withValues(alpha: 1),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade800,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
