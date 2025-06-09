// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soiltrack_mobile/core/config/supabase_config.dart';
import 'package:soiltrack_mobile/core/service/mqtt_service.dart';
import 'package:soiltrack_mobile/core/utils/notifier_helpers.dart';
import 'package:soiltrack_mobile/features/auth/provider/auth_provider.dart';
import 'package:soiltrack_mobile/features/device_registration/provider/device_provider.dart';
import 'package:soiltrack_mobile/features/home/provider/hardware_provider/soil_sensors_provider.dart';
import 'package:soiltrack_mobile/features/home/provider/soil_dashboard/plots_provider/soil_dashboard_provider.dart';

class DeviceHelper {
  final Ref ref;
  static final MQTTService mqttService = MQTTService();

  DeviceHelper(this.ref);

  Future<String> getMacAddress() async {
    final macAddress = await supabase
        .from('iot_device')
        .select('mac_address')
        .eq('user_id', supabase.auth.currentUser!.id)
        .maybeSingle();
    return macAddress?['mac_address'] ?? '';
  }

  static Future<bool> sendMqttCommand(
      BuildContext context,
      String publishTopic,
      String responseTopic,
      String message,
      String successMessage,
      String errorMessage,
      {String? expectedResponse}) async {
    try {
      final response = await mqttService.publishAndWaitForResponse(
          publishTopic, responseTopic, message,
          expectedResponse: expectedResponse);

      if (response == expectedResponse) {
        NotifierHelper.showSuccessToast(context, successMessage);
        return true;
      } else {
        NotifierHelper.logError('MQTT Command Failed: $response');
        NotifierHelper.showErrorToast(context, errorMessage);
        return false;
      }
    } catch (e) {
      NotifierHelper.logError('MQTT Command Error: $e');
      NotifierHelper.logError(e, context, errorMessage);
      return false;
    }
  }

  Future<void> initializeAll(BuildContext context, String macAdress) async {
    final soilDashboardNotifier = ref.read(soilDashboardProvider.notifier);
    final sensorNotifier = ref.read(sensorsProvider.notifier);
    final deviceNotifier = ref.read(deviceProvider.notifier);

    await checkValvesStatus(macAdress);
    await Future.delayed(const Duration(seconds: 1));
    await checkMoistureSensorStatus(macAdress);
    await Future.delayed(const Duration(seconds: 1));
    await checkNpkSensorStatus(macAdress);
    await Future.delayed(const Duration(seconds: 1));
    await deviceNotifier.checkDeviceStatus(context);

    await soilDashboardNotifier.fetchUserPlots();
    await sensorNotifier.fetchSensors();
    await mqttService.connect();
  }

  Future<void> checkValvesStatus(String? devMacAddress) async {
    final authState = ref.watch(authProvider);
    final macAddress = devMacAddress ?? authState.macAddress;
    final firstName = authState.userName ?? 'User';

    if (macAddress == null) {
      NotifierHelper.logError('No device connected.');
      return;
    }

    //FOR VALVES
    final publishTopic = "soiltrack/device/$macAddress/get-valves";
    final responseTopic = "soiltrack/device/$macAddress/get-valves/response";

    final response = await mqttService.publishAndWaitForResponse(
        publishTopic, responseTopic, "GET VALVES");
    final decoded = jsonDecode(response);
    List<dynamic> valvePins = decoded['valve_pins'];

    try {
      final existingPlots = await supabase
          .from('user_plots')
          .select('plot_name')
          .eq('user_id', authState.userId!);

      final existingNames =
          existingPlots.map((e) => e['plot_name'] as String).toSet();

      const letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

      for (int i = 0; i < valvePins.length; i++) {
        final plotName = '$firstName Plot ${letters[i]}';

        if (!existingNames.contains(plotName)) {
          await supabase.from('user_plots').insert({
            'user_id': authState.userId,
            'plot_name': plotName,
            'isValveOn': false,
            'valve_tagging': letters[i],
            'valve_pin': valvePins[i],
          });
        }
      }
    } catch (e) {
      NotifierHelper.logError(e);
      return;
    }
  }

