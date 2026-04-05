import 'package:flutter/material.dart';
import 'package:goal_breakdown_engine_app/core/theme/app_colors.dart';
import 'package:goal_breakdown_engine_app/core/widgets/atomize_figma_logo.dart';
import 'package:goal_breakdown_engine_app/core/widgets/theme_toggle_button.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: dark ? theme.colorScheme.surface : Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 4,
              right: 4,
              child: ThemeToggleIconButton(
                key: const ValueKey<String>('splash_theme_toggle'),
                iconColor: dark
                    ? theme.colorScheme.onSurface
                    : AppColors.figmaHeadingBlue,
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AtomizeFigmaSplashBlock(
                      markSize: dark ? 128 : 132,
                      titleColor: dark
                          ? theme.colorScheme.onSurface
                          : AppColors.figmaHeadingBlue,
                      taglineColor: dark
                          ? theme.colorScheme.onSurfaceVariant
                          : AppColors.figmaBodyGrey,
                      hexBlue: dark
                          ? theme.colorScheme.primary
                          : null,
                      particleGreen: dark
                          ? AppColors.figmaParticleGreen.withValues(alpha: 0.95)
                          : null,
                    ),
                    const SizedBox(height: 36),
                    SizedBox(
                      width: 36,
                      height: 36,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.8,
                        color: dark
                            ? theme.colorScheme.primary
                            : AppColors.figmaHeadingBlue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
