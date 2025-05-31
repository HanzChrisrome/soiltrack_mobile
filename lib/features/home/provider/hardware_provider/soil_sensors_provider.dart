// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soiltrack_mobile/core/config/supabase_config.dart';
import 'package:soiltrack_mobile/core/utils/notifier_helpers.dart';
import 'package:soiltrack_mobile/features/auth/provider/auth_provider.dart';
import 'package:soiltrack_mobile/features/device_registration/provider/device_provider.dart';
import 'package:soiltrack_mobile/features/home/provider/hardware_provider/soil_sensors_state.dart';

class SensorsNotifier extends Notifier<SensorsState> {
  @override
  SensorsState build() {
    return SensorsState();
  }

  Future<void> fetchSensors() async {
    if (state.isFetchingSensors) return;
    state = state.copyWith(isFetchingSensors: true);
    final authState = ref.read(authProvider);
    final deviceState = ref.read(deviceProvider);
    final macAddress = deviceState.macAddress ?? authState.macAddress;

    try {
      if (macAddress == null) {
        NotifierHelper.logMessage('Mac Address is nullings');
        return;
      }

      final sensors = await supabase.from('soil_sensors').select('''
        sensor_id,
        sensor_name,
        sensor_status,
        is_assigned,
        sensor_type,
        sensor_category,
        user_plot_sensors(
          plot_id,
          user_plots(plot_name)
        )
      ''').eq('mac_address', macAddress);

      final moistureSensors = sensors
          .where((s) => s['sensor_category'] == 'Moisture Sensor')
          .toList();

      final npkSensors =
          sensors.where((s) => s['sensor_category'] == 'NPK Sensor').toList();

      state = state.copyWith(
        moistureSensors: moistureSensors,
        nutrientSensors: npkSensors,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString(), isFetchingSensors: false);
    } finally {
      state = state.copyWith(isFetchingSensors: false);
    }
  }

  Future<void> assignSensor(
      BuildContext context, int sensorId, int plotId) async {
    final authNotifier = ref.read(authProvider.notifier);

    try {
      NotifierHelper.showLoadingToast(context, 'Assigning Sensor.');
      await supabase.from('user_plot_sensors').insert({
        'sensor_id': sensorId,
        'plot_id': plotId,
      });
      await supabase.from('soil_sensors').update({
        'is_assigned': true,
      }).eq('sensor_id', sensorId);

      await authNotifier.fetchRelatedData(false);
      NotifierHelper.showSuccessToast(context, 'Sensor Assigned.');
    } catch (e) {
      NotifierHelper.showErrorToast(context, e.toString());
    }
  }

  Future<void> unassignSensor(BuildContext context, int sensorId) async {
    final authNotifier = ref.read(authProvider.notifier);

    try {
      NotifierHelper.showLoadingToast(context, 'Unassigning Sensor.');
      await supabase.from('user_plot_sensors').delete().eq(
            'sensor_id',
            sensorId,
          );
      await supabase.from('soil_sensors').update({
        'is_assigned': false,
      }).eq('sensor_id', sensorId);

      await authNotifier.fetchRelatedData(false);
      NotifierHelper.showSuccessToast(context, 'Sensor Unassigned.');
    } catch (e) {
      NotifierHelper.logError(e.toString());
    }
  }
}

final sensorsProvider =
    NotifierProvider<SensorsNotifier, SensorsState>(() => SensorsNotifier());
