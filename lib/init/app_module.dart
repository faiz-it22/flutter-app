import 'package:hive_flutter/hive_flutter.dart';
import 'package:injectable/injectable.dart';
import 'package:projects/data/local/hiu_device_schema.dart';
import 'package:projects/data/local/user_schema.dart';

@module
abstract class AppModule {
  @preResolve
  Future<Box<User>> get userBox async {
    await Hive.initFlutter();
    Hive.registerAdapter(UserAdapter());
    return await Hive.openBox<User>('users');
  }

  @preResolve
  Future<Box<HiuDevice>> get hiuDeviceBox async {
    // Hive.initFlutter() is already called in userBox, but it's safe to call multiple times or ensure order
    if (!Hive.isAdapterRegistered(1)) {
       Hive.registerAdapter(HiuDeviceAdapter());
    }
    return await Hive.openBox<HiuDevice>('hiu_devices');
  }
}
