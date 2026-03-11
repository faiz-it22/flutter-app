import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:projects/features/authentication/bloc/onboarding_bloc.dart';
import 'package:projects/utils/constants/colors.dart';
import 'package:projects/utils/constants/sizes.dart';
import 'package:projects/utils/device/device_utility.dart';
import 'package:projects/utils/helpers/helper_function.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnBoardingDotNavigation extends StatelessWidget {
  const OnBoardingDotNavigation({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<OnBoardingBloc>();
    final isDarkMode = THelperFunctions.isDarkMode(context);
    
    return Positioned(
      bottom: TDeviceUtils.getBottomNavigationBarHeight() + 25,
      left: TSizes.defaultSpace,
      child: SmoothPageIndicator(
        controller: bloc.pageController,
        onDotClicked: (index) => bloc.add(OnBoardingPageChanged(index)),
        count: 3,
        effect: ExpandingDotsEffect(
          activeDotColor: isDarkMode ? TColors.light : TColors.dark,
          dotHeight: 6,
        ),
      ),
    );
  }
}
