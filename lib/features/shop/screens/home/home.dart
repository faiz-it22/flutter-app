import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:projects/data/repositories/authentication_repository.dart';
import 'package:projects/features/shop/screens/home/widgets/scanner_bottom_sheet.dart';
import 'package:projects/init/injection.dart';
import 'package:projects/routes/routes.dart';
import 'package:projects/utils/constants/sizes.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loggedInUser = getIt<AuthenticationRepository>().getCurrentUser();
    return Scaffold(
      appBar: AppBar(
        title: Text('HIU Dashboard', style: Theme.of(context).textTheme.headlineMedium),
        actions: [
          IconButton(
            onPressed: () async {
              // 1. Clear tokens and local data
              await getIt<AuthenticationRepository>().logout();
              
              // 2. Navigate to login (Redirect in app_pages will now allow this)
              if (context.mounted) {
                context.go(TRoutes.login);
              }
            }, 
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            children: [
              Text('Welcome ${loggedInUser?.username ?? "Guest"}', style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: TSizes.spaceBtwSections),
              
              // Device Status Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(TSizes.md),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
                ),
                child: Column(
                  children: [
                    const Text('Device Status: Not Connected', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: TSizes.spaceBtwItems),
                    const Text('Please connect via BLE to begin commissioning.'),
                    const SizedBox(height: TSizes.spaceBtwSections),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                            ),
                            builder: (context) => const ScannerBottomSheet(),
                          );
                        },
                        child: const Text('Start Scanning'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
