// ignore_for_file: use_build_context_synchronously
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soiltrack_mobile/core/config/supabase_config.dart';
import 'package:soiltrack_mobile/core/constants/device_constants.dart';
import 'package:soiltrack_mobile/core/service/mqtt_service.dart';
import 'package:soiltrack_mobile/core/utils/notifier_helpers.dart';
import 'package:soiltrack_mobile/core/utils/toast_service.dart';
import 'package:soiltrack_mobile/features/auth/provider/auth_provider.dart';
import 'package:soiltrack_mobile/features/device_registration/helper/device_helper.dart';
import 'package:soiltrack_mobile/features/device_registration/provider/device_provider_state.dart';
import 'package:soiltrack_mobile/features/home/provider/soil_dashboard_provider.dart';
import 'package:soiltrack_mobile/provider/soil_sensors_provider.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'package:wifi_scan/wifi_scan.dart';
import 'package:http/http.dart' as http;

class DeviceNotifier extends Notifier<DeviceState> {
  final MQTTService mqttService = MQTTService();

  @override
  DeviceState build() {
    return DeviceState();
  }

  Future<void> scanForDevices() async {
    state = state.copyWith(isScanning: true);

    try {
      await WiFiScan.instance.startScan();
      await Future.delayed(const Duration(seconds: 10));
      final accessPoints = await WiFiScan.instance.getScannedResults();
      final esp32Devices = accessPoints
          .where((ap) => ap.ssid.startsWith("ESP32_Config"))
          .toList();

      await connectToESP32(esp32Devices.first.ssid);
      state = state.copyWith(availableDevices: esp32Devices);
    } catch (e) {
      NotifierHelper.logError(e);
    } finally {
      state = state.copyWith(isScanning: false);
    }
  }

  Future<void> connectToESP32(String ssid) async {
    state = state.copyWith(isConnecting: true);
    try {
      bool isConnected =
          await WiFiForIoTPlugin.connect(ssid, withInternet: false);

      if (isConnected) {
        WiFiForIoTPlugin.forceWifiUsage(true);
        state = state.copyWith(selectedDeviceSSID: ssid);
      }
    } catch (e) {
      NotifierHelper.logError(e);
    } finally {
      state = state.copyWith(isConnecting: false);
    }
  }

  Future<void> scanForAvailableWifi() async {
    state = state.copyWith(isScanning: true);

    await WiFiScan.instance.startScan();
    final accessPoints = await WiFiScan.instance.getScannedResults();
    final wifiNetworks =
        accessPoints.where((ap) => ap.ssid.startsWith('')).toList();

    state = state.copyWith(availableNetworks: wifiNetworks, isScanning: false);
  }

