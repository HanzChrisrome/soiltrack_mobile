// ignore_for_file: avoid_print, use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soiltrack_mobile/core/config/supabase_config.dart';
import 'package:soiltrack_mobile/core/service/mqtt_service.dart';
import 'package:soiltrack_mobile/core/utils/loading_toast.dart';
import 'package:soiltrack_mobile/features/auth/provider/auth_provider.dart';
import 'package:soiltrack_mobile/features/home/provider/soil_dashboard_provider.dart';
import 'package:soiltrack_mobile/provider/soil_sensors_provider.dart';
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
  final Map<int, bool> valveStates;
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
    this.valveStates = const {},
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
    Map<int, bool>? valveStates,
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
      valveStates: valveStates ?? this.valveStates,
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
    print('Access point $accessPoints');
    final esp32Devices =
        accessPoints.where((ap) => ap.ssid.startsWith("ESP32_Config")).toList();

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
    print('Scanning wifi');

    await WiFiScan.instance.startScan();
    await Future.delayed(const Duration(seconds: 5));

    final accessPoints = await WiFiScan.instance.getScannedResults();
    final wifiNetworks =
        accessPoints.where((ap) => ap.ssid.startsWith('')).toList();

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
    if (state.isSaving) return;
    final soilDashboardNotifier = ref.read(soilDashboardProvider.notifier);
    final sensorProvider = ref.read(sensorsProvider.notifier);
    state = state.copyWith(isSaving: true, savingError: null);

    final macAddress = state.macAddress;
    final userId = supabase.auth.currentUser?.id;

    if (macAddress == null) {
      state =
          state.copyWith(isSaving: false, savingError: 'No device connected.');
      return;
    }

    await Future.delayed(const Duration(seconds: 15));

    try {
      final checkIfMacIsExisting = await supabase
          .from('iot_device')
          .select()
          .eq('mac_address', macAddress)
          .maybeSingle();

      if (checkIfMacIsExisting != null) {
        if (checkIfMacIsExisting['user_id'] == userId) {
          print('Device already saved to database.');
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('device_setup_completed', true);
          await prefs.setString('mac_address', macAddress);

          // await getSensorCount();
          await soilDashboardNotifier.fetchUserPlots();
          await sensorProvider.fetchSensors();

          print('ESP32 Connected Successfully without saving to database.');
          state = state.copyWith(isSaving: false);
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

      // await getSensorCount();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('device_setup_completed', true);
      await prefs.setString('mac_address', macAddress);
      print('Device saved to database.');
      state = state.copyWith(isSaving: false);
    } catch (e) {
      print(e.toString());
      state = state.copyWith(isSaving: false, savingError: e.toString());
    }
  }

  Future<void> getSensorCount() async {
    final authState = ref.read(authProvider);
    final firstName = authState.userName;
    final prefs = await SharedPreferences.getInstance();
    final macAddress = prefs.getString('mac_address');

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

      final int moistureSensors = parsedResponse['moistureSensors'] ?? 0;
      final int npkSensors = parsedResponse['npkSensors'] ?? 0;

      if (moistureSensors == 0 || npkSensors == 0) {
        print("❌ No active sensors found.");
        return;
      }

      List<Map<String, dynamic>> sensorRecords = [];

      for (int i = 1; i <= moistureSensors; i++) {
        sensorRecords.add({
          'mac_address': macAddress,
          'sensor_name': "$firstName Moisture Sensor $i",
          'sensor_status': 'ACTIVE',
          'sensor_type': 'moisture$i',
          'sensor_category': 'Moisture Sensor'
        });
      }

      for (int i = 1; i <= npkSensors; i++) {
        sensorRecords.add({
          'mac_address': macAddress,
          'sensor_name': '$firstName NPK Sensor $i',
          'sensor_status': 'ACTIVE',
          'sensor_type': 'npk$i',
          'sensor_category': 'NPK Sensor'
        });
      }

      print('🌱 Sensors saved to database.');
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

      context.pushNamed('wifi-scan');
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

  Future<bool> _openPump(BuildContext context) async {
    ToastLoadingService.showLoadingToast(
      context,
      message: 'Opening Pump...',
    );

    final mqttService = MQTTService();
    await mqttService.connect();

    final prefs = await SharedPreferences.getInstance();
    final macAddress = prefs.getString('mac_address');

    if (macAddress == null) {
      ToastLoadingService.dismissLoadingToast(
        context,
        'No MAC address found.',
        ToastificationType.error,
      );
      return false;
    }

    final pumpControlTopic = "soiltrack/device/$macAddress/pump";
    final responseTopic = "$pumpControlTopic/status";
    const expectedResponse = "P_OPEN";

    mqttService.subscribe(responseTopic);
    await Future.delayed(const Duration(seconds: 1));
    mqttService.publish(pumpControlTopic, "PUMP ON");

    try {
      String response = await mqttService.waitForResponse(responseTopic,
          expectedMessage: expectedResponse);

      if (response == expectedResponse) {
        ToastLoadingService.dismissLoadingToast(
          context,
          'Pump opened successfully!',
          ToastificationType.info,
        );

        state = state.copyWith(isPumpOpen: true);
        return true;
      } else {
        ToastLoadingService.dismissLoadingToast(
            context, 'Pump did not open', ToastificationType.error);
        return false;
      }
    } catch (e) {
      ToastLoadingService.dismissLoadingToast(
          context, 'Pump did not open', ToastificationType.error);
      return false;
    }
  }

  Future<void> _closePump(BuildContext context) async {
    ToastLoadingService.showLoadingToast(context, message: 'Closing pump...');

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
    const expectedResponse = "P_CLOSE";

    mqttService.subscribe(responseTopic);
    await Future.delayed(const Duration(seconds: 1));
    mqttService.publish(pumpControlTopic, "PUMP OFF");

    try {
      String response = await mqttService.waitForResponse(responseTopic,
          expectedMessage: expectedResponse);

      if (response == expectedResponse) {
        ToastLoadingService.dismissLoadingToast(
          context,
          'Pump closed successfully!',
          ToastificationType.info,
        );

        state = state.copyWith(isPumpOpen: false);
      } else {
        ToastLoadingService.dismissLoadingToast(
            context, 'Pump did not close', ToastificationType.error);
      }
    } catch (e) {
      ToastLoadingService.dismissLoadingToast(
          context, 'Pump did not close', ToastificationType.error);
    }
  }

  Future<void> closeAll(BuildContext context) async {
    ToastLoadingService.showLoadingToast(context,
        message: 'Closing all valves.');

    final mqttService = MQTTService();
    await mqttService.connect();

    final prefs = await SharedPreferences.getInstance();
    final macAddress = prefs.getString('mac_address');

    if (macAddress == null) {
      ToastLoadingService.dismissLoadingToast(
        context,
        'No MAC address found.',
        ToastificationType.error,
      );
      return;
    }

    final pumpControlTopic = "soiltrack/device/$macAddress/pump";
    final responseTopic = "$pumpControlTopic/status";
    const expectedResponse = "CLOSE";

    mqttService.subscribe(responseTopic);
    await Future.delayed(const Duration(seconds: 1));
    mqttService.publish(pumpControlTopic, "CLOSE ALL");

    try {
      String response = await mqttService.waitForResponse(responseTopic,
          expectedMessage: expectedResponse);

      if (response == expectedResponse) {
        ToastLoadingService.dismissLoadingToast(
          context,
          'All valves and pump closed successfully.',
          ToastificationType.info,
        );

        final openValves = state.valveStates.entries
            .where((entry) => entry.value)
            .map((entry) => entry.key)
            .toList();

        print('Open valves: $openValves');
        if (openValves.isNotEmpty) {
          await supabase
              .from('irrigation_log')
              .update({'time_stopped': DateTime.now().toIso8601String()}).eq(
                  'mac_address', macAddress);
        }

        state = state.copyWith(valveStates: {}, isPumpOpen: false);
      } else {
        ToastLoadingService.dismissLoadingToast(
            context, 'Valves did not close', ToastificationType.error);
      }
    } catch (e) {
      ToastLoadingService.dismissLoadingToast(
          context, 'Valves did not close', ToastificationType.error);
    }
  }

  Future<void> openAll(BuildContext context) async {
    final userPlotState = ref.watch(soilDashboardProvider);

    ToastLoadingService.showLoadingToast(context,
        message: 'Opening the pump and all valves.');

    final prefs = await SharedPreferences.getInstance();
    final macAddress = prefs.getString('mac_address');

    final mqttService = MQTTService();
    await mqttService.connect();

    final pumpControlTopic = "soiltrack/device/$macAddress/pump";
    final responseTopic = "$pumpControlTopic/status";

    mqttService.subscribe(responseTopic);
    await Future.delayed(const Duration(seconds: 1));

    mqttService.publish(pumpControlTopic, "OPEN ALL");

    try {
      String response = await mqttService.waitForResponse(responseTopic,
          expectedMessage: "OPEN");

      if (response == "OPEN") {
        final userPlots = userPlotState.userPlots;

        if (userPlots.isEmpty) {
          ToastLoadingService.dismissLoadingToast(
              context, 'No plots found.', ToastificationType.error);
          return;
        }

        final updatedValveStates = {
          for (var plot in userPlots) (plot['plot_id'] as int): true
        };

        state = state.copyWith(
          valveStates: updatedValveStates,
          isPumpOpen: true,
        );

        final List<Map<String, dynamic>> logEntries = userPlots.map((plot) {
          return {
            'mac_address': macAddress,
            'plot_id': plot['plot_id'],
            'time_started': DateTime.now().toIso8601String(),
          };
        }).toList();

        await supabase.from('irrigation_log').insert(logEntries);
        print('All valves opened and saved: $logEntries');

        ToastLoadingService.dismissLoadingToast(
          context,
          'Pump and all valves opened successfully.',
          ToastificationType.info,
        );
      } else {
        ToastLoadingService.dismissLoadingToast(
            context, 'Error in saving', ToastificationType.error);
      }
    } catch (e) {
      ToastLoadingService.dismissLoadingToast(
          context, 'Error in everything', ToastificationType.error);
    }
  }

  Future<void> openPump(BuildContext context, String action,
      String valveTagging, int plotId) async {
    final isValveOpening = action == 'VLVE ON';
    final newValveState = isValveOpening;
    final activeValves = state.valveStates.values.where((v) => v).length;
    final fullAction = "$action $valveTagging";

    ToastLoadingService.showLoadingToast(
      context,
      message: action == 'VLVE ON'
          ? 'Opening Pump for Valve $valveTagging.'
          : 'Closing Pump for Valve $valveTagging.',
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
        isValveOpening ? "${valveTagging}_OPEN" : "${valveTagging}_CLS";

    mqttService.subscribe(responseTopic);
    await Future.delayed(const Duration(seconds: 1));
    mqttService.publish(pumpControlTopic, fullAction);

    try {
      String response = await mqttService.waitForResponse(responseTopic,
          expectedMessage: expectedResponse);

      if (response == expectedResponse) {
        ToastLoadingService.dismissLoadingToast(
          context,
          'Valve ${action == 'VLVE ON' ? 'opened' : 'closed'} successfully ($valveTagging).',
          ToastificationType.info,
        );

        if (isValveOpening && activeValves == 0) {
          bool pumpOpened = await _openPump(context);
          if (!pumpOpened) {
            ToastLoadingService.dismissLoadingToast(
              context,
              'Failed to open pump. Valve cannot be opened.',
              ToastificationType.error,
            );
            return;
          }
        }

        final updatedValveStates = Map<int, bool>.from(state.valveStates);
        updatedValveStates[plotId] = newValveState;

        state = state.copyWith(valveStates: updatedValveStates);

        final remainingOpenValves =
            updatedValveStates.values.where((v) => v).length;
        if (remainingOpenValves == 0) {
          await _closePump(context);
        }

        //SAVE TO DB
        if (isValveOpening) {
          await supabase.from('irrigation_log').insert({
            'mac_address': macAddress,
            'plot_id': plotId,
            'time_started': DateTime.now().toIso8601String(),
          });
        } else {
          await supabase
              .from('irrigation_log')
              .update({
                'time_stopped': DateTime.now().toIso8601String(),
              })
              .eq('mac_address', macAddress)
              .eq('plot_id', plotId);
        }

        print('Valve states: $updatedValveStates');
      } else {
        ToastLoadingService.dismissLoadingToast(
            context, 'Valve did not open', ToastificationType.error);
      }
    } catch (e) {
      ToastLoadingService.dismissLoadingToast(
          context, 'Valve did not open', ToastificationType.error);
    }
  }
}

final deviceProvider =
    NotifierProvider<DeviceNotifier, DeviceState>(() => DeviceNotifier());
