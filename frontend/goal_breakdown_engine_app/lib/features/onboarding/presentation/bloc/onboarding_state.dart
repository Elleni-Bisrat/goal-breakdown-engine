part of 'onboarding_cubit.dart';

sealed class OnboardingState extends Equatable {
  const OnboardingState();

  @override
  List<Object?> get props => [];
}

final class OnboardingInitial extends OnboardingState {
  const OnboardingInitial();
}

final class OnboardingNeeded extends OnboardingState {
  const OnboardingNeeded();
}

final class OnboardingCompleted extends OnboardingState {
  const OnboardingCompleted();
}
