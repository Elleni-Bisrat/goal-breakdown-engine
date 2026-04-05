import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goal_breakdown_engine_app/core/theme/app_colors.dart';
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
      title: 'Set focused goals',
      body: 'Turn big ambitions into clear outcomes you can track every day.',
      icon: Icons.flag_outlined,
    ),
    _Slide(
      title: 'AI breakdown',
      body: 'Automatic milestones and tasks so you always know the next step.',
      icon: Icons.auto_awesome,
    ),
    _Slide(
      title: 'Stay on pace',
      body: 'See progress, complete today’s tasks, and adjust as you grow.',
      icon: Icons.trending_up,
    ),
    _Slide(
      title: 'Ready when you are',
      body: 'Sign in and start atomizing your first goal in minutes.',
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
    final isLast = _page == _slides.length - 1;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            if (!isLast)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () =>
                      context.read<OnboardingCubit>().completeOnboarding(),
                  child: const Text(
                    'Skip',
                    style: TextStyle(color: AppColors.primary),
                  ),
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
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      children: [
                        const SizedBox(height: 12),
                        Icon(
                          Icons.hexagon_outlined,
                          size: 56,
                          color: AppColors.primary,
                        ),
                        const SizedBox(height: 28),
                        Text(
                          s.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          s.body,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey.shade700,
                            height: 1.4,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          height: 160,
                          decoration: BoxDecoration(
                            color: AppColors.goalCard,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.08),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.12),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Icon(
                              s.icon,
                              size: 72,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
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
                    color: i == _page
                        ? AppColors.primary
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
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
    );
  }
}

class _Slide {
  const _Slide({required this.title, required this.body, required this.icon});

  final String title;
  final String body;
  final IconData icon;
}
