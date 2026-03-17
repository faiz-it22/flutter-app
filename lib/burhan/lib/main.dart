import 'package:flutter/material.dart';
import 'package:fourt_app/app.widget.dart';
import 'package:fourt_app/devices/schema/devices.schema.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(DeviceDataAdapter());
  runApp(const App());
}