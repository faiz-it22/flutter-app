import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:projects/features/authentication/bloc/onboarding_bloc.dart';
import 'package:projects/routes/routes.dart';
import 'package:projects/utils/constants/colors.dart';
import 'package:projects/utils/constants/sizes.dart';
import 'package:projects/utils/device/device_utility.dart';
import 'package:projects/utils/helpers/helper_function.dart';

class OnBoardingNextButton extends StatelessWidget {
  const OnBoardingNextButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = THelperFunctions.isDarkMode(context);
    return Positioned(
      right: TSizes.defaultSpace,
      bottom: TDeviceUtils.getBottomNavigationBarHeight(),
      child: SizedBox(
        width: 56,
        height: 56,
        child: BlocBuilder<OnBoardingBloc, OnBoardingState>(
          builder: (context, state) {
            return ElevatedButton(
              onPressed: () {
                if (state.currentIndex == 2) {
                  context.go(TRoutes.login);
                } else {
                  context.read<OnBoardingBloc>().add(OnBoardingNextPage());
                }
              },
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                backgroundColor: isDarkMode ? TColors.primary : Colors.black,
                padding: EdgeInsets.zero,
                elevation: 6,
                side: BorderSide.none,
              ),
              child: const Icon(Iconsax.arrow_right),
            );
          },
        ),
      ),
    );
  }
}
