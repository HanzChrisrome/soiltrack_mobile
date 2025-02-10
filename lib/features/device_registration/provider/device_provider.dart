import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soiltrack_mobile/core/config/supabase_config.dart';
import 'package:soiltrack_mobile/core/utils/generate_api.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'package:wifi_scan/wifi_scan.dart';
import 'package:http/http.dart' as http;

class DeviceState {
  final List<WiFiAccessPoint> availableDevices;
  final List<WiFiAccessPoint> availableNetworks;
  final String? selectedDeviceSSID;
  final String? selectedWifiSSID;
  final String? macAddress;
  final bool isScanning;
  final bool isConnecting;
  final bool isSaving;
  final String? savingError;

  DeviceState({
    this.availableDevices = const [],
    this.availableNetworks = const [],
    this.selectedDeviceSSID,
    this.selectedWifiSSID,
    this.macAddress,
    this.isScanning = false,
    this.isConnecting = false,
    this.isSaving = false,
    this.savingError,
  });

  DeviceState copyWith({
    List<WiFiAccessPoint>? availableDevices,
    List<WiFiAccessPoint>? availableNetworks,
    String? selectedDeviceSSID,
    String? selectedWifiSSID,
    String? macAddress,
    bool? isScanning,
    bool? isConnecting,
    bool? isSaving,
    String? savingError,
  }) {
    return DeviceState(
      availableDevices: availableDevices ?? this.availableDevices,
      availableNetworks: availableNetworks ?? this.availableNetworks,
      selectedDeviceSSID: selectedDeviceSSID ?? this.selectedDeviceSSID,
      selectedWifiSSID: selectedWifiSSID ?? this.selectedWifiSSID,
      macAddress: macAddress ?? this.macAddress,
      isScanning: isScanning ?? this.isScanning,
      isConnecting: isConnecting ?? this.isConnecting,
      isSaving: isSaving ?? this.isSaving,
      savingError: savingError ?? this.savingError,
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
    await Future.delayed(const Duration(seconds: 10));
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
        WiFiForIoTPlugin.forceWifiUsage(true);
        state = state.copyWith(selectedDeviceSSID: ssid, isConnecting: false);
      } else {
        state = state.copyWith(isConnecting: false);
      }
    } catch (e) {
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
      final response = await http.post(
        Uri.parse("$esp32IP/connect"),
        body: {"ssid": ssid, "password": password},
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        String status = responseData["status"];
        String message = responseData["message"];

        if (status == "SUCCESS") {
          String macAddress = responseData["mac"];
          WiFiForIoTPlugin.forceWifiUsage(false);
          state = state.copyWith(macAddress: macAddress);
        } else {
          throw (message);
        }
      } else {
        throw Exception("Failed to connect to ESP32.");
      }
    } catch (e) {
      throw e.toString();
    } finally {
      state = state.copyWith(isConnecting: false);
    }
  }

  Future<void> saveToDatabase() async {
    state = state.copyWith(isSaving: true, savingError: null);

    final macAddress = state.macAddress;
    final userId = supabase.auth.currentUser?.id;

    if (macAddress == null) {
      state =
          state.copyWith(isSaving: false, savingError: 'No device connected.');
      return;
    }

    await Future.delayed(const Duration(minutes: 1));
    final apiKey = await ApiKeyGenerator().generate();

    try {
      const String apiUrl =
          "https://soiltrack-server.onrender.com/device/send-api-key";

      final checkIfMacIsExisting = await supabase
          .from('iot_device')
          .select()
          .eq('mac_address', macAddress)
          .maybeSingle();

      if (checkIfMacIsExisting != null) {
        throw Exception('Device already exists in the database.');
      }

      final responseFromServer = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "mac_address": macAddress,
          "api_key": apiKey,
        }),
      );

      if (responseFromServer.statusCode == 200) {
        final responseSaving = await supabase.from('iot_device').insert({
          'mac_address': macAddress,
          'api_key': apiKey,
          "user_id": userId,
          "activation_date": DateTime.now().toIso8601String(),
        });

        if (responseSaving != null && responseSaving.error != null) {
          throw Exception(responseSaving.error!.message);
        }

        print('Device saved to database.');
      } else {
        throw Exception('Failed to send data to server.');
      }
    } catch (e) {
      print(e.toString());
      state = state.copyWith(isSaving: false, savingError: e.toString());
    } finally {
      state = state.copyWith(isSaving: false);
    }
  }
}

final deviceProvider =
    NotifierProvider<DeviceNotifier, DeviceState>(() => DeviceNotifier());
