import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goal_breakdown_engine_app/core/theme/app_colors.dart';
import 'package:goal_breakdown_engine_app/core/widgets/atomize_figma_logo.dart';
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
          'Input any massive objective like learning a new language or building '
          'a start up — and set your deadline',
    ),
    _Slide(
      title: 'Automatically Atomized',
      body:
          'Our engine instantly breaks your objective into Weekly Milestones and '
          'Daily Actionable Activities. No more guessing what to do next.',
    ),
    _Slide(
      title: 'One Day at a Time',
      body:
          "Get a curated list of tasks every morning. Focus on today's 'Atoms' "
          'and watch your progress grow without the stress.',
    ),
    _Slide(
      title: 'Visualize Your Growth',
      body:
          'Track your completion percentage and productivity streaks. Stay '
          'motivated with real-time analytics of your journey.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _complete(BuildContext context) {
    context.read<OnboardingCubit>().completeOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final brandBlue = AppColors.figmaHeadingBlue;
    final actionBlue = dark ? theme.colorScheme.primary : brandBlue;
    final titleColor = dark ? theme.colorScheme.onSurface : brandBlue;
    final bodyColor =
        dark ? theme.colorScheme.onSurfaceVariant : AppColors.figmaBodyGrey;
    final illBg = dark
        ? theme.colorScheme.surfaceContainerHighest
        : AppColors.figmaIllustrationBg;
    final isLast = _page == _slides.length - 1;
    final showBottomSkip = _page >= 1 && !isLast;

    return Scaffold(
      backgroundColor: dark ? theme.colorScheme.surface : Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 4, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: AtomizeFigmaHeaderRow(
                      markSize: dark ? 38 : 40,
                      titleColor: titleColor,
                      logoHexBlue: dark ? theme.colorScheme.primary : null,
                      logoParticleGreen: dark
                          ? AppColors.figmaParticleGreen.withValues(alpha: 0.9)
                          : null,
                    ),
                  ),
                  ThemeToggleIconButton(
                    key: const ValueKey<String>('onboarding_theme_toggle'),
                    iconColor: titleColor,
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
                  return KeyedSubtree(
                    key: ValueKey<String>('onboarding_page_$i'),
                    child: Padding(
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
                                      const SizedBox(height: 20),
                                      Text(
                                        s.title,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: titleColor,
                                          fontSize: 22,
                                          fontWeight: FontWeight.w800,
                                          height: 1.25,
                                        ),
                                      ),
                                      const SizedBox(height: 14),
                                      Text(
                                        s.body,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: bodyColor,
                                          fontSize: 15,
                                          height: 1.5,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 28),
                                    child: _OnboardingIllustration(
                                      index: i,
                                      primary: actionBlue,
                                      background: illBg,
                                      dark: dark,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 80,
                    child: showBottomSkip
                        ? GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => _complete(context),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                'Skip',
                                style: TextStyle(
                                  color: actionBlue,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _slides.length,
                        (i) => AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeOut,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: i == _page ? 22 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: i == _page
                                ? actionBlue
                                : (dark
                                    ? theme.colorScheme.outlineVariant
                                    : const Color(0xFFD0D5E0)),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 80),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 22),
              child: isLast
                  ? _OnboardingPrimaryTap(
                      label: 'Get Started',
                      filled: true,
                      color: actionBlue,
                      onTap: () => _complete(context),
                    )
                  : _OnboardingPrimaryTap(
                      label: 'Next',
                      filled: false,
                      color: actionBlue,
                      onTap: () {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 320),
                          curve: Curves.easeOut,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// No [Material] / ink splash — avoids GlobalKey conflicts with [PageView].
class _OnboardingPrimaryTap extends StatelessWidget {
  const _OnboardingPrimaryTap({
    required this.label,
    required this.filled,
    required this.color,
    required this.onTap,
  });

  final String label;
  final bool filled;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: filled ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: filled ? null : Border.all(color: color, width: 2),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: filled ? Colors.white : color,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}

class _OnboardingIllustration extends StatelessWidget {
  const _OnboardingIllustration({
    required this.index,
    required this.primary,
    required this.background,
    required this.dark,
  });

  final int index;
  final Color primary;
  final Color background;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: dark
              ? Theme.of(context).colorScheme.outlineVariant
              : const Color(0xFFE2E8F4),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: _illustrationChild(),
    );
  }

  Widget _illustrationChild() {
    switch (index) {
      case 0:
        return _DreamBigArt(color: primary);
      case 1:
        return _LightbulbArt(color: primary);
      case 2:
        return _DailyArt(color: primary);
      case 3:
        return _GrowthArt(color: primary);
      default:
        return const SizedBox.shrink();
    }
  }
}

/// Chaotic icons → structured path (conceptual).
class _DreamBigArt extends StatelessWidget {
  const _DreamBigArt({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          left: 28,
          top: 36,
          child: Icon(Icons.blur_on_rounded, size: 36, color: color.withValues(alpha: 0.35)),
        ),
        Positioned(
          left: 48,
          top: 52,
          child: Icon(Icons.star_outline_rounded, size: 22, color: color.withValues(alpha: 0.45)),
        ),
        Positioned(
          left: 36,
          bottom: 48,
          child: Icon(Icons.bolt_rounded, size: 26, color: color.withValues(alpha: 0.4)),
        ),
        Positioned.fill(
          child: CustomPaint(
            painter: _PathArtPainter(color: color),
          ),
        ),
        Positioned(
          right: 52,
          top: 72,
          child: Icon(Icons.flag_rounded, size: 32, color: color),
        ),
      ],
    );
  }
}

