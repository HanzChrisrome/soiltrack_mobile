import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:soiltrack_mobile/core/config/supabase_config.dart';
import 'package:soiltrack_mobile/core/utils/notifier_helpers.dart';
import 'package:soiltrack_mobile/features/home/service/soil_dashboard_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'irrigation_notifier.freezed.dart';

@freezed
class IrrigationState with _$IrrigationState {
  factory IrrigationState({
    @Default([]) List<Map<String, dynamic>> irrigationLogs,
    @Default(false) bool isLoading,
    String? errorMessage,
  }) = _IrrigationState;
}

class IrrigationNotifier extends Notifier<IrrigationState> {
  late final SoilDashboardService service;
  RealtimeChannel? _irrigationChannel;
  bool _listenerInitialized = false;

  @override
  IrrigationState build() {
    service = SoilDashboardService();

    ref.onDispose(() {
      if (_irrigationChannel != null) {
        supabase.removeChannel(_irrigationChannel!);
      }
    });

    _initRealtimeListener();
    return IrrigationState();
  }

  void _initRealtimeListener() {
    if (_listenerInitialized) return;

    _irrigationChannel = supabase.channel('public:irrigation_log')
      ..onPostgresChanges(
        event: PostgresChangeEvent.insert,
        schema: 'public',
        table: 'irrigation_log',
        callback: (payload) async {
          final newLog = payload.newRecord;
          final plotIds = state.irrigationLogs
              .map((log) => log['plot_id'].toString())
              .toList();

          if (plotIds.contains(newLog['plot_id'].toString())) {
            await fetchLogs(plotIds);
          }
        },
      )
      ..subscribe();

    _listenerInitialized = true;
  }

  Future<void> fetchLogs(List<String> plotIds,
      {DateTime? customStartDate, DateTime? customEndDate}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final startDate =
          customStartDate ?? DateTime.now().subtract(const Duration(days: 90));

      final endDate = customEndDate ??
          DateTime.now().add(Duration(days: 1)).subtract(Duration(seconds: 1));

      final irrigationLogs =
          await service.fetchIrrigationLogs(plotIds, startDate, endDate);

      state = state.copyWith(irrigationLogs: irrigationLogs);
    } catch (e) {
      NotifierHelper.logError(e);
      state = state.copyWith(errorMessage: e.toString());
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }
}

final irrigationNotifierProvider =
    NotifierProvider<IrrigationNotifier, IrrigationState>(() {
  return IrrigationNotifier();
});
