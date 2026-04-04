import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:goal_breakdown_engine_app/features/onboarding/data/local/onboarding_prefs.dart';

part 'onboarding_state.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  OnboardingCubit({required OnboardingPrefs prefs})
    : _prefs = prefs,
      super(const OnboardingInitial());

  final OnboardingPrefs _prefs;

  Future<void> checkStatus() async {
    final done = await _prefs.isComplete();
    if (done) {
      emit(const OnboardingCompleted());
    } else {
      emit(const OnboardingNeeded());
    }
  }

  Future<void> completeOnboarding() async {
    await _prefs.setComplete();
    emit(const OnboardingCompleted());
  }
}
