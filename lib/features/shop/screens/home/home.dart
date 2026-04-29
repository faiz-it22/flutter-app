import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:projects/data/repositories/authentication_repository.dart';
import 'package:projects/features/shop/bloc/modbus_cubit.dart';
import 'package:projects/features/shop/bloc/scanner_cubit.dart';
import 'package:projects/features/shop/screens/home/widgets/modbus_bottom_sheet.dart';
import 'package:projects/features/shop/screens/home/widgets/scanner_bottom_sheet.dart';
import 'package:projects/init/injection.dart';
import 'package:projects/routes/routes.dart';
import 'package:projects/utils/constants/colors.dart';
import 'package:projects/utils/constants/sizes.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loggedInUser = getIt<AuthenticationRepository>().getCurrentUser();
    final username = loggedInUser?.username ?? 'Guest';

    return Scaffold(
      appBar: AppBar(
        title: const Text('HIU Dashboard'),
        actions: [
          IconButton(
            onPressed: () async {
              await getIt<AuthenticationRepository>().logout();
              if (context.mounted) context.go(TRoutes.login);
            },
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _WelcomeHeader(username: username),
            const SizedBox(height: TSizes.spaceBtwSections),
            Text(
              'Device',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: TSizes.spaceBtwItems),
            BlocBuilder<ScannerCubit, ScannerState>(
              builder: (context, state) => _DeviceStatusCard(state: state),
            ),
            const SizedBox(height: TSizes.spaceBtwSections),
            Text(
              'Modbus',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: TSizes.spaceBtwItems),
            BlocBuilder<ScannerCubit, ScannerState>(
              builder: (context, state) =>
                  _ModbusCard(isConnected: state.isConnected),
            ),
          ],
        ),
      ),
    );
  }
}

class _WelcomeHeader extends StatelessWidget {
  const _WelcomeHeader({required this.username});
  final String username;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: TColors.primary.withValues(alpha: 0.12),
          child: Text(
            username[0].toUpperCase(),
            style: const TextStyle(
              color: TColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back,',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            Text(
              username,
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }
}

class _DeviceStatusCard extends StatelessWidget {
  const _DeviceStatusCard({required this.state});
  final ScannerState state;

  @override
  Widget build(BuildContext context) {
    final isConnected = state.isConnected;
    final deviceName = isConnected
        ? (state.connectedDevice!.platformName.isNotEmpty
            ? state.connectedDevice!.platformName
            : 'Unknown HIU')
        : null;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
        side: BorderSide(
          color: isConnected
              ? Colors.green.shade300
              : Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      color: isConnected ? Colors.green.withValues(alpha: 0.04) : null,
      child: Padding(
        padding: const EdgeInsets.all(TSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: (isConnected ? Colors.green : Colors.grey)
                        .withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isConnected
                        ? Icons.bluetooth_connected_rounded
                        : Icons.bluetooth_rounded,
                    color: isConnected ? Colors.green : Colors.grey,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isConnected ? deviceName! : 'No Device Connected',
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: isConnected ? Colors.green : Colors.grey,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            isConnected ? 'Connected' : 'Disconnected',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: isConnected
                                          ? Colors.green
                                          : Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant,
                                    ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: TSizes.spaceBtwItems),
            Text(
              isConnected
                  ? 'Tap below to explore device services and characteristics.'
                  : 'Scan for nearby HIU devices to begin.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: TSizes.spaceBtwItems),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  if (!isConnected) {
                    context.read<ScannerCubit>().initScan();
                  }
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    useSafeArea: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => BlocProvider.value(
                      value: context.read<ScannerCubit>(),
                      child: const ScannerBottomSheet(),
                    ),
                  );
                },
                icon: Icon(
                  isConnected ? Iconsax.cpu_copy : Iconsax.bluetooth_copy,
                  size: 18,
                ),
                label: Text(isConnected ? 'View Device' : 'Scan for Devices'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModbusCard extends StatelessWidget {
  const _ModbusCard({required this.isConnected});
  final bool isConnected;

  void _openSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<ModbusCubit>(),
        child: const ModbusBottomSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
        side: BorderSide(
          color: isConnected
              ? TColors.primary.withValues(alpha: 0.4)
              : Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      color: isConnected ? TColors.primary.withValues(alpha: 0.04) : null,
      child: Padding(
        padding: const EdgeInsets.all(TSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: (isConnected ? TColors.primary : Colors.grey)
                        .withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.memory_rounded,
                    color: isConnected ? TColors.primary : Colors.grey,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Register Operations',
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isConnected
                            ? 'Read · Write · Stream'
                            : 'Connect a device first',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: isConnected
                                  ? TColors.primary
                                  : Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: TSizes.spaceBtwItems),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: isConnected ? () => _openSheet(context) : null,
                icon: const Icon(Icons.tune_rounded, size: 18),
                label: const Text('Open Modbus Panel'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
