// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'device_provider_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$DeviceState {
  List<WiFiAccessPoint> get availableDevices =>
      throw _privateConstructorUsedError;
  List<WiFiAccessPoint> get availableNetworks =>
      throw _privateConstructorUsedError;
  String? get selectedDeviceSSID => throw _privateConstructorUsedError;
  String? get selectedWifiSSID => throw _privateConstructorUsedError;
  String? get macAddress => throw _privateConstructorUsedError;
  bool get isEspConnected => throw _privateConstructorUsedError;
  bool get isNanoConnected => throw _privateConstructorUsedError;
  bool get isScanning => throw _privateConstructorUsedError;
  bool get isConnecting => throw _privateConstructorUsedError;
  bool get isSaving => throw _privateConstructorUsedError;
  bool get isResetting => throw _privateConstructorUsedError;
  Map<int, bool> get valveStates => throw _privateConstructorUsedError;
  bool get isPumpOpen => throw _privateConstructorUsedError;
  String? get savingError => throw _privateConstructorUsedError;

  /// Create a copy of DeviceState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DeviceStateCopyWith<DeviceState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DeviceStateCopyWith<$Res> {
  factory $DeviceStateCopyWith(
          DeviceState value, $Res Function(DeviceState) then) =
      _$DeviceStateCopyWithImpl<$Res, DeviceState>;
  @useResult
  $Res call(
      {List<WiFiAccessPoint> availableDevices,
      List<WiFiAccessPoint> availableNetworks,
      String? selectedDeviceSSID,
      String? selectedWifiSSID,
      String? macAddress,
      bool isEspConnected,
      bool isNanoConnected,
      bool isScanning,
      bool isConnecting,
      bool isSaving,
      bool isResetting,
      Map<int, bool> valveStates,
      bool isPumpOpen,
      String? savingError});
}