  Future<void> checkMoistureSensorStatus(String? devMacAddress) async {
    final authState = ref.watch(authProvider);
    final macAddress = devMacAddress ?? authState.macAddress;
    final firstName = authState.userName ?? 'User';

    if (macAddress == null)
      return NotifierHelper.logError('No device connected.');

    final response = await mqttService.publishAndWaitForResponse(
        "soiltrack/device/$macAddress/get-moisture-sensors",
        "soiltrack/device/$macAddress/get-moisture-sensors/response",
        "GET MOISTURE SENSORS");

    final decoded = jsonDecode(response);
    List<dynamic> moisturePins = decoded['moisture_pins'];

    for (int i = 0; i < moisturePins.length; i++) {
      final pin = moisturePins[i];
      final sensorName = '$firstName Moisture Sensor ${i + 1}';
      final sensorType = 'moisture${i + 1}';

      final existingSensors = await supabase
          .from('soil_sensors')
          .select()
          .eq('mac_address', macAddress)
          .eq('sensor_type', sensorType)
          .maybeSingle();

      if (existingSensors != null) {
        if (existingSensors['sensor_name'] != sensorName) {
          await supabase
              .from('soil_sensors')
              .update({'sensor_name': sensorName})
              .eq('mac_address', macAddress)
              .eq('sensor_id', existingSensors['sensor_id']);
        }
      } else {
        await supabase.from('soil_sensors').insert({
          'mac_address': macAddress,
          'sensor_name': sensorName,
          'sensor_type': sensorType,
          'sensor_status': 'ACTIVE',
          'sensor_category': 'Moisture Sensor',
          'is_assigned': false,
          'sensor_pin': pin,
        });
      }
    }
  }

  Future<void> checkNpkSensorStatus(String? devMacAddress) async {
    final authState = ref.watch(authProvider);
    final macAddress = devMacAddress ?? authState.macAddress;
    final firstName = authState.userName ?? 'User';

    if (macAddress == null)
      return NotifierHelper.logError('No device connected.');

    final response = await mqttService.publishAndWaitForResponse(
        "soiltrack/device/$macAddress/get-npk-sensors",
        "soiltrack/device/$macAddress/get-npk-sensors/response",
        "GET NPK SENSORS");

    final decoded = jsonDecode(response);

    final npkCount = decoded['npk_count'] as int;

    for (int i = 0; i < npkCount; i++) {
      final sensorName = '$firstName NPK Sensor ${i + 1}';
      final sensorType = 'npk${i + 1}';
      final existingSensors = await supabase
          .from('soil_sensors')
          .select()
          .eq('mac_address', macAddress)
          .eq('sensor_type', sensorType)
          .maybeSingle();

      if (existingSensors != null) {
        if (existingSensors['sensor_name'] != sensorName) {
          await supabase
              .from('soil_sensors')
              .update({'sensor_name': sensorName})
              .eq('mac_address', macAddress)
              .eq('sensor_id', existingSensors['sensor_id']);
        }
      } else {
        await supabase.from('soil_sensors').insert({
          'mac_address': macAddress,
          'sensor_name': sensorName,
          'sensor_type': sensorType,
          'sensor_status': 'ACTIVE',
          'sensor_category': 'NPK Sensor',
          'is_assigned': false,
        });
      }
    }
  }

  Future<bool> sendCommandWithFeedback({
    required BuildContext context,
    required String command,
    required String expectedResponse,
    required String successMessage,
    required String errorMessage,
  }) async {
    final macAddress = ref.watch(authProvider).macAddress;
    final topic = "soiltrack/device/$macAddress/pump";
    final responseTopic = "$topic/status";

    return await sendMqttCommand(
      context,
      topic,
      responseTopic,
      command,
      successMessage,
      errorMessage,
      expectedResponse: expectedResponse,
    );
  }

  Future<bool> setPumpState(
      {required BuildContext context,
      required bool open,
      required String macAddress}) async {
    final topic = "soiltrack/device/$macAddress/pump";
    final responseTopic = "$topic/status";
    final action = open ? 'PUMP ON' : 'PUMP OFF';
    final expectedResponse = open ? 'P_OPEN' : 'P_CLOSE';
    final successMessage =
        open ? 'Pump opened successfully.' : 'Pump closed successfully.';
    final errorMessage =
        open ? 'Failed to open pump.' : 'Failed to close pump.';

    await supabase.from('iot_device').update({
      'isPumpOnManually': open,
      'isPumpOn': open,
    }).eq('mac_address', macAddress);

    return await DeviceHelper.sendMqttCommand(
      context,
      topic,
      responseTopic,
      action,
      successMessage,
      errorMessage,
      expectedResponse: expectedResponse,
    );
  }
}
