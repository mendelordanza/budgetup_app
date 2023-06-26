import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../../helper/shared_prefs.dart';

part 'onboarding_state.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  final SharedPrefs sharedPrefs;

  OnboardingCubit({
    required this.sharedPrefs,
  }) : super(OnboardingInitial()) {
    loadCurrentOnboarding();
  }

  loadCurrentOnboarding() {
    final isFinished = sharedPrefs.getFinishedOnboarding() ?? false;
    emit(OnboardingLoaded(isFinished: isFinished));
  }

  finishOnboarding() {
    sharedPrefs.setFinishedOnboarding(true);
    emit(OnboardingLoaded(isFinished: true));
  }
}
