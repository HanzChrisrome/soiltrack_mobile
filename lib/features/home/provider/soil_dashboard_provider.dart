// ignore_for_file: avoid_print

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soiltrack_mobile/core/config/supabase_config.dart';

class SoilDashboardState {
  final List<Map<String, dynamic>> userPlots;
  final bool isFetchingUserPlots;
  final String? error;

  SoilDashboardState({
    this.userPlots = const [],
    this.isFetchingUserPlots = false,
    this.error,
  });

  SoilDashboardState copyWith({
    List<Map<String, dynamic>>? userPlots,
    bool? isFetchingUserPlots,
    String? error,
  }) {
    return SoilDashboardState(
      userPlots: userPlots ?? this.userPlots,
      isFetchingUserPlots: isFetchingUserPlots ?? this.isFetchingUserPlots,
      error: error ?? this.error,
    );
  }
}

class SoilDashboardNotifier extends Notifier<SoilDashboardState> {
  @override
  SoilDashboardState build() {
    return SoilDashboardState();
  }

  Future<void> fetchUserPlots() async {
    if (state.isFetchingUserPlots) return;
    state = state.copyWith(isFetchingUserPlots: true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final macAddress = prefs.getString('mac_address') ?? '';
      final String userId = supabase.auth.currentUser!.id;

      if (macAddress.isEmpty) {
        print('No device registered');
        state = state.copyWith(error: 'No device registered');
        return;
      }

      // Fetch user plots from Supabase
      final userPlots = await supabase.from('user_plots').select('''
        plot_id,
        plot_name,
        soil_type,
        crop_id,
        crops (
            crop_name,
            category,
            moisture_min,
            moisture_max,
            nitrogen_min,
            nitrogen_max,
            phosphorus_min,
            phosphorus_max,
            potassium_min,
            potassium_max
        ),
        soil_moisture_sensor_id,
        soil_moisture_sensors (
            soil_moisture_sensor_id,
            soil_moisture_name,
            soil_moisture_status,
            is_assigned
        ),
        soil_nutrient_sensor_id,
        soil_nutrient_sensors (
            soil_nutrient_sensor_id,
            soil_nutrient_name,
            soil_nutrient_status,
            is_assigned
        ),
        soil_moisture_readings (
            soil_moisture_id,
            soil_moisture,
            read_time
        )
    ''').eq('user_id', userId);

      if (userPlots.isEmpty) {
        print('No plots available');
        state = state.copyWith(
            error: 'No plots available', isFetchingUserPlots: false);
      }

      print('User plots: $userPlots');

      state = state.copyWith(userPlots: userPlots, isFetchingUserPlots: false);
    } catch (e) {
      print(e);
      state = state.copyWith(error: e.toString(), isFetchingUserPlots: false);
    }
  }
}

final soilDashboardProvider =
    NotifierProvider<SoilDashboardNotifier, SoilDashboardState>(
        () => SoilDashboardNotifier());
