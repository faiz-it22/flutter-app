
import 'package:flutter/material.dart';
import 'package:fourt_app/auth/screens/login.screen.dart';
import 'package:fourt_app/bluetooth/screens/bluetooth.screen.dart';
import 'package:fourt_app/devices/screens/devices.screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LeftMenu extends StatefulWidget {
  const LeftMenu({super.key});


  @override
  State<LeftMenu> createState() => _LeftMenuState();
}

class _LeftMenuState extends State<LeftMenu> {
  bool _isLoggedIn = false;

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    
    setState(() {
      _isLoggedIn = token != null && token.isNotEmpty;
    });
  }

  Future<void> _handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    setState(() {
      _isLoggedIn = false;
    });
    if (mounted) Navigator.pop(context); // Close Drawer
  }

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme; 
    return Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: colorScheme.primary),
              child: Center(
                child: Text(
                _isLoggedIn? 'Welcome Back': 'Not logged In',
                style: TextStyle(color: Colors.white, fontSize: 24))),
            ),
            if (!_isLoggedIn)
              ListTile(
                leading: const Icon(Icons.login),
                title: const Text('Login'),
                onTap: () async {
                  Navigator.pop(context);
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                  _checkLoginStatus();
                },
              )
            else ...[
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Logout', style: TextStyle(color: Colors.red)),
                onTap: _handleLogout,
              ),
              ListTile(
                leading: const Icon(Icons.search_outlined),
                title: const Text('Scan Bluetooth Devices'),
                onTap: () async {
                  Navigator.pop(context);
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const BluetoothScreen())
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.list_outlined),
                title: const Text('List Devices'),
                onTap: () async {
                  Navigator.pop(context);
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const DevicesScreen())
                  );
                }
              ),
            ]
          ],
        ),
    ); 
  }
}