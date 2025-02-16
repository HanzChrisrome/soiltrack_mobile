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
    state = state.copyWith(isFetchingUserPlots: true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final macAddress = prefs.getString('mac_address') ?? '';

      if (macAddress.isEmpty) {
        print('No device registered');
        state = state.copyWith(error: 'No device registered');
        return;
      }
    } catch (e) {}
  }
}
