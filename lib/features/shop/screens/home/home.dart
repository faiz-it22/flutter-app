import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:projects/data/repositories/authentication_repository.dart';
import 'package:projects/features/shop/bloc/scanner_cubit.dart';
import 'package:projects/features/shop/screens/home/widgets/scanner_bottom_sheet.dart';
import 'package:projects/init/injection.dart';
import 'package:projects/routes/routes.dart';
import 'package:projects/utils/constants/sizes.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('HIU Dashboard',
            style: Theme.of(context).textTheme.headlineMedium),
        actions: [
          IconButton(
            onPressed: () async {
              await getIt<AuthenticationRepository>().logout();
              if (context.mounted) context.go(TRoutes.login);
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            children: [
              Text('Welcome to Fortes Energy HIU Control',
                  style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: TSizes.spaceBtwSections),

              // Device Status Card — reacts to ScannerCubit connection state
              BlocBuilder<ScannerCubit, ScannerState>(
                builder: (context, state) {
                  final isConnected = state.isConnected;
                  final deviceName = isConnected
                      ? (state.connectedDevice!.platformName.isNotEmpty
                          ? state.connectedDevice!.platformName
                          : 'Unknown HIU')
                      : null;

                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(TSizes.md),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isConnected ? Colors.green : Colors.grey,
                      ),
                      borderRadius:
                          BorderRadius.circular(TSizes.cardRadiusLg),
                    ),
                    child: Column(
                      children: [
                        Text(
                          isConnected
                              ? 'Device Status: Connected to $deviceName'
                              : 'Device Status: Not Connected',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isConnected ? Colors.green : null,
                          ),
                        ),
                        const SizedBox(height: TSizes.spaceBtwItems),
                        Text(
                          isConnected
                              ? 'Tap below to manage the connection.'
                              : 'Please connect via BLE to begin commissioning.',
                        ),
                        const SizedBox(height: TSizes.spaceBtwSections),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              // Trigger initial scan when opening (only if not connected)
                              if (!isConnected) {
                                context.read<ScannerCubit>().initScan();
                              }
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(20)),
                                ),
                                builder: (_) => BlocProvider.value(
                                  value: context.read<ScannerCubit>(),
                                  child: const ScannerBottomSheet(),
                                ),
                              );
                            },
                            child: Text(
                                isConnected ? 'Manage Connection' : 'Start Scanning'),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
