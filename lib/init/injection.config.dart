// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i6;
import 'package:get_it/get_it.dart' as _i1;
import 'package:hive/hive.dart' as _i12;
import 'package:hive_flutter/hive_flutter.dart' as _i3;
import 'package:injectable/injectable.dart' as _i2;

import '../common/widgets/connectivity/connectivity_cubit.dart' as _i13;
import '../data/local/hiu_device_schema.dart' as _i5;
import '../data/local/user_schema.dart' as _i4;
import '../data/repositories/authentication_repository.dart' as _i11;
import '../data/services/auth_api_service.dart' as _i10;
import '../data/services/bluetooth_service.dart' as _i9;
import '../features/authentication/bloc/login_bloc.dart' as _i14;
import '../features/authentication/bloc/onboarding_bloc.dart' as _i8;
import '../features/shop/bloc/scanner_cubit.dart' as _i15;
import '../utils/network/network_manager.dart' as _i7;
import 'app_module.dart' as _i16;
import 'network_module.dart' as _i17;

extension GetItInjectableX on _i1.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  Future<_i1.GetIt> init({
    String? environment,
    _i2.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i2.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final appModule = _$AppModule();
    final networkModule = _$NetworkModule();
    await gh.factoryAsync<_i3.Box<_i4.User>>(
      () => appModule.userBox,
      preResolve: true,
    );
    await gh.factoryAsync<_i3.Box<_i5.HiuDevice>>(
      () => appModule.hiuDeviceBox,
      preResolve: true,
    );
    gh.lazySingleton<_i6.Dio>(() => networkModule.dio);
    gh.lazySingleton<_i7.NetworkManager>(
      () => _i7.NetworkManager(),
      dispose: (i) => i.dispose(),
    );
    gh.factory<_i8.OnBoardingBloc>(() => _i8.OnBoardingBloc());
    gh.lazySingleton<_i9.TBluetoothService>(() => _i9.TBluetoothService());
    gh.factory<_i10.AuthApiService>(() => _i10.AuthApiService(gh<_i6.Dio>()));
    gh.lazySingleton<_i11.AuthenticationRepository>(
        () => _i11.AuthenticationRepository(
              gh<_i10.AuthApiService>(),
              gh<_i12.Box<_i4.User>>(),
            ));
    gh.factory<_i13.ConnectivityCubit>(
        () => _i13.ConnectivityCubit(gh<_i7.NetworkManager>()));
    gh.factory<_i14.LoginBloc>(() => _i14.LoginBloc(
        authenticationRepository: gh<_i11.AuthenticationRepository>()));
    gh.factory<_i15.ScannerCubit>(
        () => _i15.ScannerCubit(gh<_i9.TBluetoothService>()));
    return this;
  }
}

class _$AppModule extends _i16.AppModule {}

class _$NetworkModule extends _i17.NetworkModule {}
