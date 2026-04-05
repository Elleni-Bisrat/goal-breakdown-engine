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
      body:
          'Name what you want to achieve, add optional context, and choose start '
          'and end dates plus priority. ATOMIZE keeps the goal clear so you are not '
          'overwhelmed by a vague ambition.',
      icon: Icons.flag_outlined,
    ),
    _Slide(
      title: 'Break work into steps',
      body:
          'Goals become milestones and concrete tasks. You always see the next '
          'action instead of guessing what to do today. The app is built for steady '
          'progress, not one-off to-do dumps.',
      icon: Icons.auto_awesome,
    ),
    _Slide(
      title: 'Track and finish',
      body:
          'Mark tasks done, watch overall progress, and open any goal for details. '
          'Use the Home overview for a snapshot and the Tasks tab to work through '
          'your hierarchy by goal.',
      icon: Icons.trending_up,
    ),
    _Slide(
      title: 'Start in minutes',
      body:
          'Create an account or sign in, add your first goal with timeline and '
          'priority, then refine as you go. Everything stays synced with your '
          'backend so lists and progress stay up to date.',
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
      backgroundColor: const Color(0xFFEEF2FF),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFE8EEFF),
              AppColors.background,
            ],
          ),
        ),
        child: SafeArea(
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
                      style: TextStyle(
                        color: AppColors.splashMid,
                        fontWeight: FontWeight.w600,
                      ),
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
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          const SizedBox(height: 8),
                          Icon(
                            Icons.hexagon_outlined,
                            size: 52,
                            color: AppColors.splashMid,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            s.title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A2744),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            s.body,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey.shade800,
                              height: 1.45,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            height: 168,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: AppColors.splashAccent.withValues(
                                  alpha: 0.35,
                                ),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.splashMid.withValues(
                                    alpha: 0.12,
                                  ),
                                  blurRadius: 22,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Icon(
                                s.icon,
                                size: 72,
                                color: AppColors.splashMid,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
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
                          ? AppColors.splashMid
                          : Colors.grey.shade300,
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
  const _Slide({required this.title, required this.body, required this.icon});

  final String title;
  final String body;
  final IconData icon;
}
