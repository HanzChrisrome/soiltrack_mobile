// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dashboard_notifier.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$DashboardState {
// Plot selection
  int get selectedPlotId => throw _privateConstructorUsedError;
  int get selectedPlotHistoryId => throw _privateConstructorUsedError;
  int get selectedAnalysisId => throw _privateConstructorUsedError;
  int get loadedPlotId => throw _privateConstructorUsedError; // Filters
  String get selectedTimeRangeFilter => throw _privateConstructorUsedError;
  String get selectedTimeRangeFilterGeneral =>
      throw _privateConstructorUsedError;
  String get selectedHistoryFilter => throw _privateConstructorUsedError;
  String get selectedLanguage => throw _privateConstructorUsedError;
  String get currentCardToggled => throw _privateConstructorUsedError;
  String get currentDeviceToggled => throw _privateConstructorUsedError;
  String get mainDeviceToggled =>
      throw _privateConstructorUsedError; // Date ranges (for custom filtering)
  DateTime? get customStartDate => throw _privateConstructorUsedError;
  DateTime? get customEndDate => throw _privateConstructorUsedError;

  /// Create a copy of DashboardState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DashboardStateCopyWith<DashboardState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DashboardStateCopyWith<$Res> {
  factory $DashboardStateCopyWith(
          DashboardState value, $Res Function(DashboardState) then) =
      _$DashboardStateCopyWithImpl<$Res, DashboardState>;
  @useResult
  $Res call(
      {int selectedPlotId,
      int selectedPlotHistoryId,
      int selectedAnalysisId,
      int loadedPlotId,
      String selectedTimeRangeFilter,
      String selectedTimeRangeFilterGeneral,
      String selectedHistoryFilter,
      String selectedLanguage,
      String currentCardToggled,
      String currentDeviceToggled,
      String mainDeviceToggled,
      DateTime? customStartDate,
      DateTime? customEndDate});
}

