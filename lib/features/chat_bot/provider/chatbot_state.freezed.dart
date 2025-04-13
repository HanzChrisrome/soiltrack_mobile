// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chatbot_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ChatBotState {
  List<Map<String, dynamic>> get userConversations =>
      throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  int get currentConversationId => throw _privateConstructorUsedError;

  /// Create a copy of ChatBotState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChatBotStateCopyWith<ChatBotState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChatBotStateCopyWith<$Res> {
  factory $ChatBotStateCopyWith(
          ChatBotState value, $Res Function(ChatBotState) then) =
      _$ChatBotStateCopyWithImpl<$Res, ChatBotState>;
  @useResult
  $Res call(
      {List<Map<String, dynamic>> userConversations,
      bool isLoading,
      int currentConversationId});
}

/// @nodoc
class _$ChatBotStateCopyWithImpl<$Res, $Val extends ChatBotState>
    implements $ChatBotStateCopyWith<$Res> {
  _$ChatBotStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChatBotState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userConversations = null,
    Object? isLoading = null,
    Object? currentConversationId = null,
  }) {
    return _then(_value.copyWith(
      userConversations: null == userConversations
          ? _value.userConversations
          : userConversations // ignore: cast_nullable_to_non_nullable
              as List<Map<String, dynamic>>,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      currentConversationId: null == currentConversationId
          ? _value.currentConversationId
          : currentConversationId // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ChatBotStateImplCopyWith<$Res>
    implements $ChatBotStateCopyWith<$Res> {
  factory _$$ChatBotStateImplCopyWith(
          _$ChatBotStateImpl value, $Res Function(_$ChatBotStateImpl) then) =
      __$$ChatBotStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<Map<String, dynamic>> userConversations,
      bool isLoading,
      int currentConversationId});
}

/// @nodoc
class __$$ChatBotStateImplCopyWithImpl<$Res>
    extends _$ChatBotStateCopyWithImpl<$Res, _$ChatBotStateImpl>
    implements _$$ChatBotStateImplCopyWith<$Res> {
  __$$ChatBotStateImplCopyWithImpl(
      _$ChatBotStateImpl _value, $Res Function(_$ChatBotStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of ChatBotState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userConversations = null,
    Object? isLoading = null,
    Object? currentConversationId = null,
  }) {
    return _then(_$ChatBotStateImpl(
      userConversations: null == userConversations
          ? _value._userConversations
          : userConversations // ignore: cast_nullable_to_non_nullable
              as List<Map<String, dynamic>>,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      currentConversationId: null == currentConversationId
          ? _value.currentConversationId
          : currentConversationId // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$ChatBotStateImpl implements _ChatBotState {
  _$ChatBotStateImpl(
      {final List<Map<String, dynamic>> userConversations = const [],
      this.isLoading = false,
      this.currentConversationId = 0})
      : _userConversations = userConversations;

  final List<Map<String, dynamic>> _userConversations;
  @override
  @JsonKey()
  List<Map<String, dynamic>> get userConversations {
    if (_userConversations is EqualUnmodifiableListView)
      return _userConversations;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_userConversations);
  }

  @override
  @JsonKey()
  final bool isLoading;
  @override
  @JsonKey()
  final int currentConversationId;

  @override
  String toString() {
    return 'ChatBotState(userConversations: $userConversations, isLoading: $isLoading, currentConversationId: $currentConversationId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatBotStateImpl &&
            const DeepCollectionEquality()
                .equals(other._userConversations, _userConversations) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.currentConversationId, currentConversationId) ||
                other.currentConversationId == currentConversationId));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_userConversations),
      isLoading,
      currentConversationId);

  /// Create a copy of ChatBotState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChatBotStateImplCopyWith<_$ChatBotStateImpl> get copyWith =>
      __$$ChatBotStateImplCopyWithImpl<_$ChatBotStateImpl>(this, _$identity);
}

abstract class _ChatBotState implements ChatBotState {
  factory _ChatBotState(
      {final List<Map<String, dynamic>> userConversations,
      final bool isLoading,
      final int currentConversationId}) = _$ChatBotStateImpl;

  @override
  List<Map<String, dynamic>> get userConversations;
  @override
  bool get isLoading;
  @override
  int get currentConversationId;

  /// Create a copy of ChatBotState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChatBotStateImplCopyWith<_$ChatBotStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
