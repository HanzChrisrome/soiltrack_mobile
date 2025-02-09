import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'package:wifi_scan/wifi_scan.dart';
import 'package:http/http.dart' as http;

class DeviceState {
  final List<WiFiAccessPoint> availableDevices;
  final List<WiFiAccessPoint> availableNetworks;
  final String? selectedDeviceSSID;
  final String? selectedWifiSSID;
  final bool isScanning;
  final bool isConnecting;
  final bool isConnected;

  DeviceState({
    this.availableDevices = const [],
    this.availableNetworks = const [],
    this.selectedDeviceSSID,
    this.selectedWifiSSID,
    this.isScanning = false,
    this.isConnecting = false,
    this.isConnected = false,
  });

  DeviceState copyWith({
    List<WiFiAccessPoint>? availableDevices,
    List<WiFiAccessPoint>? availableNetworks,
    String? selectedDeviceSSID,
    String? selectedWifiSSID,
    bool? isScanning,
    bool? isConnecting,
    bool? isConnected,
  }) {
    return DeviceState(
      availableDevices: availableDevices ?? this.availableDevices,
      availableNetworks: availableNetworks ?? this.availableNetworks,
      selectedDeviceSSID: selectedDeviceSSID ?? this.selectedDeviceSSID,
      selectedWifiSSID: selectedWifiSSID ?? this.selectedWifiSSID,
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

    await WiFiScan.instance.startScan();
    await Future.delayed(const Duration(seconds: 3));
    final accessPoints = await WiFiScan.instance.getScannedResults();
    final esp32Devices =
        accessPoints.where((ap) => ap.ssid.startsWith("ESP32")).toList();

    if (esp32Devices.isEmpty) {
      state = state.copyWith(isScanning: false);
      throw Exception('No ESP32 devices found.');
    }

    await connectToESP32(esp32Devices.first.ssid);
    state = state.copyWith(availableDevices: esp32Devices, isScanning: false);
  }

  Future<void> connectToESP32(String ssid) async {
    state = state.copyWith(isConnecting: true);

    try {
      bool isConnected = await WiFiForIoTPlugin.connect(
        ssid,
        withInternet: false,
      );

      if (isConnected) {
        print('Successfully connected to $ssid!');

        WiFiForIoTPlugin.forceWifiUsage(true);
        state = state.copyWith(
            selectedDeviceSSID: ssid, isConnected: true, isConnecting: false);
      } else {
        print('Failed to connect to $ssid.');
        state = state.copyWith(isConnecting: false);
      }
    } catch (e) {
      print('Error connecting to $ssid: $e');
      state = state.copyWith(isConnecting: false);
    }
  }

  Future<void> scanForAvailableWifi() async {
    state = state.copyWith(isScanning: true);

    await Future.delayed(const Duration(seconds: 5));

    final accessPoints = await WiFiScan.instance.getScannedResults();
    final wifiNetworks =
        accessPoints.where((ap) => ap.ssid.startsWith("")).toList();

    state = state.copyWith(availableNetworks: wifiNetworks, isScanning: false);
  }

  void selectDevice(String ssid) {
    state = state.copyWith(selectedDeviceSSID: ssid);
  }

  Future<void> connectESPToWiFi(String password) async {
    const String esp32IP = "http://192.168.4.1";
    final ssid = state.selectedDeviceSSID;

    state = state.copyWith(isConnecting: true);

    if (ssid == null) {
      state = state.copyWith(isConnecting: false);
      throw Exception('No device selected.');
    }

    try {
      // Send WiFi credentials to ESP32
      final response = await http.post(
        Uri.parse("$esp32IP/connect"),
        body: {"ssid": ssid, "password": password},
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        String status = responseData["status"];
        String message = responseData["message"];

        if (status == "FAILED") throw (message);
      } else {
        throw Exception("Failed to connect to ESP32.");
      }
    } catch (e) {
      throw e.toString();
    } finally {
      state = state.copyWith(isConnecting: false);
    }
  }
}

final deviceProvider =
    NotifierProvider<DeviceNotifier, DeviceState>(() => DeviceNotifier());
