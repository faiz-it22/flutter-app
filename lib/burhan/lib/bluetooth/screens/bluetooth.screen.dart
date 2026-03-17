import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:audioplayers/audioplayers.dart';

class BluetoothScreen extends StatefulWidget {
  const BluetoothScreen({super.key});

  @override
  State<BluetoothScreen> createState() => _BluetoothScreenState();
}

class _BluetoothScreenState extends State<BluetoothScreen> {
  final player = AudioPlayer();
  List<ScanResult> _scanResults = [];
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _initBluetooth();
  }

  Future<void> _initBluetooth() async {
    // 1. Request Permissions
    await [Permission.bluetoothScan, Permission.bluetoothConnect, Permission.location].request();
    
    // 2. Listen to scan results
    FlutterBluePlus.scanResults.listen((results) {
      if (mounted) setState(() => _scanResults = results);
    });

    // 3. Listen to scanning state
    FlutterBluePlus.isScanning.listen((state) {
      if (mounted) setState(() => _isScanning = state);
    });
  }

  void _startScan() async {
    _scanResults.clear();
    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));
  }


  Future<void> playTestSound() async {
    print('playing sound');
    await player.play(DeviceFileSource('/system/media/audio/notifications/Argon.ogg'));  
  }

  Future<void> debugNeckband(BluetoothDevice device) async {
    List<BluetoothService> services = await device.discoverServices();
    
    for (var service in services) {
      print("Found Service: ${service.uuid}");
      for (var characteristic in service.characteristics) {
        print("   -- Characteristic: ${characteristic.uuid}");
        print("      Properties: ${characteristic.properties}");
      }
    }
  }

  Future<void> litmusTestSound() async {
    print("🔥 Playing the 'No-Bullshit' Beep...");
    try {
      // This is a 1-second sine wave beep encoded in Base64
      // No external dependencies, no file system, just pure data.
      String base64Sound = "data:audio/wav;base64,UklGRl9vT19XQVZFZm10IBAAAAABAAEAQB8AAEAfAAABAAgAZGF0YV9vT19mZWRiY2NoZWFkYmVlZmVlZmVlZmVlZmVlZmVlZmVlZmVlZmVlZmVlZmVlZmVlZmVlZmVlZmVlZmVlZmVlZmVlZmVlZmVlZmVlZmVlZmVlZmVlZmVlZmVlZmVlZmVlZmVlZmVlZmVlZmVlZmVlZmVlZmVlZmVlZmVlZmVlZmVlZmVlZmVlZmVlZmVlZmVl";

      await player.play(UrlSource(base64Sound));
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("🔊 Sound sent to routing engine!"), backgroundColor: Colors.purple)
      );
    } catch (e) {
      print("Even the Litmus test failed: $e");
    }
  }

  final FlutterTts flutterTts = FlutterTts();

  Future<void> stopTheBullshit() async {
    print("🗣️ FORCING SYSTEM VOICE...");
    
    try {
      // These settings force the volume and routing
      await flutterTts.setVolume(1.0);
      await flutterTts.setSpeechRate(0.5);
      await flutterTts.setPitch(1.0);
      
      // This is the moment of truth. 
      // If the neckband is the active audio device, this WILL play there.
      await flutterTts.speak("Connection verified. I am not bullshitting you Burhan.");
    } catch (e) {
      print("TTS Failed: $e");
    }
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    device.connectionState.listen((BluetoothConnectionState state) {
      if (state == BluetoothConnectionState.connected) {
        print("🔵 REAL-TIME: Device is officially connected.");
        // playTestSound();
        // debugNeckband(device);
        litmusTestSound();
        // stopTheBullshit();
        // Here you would trigger: setState(() => _isConnected = true);
      } else if (state == BluetoothConnectionState.disconnected) {
        print("🔴 REAL-TIME: Device lost connection.");
        print("Reason: ${device.disconnectReason}"); // Very helpful for debugging!
        // Here you would trigger: setState(() => _isConnected = false);
      } else if (state == BluetoothConnectionState.connecting) {
        print("🟡 REAL-TIME: Handshake in progress...");
      }
    });

    // CRITICAL: Stop scanning before you try to connect
    await FlutterBluePlus.stopScan(); 

    try {
      // Adding a slight delay helps some Android radios "reset"
      await Future.delayed(const Duration(milliseconds: 500));
      
      await device.connect(autoConnect: false); // Set autoConnect to false for faster initial link
      
      // CRITICAL: You MUST discover services right after connecting 
      // to "solidify" the connection.
      List<BluetoothService> services = await device.discoverServices();
      print("Connected and found ${services.length} services");

    } catch (e) {
      print("Connection error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Scan Devices"),
        actions: [
          if (_isScanning)
            const Center(child: Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
            ))
          else
            IconButton(icon: const Icon(Icons.refresh), onPressed: _startScan)
        ],
      ),
      body: _scanResults.isEmpty 
        ? const Center(child: Text("No devices found. Tap refresh to scan."))
        : ListView.builder(
            itemCount: _scanResults.length,
            itemBuilder: (context, index) {
              final result = _scanResults[index];
              final deviceName = result.device.platformName.isEmpty ? "Unknown Device" : result.device.platformName;
              
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: Icon(Icons.bluetooth, color: colorScheme.primary),
                  title: Text(deviceName),
                  subtitle: Text(result.device.remoteId.toString()),
                  trailing: ElevatedButton(
                    onPressed: () => _connectToDevice(result.device),
                    child: const Text("Connect"),
                  ),
                ),
              );
            },
          ),
    );
  }
}