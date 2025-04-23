import 'package:freezed_annotation/freezed_annotation.dart';

part 'soil_sensors_state.freezed.dart';

@freezed
class SensorsState with _$SensorsState {
  factory SensorsState({
    @Default([]) List<Map<String, dynamic>> moistureSensors,
    @Default([]) List<Map<String, dynamic>> nutrientSensors,
    @Default(false) bool isFetchingSensors,
    @Default(false) bool isAssigningSensor,
    String? error,
  }) = _SensorsState;
}
