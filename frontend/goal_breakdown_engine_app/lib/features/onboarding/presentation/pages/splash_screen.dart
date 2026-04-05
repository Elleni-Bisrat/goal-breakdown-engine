import 'package:flutter/material.dart';
import 'package:goal_breakdown_engine_app/core/theme/app_colors.dart';
import 'package:goal_breakdown_engine_app/core/widgets/theme_toggle_button.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: dark ? theme.scaffoldBackgroundColor : null,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: dark
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.surfaceContainerHigh,
                    theme.scaffoldBackgroundColor,
                  ],
                )
              : const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.splashDeep,
                    AppColors.splashMid,
                    AppColors.splashAccent,
                  ],
                  stops: [0.0, 0.55, 1.0],
                ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: 4,
                right: 4,
                child: ThemeToggleIconButton(
                  iconColor: dark ? theme.colorScheme.primary : Colors.white,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 92,
                      height: 92,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.45,
                          ),
                        ),
                      ),
                      child: Icon(
                        Icons.hexagon_outlined,
                        color: dark
                            ? theme.colorScheme.primary
                            : Colors.white,
                        size: 50,
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'ATOMIZE',
                      style: TextStyle(
                        color: dark
                            ? theme.colorScheme.onSurface
                            : Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 3,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Break big goals into milestones and daily tasks. '
                      'Plan with dates and priority, then track progress in one place.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: dark
                            ? theme.colorScheme.onSurfaceVariant
                            : Colors.white.withValues(alpha: 0.92),
                        fontSize: 15,
                        height: 1.45,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: 32,
                      height: 32,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: dark
                            ? theme.colorScheme.primary
                            : Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
