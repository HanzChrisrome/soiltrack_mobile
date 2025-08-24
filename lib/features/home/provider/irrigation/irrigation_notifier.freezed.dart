// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'irrigation_notifier.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$IrrigationState {
  List<Map<String, dynamic>> get irrigationLogs =>
      throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;

  /// Create a copy of IrrigationState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $IrrigationStateCopyWith<IrrigationState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $IrrigationStateCopyWith<$Res> {
  factory $IrrigationStateCopyWith(
          IrrigationState value, $Res Function(IrrigationState) then) =
      _$IrrigationStateCopyWithImpl<$Res, IrrigationState>;
  @useResult
  $Res call(
      {List<Map<String, dynamic>> irrigationLogs,
      bool isLoading,
      String? errorMessage});
}

/// @nodoc
class _$IrrigationStateCopyWithImpl<$Res, $Val extends IrrigationState>
    implements $IrrigationStateCopyWith<$Res> {
  _$IrrigationStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of IrrigationState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? irrigationLogs = null,
    Object? isLoading = null,
    Object? errorMessage = freezed,
  }) {
    return _then(_value.copyWith(
      irrigationLogs: null == irrigationLogs
          ? _value.irrigationLogs
          : irrigationLogs // ignore: cast_nullable_to_non_nullable
              as List<Map<String, dynamic>>,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$IrrigationStateImplCopyWith<$Res>
    implements $IrrigationStateCopyWith<$Res> {
  factory _$$IrrigationStateImplCopyWith(_$IrrigationStateImpl value,
          $Res Function(_$IrrigationStateImpl) then) =
      __$$IrrigationStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<Map<String, dynamic>> irrigationLogs,
      bool isLoading,
      String? errorMessage});
}

/// @nodoc
class __$$IrrigationStateImplCopyWithImpl<$Res>
    extends _$IrrigationStateCopyWithImpl<$Res, _$IrrigationStateImpl>
    implements _$$IrrigationStateImplCopyWith<$Res> {
  __$$IrrigationStateImplCopyWithImpl(
      _$IrrigationStateImpl _value, $Res Function(_$IrrigationStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of IrrigationState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? irrigationLogs = null,
    Object? isLoading = null,
    Object? errorMessage = freezed,
  }) {
    return _then(_$IrrigationStateImpl(
      irrigationLogs: null == irrigationLogs
          ? _value._irrigationLogs
          : irrigationLogs // ignore: cast_nullable_to_non_nullable
              as List<Map<String, dynamic>>,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$IrrigationStateImpl implements _IrrigationState {
  _$IrrigationStateImpl(
      {final List<Map<String, dynamic>> irrigationLogs = const [],
      this.isLoading = false,
      this.errorMessage})
      : _irrigationLogs = irrigationLogs;

  final List<Map<String, dynamic>> _irrigationLogs;
  @override
  @JsonKey()
  List<Map<String, dynamic>> get irrigationLogs {
    if (_irrigationLogs is EqualUnmodifiableListView) return _irrigationLogs;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_irrigationLogs);
  }

  @override
  @JsonKey()
  final bool isLoading;
  @override
  final String? errorMessage;

  @override
  String toString() {
    return 'IrrigationState(irrigationLogs: $irrigationLogs, isLoading: $isLoading, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$IrrigationStateImpl &&
            const DeepCollectionEquality()
                .equals(other._irrigationLogs, _irrigationLogs) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_irrigationLogs),
      isLoading,
      errorMessage);

  /// Create a copy of IrrigationState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$IrrigationStateImplCopyWith<_$IrrigationStateImpl> get copyWith =>
      __$$IrrigationStateImplCopyWithImpl<_$IrrigationStateImpl>(
          this, _$identity);
}

abstract class _IrrigationState implements IrrigationState {
  factory _IrrigationState(
      {final List<Map<String, dynamic>> irrigationLogs,
      final bool isLoading,
      final String? errorMessage}) = _$IrrigationStateImpl;

  @override
  List<Map<String, dynamic>> get irrigationLogs;
  @override
  bool get isLoading;
  @override
  String? get errorMessage;

  /// Create a copy of IrrigationState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$IrrigationStateImplCopyWith<_$IrrigationStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
