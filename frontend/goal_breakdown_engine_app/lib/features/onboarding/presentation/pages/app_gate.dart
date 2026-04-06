import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goal_breakdown_engine_app/core/theme/app_colors.dart';
import 'package:goal_breakdown_engine_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:goal_breakdown_engine_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:goal_breakdown_engine_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:goal_breakdown_engine_app/features/auth/presentation/pages/sign_in_screen.dart';
import 'package:goal_breakdown_engine_app/features/onboarding/presentation/bloc/onboarding_cubit.dart';
import 'package:goal_breakdown_engine_app/features/onboarding/presentation/pages/main_shell.dart';
import 'package:goal_breakdown_engine_app/features/onboarding/presentation/pages/onboarding_screen.dart';
import 'package:goal_breakdown_engine_app/features/onboarding/presentation/pages/splash_screen.dart';

class AppGate extends StatefulWidget {
  const AppGate({super.key});

  @override
  State<AppGate> createState() => _AppGateState();
}

class _AppGateState extends State<AppGate> {
  var _brandSplash = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<OnboardingCubit>().checkStatus();
      context.read<AuthBloc>().add(const AuthStarted());
      _hideBrandSplash();
    });
  }

  Future<void> _hideBrandSplash() async {
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    if (mounted) setState(() => _brandSplash = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_brandSplash) return const SplashScreen();

    return BlocBuilder<OnboardingCubit, OnboardingState>(
      builder: (context, onState) {
        if (onState is OnboardingInitial) {
          return const _GateLoadingScaffold(message: 'Preparing app…');
        }
        if (onState is OnboardingNeeded) {
          return const OnboardingScreen();
        }
        return BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            if (authState is AuthInitial || authState is AuthLoading) {
              return const _GateLoadingScaffold(message: 'Checking session…');
            }
            if (authState is AuthAuthenticated) {
              return const MainShell();
            }
            return const SignInScreen();
          },
        );
      },
    );
  }
}

class _GateLoadingScaffold extends StatelessWidget {
  const _GateLoadingScaffold({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.hexagon_outlined,
              size: 40,
              color: AppColors.primary.withValues(alpha: 0.85),
            ),
            const SizedBox(height: 20),
            const SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
