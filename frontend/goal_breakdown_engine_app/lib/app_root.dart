import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goal_breakdown_engine_app/core/data/local/app_settings_storage.dart';
import 'package:goal_breakdown_engine_app/core/settings/app_settings_cubit.dart';
import 'package:goal_breakdown_engine_app/core/theme/app_theme.dart';
import 'package:goal_breakdown_engine_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:goal_breakdown_engine_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:goal_breakdown_engine_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:goal_breakdown_engine_app/features/goals/data/repositories/goal_repository_impl.dart';
import 'package:goal_breakdown_engine_app/features/goals/data/repositories/progress_repository_impl.dart';
import 'package:goal_breakdown_engine_app/features/goals/domain/repositories/goal_repository.dart';
import 'package:goal_breakdown_engine_app/features/goals/domain/repositories/progress_repository.dart';
import 'package:goal_breakdown_engine_app/features/goals/presentation/bloc/goals_bloc.dart';
import 'package:goal_breakdown_engine_app/features/onboarding/data/local/onboarding_prefs.dart';
import 'package:goal_breakdown_engine_app/features/onboarding/data/local/token_memory.dart';
import 'package:goal_breakdown_engine_app/features/onboarding/data/local/token_storage_prefs.dart';
import 'package:goal_breakdown_engine_app/features/onboarding/data/remote/dio_client_factory.dart';
import 'package:goal_breakdown_engine_app/features/onboarding/presentation/bloc/onboarding_cubit.dart';
import 'package:goal_breakdown_engine_app/features/onboarding/presentation/pages/app_gate.dart';
import 'package:goal_breakdown_engine_app/features/tasks/data/repositories/task_repository_impl.dart';
import 'package:goal_breakdown_engine_app/features/tasks/domain/repositories/task_repository.dart';

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    final tokenMemory = TokenMemory();
    final dio = DioClientFactory(tokenMemory: tokenMemory).create();
    final tokenPrefs = TokenStoragePrefs();
    final onboardingPrefs = OnboardingPrefs();
    final appSettingsStorage = AppSettingsStorage();

    final AuthRepository authRepo = AuthRepositoryImpl(
      dio: dio,
      prefs: tokenPrefs,
      memory: tokenMemory,
    );
    final GoalRepository goalRepo = GoalRepositoryImpl(dio);
    final TaskRepository taskRepo = TaskRepositoryImpl(dio);
    final ProgressRepository progressRepo = ProgressRepositoryImpl(dio);

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc(authRepository: authRepo)),
        BlocProvider(create: (_) => OnboardingCubit(prefs: onboardingPrefs)),
        BlocProvider(create: (_) => GoalsBloc(goalRepository: goalRepo)),
        BlocProvider(
          create: (_) => AppSettingsCubit(appSettingsStorage),
        ),
      ],
      child: _ShellDeps(
        goalRepo: goalRepo,
        taskRepo: taskRepo,
        progressRepo: progressRepo,
        child: BlocBuilder<AppSettingsCubit, AppSettingsState>(
          // Rebuild when theme changes or prefs finish loading so [themeMode] applies.
          buildWhen: (p, c) =>
              p.themeMode != c.themeMode || p.hydrated != c.hydrated,
          builder: (context, settings) {
            return MaterialApp(
              title: 'ATOMIZE',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light(),
              darkTheme: AppTheme.dark(),
              themeMode: settings.themeMode,
              home: const AppGate(),
            );
          },
        ),
      ),
    );
  }
}

/// Provides repositories to the widget tree for screens below [MainShell].
class _ShellDeps extends InheritedWidget {
  const _ShellDeps({
    required this.goalRepo,
    required this.taskRepo,
    required this.progressRepo,
    required super.child,
  });

  final GoalRepository goalRepo;
  final TaskRepository taskRepo;
  final ProgressRepository progressRepo;

  static _ShellDeps of(BuildContext context) {
    final r = context.getInheritedWidgetOfExactType<_ShellDeps>();
    assert(r != null, '_ShellDeps not found');
    return r!;
  }

  @override
  bool updateShouldNotify(_ShellDeps oldWidget) =>
      goalRepo != oldWidget.goalRepo ||
      taskRepo != oldWidget.taskRepo ||
      progressRepo != oldWidget.progressRepo;
}

extension ShellDepsX on BuildContext {
  GoalRepository get goalRepository => _ShellDeps.of(this).goalRepo;
  TaskRepository get taskRepository => _ShellDeps.of(this).taskRepo;
  ProgressRepository get progressRepository => _ShellDeps.of(this).progressRepo;
}
