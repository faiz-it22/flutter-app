import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:projects/common/widgets/connectivity/connectivity_banner.dart';
import 'package:projects/common/widgets/connectivity/connectivity_cubit.dart';
import 'package:projects/features/shop/bloc/scanner_cubit.dart';
import 'package:projects/init/injection.dart';
import 'package:projects/routes/app_pages.dart';
import 'package:projects/utils/theme/theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<ConnectivityCubit>()),
        BlocProvider(create: (_) => getIt<ScannerCubit>()),
      ],
      child: MaterialApp.router(
        themeMode: ThemeMode.system,
        theme: TAppTheme.lightTheme,
        darkTheme: TAppTheme.darkTheme,
        debugShowCheckedModeBanner: false,
        routerConfig: AppPages.router,
        builder: (context, child) {
          return ConnectivityBanner(child: child!);
        },
      ),
    );
  }
}
