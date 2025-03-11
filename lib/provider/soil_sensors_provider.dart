// ignore_for_file: avoid_print

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soiltrack_mobile/core/config/supabase_config.dart';
import 'package:soiltrack_mobile/core/utils/notifier_helpers.dart';
import 'package:soiltrack_mobile/features/auth/provider/auth_provider.dart';

class SensorsState {
  final List<Map<String, dynamic>> moistureSensors;
  final List<Map<String, dynamic>> nutrientSensors;
  final bool isFetchingSensors;
  final String? error;

  SensorsState({
    this.moistureSensors = const [],
    this.nutrientSensors = const [],
    this.isFetchingSensors = false,
    this.error,
  });

  SensorsState copyWith({
    List<Map<String, dynamic>>? moistureSensors,
    List<Map<String, dynamic>>? nutrientSensors,
    bool? isFetchingSensors,
    String? error,
  }) {
    return SensorsState(
      moistureSensors: moistureSensors ?? this.moistureSensors,
      nutrientSensors: nutrientSensors ?? this.nutrientSensors,
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
    if (state.isFetchingSensors) return;
    state = state.copyWith(isFetchingSensors: true);
    final authState = ref.watch(authProvider);
    final macAddress = authState.macAddress;

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
          user_plots (
            plot_name,
            user_crops (
              crop_name
            )
          )
        )
      ''').eq('mac_address', macAddress);

      final moistureSensors = sensors
          .where((s) => s['sensor_category'] == 'Moisture Sensor')
          .toList();

      print('Moisture Sensors $moistureSensors');
      final npkSensors =
          sensors.where((s) => s['sensor_category'] == 'NPK Sensor').toList();
      print('NPK Sensors $npkSensors');

      state = state.copyWith(
        moistureSensors: moistureSensors,
        nutrientSensors: npkSensors,
      );
    } catch (e) {
      print('❌ Error fetching sensors: $e');
      state = state.copyWith(error: e.toString(), isFetchingSensors: false);
    } finally {
      state = state.copyWith(isFetchingSensors: false);
    }
  }
}

final sensorsProvider =
    NotifierProvider<SensorsNotifier, SensorsState>(() => SensorsNotifier());
