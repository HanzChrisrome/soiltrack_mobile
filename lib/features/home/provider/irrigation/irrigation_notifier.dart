import 'package:flutter/widgets.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:soiltrack_mobile/core/config/supabase_config.dart';
import 'package:soiltrack_mobile/core/utils/notifier_helpers.dart';
import 'package:soiltrack_mobile/features/home/provider/soil_dashboard/plots_provider/soil_dashboard_provider.dart';
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
          if (newLog.isNotEmpty) {
            state = state.copyWith(
              irrigationLogs: [newLog, ...state.irrigationLogs],
            );
          }
        },
      )
      ..subscribe();

    _listenerInitialized = true;
  }

  Future<void> fetchInitialLogs(
      {DateTime? customStartDate, DateTime? customEndDate}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final userPlots = ref.watch(soilDashboardProvider).userPlots;
      final List<String> plotIds =
          userPlots.map((plot) => plot['plot_id'].toString()).toList();

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

  Future<void> saveIrrigationSchedule({
    required BuildContext context,
    required String formattedTime,
    required int plotId,
    required Duration timeDuration,
    required String irrigationType,
    required List<String> selectedDays,
    required String scheduleLabel,
    required int scheduleId,
    required String savingType,
  }) async {
    NotifierHelper.showLoadingToast(context, 'Uploading irrigation schedule.');

    try {
      final soilDashboardNotifier = ref.read(soilDashboardProvider.notifier);

      await supabase.from('user_plots').update({
        'irrigation_type': irrigationType,
      }).eq('plot_id', plotId);

      if (savingType == 'create') {
        await supabase.from('irrigation_schedule').insert({
          'plot_id': plotId,
          'schedule_label': scheduleLabel,
          'start_time': formattedTime,
          'duration_minutes': timeDuration.inMinutes,
          'days_of_week': selectedDays,
          'is_enabled': true,
          'created_at': DateTime.now().toIso8601String(),
        });
      }

      if (savingType == 'update') {
        await supabase.from('irrigation_schedule').update({
          'plot_id': plotId,
          'schedule_label': scheduleLabel,
          'start_time': formattedTime,
          'duration_minutes': timeDuration.inMinutes,
          'days_of_week': selectedDays,
          'is_enabled': true,
          'created_at': DateTime.now().toIso8601String(),
        }).eq('schedule_id', scheduleId);
      }

      NotifierHelper.logMessage('Irrigation Type: $irrigationType');
      NotifierHelper.showSuccessToast(context, 'Irrigation schedule uploaded');
      soilDashboardNotifier.fetchUserPlots();
    } catch (e) {
      NotifierHelper.logError(
          e, context, 'Error uploading irrigation schedule');
    } finally {
      NotifierHelper.closeToast(context);
    }
  }

  Future<void> changeIrrigationStatus(
      BuildContext context, int plotId, String selectedType) async {
    try {
      final soilDashboardNotifier = ref.read(soilDashboardProvider.notifier);

      await supabase.from('user_plots').update({
        'irrigation_type': selectedType,
      }).eq('plot_id', plotId);

      NotifierHelper.showSuccessToast(context, 'Irrigation status updated');
      soilDashboardNotifier.fetchUserPlots();
    } catch (e) {
      NotifierHelper.logError(e, context, 'Error changing irrigation status');
    } finally {
      NotifierHelper.closeToast(context);
    }
  }

  Future<void> deleteSchedule(BuildContext context, int schedule_id) async {
    final soilDashboardNotifier = ref.read(soilDashboardProvider.notifier);

    NotifierHelper.showLoadingToast(context, 'Deleting irrigation schedule');
    await supabase.from('irrigation_schedule').delete().eq(
          'schedule_id',
          schedule_id,
        );

    NotifierHelper.showSuccessToast(context, 'Irrigation schedule deleted');
    soilDashboardNotifier.fetchUserPlots();
  }
}

final irrigationNotifierProvider =
    NotifierProvider<IrrigationNotifier, IrrigationState>(() {
  return IrrigationNotifier();
});
