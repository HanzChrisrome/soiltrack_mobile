// ignore_for_file: use_build_context_synchronously
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soiltrack_mobile/core/config/supabase_config.dart';
import 'package:soiltrack_mobile/core/constants/device_constants.dart';
import 'package:soiltrack_mobile/core/service/mqtt_service.dart';
import 'package:soiltrack_mobile/core/utils/notifier_helpers.dart';
import 'package:soiltrack_mobile/core/utils/toast_service.dart';
import 'package:soiltrack_mobile/features/auth/provider/auth_provider.dart';
import 'package:soiltrack_mobile/features/device_registration/helper/device_helper.dart';
import 'package:soiltrack_mobile/features/device_registration/provider/device_provider_state.dart';
import 'package:soiltrack_mobile/features/home/provider/soil_dashboard/soil_dashboard_provider.dart';
import 'package:soiltrack_mobile/features/home/provider/hardware_provider/soil_sensors_provider.dart';
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
      await Future.delayed(const Duration(seconds: 5));
      final accessPoints = await WiFiScan.instance.getScannedResults();
      final esp32Devices = accessPoints
          .where((ap) => ap.ssid.startsWith("ESP32_Config"))
          .toList();

      if (esp32Devices.isEmpty) {
        throw ('No ESP32 devices found.');
      }

      await connectToESP32(esp32Devices.first.ssid);
      state = state.copyWith(availableDevices: esp32Devices);
    } catch (e) {
      NotifierHelper.logError(e);
      rethrow;
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
    final wifiNetworks = accessPoints
        .where((ap) => !ap.ssid.startsWith('ESP32_Config'))
        .toList();

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

  Future<void> saveToDatabase(BuildContext context) async {
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
          await mqttService.connect();

          // await checkDeviceStatus();
          NotifierHelper.logMessage('Device already saved to database.');
          state = state.copyWith(isSaving: false);
          return;
        } else {
          context.pushNamed('device-exists');
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

      // await checkDeviceStatus();
      NotifierHelper.logMessage('Device saved to database.');
      state = state.copyWith(isSaving: false);
    } catch (e) {
      NotifierHelper.logError(e);
      state = state.copyWith(isSaving: false, savingError: e.toString());
    }
  }

  Future<bool> checkDeviceStatus(BuildContext context) async {
    final authState = ref.watch(authProvider);
    final macAddress = authState.macAddress;

    final responseTopic = "soiltrack/device/$macAddress/check-device/response";
    final publishTopic = "soiltrack/device/$macAddress/check-device";
    final nanoTopic = "soiltrack/device/$macAddress/check-nano";
    final nanoResponseTopic =
        "soiltrack/device/$macAddress/check-nano/response";

    try {
      NotifierHelper.showLoadingToast(context, 'Checking ESP32 connection');
      final response = await mqttService.publishAndWaitForResponse(
          publishTopic, responseTopic, "CHECK DEVICE",
          expectedResponse: "PONG");

      if (response != "PONG") {
        NotifierHelper.showErrorToast(context, 'ESP32 is not connected.');
        state = state.copyWith(isEspConnected: false);
        return false;
      }

      final nanoResponse = await mqttService.publishAndWaitForResponse(
          nanoTopic, nanoResponseTopic, "CHECK NANO",
          expectedResponse: "NANO_PONG");

      if (nanoResponse != "NANO_PONG") {
        NotifierHelper.showErrorToast(context, 'NANO is not connected.');
        state = state.copyWith(isNanoConnected: false);
      }

      state = state.copyWith(isEspConnected: true, isNanoConnected: true);
      return true;
    } catch (e) {
      NotifierHelper.logError(e);
      return false;
    } finally {
      NotifierHelper.closeToast(context);
    }
  }

  Future<void> checkSensorsStatus() async {
    //Check the number of devices associated with the user account first

    //If the user has no device, then return

    //If the user has a device, check the number of moisture sensors associated with the account

    //If the user has a device, check the number of nutrient sensors associated with the account

    //Request to the ESP32 to get the number of soil moisture devices connected to it

    //Request to the ESP32 to get the number of soil nutrient devices connected to it

    //If the number of devices connected to the ESP32 is not equal to the number of devices associated with the user account, then add a warning
  }

  Future<void> checkValveStatus() async {}

  Future<bool> _openPump(BuildContext context) async {
    NotifierHelper.showLoadingToast(context, 'Opening pump');
    await mqttService.connect();
    final macAddress = ref.watch(authProvider).macAddress;

    if (!state.isEspConnected) {
      NotifierHelper.showErrorToast(context, 'No device connected.');
      return false;
    }

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
    NotifierHelper.showLoadingToast(context, 'Closing pump...');
    await mqttService.connect();
    final macAddress = ref.watch(authProvider).macAddress;

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

    final macAddress = ref.watch(authProvider).macAddress;
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
                'mac_address', macAddress as Object);
      }

      state = state.copyWith(valveStates: {}, isPumpOpen: false);
    }
  }

  Future<void> openAll(BuildContext context) async {
    final userPlotState = ref.watch(soilDashboardProvider);
    NotifierHelper.showLoadingToast(context, 'Opening all valves...');

    final macAddress = ref.watch(authProvider).macAddress;
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
    }
  }

  Future<void> openPump(BuildContext context, String action,
      String valveTagging, int plotId) async {
    if (!state.isEspConnected) {
      NotifierHelper.showErrorToast(
          context, 'Your SoilTracker is not connected.');
      return;
    }
    final isValveOpening = action == 'VLVE ON';
    final newValveState = isValveOpening;
    final activeValves = state.valveStates.values.where((v) => v).length;
    final fullAction = "$action $valveTagging";

    NotifierHelper.showLoadingToast(
        context,
        action == 'VLVE ON'
            ? 'Opening Pump for Valve $valveTagging.'
            : 'Closing Pump for Valve $valveTagging.');

    final macAddress = ref.watch(authProvider).macAddress;
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
            .eq('mac_address', macAddress!)
            .eq('plot_id', plotId);
      }

      NotifierHelper.logMessage('Valve states: $updatedValveStates');
    }
  }

  Future<void> changeWifi(BuildContext context) async {
    final userMacAddress = ref.watch(authProvider).macAddress;

    NotifierHelper.showLoadingToast(context, 'Resetting device. Please wait');

    await mqttService.connect();
    final resetDeviceTopic = "soiltrack/device/$userMacAddress/reset";
    final responseTopic = "$resetDeviceTopic/status";

    final success = await DeviceHelper.sendMqttCommand(
        context,
        resetDeviceTopic,
        responseTopic,
        'RESET DEVICE',
        'Device reset successfully.',
        'Failed to reset device',
        expectedResponse: 'DEVICE RESET');

    if (success) {
      NotifierHelper.closeToast(context);
      state = state.copyWith(isEspConnected: false, isNanoConnected: false);
      context.pushNamed('wifi-scan');
    }
  }

  Future<void> disconnectWifi(BuildContext context) async {
    final userMacAddress = ref.watch(authProvider).macAddress;

    NotifierHelper.showLoadingToast(
        context, 'Disconnecting device. Please wait');

    await mqttService.connect();
    final resetDeviceTopic = "soiltrack/device/$userMacAddress/reset";
    final responseTopic = "$resetDeviceTopic/status";

    final success = await DeviceHelper.sendMqttCommand(
        context,
        resetDeviceTopic,
        responseTopic,
        'RESET DEVICE',
        'Device reset successfully.',
        'Failed to reset device',
        expectedResponse: 'DEVICE RESET');

    if (!success) {
      NotifierHelper.showSuccessToast(context, 'Device error');
      return;
    }

    NotifierHelper.showSuccessToast(
        context, 'Device disconnected successfully.');
    state = state.copyWith(isEspConnected: false, isNanoConnected: false);
  }

  void selectDevice(String ssid) {
    state = state.copyWith(selectedDeviceSSID: ssid);
  }

  void resetPreferences() {
    final prefs = SharedPreferences.getInstance();
    prefs.then((value) {
      value.remove('device_setup_completed');
      value.remove('mac_address');
    });
  }
}

final deviceProvider =
    NotifierProvider<DeviceNotifier, DeviceState>(() => DeviceNotifier());
