import 'package:flutter/material.dart';
import 'package:fourt_app/common/widgets/left_menu.widget.dart';
import 'package:fourt_app/common/widgets/right_menu.widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: LeftMenu(),
      appBar: AppBar(
        centerTitle: true, 
        title: const Text('Fortes Demo'),
        actions: [RightMenu(),],
      ),
      body: const Center(
        child: Text(
          'Welcome to the Demo',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}