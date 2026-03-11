import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:projects/features/authentication/bloc/onboarding_bloc.dart';
import 'package:projects/utils/constants/sizes.dart';
import 'package:projects/utils/device/device_utility.dart';

class OnBoardingSkip extends StatelessWidget {
  const OnBoardingSkip({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: TDeviceUtils.getAppBarHeight(),
      right: TSizes.defaultSpace,
      child: TextButton(
        onPressed: () => context.read<OnBoardingBloc>().add(OnBoardingSkipPage()),
        child: const Text('Skip'),
      ),
    );
  }
}
