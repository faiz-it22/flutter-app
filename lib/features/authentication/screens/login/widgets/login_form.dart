import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:projects/features/authentication/bloc/login_bloc.dart';
import 'package:projects/features/authentication/bloc/login_event.dart';
import 'package:projects/features/authentication/bloc/login_state.dart';
import 'package:projects/init/injection.dart';
import 'package:projects/routes/routes.dart';
import 'package:projects/utils/constants/sizes.dart';
import 'package:projects/utils/constants/text_strings.dart';
import 'package:projects/utils/validators/validation.dart';

class TLoginForm extends StatelessWidget {
  const TLoginForm({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<LoginBloc>(),
      child: BlocListener<LoginBloc, LoginState>(
        listener: (context, state) {
          if (state.status == LoginStatus.success) {
            context.go(TRoutes.home);
          } else if (state.status == LoginStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage ?? 'Authentication Failed')),
            );
          }
        },
        child: const LoginFormContent(),
      ),
    );
  }
}

class LoginFormContent extends StatelessWidget {
  const LoginFormContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: TSizes.spaceBtwSections,
      ),
      child: Form(
        child: Column(
          children: [
            // Email
            TextFormField(
              onChanged: (email) => context.read<LoginBloc>().add(LoginEmailChanged(email)),
              validator: (value) => TValidator.validateEmail(value),
              decoration: const InputDecoration(
                prefixIcon: Icon(Iconsax.sms),
                labelText: TTexts.email,
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwInputFields),
            
            // Password
            BlocBuilder<LoginBloc, LoginState>(
              buildWhen: (previous, current) => previous.showPassword != current.showPassword,
              builder: (context, state) {
                return TextFormField(
                  onChanged: (password) => context.read<LoginBloc>().add(LoginPasswordChanged(password)),
                  validator: (value) => TValidator.validatePassword(value),
                  obscureText: !state.showPassword,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Iconsax.lock),
                    labelText: TTexts.password,
                    suffixIcon: IconButton(
                      onPressed: () => context.read<LoginBloc>().add(const LoginShowPasswordToggled()),
                      icon: Icon(state.showPassword ? Iconsax.eye : Iconsax.eye_slash),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: TSizes.spaceBtwInputFields / 2),
            
            const SizedBox(height: TSizes.spaceBtwItems),
            
            // Sign In Button
            SizedBox(
              width: double.infinity,
              child: BlocBuilder<LoginBloc, LoginState>(
                buildWhen: (previous, current) => previous.status != current.status,
                builder: (context, loginState) {
                  final isLoading = loginState.status == LoginStatus.loading;
                  
                  return ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () => context.read<LoginBloc>().add(const LoginSubmitted()),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text(TTexts.tSignIn),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
