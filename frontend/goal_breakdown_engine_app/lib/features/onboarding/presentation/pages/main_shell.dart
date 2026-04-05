import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goal_breakdown_engine_app/app_root.dart';
import 'package:goal_breakdown_engine_app/features/dashboard/presentation/bloc/dashboard_cubit.dart';
import 'package:goal_breakdown_engine_app/features/dashboard/presentation/pages/home_screen.dart';
import 'package:goal_breakdown_engine_app/features/goals/presentation/bloc/goals_bloc.dart';
import 'package:goal_breakdown_engine_app/features/goals/presentation/bloc/goals_event.dart';
import 'package:goal_breakdown_engine_app/features/goals/presentation/pages/my_goals_screen.dart';
import 'package:goal_breakdown_engine_app/features/profile/presentation/pages/profile_screen.dart';
import 'package:goal_breakdown_engine_app/features/tasks/presentation/bloc/tasks_hierarchy_cubit.dart';
import 'package:goal_breakdown_engine_app/features/tasks/presentation/pages/my_tasks_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  var _index = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<GoalsBloc>().add(const GoalsLoadRequested());
    });
  }

  @override
  Widget build(BuildContext context) {
    final goalRepo = context.goalRepository;
    final taskRepo = context.taskRepository;
    final progressRepo = context.progressRepository;

    return MultiBlocProvider(
      key: const ValueKey('main_shell_blocs'),
      providers: [
        BlocProvider(
          create: (_) => DashboardCubit(
            goalRepository: goalRepo,
            taskRepository: taskRepo,
            progressRepository: progressRepo,
          )..refresh(),
        ),
        BlocProvider(
          create: (_) => TasksHierarchyCubit(
            goalRepository: goalRepo,
            taskRepository: taskRepo,
          )..load(),
        ),
      ],
      child: Scaffold(
        body: IndexedStack(
          index: _index,
          children: const [
            HomeScreen(),
            MyGoalsScreen(),
            MyTasksScreen(),
            ProfileScreen(),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) {
            setState(() => _index = i);
            // Goals tab: ensure list loads when opening the tab (IndexedStack
            // may have kept the subtree inactive; also covers missed initial load).
            if (i == 1) {
              context.read<GoalsBloc>().add(const GoalsLoadRequested());
            }
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.flag_outlined),
              selectedIcon: Icon(Icons.flag),
              label: 'Goals',
            ),
            NavigationDestination(
              icon: Icon(Icons.checklist_outlined),
              selectedIcon: Icon(Icons.checklist),
              label: 'Tasks',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