class _PathArtPainter extends CustomPainter {
  _PathArtPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color.withValues(alpha: 0.45)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final path = Path()
      ..moveTo(size.width * 0.42, size.height * 0.72)
      ..quadraticBezierTo(
        size.width * 0.52,
        size.height * 0.45,
        size.width * 0.68,
        size.height * 0.38,
      );
    canvas.drawPath(path, p);
    canvas.drawCircle(
      Offset(size.width * 0.42, size.height * 0.72),
      10,
      Paint()..color = color.withValues(alpha: 0.2),
    );
    canvas.drawCircle(
      Offset(size.width * 0.42, size.height * 0.72),
      6,
      Paint()..color = color,
    );
    final metrics = path.computeMetrics(forceClosed: false);
    for (final m in metrics) {
      for (var i = 0; i < 4; i++) {
        final t = 0.35 + i * 0.12;
        final tan = m.getTangentForOffset(m.length * t);
        if (tan != null) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromCenter(center: tan.position, width: 10, height: 10),
              const Radius.circular(3),
            ),
            Paint()..color = color.withValues(alpha: 0.85),
          );
        }
      }
      break;
    }
  }

  @override
  bool shouldRepaint(covariant _PathArtPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _LightbulbArt extends StatelessWidget {
  const _LightbulbArt({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          left: 36,
          child: Icon(Icons.person_outline_rounded, size: 48, color: color.withValues(alpha: 0.55)),
        ),
        Positioned(
          right: 36,
          child: Icon(Icons.person_outline_rounded, size: 48, color: color.withValues(alpha: 0.55)),
        ),
        Icon(Icons.lightbulb_outline_rounded, size: 76, color: color),
        Positioned(
          bottom: 40,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              4,
              (i) => Container(
                width: 14,
                height: 14,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2 + i * 0.15),
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(color: color.withValues(alpha: 0.5)),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DailyArt extends StatelessWidget {
  const _DailyArt({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Icon(Icons.assignment_turned_in_outlined, size: 56, color: color),
        Icon(Icons.schedule_rounded, size: 52, color: color.withValues(alpha: 0.85)),
        Icon(Icons.edit_calendar_rounded, size: 50, color: color.withValues(alpha: 0.8)),
      ],
    );
  }
}

class _GrowthArt extends StatelessWidget {
  const _GrowthArt({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(Icons.psychology_outlined, size: 120, color: color.withValues(alpha: 0.18)),
        Positioned(
          bottom: 48,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _bar(28, color.withValues(alpha: 0.45)),
              const SizedBox(width: 8),
              _bar(44, color.withValues(alpha: 0.65)),
              const SizedBox(width: 8),
              _bar(62, color),
            ],
          ),
        ),
        Icon(Icons.eco_rounded, size: 40, color: AppColors.figmaParticleGreen),
      ],
    );
  }

  static Widget _bar(double h, Color c) => Container(
        width: 14,
        height: h,
        decoration: BoxDecoration(
          color: c,
          borderRadius: BorderRadius.circular(4),
        ),
      );
}

class _Slide {
  const _Slide({required this.title, required this.body});

  final String title;
  final String body;
}
