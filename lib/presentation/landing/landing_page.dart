import 'package:budgetup_app/presentation/landing/bloc/onboarding_cubit.dart';
import 'package:budgetup_app/presentation/landing/home_page.dart';
import 'package:budgetup_app/presentation/onboarding/onboarding_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnboardingCubit, OnboardingState>(
      builder: (context, state) {
        if (state is OnboardingLoaded && state.isFinished) {
          return HomePage();
        }
        return OnboardingPage();
      },
    );
  }
}
