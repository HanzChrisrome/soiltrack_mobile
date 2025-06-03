import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soiltrack_mobile/core/config/supabase_config.dart';
import 'package:soiltrack_mobile/features/auth/provider/auth_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ValveStatesNotifier extends StateNotifier<Map<int, bool>> {
  ValveStatesNotifier(this._userId) : super({}) {
    _init();
  }

  final String _userId;
  RealtimeChannel? _channel;

  Future<void> _init() async {
    await _fetchInitialStates();
    _subscribeToValveChanges();
  }

  Future<void> _fetchInitialStates() async {
    final response = await supabase
        .from('user_plots')
        .select('plot_id, isValveOn')
        .eq('user_id', _userId);

    final List data = response as List;

    final Map<int, bool> initialStates = {
      for (var item in data) item['plot_id'] as int: item['isValveOn'] as bool,
    };

    state = initialStates;
  }

  void _subscribeToValveChanges() {
    _channel = supabase.channel('public:user_plots_all')
      ..onPostgresChanges(
        event: PostgresChangeEvent.update,
        schema: 'public',
        table: 'user_plots',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'user_id',
          value: _userId,
        ),
        callback: (payload) {
          final newRecord = payload.newRecord;
          if (newRecord.isNotEmpty &&
              newRecord.containsKey('plot_id') &&
              newRecord.containsKey('isValveOn')) {
            final int plotId = newRecord['plot_id'] as int;
            final bool isValveOn = newRecord['isValveOn'] as bool;

            print(
                '[ValveStatesNotifier] Plot $plotId valve updated to $isValveOn');

            state = {
              ...state,
              plotId: isValveOn,
            };
          }
        },
      ).subscribe();
  }

  @override
  void dispose() {
    if (_channel != null) {
      supabase.removeChannel(_channel!);
    }
    super.dispose();
  }
}

final valveStatesProvider =
    StateNotifierProvider<ValveStatesNotifier, Map<int, bool>>((ref) {
  final authState = ref.watch(authProvider);
  final userId = authState.userId ?? '';

  return ValveStatesNotifier(userId);
});
