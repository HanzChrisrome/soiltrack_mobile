// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:soiltrack_mobile/core/config/supabase_config.dart';
import 'package:soiltrack_mobile/core/service/mqtt_service.dart';
import 'package:soiltrack_mobile/core/utils/notifier_helpers.dart';

class DeviceHelper {
  static final MQTTService mqttService = MQTTService();

  static Future<String> getMacAddress() async {
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

      if (expectedResponse == null || response == expectedResponse) {
        NotifierHelper.showSuccessToast(context, successMessage);
        return true;
      } else {
        NotifierHelper.showErrorToast(context, errorMessage);
        return false;
      }
    } catch (e) {
      NotifierHelper.logError(e, context, errorMessage);
      return false;
    }
  }
}
