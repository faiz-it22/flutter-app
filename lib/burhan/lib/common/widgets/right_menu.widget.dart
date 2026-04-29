import 'package:flutter/material.dart';

class RightMenu extends StatelessWidget {
  const RightMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) => print('Selected: $value'),
      itemBuilder: (BuildContext context) {
        return {'Login', 'Bluetooth Devices', 'Show Devices'}.map((String choice) {
          return PopupMenuItem<String>(
            value: choice,
            child: Text(choice),
          );
        }).toList();
      },
    );
  }
}