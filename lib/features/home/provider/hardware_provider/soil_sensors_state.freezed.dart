// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'soil_sensors_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$SensorsState {
  List<Map<String, dynamic>> get moistureSensors =>
      throw _privateConstructorUsedError;
  List<Map<String, dynamic>> get nutrientSensors =>
      throw _privateConstructorUsedError;
  bool get isFetchingSensors => throw _privateConstructorUsedError;
  bool get isAssigningSensor => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;

  /// Create a copy of SensorsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SensorsStateCopyWith<SensorsState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SensorsStateCopyWith<$Res> {
  factory $SensorsStateCopyWith(
          SensorsState value, $Res Function(SensorsState) then) =
      _$SensorsStateCopyWithImpl<$Res, SensorsState>;
  @useResult
  $Res call(
      {List<Map<String, dynamic>> moistureSensors,
      List<Map<String, dynamic>> nutrientSensors,
      bool isFetchingSensors,
      bool isAssigningSensor,
      String? error});
}

/// @nodoc
class _$SensorsStateCopyWithImpl<$Res, $Val extends SensorsState>
    implements $SensorsStateCopyWith<$Res> {
  _$SensorsStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SensorsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? moistureSensors = null,
    Object? nutrientSensors = null,
    Object? isFetchingSensors = null,
    Object? isAssigningSensor = null,
    Object? error = freezed,
  }) {
    return _then(_value.copyWith(
      moistureSensors: null == moistureSensors
          ? _value.moistureSensors
          : moistureSensors // ignore: cast_nullable_to_non_nullable
              as List<Map<String, dynamic>>,
      nutrientSensors: null == nutrientSensors
          ? _value.nutrientSensors
          : nutrientSensors // ignore: cast_nullable_to_non_nullable
              as List<Map<String, dynamic>>,
      isFetchingSensors: null == isFetchingSensors
          ? _value.isFetchingSensors
          : isFetchingSensors // ignore: cast_nullable_to_non_nullable
              as bool,
      isAssigningSensor: null == isAssigningSensor
          ? _value.isAssigningSensor
          : isAssigningSensor // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SensorsStateImplCopyWith<$Res>
    implements $SensorsStateCopyWith<$Res> {
  factory _$$SensorsStateImplCopyWith(
          _$SensorsStateImpl value, $Res Function(_$SensorsStateImpl) then) =
      __$$SensorsStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<Map<String, dynamic>> moistureSensors,
      List<Map<String, dynamic>> nutrientSensors,
      bool isFetchingSensors,
      bool isAssigningSensor,
      String? error});
}

/// @nodoc
class __$$SensorsStateImplCopyWithImpl<$Res>
    extends _$SensorsStateCopyWithImpl<$Res, _$SensorsStateImpl>
    implements _$$SensorsStateImplCopyWith<$Res> {
  __$$SensorsStateImplCopyWithImpl(
      _$SensorsStateImpl _value, $Res Function(_$SensorsStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of SensorsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? moistureSensors = null,
    Object? nutrientSensors = null,
    Object? isFetchingSensors = null,
    Object? isAssigningSensor = null,
    Object? error = freezed,
  }) {
    return _then(_$SensorsStateImpl(
      moistureSensors: null == moistureSensors
          ? _value._moistureSensors
          : moistureSensors // ignore: cast_nullable_to_non_nullable
              as List<Map<String, dynamic>>,
      nutrientSensors: null == nutrientSensors
          ? _value._nutrientSensors
          : nutrientSensors // ignore: cast_nullable_to_non_nullable
              as List<Map<String, dynamic>>,
      isFetchingSensors: null == isFetchingSensors
          ? _value.isFetchingSensors
          : isFetchingSensors // ignore: cast_nullable_to_non_nullable
              as bool,
      isAssigningSensor: null == isAssigningSensor
          ? _value.isAssigningSensor
          : isAssigningSensor // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$SensorsStateImpl implements _SensorsState {
  _$SensorsStateImpl(
      {final List<Map<String, dynamic>> moistureSensors = const [],
      final List<Map<String, dynamic>> nutrientSensors = const [],
      this.isFetchingSensors = false,
      this.isAssigningSensor = false,
      this.error})
      : _moistureSensors = moistureSensors,
        _nutrientSensors = nutrientSensors;

  final List<Map<String, dynamic>> _moistureSensors;
  @override
  @JsonKey()
  List<Map<String, dynamic>> get moistureSensors {
    if (_moistureSensors is EqualUnmodifiableListView) return _moistureSensors;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_moistureSensors);
  }

  final List<Map<String, dynamic>> _nutrientSensors;
  @override
  @JsonKey()
  List<Map<String, dynamic>> get nutrientSensors {
    if (_nutrientSensors is EqualUnmodifiableListView) return _nutrientSensors;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_nutrientSensors);
  }

  @override
  @JsonKey()
  final bool isFetchingSensors;
  @override
  @JsonKey()
  final bool isAssigningSensor;
  @override
  final String? error;

  @override
  String toString() {
    return 'SensorsState(moistureSensors: $moistureSensors, nutrientSensors: $nutrientSensors, isFetchingSensors: $isFetchingSensors, isAssigningSensor: $isAssigningSensor, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SensorsStateImpl &&
            const DeepCollectionEquality()
                .equals(other._moistureSensors, _moistureSensors) &&
            const DeepCollectionEquality()
                .equals(other._nutrientSensors, _nutrientSensors) &&
            (identical(other.isFetchingSensors, isFetchingSensors) ||
                other.isFetchingSensors == isFetchingSensors) &&
            (identical(other.isAssigningSensor, isAssigningSensor) ||
                other.isAssigningSensor == isAssigningSensor) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_moistureSensors),
      const DeepCollectionEquality().hash(_nutrientSensors),
      isFetchingSensors,
      isAssigningSensor,
      error);

  /// Create a copy of SensorsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SensorsStateImplCopyWith<_$SensorsStateImpl> get copyWith =>
      __$$SensorsStateImplCopyWithImpl<_$SensorsStateImpl>(this, _$identity);
}

abstract class _SensorsState implements SensorsState {
  factory _SensorsState(
      {final List<Map<String, dynamic>> moistureSensors,
      final List<Map<String, dynamic>> nutrientSensors,
      final bool isFetchingSensors,
      final bool isAssigningSensor,
      final String? error}) = _$SensorsStateImpl;

  @override
  List<Map<String, dynamic>> get moistureSensors;
  @override
  List<Map<String, dynamic>> get nutrientSensors;
  @override
  bool get isFetchingSensors;
  @override
  bool get isAssigningSensor;
  @override
  String? get error;

  /// Create a copy of SensorsState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SensorsStateImplCopyWith<_$SensorsStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
