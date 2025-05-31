import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:wifi_scan/wifi_scan.dart';

part 'device_provider_state.freezed.dart';

@freezed
class DeviceState with _$DeviceState {
  factory DeviceState({
    @Default([]) List<WiFiAccessPoint> availableDevices,
    @Default([]) List<WiFiAccessPoint> availableNetworks,
    String? selectedDeviceSSID,
    String? selectedWifiSSID,
    String? macAddress,
    @Default(false) bool isEspConnected,
    @Default(false) bool isNanoConnected,
    @Default(false) bool isScanning,
    @Default(false) bool isConnecting,
    @Default(false) bool isSettingUpAccount,
    @Default(false) bool isSaving,
    @Default(false) bool isResetting,
    @Default({}) Map<int, bool> valveStates,
    @Default(false) bool isPumpOpen,
    String? savingError,
  }) = _DeviceState;
}
