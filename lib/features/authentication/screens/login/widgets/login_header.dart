import 'package:flutter/material.dart';
import 'package:projects/utils/constants/image_strings.dart';
import 'package:projects/utils/constants/sizes.dart';
import 'package:projects/utils/constants/text_strings.dart';

class TLoginHeader extends StatelessWidget {
  const TLoginHeader({
    super.key,
    required this.isDarkMode,
  });

  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start
      ,
      // Header
      children: [
        Image(
          height: 80,
          image: AssetImage(
            isDarkMode ? TImages.lightAppLogo : TImages.darkAppLogo,
          ),
        ),
        const SizedBox(height: TSizes.sm),
        Text(
          TTexts.tLoginTitle,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: TSizes.sm),
        Text(
          TTexts.tLoginSubTitle,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}
