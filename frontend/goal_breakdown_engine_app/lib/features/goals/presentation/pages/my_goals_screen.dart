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
                        context.read<GoalsBloc>().add(
                          GoalCreateRequested(
                            title: data['title']!,
                            priorityLabel: data['priority']!,
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
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(state.message)));
                }
              },
              builder: (context, state) {
                if (state is GoalsLoading || state is GoalsInitial) {
                  return const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (state is GoalsLoaded) {
                  if (state.goals.isEmpty) {
                    return SliverFillRemaining(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            'No goals yet.\nTap Create to add a goal and priority.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey.shade700),
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
                      delegate: SliverChildBuilderDelegate((context, i) {
                        final g = state.goals[i];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Material(
                            color: AppColors.goalCard,
                            borderRadius: BorderRadius.circular(24),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(24),
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
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      g.title,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      g.description ?? '${g.duration} day plan',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.grey.shade800,
                                        height: 1.3,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: OutlinedButton(
                                        onPressed: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute<void>(
                                              builder: (_) => BlocProvider(
                                                create: (_) => GoalDetailCubit(
                                                  goalRepository:
                                                      context.goalRepository,
                                                  taskRepository:
                                                      context.taskRepository,
                                                  progressRepository: context
                                                      .progressRepository,
                                                )..load(g.id),
                                                child: const GoalDetailScreen(),
                                              ),
                                            ),
                                          );
                                        },
                                        child: const Text('Update'),
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
}