/// @nodoc
class _$DeviceStateCopyWithImpl<$Res, $Val extends DeviceState>
    implements $DeviceStateCopyWith<$Res> {
  _$DeviceStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DeviceState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? availableDevices = null,
    Object? availableNetworks = null,
    Object? selectedDeviceSSID = freezed,
    Object? selectedWifiSSID = freezed,
    Object? macAddress = freezed,
    Object? isEspConnected = null,
    Object? isNanoConnected = null,
    Object? isScanning = null,
    Object? isConnecting = null,
    Object? isSaving = null,
    Object? isResetting = null,
    Object? valveStates = null,
    Object? isPumpOpen = null,
    Object? savingError = freezed,
  }) {
    return _then(_value.copyWith(
      availableDevices: null == availableDevices
          ? _value.availableDevices
          : availableDevices // ignore: cast_nullable_to_non_nullable
              as List<WiFiAccessPoint>,
      availableNetworks: null == availableNetworks
          ? _value.availableNetworks
          : availableNetworks // ignore: cast_nullable_to_non_nullable
              as List<WiFiAccessPoint>,
      selectedDeviceSSID: freezed == selectedDeviceSSID
          ? _value.selectedDeviceSSID
          : selectedDeviceSSID // ignore: cast_nullable_to_non_nullable
              as String?,
      selectedWifiSSID: freezed == selectedWifiSSID
          ? _value.selectedWifiSSID
          : selectedWifiSSID // ignore: cast_nullable_to_non_nullable
              as String?,
      macAddress: freezed == macAddress
          ? _value.macAddress
          : macAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      isEspConnected: null == isEspConnected
          ? _value.isEspConnected
          : isEspConnected // ignore: cast_nullable_to_non_nullable
              as bool,
      isNanoConnected: null == isNanoConnected
          ? _value.isNanoConnected
          : isNanoConnected // ignore: cast_nullable_to_non_nullable
              as bool,
      isScanning: null == isScanning
          ? _value.isScanning
          : isScanning // ignore: cast_nullable_to_non_nullable
              as bool,
      isConnecting: null == isConnecting
          ? _value.isConnecting
          : isConnecting // ignore: cast_nullable_to_non_nullable
              as bool,
      isSaving: null == isSaving
          ? _value.isSaving
          : isSaving // ignore: cast_nullable_to_non_nullable
              as bool,
      isResetting: null == isResetting
          ? _value.isResetting
          : isResetting // ignore: cast_nullable_to_non_nullable
              as bool,
      valveStates: null == valveStates
          ? _value.valveStates
          : valveStates // ignore: cast_nullable_to_non_nullable
              as Map<int, bool>,
      isPumpOpen: null == isPumpOpen
          ? _value.isPumpOpen
          : isPumpOpen // ignore: cast_nullable_to_non_nullable
              as bool,
      savingError: freezed == savingError
          ? _value.savingError
          : savingError // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DeviceStateImplCopyWith<$Res>
    implements $DeviceStateCopyWith<$Res> {
  factory _$$DeviceStateImplCopyWith(
          _$DeviceStateImpl value, $Res Function(_$DeviceStateImpl) then) =
      __$$DeviceStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<WiFiAccessPoint> availableDevices,
      List<WiFiAccessPoint> availableNetworks,
      String? selectedDeviceSSID,
      String? selectedWifiSSID,
      String? macAddress,
      bool isEspConnected,
      bool isNanoConnected,
      bool isScanning,
      bool isConnecting,
      bool isSaving,
      bool isResetting,
      Map<int, bool> valveStates,
      bool isPumpOpen,
      String? savingError});
}

/// @nodoc
class __$$DeviceStateImplCopyWithImpl<$Res>
    extends _$DeviceStateCopyWithImpl<$Res, _$DeviceStateImpl>
    implements _$$DeviceStateImplCopyWith<$Res> {
  __$$DeviceStateImplCopyWithImpl(
      _$DeviceStateImpl _value, $Res Function(_$DeviceStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of DeviceState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? availableDevices = null,
    Object? availableNetworks = null,
    Object? selectedDeviceSSID = freezed,
    Object? selectedWifiSSID = freezed,
    Object? macAddress = freezed,
    Object? isEspConnected = null,
    Object? isNanoConnected = null,
    Object? isScanning = null,
    Object? isConnecting = null,
    Object? isSaving = null,
    Object? isResetting = null,
    Object? valveStates = null,
    Object? isPumpOpen = null,
    Object? savingError = freezed,
  }) {
    return _then(_$DeviceStateImpl(
      availableDevices: null == availableDevices
          ? _value._availableDevices
          : availableDevices // ignore: cast_nullable_to_non_nullable
              as List<WiFiAccessPoint>,
      availableNetworks: null == availableNetworks
          ? _value._availableNetworks
          : availableNetworks // ignore: cast_nullable_to_non_nullable
              as List<WiFiAccessPoint>,
      selectedDeviceSSID: freezed == selectedDeviceSSID
          ? _value.selectedDeviceSSID
          : selectedDeviceSSID // ignore: cast_nullable_to_non_nullable
              as String?,
      selectedWifiSSID: freezed == selectedWifiSSID
          ? _value.selectedWifiSSID
          : selectedWifiSSID // ignore: cast_nullable_to_non_nullable
              as String?,
      macAddress: freezed == macAddress
          ? _value.macAddress
          : macAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      isEspConnected: null == isEspConnected
          ? _value.isEspConnected
          : isEspConnected // ignore: cast_nullable_to_non_nullable
              as bool,
      isNanoConnected: null == isNanoConnected
          ? _value.isNanoConnected
          : isNanoConnected // ignore: cast_nullable_to_non_nullable
              as bool,
      isScanning: null == isScanning
          ? _value.isScanning
          : isScanning // ignore: cast_nullable_to_non_nullable
              as bool,
      isConnecting: null == isConnecting
          ? _value.isConnecting
          : isConnecting // ignore: cast_nullable_to_non_nullable
              as bool,
      isSaving: null == isSaving
          ? _value.isSaving
          : isSaving // ignore: cast_nullable_to_non_nullable
              as bool,
      isResetting: null == isResetting
          ? _value.isResetting
          : isResetting // ignore: cast_nullable_to_non_nullable
              as bool,
      valveStates: null == valveStates
          ? _value._valveStates
          : valveStates // ignore: cast_nullable_to_non_nullable
              as Map<int, bool>,
      isPumpOpen: null == isPumpOpen
          ? _value.isPumpOpen
          : isPumpOpen // ignore: cast_nullable_to_non_nullable
              as bool,
      savingError: freezed == savingError
          ? _value.savingError
          : savingError // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$DeviceStateImpl implements _DeviceState {
  _$DeviceStateImpl(
      {final List<WiFiAccessPoint> availableDevices = const [],
      final List<WiFiAccessPoint> availableNetworks = const [],
      this.selectedDeviceSSID,
      this.selectedWifiSSID,
      this.macAddress,
      this.isEspConnected = false,
      this.isNanoConnected = false,
      this.isScanning = false,
      this.isConnecting = false,
      this.isSaving = false,
      this.isResetting = false,
      final Map<int, bool> valveStates = const {},
      this.isPumpOpen = false,
      this.savingError})
      : _availableDevices = availableDevices,
        _availableNetworks = availableNetworks,
        _valveStates = valveStates;

  final List<WiFiAccessPoint> _availableDevices;
  @override
  @JsonKey()
  List<WiFiAccessPoint> get availableDevices {
    if (_availableDevices is EqualUnmodifiableListView)
      return _availableDevices;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_availableDevices);
  }

  final List<WiFiAccessPoint> _availableNetworks;
  @override
  @JsonKey()
  List<WiFiAccessPoint> get availableNetworks {
    if (_availableNetworks is EqualUnmodifiableListView)
      return _availableNetworks;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_availableNetworks);
  }

  @override
  final String? selectedDeviceSSID;
  @override
  final String? selectedWifiSSID;
  @override
  final String? macAddress;
  @override
  @JsonKey()
  final bool isEspConnected;
  @override
  @JsonKey()
  final bool isNanoConnected;
  @override
  @JsonKey()
  final bool isScanning;
  @override
  @JsonKey()
  final bool isConnecting;
  @override
  @JsonKey()
  final bool isSaving;
  @override
  @JsonKey()
  final bool isResetting;
  final Map<int, bool> _valveStates;
  @override
  @JsonKey()
  Map<int, bool> get valveStates {
    if (_valveStates is EqualUnmodifiableMapView) return _valveStates;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_valveStates);
  }

  @override
  @JsonKey()
  final bool isPumpOpen;
  @override
  final String? savingError;

  @override
  String toString() {
    return 'DeviceState(availableDevices: $availableDevices, availableNetworks: $availableNetworks, selectedDeviceSSID: $selectedDeviceSSID, selectedWifiSSID: $selectedWifiSSID, macAddress: $macAddress, isEspConnected: $isEspConnected, isNanoConnected: $isNanoConnected, isScanning: $isScanning, isConnecting: $isConnecting, isSaving: $isSaving, isResetting: $isResetting, valveStates: $valveStates, isPumpOpen: $isPumpOpen, savingError: $savingError)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DeviceStateImpl &&
            const DeepCollectionEquality()
                .equals(other._availableDevices, _availableDevices) &&
            const DeepCollectionEquality()
                .equals(other._availableNetworks, _availableNetworks) &&
            (identical(other.selectedDeviceSSID, selectedDeviceSSID) ||
                other.selectedDeviceSSID == selectedDeviceSSID) &&
            (identical(other.selectedWifiSSID, selectedWifiSSID) ||
                other.selectedWifiSSID == selectedWifiSSID) &&
            (identical(other.macAddress, macAddress) ||
                other.macAddress == macAddress) &&
            (identical(other.isEspConnected, isEspConnected) ||
                other.isEspConnected == isEspConnected) &&
            (identical(other.isNanoConnected, isNanoConnected) ||
                other.isNanoConnected == isNanoConnected) &&
            (identical(other.isScanning, isScanning) ||
                other.isScanning == isScanning) &&
            (identical(other.isConnecting, isConnecting) ||
                other.isConnecting == isConnecting) &&
            (identical(other.isSaving, isSaving) ||
                other.isSaving == isSaving) &&
            (identical(other.isResetting, isResetting) ||
                other.isResetting == isResetting) &&
            const DeepCollectionEquality()
                .equals(other._valveStates, _valveStates) &&
            (identical(other.isPumpOpen, isPumpOpen) ||
                other.isPumpOpen == isPumpOpen) &&
            (identical(other.savingError, savingError) ||
                other.savingError == savingError));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_availableDevices),
      const DeepCollectionEquality().hash(_availableNetworks),
      selectedDeviceSSID,
      selectedWifiSSID,
      macAddress,
      isEspConnected,
      isNanoConnected,
      isScanning,
      isConnecting,
      isSaving,
      isResetting,
      const DeepCollectionEquality().hash(_valveStates),
      isPumpOpen,
      savingError);

  /// Create a copy of DeviceState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DeviceStateImplCopyWith<_$DeviceStateImpl> get copyWith =>
      __$$DeviceStateImplCopyWithImpl<_$DeviceStateImpl>(this, _$identity);
}

