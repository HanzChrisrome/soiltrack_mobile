import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soiltrack_mobile/core/config/supabase_config.dart';
import 'package:soiltrack_mobile/features/auth/provider/auth_provider.dart';
import 'package:soiltrack_mobile/features/device_registration/provider/device_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PumpStateNotifier extends StateNotifier<bool?> {
  PumpStateNotifier(this._macAddress) : super(null) {
    _init();
  }

  final String _macAddress;
  RealtimeChannel? _channel;

  Future<void> _init() async {
    await _fetchInitialState();
    _subscribeToPumpChanges();
  }

  Future<void> _fetchInitialState() async {
    try {
      final response = await supabase
          .from('iot_device')
          .select('isPumpOn')
          .eq('mac_address', _macAddress)
          .maybeSingle();

      if (response != null && response['isPumpOn'] != null) {
        state = response['isPumpOn'] as bool;
      }
    } catch (e) {
      print('[PumpStateNotifier] Initial fetch error: $e');
    }
  }

  void _subscribeToPumpChanges() {
    _channel = supabase.channel('public:iot_device')
      ..onPostgresChanges(
        event: PostgresChangeEvent.update,
        schema: 'public',
        table: 'iot_device',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'mac_address',
          value: _macAddress,
        ),
        callback: (payload) {
          final newRecord = payload.newRecord;
          if (newRecord.isNotEmpty && newRecord.containsKey('isPumpOn')) {
            final isPumpOn = newRecord['isPumpOn'] as bool;
            print('[PumpStateNotifier] Pump state updated to $isPumpOn');
            state = isPumpOn;
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

final pumpStateProvider =
    StateNotifierProvider<PumpStateNotifier, bool?>((ref) {
  final deviceState = ref.read(deviceProvider);
  final authState = ref.read(authProvider);

  final macAddress = deviceState.macAddress ?? authState.macAddress ?? '';

  return PumpStateNotifier(macAddress);
});
