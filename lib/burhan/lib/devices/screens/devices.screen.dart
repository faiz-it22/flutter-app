import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../schema/devices.schema.dart';

class DevicesScreen extends StatefulWidget {
  const DevicesScreen({super.key}); // No longer taking authToken in constructor

  @override
  State<DevicesScreen> createState() => _DevicesScreenState();
}

class _DevicesScreenState extends State<DevicesScreen> {
  Box<DeviceData>? deviceBox;
  List<DeviceData> _localDevices = [];
  bool _isLoading = false;
  String? _token;
  bool _isCheckingAuth = true;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // 1. Check Auth Status first
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null || token.isEmpty) {
      setState(() {
        _isCheckingAuth = false;
        _token = null;
      });
      return;
    }

    // 2. If token exists, init Hive
    deviceBox = await Hive.openBox<DeviceData>('devicesBox');
    
    setState(() {
      _token = token;
      _isCheckingAuth = false;
    });
    
    _loadFromLocal();
  }

  void _loadFromLocal() {
    if (deviceBox != null) {
      setState(() {
        _localDevices = deviceBox!.values.toList();
      });
    }
  }

  Future<void> fetchAndStoreDevices() async {
    if (_token == null || deviceBox == null) return;
    
    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('https://api.a.fortesdata.com/mp/device/v1/device/getAllDevicesDynamic'),
        headers: {
          'Authorization': 'Bearer $_token', // Using internal token
          'X-User-ID': '700',
          'Content-Type': 'application/json;charset=utf-8',
        },
        body: jsonEncode({
          "Filter": {"page": 0, "limit": 1000},
          "fieldList": {
            "device": ["device_name", "city", "updated_at", "device_id", "device_status", "serial_number"],
            "device_register": ["reg_100", "reg_101"],
            "settings": ["type"]
          },
          "appliance_category": "hiu"
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> decoded = jsonDecode(response.body);
        final List<dynamic> devices = decoded['data'] ?? [];

        for (var d in devices) {
          final String dId = d['device_id']?.toString() ?? 'unknown';
          final newDevice = DeviceData()
            ..deviceId = dId
            ..deviceName = d['device_name']
            ..serialNumber = d['serial_number']
            ..city = d['city']
            ..status = d['device_status']
            ..updatedAt = d['updated_at'];
          
          await deviceBox!.put(dId, newDevice);
        }
        _loadFromLocal();
      } else if (response.statusCode == 401) {
        // Handle expired token
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Session Expired. Please Login again.")),
        );
      }
    } catch (e) {
      debugPrint("Fetch Error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. Loading state while checking SharedPreferences
    if (_isCheckingAuth) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // 2. Error state if no token found
    if (_token == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Access Denied")),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text("You must be logged in to view devices."),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Go Back"),
              )
            ],
          ),
        ),
      );
    }

    // 3. Normal UI if token exists
    return Scaffold(
      appBar: AppBar(
        title: const Text("Devices Catalog"),
        actions: [
          IconButton(icon: const Icon(Icons.sync), onPressed: fetchAndStoreDevices),
        ],
      ),
      body: Column(
        children: [
          if (_isLoading) const LinearProgressIndicator(),
          Expanded(
            child: _localDevices.isEmpty
                ? const Center(child: Text("No data. Tap Sync."))
                : ListView.builder(
                    itemCount: _localDevices.length,
                    itemBuilder: (context, index) {
                      final device = _localDevices[index];
                      return ListTile(
                        leading: const Icon(Icons.developer_board),
                        title: Text(device.deviceName ?? "Unnamed"),
                        subtitle: Text("${device.city} | ${device.status}"),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}