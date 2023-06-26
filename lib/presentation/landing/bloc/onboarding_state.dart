part of 'onboarding_cubit.dart';

@immutable
abstract class OnboardingState {}

class OnboardingInitial extends OnboardingState {}

class OnboardingLoaded extends OnboardingState {
  final bool isFinished;

  OnboardingLoaded({required this.isFinished});
}
