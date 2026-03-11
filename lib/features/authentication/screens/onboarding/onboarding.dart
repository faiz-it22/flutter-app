import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:projects/features/authentication/bloc/onboarding_bloc.dart';
import 'package:projects/init/injection.dart';
import 'package:projects/utils/constants/image_strings.dart';
import 'package:projects/utils/constants/text_strings.dart';
import 'package:projects/features/authentication/controllers/controller.onboarding/widgets/onboarding_page.dart';
import 'package:projects/features/authentication/controllers/controller.onboarding/widgets/onboarding_skip.dart';
import 'package:projects/features/authentication/controllers/controller.onboarding/widgets/onboarding_dot_navigation.dart';
import 'package:projects/features/authentication/controllers/controller.onboarding/widgets/onboarding_next_button.dart';

class OnBoardingScreen extends StatelessWidget {
  const OnBoardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<OnBoardingBloc>(),
      child: Scaffold(
        body: Stack(
          children: [
            // Horizontal Scrollable Pages
            BlocBuilder<OnBoardingBloc, OnBoardingState>(
              builder: (context, state) {
                final bloc = context.read<OnBoardingBloc>();
                return PageView(
                  controller: bloc.pageController,
                  onPageChanged: (index) => bloc.add(OnBoardingPageChanged(index)),
                  children: const [
                    OnBoardingPage(
                      title: TTexts.tOnBoardingTitle1,
                      subTitle: TTexts.tOnBoardingSubTitle1,
                      image: TImages.onBoardingImage1,
                    ),
                    OnBoardingPage(
                      title: TTexts.tOnBoardingTitle2,
                      subTitle: TTexts.tOnBoardingSubTitle2,
                      image: TImages.onBoardingImage2,
                    ),
                    OnBoardingPage(
                      title: TTexts.tOnBoardingTitle3,
                      subTitle: TTexts.tOnBoardingSubTitle3,
                      image: TImages.onBoardingImage3,
                    ),
                  ],
                );
              },
            ),
            // Skip Button
            const OnBoardingSkip(),
            // Dot Navigation Smooth Page Indicator
            const OnBoardingDotNavigation(),
            // Circular Button
            const OnBoardingNextButton(),
          ],
        ),
      ),
    );
  }
}
