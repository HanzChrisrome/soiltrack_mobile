// ignore_for_file: avoid_print

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soiltrack_mobile/core/config/supabase_config.dart';

class SensorsState {
  final List<Map<String, dynamic>> sensors;
  final bool isFetchingSensors;
  final String? error;

  SensorsState({
    this.sensors = const [],
    this.isFetchingSensors = false,
    this.error,
  });

  SensorsState copyWith({
    List<Map<String, dynamic>>? sensors,
    bool? isFetchingSensors,
    String? error,
  }) {
    return SensorsState(
      sensors: sensors ?? this.sensors,
      isFetchingSensors: isFetchingSensors ?? this.isFetchingSensors,
      error: error ?? this.error,
    );
  }
}

class SensorsNotifier extends Notifier<SensorsState> {
  @override
  SensorsState build() {
    return SensorsState();
  }

  Future<void> fetchSensors() async {
    state = state.copyWith(isFetchingSensors: true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final macAddress = prefs.getString('mac_address') ?? '';

      if (macAddress.isEmpty) {
        print('No device registered');
        state = state.copyWith(error: 'No device registered');
        return;
      }

      final sensors = await supabase.from('soil_moisture_sensors').select('''
        soil_moisture_sensor_id,
        soil_moisture_name,
        soil_moisture_status,
        is_assigned,
        plot_id,
        user_plots (
          crop_id,
          crops (
            crop_name
          )
        )
      ''').eq('mac_address', macAddress);

      state = state.copyWith(sensors: sensors);
    } catch (e) {
      print(e);
      state = state.copyWith(error: e.toString(), isFetchingSensors: false);
    } finally {
      state = state.copyWith(isFetchingSensors: false);
    }
  }
}

final sensorsProvider =
    NotifierProvider<SensorsNotifier, SensorsState>(() => SensorsNotifier());
