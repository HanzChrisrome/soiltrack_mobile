import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soiltrack_mobile/core/config/supabase_config.dart';
import 'package:soiltrack_mobile/core/utils/notifier_helpers.dart';
import 'package:soiltrack_mobile/features/auth/provider/auth_provider.dart';
import 'package:soiltrack_mobile/features/device_registration/provider/device_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final pumpInitialState = FutureProvider<bool>((ref) async {
  final deviceState = ref.watch(deviceProvider);
  final authState = ref.watch(authProvider);

  final macAddress = deviceState.macAddress ?? authState.macAddress;
  if (macAddress == null) {
    throw Exception('MAC address is null');
  }

  final response = await supabase
      .from('iot_device')
      .select('isPumpOn')
      .eq('mac_address', macAddress)
      .single();

  return response['isPumpOn'] as bool;
});

final pumpStatusRealtimeProvider = StreamProvider.autoDispose<bool>((ref) {
  final deviceState = ref.watch(deviceProvider);
  final authState = ref.watch(authProvider);

  final macAddress = deviceState.macAddress ?? authState.macAddress;
  if (macAddress == null) {
    throw Exception('MAC address is null');
  }

  final controller = StreamController<bool>();

  final channel = supabase.channel('public:iot_device')
    ..onPostgresChanges(
      event: PostgresChangeEvent.update,
      schema: 'public',
      table: 'iot_device',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'mac_address',
        value: macAddress,
      ),
      callback: (payload) {
        final newRecord = payload.newRecord;
        if (newRecord.isNotEmpty && newRecord.containsKey('isPumpOn')) {
          controller.add(newRecord['isPumpOn'] as bool);
        }
      },
    ).subscribe();

  ref.onDispose(() async {
    await channel.unsubscribe();
    await controller.close();
  });

  return controller.stream;
});

final pumpStateProvider = Provider<AsyncValue<bool>>((ref) {
  final initial = ref.watch(pumpInitialState);
  final realtime = ref.watch(pumpStatusRealtimeProvider);

  return initial.when(
    data: (initialData) => realtime.when(
      data: (realTimeData) => AsyncValue.data(realTimeData),
      loading: () => AsyncValue.data(initialData),
      error: (error, stack) => AsyncValue.error(error, stack),
    ),
    loading: () => AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});
