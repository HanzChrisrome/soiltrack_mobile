import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi_scan/wifi_scan.dart';

class DeviceState {
  final List<WiFiAccessPoint> availableDevices;
  final String? selectedDeviceSSID;
  final bool isScanning;
  final bool isConnecting;
  final bool isConnected;

  DeviceState({
    this.availableDevices = const [],
    this.selectedDeviceSSID,
    this.isScanning = false,
    this.isConnecting = false,
    this.isConnected = false,
  });

  DeviceState copyWith({
    List<WiFiAccessPoint>? availableDevices,
    String? selectedDeviceSSID,
    bool? isScanning,
    bool? isConnecting,
    bool? isConnected,
  }) {
    return DeviceState(
      availableDevices: availableDevices ?? this.availableDevices,
      selectedDeviceSSID: selectedDeviceSSID ?? this.selectedDeviceSSID,
      isScanning: isScanning ?? this.isScanning,
      isConnecting: isConnecting ?? this.isConnecting,
      isConnected: isConnected ?? this.isConnected,
    );
  }
}

class DeviceNotifier extends Notifier<DeviceState> {
  @override
  DeviceState build() {
    return DeviceState();
  }

  Future<void> scanForDevices() async {
    state = state.copyWith(isScanning: true);
    final accessPoints = await WiFiScan.instance.getScannedResults();
  }
}
