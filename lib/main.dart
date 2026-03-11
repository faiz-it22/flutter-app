import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:projects/init/injection.dart';

import 'app.dart';

void main() async {
  // Ensure that widgets are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: '.env');

  // Initialize Dependency Injection
  // We MUST await this because we have @preResolve dependencies (like Hive Boxes)
  await configureDependencies();

  runApp(const App());
}