  Future<void> connectESPToWiFi(String password) async {
    const String esp32IP = DeviceConstants.esp32IP;
    final ssid = state.selectedDeviceSSID;
    if (ssid == null) throw Exception('No device selected.');

    state = state.copyWith(isConnecting: true);

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
      NotifierHelper.logError(e);
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
          NotifierHelper.logMessage('Device already saved to database.');
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('device_setup_completed', true);
          await prefs.setString('mac_address', macAddress);

          // await getSensorCount();
          await soilDashboardNotifier.fetchUserPlots();
          await sensorProvider.fetchSensors();

          NotifierHelper.logMessage('Device already saved to database.');
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
      NotifierHelper.logMessage('Device saved to database.');
      state = state.copyWith(isSaving: false);
    } catch (e) {
      NotifierHelper.logError(e);
      state = state.copyWith(isSaving: false, savingError: e.toString());
    }
  }

  Future<void> getSensorCount() async {
    final authState = ref.read(authProvider);
    final firstName = authState.userName;
    final macAddress = DeviceHelper.getMacAddress();
    await mqttService.connect();

    final responseTopic = "soiltrack/device/$macAddress/get-sensors/response";
    final publishTopic = "soiltrack/device/$macAddress/get-sensors";

    try {
      final response = await mqttService.publishAndWaitForResponse(
          publishTopic, responseTopic, "GET SENSORS");
      final parsedResponse = jsonDecode(response);

      final int moistureSensors = parsedResponse['moistureSensors'] ?? 0;
      final int npkSensors = parsedResponse['npkSensors'] ?? 0;

      if (moistureSensors == 0 || npkSensors == 0) {
        debugPrint("❌ No active sensors found.");
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

      debugPrint('🌱 Sensors saved to database.');
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> checkDeviceStatus() async {
    await mqttService.connect();
    final macAddress = await DeviceHelper.getMacAddress();

    final String pingTopic = "soiltrack/device/$macAddress/ping";
    final String responseTopic = "$pingTopic/status";

    try {
      String response = await mqttService.publishAndWaitForResponse(
          pingTopic, responseTopic, "PING",
          expectedResponse: "PONG");

      if (response != "PONG") {
        NotifierHelper.logError('Device did not respond.');
        return;
      }

      NotifierHelper.logMessage('Device did not respond.');
    } catch (e) {
      NotifierHelper.logError(e);
    }
  }

  Future<bool> _openPump(BuildContext context) async {
    NotifierHelper.showLoadingToast(context, 'Opening pump');
    await mqttService.connect();
    final macAddress = await DeviceHelper.getMacAddress();

    final pumpControlTopic = "soiltrack/device/$macAddress/pump";
    final responseTopic = "$pumpControlTopic/status";
    const expectedResponse = "P_OPEN";

    return await DeviceHelper.sendMqttCommand(
        context,
        pumpControlTopic,
        responseTopic,
        "PUMP ON",
        "Pump opened successfully.",
        "Failed to open pump.",
        expectedResponse: expectedResponse);
  }

  Future<void> _closePump(BuildContext context) async {
    NotifierHelper.showSuccessToast(context, 'Closing pump...');
    await mqttService.connect();
    final macAddress = DeviceHelper.getMacAddress();

    final pumpControlTopic = "soiltrack/device/$macAddress/pump";
    final responseTopic = "$pumpControlTopic/status";
    const expectedResponse = "P_CLOSE";

    try {
      String response = await mqttService.publishAndWaitForResponse(
          pumpControlTopic, responseTopic, "PUMP OFF",
          expectedResponse: expectedResponse);

      if (response == expectedResponse) {
        NotifierHelper.showSuccessToast(context, 'Pump closed successfully.');
        state = state.copyWith(isPumpOpen: false);
      } else {
        NotifierHelper.showErrorToast(context, 'Failed to close pump.');
      }
    } catch (e) {
      NotifierHelper.logError(e, context, 'Failed to close pump.');
    }
  }

  Future<void> closeAll(BuildContext context) async {
    ToastService.showLoadingToast(context, message: 'Closing all valves.');
    await mqttService.connect();

    final macAddress = DeviceHelper.getMacAddress();
    final pumpControlTopic = "soiltrack/device/$macAddress/pump";
    final responseTopic = "$pumpControlTopic/status";
    const expectedResponse = "CLOSE";

    final success = await DeviceHelper.sendMqttCommand(
        context,
        pumpControlTopic,
        responseTopic,
        'CLOSE ALL',
        'All Valves closed.',
        'Valves did not close',
        expectedResponse: expectedResponse);

    if (success) {
      final openValves = state.valveStates.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key)
          .toList();

      debugPrint('Open valves: $openValves');
      if (openValves.isNotEmpty) {
        await supabase
            .from('irrigation_log')
            .update({'time_stopped': DateTime.now().toIso8601String()}).eq(
                'mac_address', macAddress);
      }

      state = state.copyWith(valveStates: {}, isPumpOpen: false);
    }
  }

  Future<void> openAll(BuildContext context) async {
    final userPlotState = ref.watch(soilDashboardProvider);
    NotifierHelper.showLoadingToast(context, 'Opening all valves...');

    final macAddress = DeviceHelper.getMacAddress();
    await mqttService.connect();
    final pumpControlTopic = "soiltrack/device/$macAddress/pump";
    final responseTopic = "$pumpControlTopic/status";
    mqttService.subscribe(responseTopic);

    await Future.delayed(const Duration(seconds: 1));
    mqttService.publish(pumpControlTopic, "OPEN ALL");

    final success = await DeviceHelper.sendMqttCommand(
        context,
        pumpControlTopic,
        responseTopic,
        'OPEN ALL',
        'All Valves Open',
        'Failed to open valves');

    if (success) {
      final userPlots = userPlotState.userPlots;
      if (userPlots.isEmpty) {
        NotifierHelper.showErrorToast(context, 'No plots found.');
        return;
      }

      final updatedValveStates = {
        for (var plot in userPlots) (plot['plot_id'] as int): true
      };

      state = state.copyWith(valveStates: updatedValveStates, isPumpOpen: true);

      final List<Map<String, dynamic>> logEntries = userPlots.map((plot) {
        return {
          'mac_address': macAddress,
          'plot_id': plot['plot_id'],
          'time_started': DateTime.now().toIso8601String(),
        };
      }).toList();

      await supabase.from('irrigation_log').insert(logEntries);
      NotifierHelper.logMessage('All valves opened.');
    }
  }

  Future<void> openPump(BuildContext context, String action,
      String valveTagging, int plotId) async {
    final isValveOpening = action == 'VLVE ON';
    final newValveState = isValveOpening;
    final activeValves = state.valveStates.values.where((v) => v).length;
    final fullAction = "$action $valveTagging";

    NotifierHelper.showLoadingToast(
        context,
        action == 'VLVE ON'
            ? 'Opening Pump for Valve $valveTagging.'
            : 'Closing Pump for Valve $valveTagging.');

    final macAddress = await DeviceHelper.getMacAddress();
    final pumpControlTopic = "soiltrack/device/$macAddress/pump";
    final responseTopic = "$pumpControlTopic/status";
    final expectedResponse =
        isValveOpening ? "${valveTagging}_OPEN" : "${valveTagging}_CLS";
    final successMessage =
        'Valve ${action == 'VLVE ON' ? 'opened' : 'closed'} successfully ($valveTagging).';
    final errorMessage =
        'Failed to ${action == 'VLVE ON' ? 'open' : 'close'} valve $valveTagging.';

    final success = await DeviceHelper.sendMqttCommand(
        context,
        pumpControlTopic,
        responseTopic,
        fullAction,
        successMessage,
        errorMessage,
        expectedResponse: expectedResponse);

    if (success) {
      if (isValveOpening && activeValves == 0) {
        bool pumpOpened = await _openPump(context);
        if (!pumpOpened) {
          NotifierHelper.showErrorToast(context, 'Failed to open pump.');
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

      NotifierHelper.logMessage('Valve states: $updatedValveStates');
    }
  }

  void selectDevice(String ssid) {
    state = state.copyWith(selectedDeviceSSID: ssid);
  }
}

final deviceProvider =
    NotifierProvider<DeviceNotifier, DeviceState>(() => DeviceNotifier());
