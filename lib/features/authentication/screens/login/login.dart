import 'package:flutter/material.dart';
import 'package:projects/common/styles/spacing_styles.dart';
import 'package:projects/common/widgets/login_signup/form_divider.dart';
import 'package:projects/common/widgets/login_signup/social_buttons.dart';
import 'package:projects/features/authentication/screens/login/widgets/login_form.dart';
import 'package:projects/features/authentication/screens/login/widgets/login_header.dart';
import 'package:projects/utils/constants/sizes.dart';
import 'package:projects/utils/constants/text_strings.dart';
import 'package:projects/utils/helpers/helper_function.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = THelperFunctions.isDarkMode(context);
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: TSpacingStyles.paddingWithAppBarHeight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              TLoginHeader(isDarkMode: isDarkMode),

              // Form
              TLoginForm(),

              // Divider
              // TFormDivider(
              //   dividerText: TTexts.tOrSignInWith,
              //   isDarkMode: isDarkMode,
              // ),

              // Footer
              // const SizedBox(height: TSizes.spaceBtwSections),
              // TSocialButtons(),
            ],
          ),
        ),
      ),
    );
  }
}
