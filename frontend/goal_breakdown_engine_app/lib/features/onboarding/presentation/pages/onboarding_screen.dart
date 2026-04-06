import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goal_breakdown_engine_app/core/theme/app_colors.dart';
import 'package:goal_breakdown_engine_app/core/widgets/theme_toggle_button.dart';
import 'package:goal_breakdown_engine_app/features/onboarding/presentation/bloc/onboarding_cubit.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _page = 0;

  static const _slides = [
    _Slide(
      title: 'Dream Big Start Small',
      body:
          'Set a clear goal with dates and priority. ATOMIZE keeps the target visible '
          'so you can focus on the next step instead of the whole mountain.',
      icon: Icons.flag_outlined,
    ),
    _Slide(
      title: 'Automatically Atomized',
      body:
          'Goals break into milestones and tasks automatically. You always know what '
          'to do today while the app keeps structure aligned with your timeline.',
      icon: Icons.auto_awesome,
    ),
    _Slide(
      title: 'One Day at a Time',
      body:
          'Check off tasks, watch progress on Home, and drill into details when you '
          'need context. Small wins add up to finished goals.',
      icon: Icons.trending_up,
    ),
    _Slide(
      title: 'Visualize Your Growth',
      body:
          'Sign in, create your first goal, and see stats, lists, and completion '
          'rings update as you work. Your data stays in sync with the server.',
      icon: Icons.rocket_launch_outlined,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isLast = _page == _slides.length - 1;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: theme.brightness == Brightness.dark
                ? [
                    cs.surfaceContainerHigh,
                    theme.scaffoldBackgroundColor,
                  ]
                : [
                    const Color(0xFFE8EEFF),
                    AppColors.background,
                  ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    ThemeToggleIconButton(
                      iconColor: theme.brightness == Brightness.dark
                          ? cs.onSurface
                          : null,
                    ),
                    const Spacer(),
                    if (!isLast)
                      TextButton(
                        onPressed: () => context
                            .read<OnboardingCubit>()
                            .completeOnboarding(),
                        child: Text(
                          'Skip',
                          style: TextStyle(
                            color: cs.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _slides.length,
                  onPageChanged: (i) => setState(() => _page = i),
                  itemBuilder: (context, i) {
                    final s = _slides[i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight: constraints.maxHeight,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    children: [
                                      const SizedBox(height: 8),
                                      Icon(
                                        Icons.hexagon_outlined,
                                        size: 48,
                                        color: cs.primary,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        s.title,
                                        textAlign: TextAlign.center,
                                        style: theme.textTheme.titleLarge
                                            ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        s.body,
                                        textAlign: TextAlign.center,
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                          height: 1.45,
                                          color: cs.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 24),
                                    child: Container(
                                      height: 168,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: theme.brightness ==
                                                Brightness.dark
                                            ? cs.surfaceContainerHighest
                                            : Colors.white,
                                        borderRadius: BorderRadius.circular(24),
                                        border: Border.all(
                                          color: cs.outlineVariant
                                              .withValues(alpha: 0.5),
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: cs.primary
                                                .withValues(alpha: 0.08),
                                            blurRadius: 18,
                                            offset: const Offset(0, 8),
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: Icon(
                                          s.icon,
                                          size: 72,
                                          color: cs.primary,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _slides.length,
                  (i) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: i == _page ? 22 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: i == _page ? cs.primary : cs.outlineVariant,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 22),
                child: isLast
                    ? SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => context
                              .read<OnboardingCubit>()
                              .completeOnboarding(),
                          child: const Text('Get Started'),
                        ),
                      )
                    : SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 320),
                              curve: Curves.easeOut,
                            );
                          },
                          child: const Text('Next'),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Slide {
  const _Slide({
    required this.title,
    required this.body,
    required this.icon,
  });

  final String title;
  final String body;
  final IconData icon;
}
