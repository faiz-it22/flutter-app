import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:projects/common/widgets/connectivity/connectivity_cubit.dart';
import 'package:projects/utils/constants/colors.dart';

class ConnectivityBanner extends StatelessWidget {
  final Widget child;

  const ConnectivityBanner({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BlocBuilder<ConnectivityCubit, ConnectivityStatus>(
          builder: (context, status) {
            if (status == ConnectivityStatus.offline) {
              return Material(
                child: SafeArea(
                  bottom: false,
                  child: Container(
                    width: double.infinity,
                    color: TColors.error,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: const Text(
                      'Offline',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
        Expanded(child: child),
      ],
    );
  }
}