abstract class _DeviceState implements DeviceState {
  factory _DeviceState(
      {final List<WiFiAccessPoint> availableDevices,
      final List<WiFiAccessPoint> availableNetworks,
      final String? selectedDeviceSSID,
      final String? selectedWifiSSID,
      final String? macAddress,
      final bool isEspConnected,
      final bool isNanoConnected,
      final bool isScanning,
      final bool isConnecting,
      final bool isSaving,
      final bool isResetting,
      final Map<int, bool> valveStates,
      final bool isPumpOpen,
      final String? savingError}) = _$DeviceStateImpl;

  @override
  List<WiFiAccessPoint> get availableDevices;
  @override
  List<WiFiAccessPoint> get availableNetworks;
  @override
  String? get selectedDeviceSSID;
  @override
  String? get selectedWifiSSID;
  @override
  String? get macAddress;
  @override
  bool get isEspConnected;
  @override
  bool get isNanoConnected;
  @override
  bool get isScanning;
  @override
  bool get isConnecting;
  @override
  bool get isSaving;
  @override
  bool get isResetting;
  @override
  Map<int, bool> get valveStates;
  @override
  bool get isPumpOpen;
  @override
  String? get savingError;

  /// Create a copy of DeviceState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DeviceStateImplCopyWith<_$DeviceStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
