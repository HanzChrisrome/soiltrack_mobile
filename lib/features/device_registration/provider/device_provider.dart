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

  Future<bool> connectESPToWiFi(String password) async {
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
          return true;
        } else {
          await Future.delayed(const Duration(seconds: 5));
          throw (message);
        }
      } else {
        throw Exception("Failed to connect to ESP32.");
      }
    } catch (e) {
      throw Exception("${e.toString()}");
    } finally {
      state = state.copyWith(isConnecting: false);
    }
  }

  Future<void> saveToDatabase(BuildContext context) async {
    if (state.isSaving) return;
    state = state.copyWith(isSaving: true, savingError: null);

    final macAddress = state.macAddress;
    final userId = supabase.auth.currentUser?.id;

    if (macAddress == null) {
      state =
          state.copyWith(isSaving: false, savingError: 'No device connected.');
      return;
    }

    try {
      final initializer = DeviceHelper(ref);

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

          await initializer.initializeAll(context, macAddress);
          await checkDeviceStatus(context);

          state = state.copyWith(isSaving: false);
          context.go('/home/device-screen');
        } else {
          context.pushNamed('device-exists');
        }
      } else {
        final responseSaving = await supabase.from('iot_device').insert({
          'mac_address': macAddress,
          "user_id": userId,
          "activation_date": DateTime.now().toIso8601String(),
        });

        if (responseSaving != null && responseSaving.error != null) {
          throw Exception(responseSaving.error!.message);
        }

        await initializer.initializeAll(context, macAddress);
        await checkDeviceStatus(context);
        state = state.copyWith(isSaving: false);
        context.go('/home');
      }
    } catch (e) {
      NotifierHelper.logError(e);
      state = state.copyWith(isSaving: false, savingError: e.toString());
    }
  }

  Future<bool> checkDeviceStatus(BuildContext context) async {
    final authState = ref.watch(authProvider);
    final macAddress = state.macAddress ?? authState.macAddress;
    if (macAddress == null) {
      NotifierHelper.showErrorToast(context, 'No device connected.');
      return false;
    }

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

      await Future.delayed(const Duration(seconds: 1));

      final nanoResponse = await mqttService.publishAndWaitForResponse(
          nanoTopic, nanoResponseTopic, "CHECK NANO",
          expectedResponse: "NANO_PONG");

      if (nanoResponse != "NANO_PONG") {
        NotifierHelper.showErrorToast(context, 'NANO is not connected.');
        state = state.copyWith(isNanoConnected: false);
      }

      if (response == "PONG" && nanoResponse == "NANO_PONG") {
        await supabase.from('iot_device').update({
          'last_seen': DateTime.now().toIso8601String(),
          'device_status': 'ONLINE'
        }).eq('mac_address', macAddress);

        state = state.copyWith(isEspConnected: true, isNanoConnected: true);
        return true;
      } else {
        NotifierHelper.showErrorToast(context, 'Device connection failed.');
        return false;
      }
    } catch (e) {
      NotifierHelper.logError(e);
      return false;
    } finally {
      NotifierHelper.closeToast(context);
    }
  }

  Future<void> closeAll(BuildContext context) async {
    ToastService.showLoadingToast(context, message: 'Closing all valves.');

    final macAddress = ref.watch(authProvider).macAddress;
    final userId = ref.watch(authProvider).userId;

    if (macAddress == null || userId == null) {
      NotifierHelper.showErrorToast(context, 'Missing user/device info.');
      return;
    }

    await mqttService.connect();

    final pumpControlTopic = "soiltrack/device/$macAddress/pump";
    final responseTopic = "$pumpControlTopic/status";

    final success = await DeviceHelper.sendMqttCommand(
      context,
      pumpControlTopic,
      responseTopic,
      'CLOSE ALL',
      'All valves closed.',
      'Failed to close valves',
      expectedResponse: 'CLOSE',
    );

    if (!success) return;

    final response = await supabase
        .from('user_plots')
        .select('plot_id')
        .eq('user_id', userId)
        .eq('isValveOn', true);

    final openPlots = response as List;

    if (openPlots.isNotEmpty) {
      final plotIds = openPlots.map((p) => p['plot_id'] as int).toList();

      final now = DateTime.now().toIso8601String();
      for (final plotId in plotIds) {
        await supabase
            .from('irrigation_log')
            .update({'time_stopped': now})
            .eq('mac_address', macAddress)
            .eq('plot_id', plotId);
      }

      await supabase
          .from('user_plots')
          .update({'isValveOn': false}).inFilter('plot_id', plotIds);
    }

    final remainingValves = await supabase
        .from('user_plots')
        .select('plot_id')
        .eq('user_id', userId)
        .eq('isValveOn', true);

    state = state.copyWith(valveStates: {}, isPumpOpen: false);
  }

  Future<void> openAll(BuildContext context) async {
    NotifierHelper.showLoadingToast(context, 'Opening all valves...');

    final macAddress = ref.watch(authProvider).macAddress ?? state.macAddress;
    final userId = ref.watch(authProvider).userId;

    if (macAddress == null || userId == null) {
      NotifierHelper.showErrorToast(context, 'Missing user/device info.');
      return;
    }

    await mqttService.connect();

    final pumpControlTopic = "soiltrack/device/$macAddress/pump";
    final responseTopic = "$pumpControlTopic/status";

    final plotsResponse = await supabase
        .from('user_plots')
        .select('plot_id')
        .eq('user_id', userId);

    final userPlots = (plotsResponse as List);

    final plotIds = userPlots.map((e) => e['plot_id'] as int).toList();

    if (userPlots.isEmpty) {
      NotifierHelper.showErrorToast(context, 'No plots found.');
      return;
    }

    await supabase
        .from('user_plots')
        .update({'isValveOn': true}).inFilter('plot_id', plotIds);

    final success = await DeviceHelper.sendMqttCommand(
      context,
      pumpControlTopic,
      responseTopic,
      'OPEN ALL',
      'All Valves Opened',
      'Failed to open valves',
      expectedResponse: 'OPEN',
    );

    if (!success) return;

    final now = DateTime.now().toIso8601String();
    final logEntries = plotIds.map((plotId) {
      return {
        'mac_address': macAddress,
        'plot_id': plotId,
        'time_started': now,
      };
    }).toList();

    await supabase.from('irrigation_log').insert(logEntries);
  }

  Future<void> openOrCloseValve(BuildContext context, String action,
      String valveTagging, int plotId) async {
    if (!state.isEspConnected) {
      NotifierHelper.showErrorToast(
          context, 'Your SoilTracker is not connected.');
      return;
    }
    final isValveOpening = action == 'VLVE ON';
    final newValveState = isValveOpening;
    final fullAction = "$action $valveTagging";

    NotifierHelper.showLoadingToast(
        context,
        action == 'VLVE ON'
            ? 'Opening Pump for Valve $valveTagging.'
            : 'Closing Pump for Valve $valveTagging.');

    final macAddress = ref.watch(authProvider).macAddress ?? state.macAddress;
    final userId = ref.watch(authProvider).userId;
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

    if (!success) return;

    await supabase
        .from('user_plots')
        .update({'isValveOn': newValveState}).eq('plot_id', plotId);

    // final response = await supabase
    //     .from('user_plots')
    //     .select('plot_id')
    //     .eq('user_id', userId!)
    //     .eq('isValveOn', true);

    final updatedValveStates = Map<int, bool>.from(state.valveStates);
    updatedValveStates[plotId] = newValveState;
    state = state.copyWith(valveStates: updatedValveStates);

    // if (isValveOpening) {
    //   await supabase.from('irrigation_log').insert({
    //     'mac_address': macAddress,
    //     'plot_id': plotId,
    //     'time_started': DateTime.now().toIso8601String(),
    //   });
    // } else {
    //   await supabase
    //       .from('irrigation_log')
    //       .update({
    //         'time_stopped': DateTime.now().toIso8601String(),
    //       })
    //       .eq('mac_address', macAddress!)
    //       .eq('plot_id', plotId);
    // }
  }

  Future<void> controlPump(BuildContext context, bool action) async {
    final macAddress = ref.watch(authProvider).macAddress ?? state.macAddress;
    final deviceHelper = DeviceHelper(ref);
    final pumpOpened = await deviceHelper.setPumpState(
        context: context, open: action, macAddress: macAddress!);

    if (!pumpOpened) {
      NotifierHelper.logError('Failed Opening or closing the Pump');
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
