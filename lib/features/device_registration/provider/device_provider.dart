// ignore_for_file: avoid_print, use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soiltrack_mobile/core/config/supabase_config.dart';
import 'package:soiltrack_mobile/core/service/mqtt_service.dart';
import 'package:soiltrack_mobile/core/utils/loading_toast.dart';
import 'package:soiltrack_mobile/core/utils/toast_service.dart';
import 'package:soiltrack_mobile/features/auth/provider/auth_provider.dart';
import 'package:toastification/toastification.dart';
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
  final bool isResetting;
  final bool isPumpOpen;
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
    this.isResetting = false,
    this.isPumpOpen = false,
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
    bool? isResetting,
    bool? isPumpOpen,
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
      isResetting: isResetting ?? this.isResetting,
      isPumpOpen: isPumpOpen ?? this.isPumpOpen,
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
          await Future.delayed(const Duration(seconds: 5));
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

    await Future.delayed(const Duration(seconds: 30));

    try {
      final checkIfMacIsExisting = await supabase
          .from('iot_device')
          .select()
          .eq('mac_address', macAddress)
          .maybeSingle();

      if (checkIfMacIsExisting != null) {
        if (checkIfMacIsExisting['user_id'] == userId) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('device_setup_completed', true);
          await prefs.setString('mac_address', macAddress);
          print('ESP32 Connected Successfully without saving to database.');
          return;
        }
      }

      final responseSaving = await supabase.from('iot_device').insert({
        'mac_address': macAddress,
        "user_id": userId,
        "activation_date": DateTime.now().toIso8601String(),
      });

      if (responseSaving != null && responseSaving.error != null) {
        throw Exception(responseSaving.error!.message);
      }

      await getSensorCount();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('device_setup_completed', true);
      await prefs.setString('mac_address', macAddress);
      print('Device saved to database.');
    } catch (e) {
      print(e.toString());
      state = state.copyWith(isSaving: false, savingError: e.toString());
    } finally {
      state = state.copyWith(isSaving: false);
    }
  }

  Future<void> getSensorCount() async {
    final authState = ref.read(authProvider);
    final firstName = authState.userName;
    final String? macAddress = state.macAddress;

    final mqttService = MQTTService();
    await mqttService.connect();

    final responseTopic = "soiltrack/device/$macAddress/get-sensors/response";
    final publishTopic = "soiltrack/device/$macAddress/get-sensors";

    print('📡 Subscribing to response topic: $responseTopic');
    mqttService.subscribe(responseTopic);

    await Future.delayed(const Duration(seconds: 1));

    print('📤 Sending GET SENSORS request to device...');
    mqttService.publish(publishTopic, "GET SENSORS");

    try {
      final response = await mqttService.waitForResponse(responseTopic);
      final parsedResponse = jsonDecode(response);

      final activeSensors = parsedResponse['active_sensors'] as int?;

      if (activeSensors == null) {
        print("❌ No active sensors found.");
        return;
      }

      for (int i = 1; i <= activeSensors; i++) {
        final sensorName = "$firstName Sensor $i";

        await supabase.from('soil_moisture_sensors').insert({
          'mac_address': macAddress,
          'soil_moisture_name': sensorName,
          'soil_moisture_status': 'ACTIVE'
        });
      }

      print("✅ Successfully saved $activeSensors sensors to the database.");
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> checkDeviceStatus() async {
    final mqttService = MQTTService();
    await mqttService.connect();

    final prefs = await SharedPreferences.getInstance();
    final macAddress = prefs.getString('mac_address');

    if (macAddress == null) {
      print("❌ No MAC address found in storage.");
      return;
    }

    final String pingTopic = "soiltrack/device/$macAddress/ping";
    final String responseTopic = "$pingTopic/status";

    print(
        "📡 Subscribing to response topic before sending PING: $responseTopic");
    mqttService.subscribe(responseTopic);

    await Future.delayed(const Duration(seconds: 1));

    print('📤 Sending PING to device...');
    mqttService.publish(pingTopic, "PING");

    try {
      String response = await mqttService.waitForResponse(responseTopic,
          expectedMessage: "PONG");

      if (response != "PONG") {
        print("❌ Device did not respond.");
        return;
      }

      print("✅ Device is ONLINE.");
    } catch (e) {
      print("❌ Device did not respond. It might be OFFLINE.");
    }
  }

  Future<void> changeWifiConnection(BuildContext context) async {
    ToastLoadingService.showLoadingToast(context, message: 'Changing WiFi...');

    final mqttService = MQTTService();
    await mqttService.connect();

    final prefs = await SharedPreferences.getInstance();
    final macAddress = prefs.getString('mac_address');

    if (macAddress == null) {
      print("❌ No MAC address found in storage.");
      return;
    }

    final String pingTopic = "soiltrack/device/$macAddress/reset";
    final String responseTopic = "$pingTopic/status";
    mqttService.subscribe(responseTopic);

    await Future.delayed(const Duration(seconds: 1));

    print('📤 Sending RESET WIFI to device...');
    mqttService.publish(pingTopic, "RESET WIFI");

    try {
      String response = await mqttService.waitForResponse(responseTopic,
          expectedMessage: "RESET_SUCCESS");

      if (response != "RESET_SUCCESS") {
        ToastLoadingService.dismissLoadingToast(
            context, 'Device did not respond.', ToastificationType.error);
        return;
      }

      // final prefs = await SharedPreferences.getInstance();
      // await prefs.setBool('device_setup_completed', false);
      // await prefs.remove('api_key');
      // await prefs.remove('mac_address');

      ToastLoadingService.dismissLoadingToast(
          context, 'Device is reset successfully.', ToastificationType.info);
    } catch (e) {
      print("❌ Device did not respond. It might be OFFLINE.");
      ToastLoadingService.dismissLoadingToast(
          context, 'Device did not respond.', ToastificationType.error);
    }
  }

  Future<void> clearPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('device_setup_completed');
    await prefs.remove('api_key');
    await prefs.remove('mac_address');
  }

  Future<void> openPump(BuildContext context, String action) async {
    final newPumpState = !state.isPumpOpen;
    final action = newPumpState ? 'PUMP ON' : 'PUMP OFF';
    // Show loading
    ToastLoadingService.showLoadingToast(
      context,
      message: action == 'PUMP ON' ? 'Opening pump...' : 'Closing pump...',
    );

    final mqttService = MQTTService();
    await mqttService.connect();

    final prefs = await SharedPreferences.getInstance();
    final macAddress = prefs.getString('mac_address');

    if (macAddress == null) {
      ToastLoadingService.dismissLoadingToast(
          context, 'No MAC address found.', ToastificationType.error);
      return;
    }

    final pumpControlTopic = "soiltrack/device/$macAddress/pump";
    final responseTopic = "$pumpControlTopic/status";
    final expectedResponse =
        action == 'PUMP ON' ? "PUMP_OPENED" : "PUMP_CLOSED";

    mqttService.subscribe(responseTopic);

    await Future.delayed(const Duration(seconds: 1));
    mqttService.publish(pumpControlTopic, action);

    try {
      String response = await mqttService.waitForResponse(responseTopic,
          expectedMessage: expectedResponse);

      if (response == expectedResponse) {
        ToastLoadingService.dismissLoadingToast(
            context,
            'Pump ${action == 'PUMP ON' ? 'opened' : 'closed'} successfully.',
            ToastificationType.info);
        state = state.copyWith(isPumpOpen: newPumpState);
        print('Pump is open: ${state.isPumpOpen}');
      } else {
        throw Exception('Unexpected device response.');
      }
    } catch (e) {
      ToastService.showToast(
        context: context,
        message: 'Failed to ${action == 'PUMP ON' ? 'open' : 'close'} pump.',
        type: ToastificationType.error,
      );
    }
  }
}

final deviceProvider =
    NotifierProvider<DeviceNotifier, DeviceState>(() => DeviceNotifier());
