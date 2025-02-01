import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi_scan/wifi_scan.dart';

final wifiProvider = StateProvider<List<WiFiAccessPoint>>((ref) => []);

class WifiScanScreen extends ConsumerStatefulWidget {
  const WifiScanScreen({super.key});

  @override
  _WifiScanScreenState createState() => _WifiScanScreenState();
}

class _WifiScanScreenState extends ConsumerState<WifiScanScreen> {
  bool isScanning = false;

  Future<void> scanForESP32() async {
    setState(() => isScanning = true);

    final accessPoints = await WiFiScan.instance.getScannedResults();

    final esp32Networks =
        accessPoints.where((ap) => ap.ssid.startsWith("ESP32-")).toList();

    ref.read(wifiProvider.notifier).state = esp32Networks;
    setState(() => isScanning = false);
  }

  @override
  Widget build(BuildContext context) {}
}