/// @nodoc
class _$DashboardStateCopyWithImpl<$Res, $Val extends DashboardState>
    implements $DashboardStateCopyWith<$Res> {
  _$DashboardStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DashboardState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? selectedPlotId = null,
    Object? selectedPlotHistoryId = null,
    Object? selectedAnalysisId = null,
    Object? loadedPlotId = null,
    Object? selectedTimeRangeFilter = null,
    Object? selectedTimeRangeFilterGeneral = null,
    Object? selectedHistoryFilter = null,
    Object? selectedLanguage = null,
    Object? currentCardToggled = null,
    Object? currentDeviceToggled = null,
    Object? mainDeviceToggled = null,
    Object? customStartDate = freezed,
    Object? customEndDate = freezed,
  }) {
    return _then(_value.copyWith(
      selectedPlotId: null == selectedPlotId
          ? _value.selectedPlotId
          : selectedPlotId // ignore: cast_nullable_to_non_nullable
              as int,
      selectedPlotHistoryId: null == selectedPlotHistoryId
          ? _value.selectedPlotHistoryId
          : selectedPlotHistoryId // ignore: cast_nullable_to_non_nullable
              as int,
      selectedAnalysisId: null == selectedAnalysisId
          ? _value.selectedAnalysisId
          : selectedAnalysisId // ignore: cast_nullable_to_non_nullable
              as int,
      loadedPlotId: null == loadedPlotId
          ? _value.loadedPlotId
          : loadedPlotId // ignore: cast_nullable_to_non_nullable
              as int,
      selectedTimeRangeFilter: null == selectedTimeRangeFilter
          ? _value.selectedTimeRangeFilter
          : selectedTimeRangeFilter // ignore: cast_nullable_to_non_nullable
              as String,
      selectedTimeRangeFilterGeneral: null == selectedTimeRangeFilterGeneral
          ? _value.selectedTimeRangeFilterGeneral
          : selectedTimeRangeFilterGeneral // ignore: cast_nullable_to_non_nullable
              as String,
      selectedHistoryFilter: null == selectedHistoryFilter
          ? _value.selectedHistoryFilter
          : selectedHistoryFilter // ignore: cast_nullable_to_non_nullable
              as String,
      selectedLanguage: null == selectedLanguage
          ? _value.selectedLanguage
          : selectedLanguage // ignore: cast_nullable_to_non_nullable
              as String,
      currentCardToggled: null == currentCardToggled
          ? _value.currentCardToggled
          : currentCardToggled // ignore: cast_nullable_to_non_nullable
              as String,
      currentDeviceToggled: null == currentDeviceToggled
          ? _value.currentDeviceToggled
          : currentDeviceToggled // ignore: cast_nullable_to_non_nullable
              as String,
      mainDeviceToggled: null == mainDeviceToggled
          ? _value.mainDeviceToggled
          : mainDeviceToggled // ignore: cast_nullable_to_non_nullable
              as String,
      customStartDate: freezed == customStartDate
          ? _value.customStartDate
          : customStartDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      customEndDate: freezed == customEndDate
          ? _value.customEndDate
          : customEndDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DashboardStateImplCopyWith<$Res>
    implements $DashboardStateCopyWith<$Res> {
  factory _$$DashboardStateImplCopyWith(_$DashboardStateImpl value,
          $Res Function(_$DashboardStateImpl) then) =
      __$$DashboardStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int selectedPlotId,
      int selectedPlotHistoryId,
      int selectedAnalysisId,
      int loadedPlotId,
      String selectedTimeRangeFilter,
      String selectedTimeRangeFilterGeneral,
      String selectedHistoryFilter,
      String selectedLanguage,
      String currentCardToggled,
      String currentDeviceToggled,
      String mainDeviceToggled,
      DateTime? customStartDate,
      DateTime? customEndDate});
}

/// @nodoc
class __$$DashboardStateImplCopyWithImpl<$Res>
    extends _$DashboardStateCopyWithImpl<$Res, _$DashboardStateImpl>
    implements _$$DashboardStateImplCopyWith<$Res> {
  __$$DashboardStateImplCopyWithImpl(
      _$DashboardStateImpl _value, $Res Function(_$DashboardStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of DashboardState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? selectedPlotId = null,
    Object? selectedPlotHistoryId = null,
    Object? selectedAnalysisId = null,
    Object? loadedPlotId = null,
    Object? selectedTimeRangeFilter = null,
    Object? selectedTimeRangeFilterGeneral = null,
    Object? selectedHistoryFilter = null,
    Object? selectedLanguage = null,
    Object? currentCardToggled = null,
    Object? currentDeviceToggled = null,
    Object? mainDeviceToggled = null,
    Object? customStartDate = freezed,
    Object? customEndDate = freezed,
  }) {
    return _then(_$DashboardStateImpl(
      selectedPlotId: null == selectedPlotId
          ? _value.selectedPlotId
          : selectedPlotId // ignore: cast_nullable_to_non_nullable
              as int,
      selectedPlotHistoryId: null == selectedPlotHistoryId
          ? _value.selectedPlotHistoryId
          : selectedPlotHistoryId // ignore: cast_nullable_to_non_nullable
              as int,
      selectedAnalysisId: null == selectedAnalysisId
          ? _value.selectedAnalysisId
          : selectedAnalysisId // ignore: cast_nullable_to_non_nullable
              as int,
      loadedPlotId: null == loadedPlotId
          ? _value.loadedPlotId
          : loadedPlotId // ignore: cast_nullable_to_non_nullable
              as int,
      selectedTimeRangeFilter: null == selectedTimeRangeFilter
          ? _value.selectedTimeRangeFilter
          : selectedTimeRangeFilter // ignore: cast_nullable_to_non_nullable
              as String,
      selectedTimeRangeFilterGeneral: null == selectedTimeRangeFilterGeneral
          ? _value.selectedTimeRangeFilterGeneral
          : selectedTimeRangeFilterGeneral // ignore: cast_nullable_to_non_nullable
              as String,
      selectedHistoryFilter: null == selectedHistoryFilter
          ? _value.selectedHistoryFilter
          : selectedHistoryFilter // ignore: cast_nullable_to_non_nullable
              as String,
      selectedLanguage: null == selectedLanguage
          ? _value.selectedLanguage
          : selectedLanguage // ignore: cast_nullable_to_non_nullable
              as String,
      currentCardToggled: null == currentCardToggled
          ? _value.currentCardToggled
          : currentCardToggled // ignore: cast_nullable_to_non_nullable
              as String,
      currentDeviceToggled: null == currentDeviceToggled
          ? _value.currentDeviceToggled
          : currentDeviceToggled // ignore: cast_nullable_to_non_nullable
              as String,
      mainDeviceToggled: null == mainDeviceToggled
          ? _value.mainDeviceToggled
          : mainDeviceToggled // ignore: cast_nullable_to_non_nullable
              as String,
      customStartDate: freezed == customStartDate
          ? _value.customStartDate
          : customStartDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      customEndDate: freezed == customEndDate
          ? _value.customEndDate
          : customEndDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc

class _$DashboardStateImpl implements _DashboardState {
  _$DashboardStateImpl(
      {this.selectedPlotId = 0,
      this.selectedPlotHistoryId = 0,
      this.selectedAnalysisId = 0,
      this.loadedPlotId = 0,
      this.selectedTimeRangeFilter = "1D",
      this.selectedTimeRangeFilterGeneral = "1D",
      this.selectedHistoryFilter = "1W",
      this.selectedLanguage = "en",
      this.currentCardToggled = 'Daily',
      this.currentDeviceToggled = 'Moisture',
      this.mainDeviceToggled = 'Controller',
      this.customStartDate,
      this.customEndDate});

// Plot selection
  @override
  @JsonKey()
  final int selectedPlotId;
  @override
  @JsonKey()
  final int selectedPlotHistoryId;
  @override
  @JsonKey()
  final int selectedAnalysisId;
  @override
  @JsonKey()
  final int loadedPlotId;
// Filters
  @override
  @JsonKey()
  final String selectedTimeRangeFilter;
  @override
  @JsonKey()
  final String selectedTimeRangeFilterGeneral;
  @override
  @JsonKey()
  final String selectedHistoryFilter;
  @override
  @JsonKey()
  final String selectedLanguage;
  @override
  @JsonKey()
  final String currentCardToggled;
  @override
  @JsonKey()
  final String currentDeviceToggled;
  @override
  @JsonKey()
  final String mainDeviceToggled;
// Date ranges (for custom filtering)
  @override
  final DateTime? customStartDate;
  @override
  final DateTime? customEndDate;

  @override
  String toString() {
    return 'DashboardState(selectedPlotId: $selectedPlotId, selectedPlotHistoryId: $selectedPlotHistoryId, selectedAnalysisId: $selectedAnalysisId, loadedPlotId: $loadedPlotId, selectedTimeRangeFilter: $selectedTimeRangeFilter, selectedTimeRangeFilterGeneral: $selectedTimeRangeFilterGeneral, selectedHistoryFilter: $selectedHistoryFilter, selectedLanguage: $selectedLanguage, currentCardToggled: $currentCardToggled, currentDeviceToggled: $currentDeviceToggled, mainDeviceToggled: $mainDeviceToggled, customStartDate: $customStartDate, customEndDate: $customEndDate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DashboardStateImpl &&
            (identical(other.selectedPlotId, selectedPlotId) ||
                other.selectedPlotId == selectedPlotId) &&
            (identical(other.selectedPlotHistoryId, selectedPlotHistoryId) ||
                other.selectedPlotHistoryId == selectedPlotHistoryId) &&
            (identical(other.selectedAnalysisId, selectedAnalysisId) ||
                other.selectedAnalysisId == selectedAnalysisId) &&
            (identical(other.loadedPlotId, loadedPlotId) ||
                other.loadedPlotId == loadedPlotId) &&
            (identical(
                    other.selectedTimeRangeFilter, selectedTimeRangeFilter) ||
                other.selectedTimeRangeFilter == selectedTimeRangeFilter) &&
            (identical(other.selectedTimeRangeFilterGeneral,
                    selectedTimeRangeFilterGeneral) ||
                other.selectedTimeRangeFilterGeneral ==
                    selectedTimeRangeFilterGeneral) &&
            (identical(other.selectedHistoryFilter, selectedHistoryFilter) ||
                other.selectedHistoryFilter == selectedHistoryFilter) &&
            (identical(other.selectedLanguage, selectedLanguage) ||
                other.selectedLanguage == selectedLanguage) &&
            (identical(other.currentCardToggled, currentCardToggled) ||
                other.currentCardToggled == currentCardToggled) &&
            (identical(other.currentDeviceToggled, currentDeviceToggled) ||
                other.currentDeviceToggled == currentDeviceToggled) &&
            (identical(other.mainDeviceToggled, mainDeviceToggled) ||
                other.mainDeviceToggled == mainDeviceToggled) &&
            (identical(other.customStartDate, customStartDate) ||
                other.customStartDate == customStartDate) &&
            (identical(other.customEndDate, customEndDate) ||
                other.customEndDate == customEndDate));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      selectedPlotId,
      selectedPlotHistoryId,
      selectedAnalysisId,
      loadedPlotId,
      selectedTimeRangeFilter,
      selectedTimeRangeFilterGeneral,
      selectedHistoryFilter,
      selectedLanguage,
      currentCardToggled,
      currentDeviceToggled,
      mainDeviceToggled,
      customStartDate,
      customEndDate);

  /// Create a copy of DashboardState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DashboardStateImplCopyWith<_$DashboardStateImpl> get copyWith =>
      __$$DashboardStateImplCopyWithImpl<_$DashboardStateImpl>(
          this, _$identity);
}

abstract class _DashboardState implements DashboardState {
  factory _DashboardState(
      {final int selectedPlotId,
      final int selectedPlotHistoryId,
      final int selectedAnalysisId,
      final int loadedPlotId,
      final String selectedTimeRangeFilter,
      final String selectedTimeRangeFilterGeneral,
      final String selectedHistoryFilter,
      final String selectedLanguage,
      final String currentCardToggled,
      final String currentDeviceToggled,
      final String mainDeviceToggled,
      final DateTime? customStartDate,
      final DateTime? customEndDate}) = _$DashboardStateImpl;

// Plot selection
  @override
  int get selectedPlotId;
  @override
  int get selectedPlotHistoryId;
  @override
  int get selectedAnalysisId;
  @override
  int get loadedPlotId; // Filters
  @override
  String get selectedTimeRangeFilter;
  @override
  String get selectedTimeRangeFilterGeneral;
  @override
  String get selectedHistoryFilter;
  @override
  String get selectedLanguage;
  @override
  String get currentCardToggled;
  @override
  String get currentDeviceToggled;
  @override
  String get mainDeviceToggled; // Date ranges (for custom filtering)
  @override
  DateTime? get customStartDate;
  @override
  DateTime? get customEndDate;

  /// Create a copy of DashboardState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DashboardStateImplCopyWith<_$DashboardStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
