// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'campaign.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Campaign _$CampaignFromJson(Map<String, dynamic> json) {
  return _Campaign.fromJson(json);
}

/// @nodoc
mixin _$Campaign {
  String get id => throw _privateConstructorUsedError;
  int get riskScore => throw _privateConstructorUsedError;
  String get riskLevel => throw _privateConstructorUsedError;
  List<String> get categories => throw _privateConstructorUsedError;
  List<StageTransition> get stageHistory => throw _privateConstructorUsedError;
  double? get velocitySeconds => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _exposureFromJson, toJson: _exposureToJson)
  Exposure get exposure => throw _privateConstructorUsedError;
  int get eventCount => throw _privateConstructorUsedError;
  List<String> get channels => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;

  /// Serializes this Campaign to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Campaign
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CampaignCopyWith<Campaign> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CampaignCopyWith<$Res> {
  factory $CampaignCopyWith(Campaign value, $Res Function(Campaign) then) =
      _$CampaignCopyWithImpl<$Res, Campaign>;
  @useResult
  $Res call(
      {String id,
      int riskScore,
      String riskLevel,
      List<String> categories,
      List<StageTransition> stageHistory,
      double? velocitySeconds,
      @JsonKey(fromJson: _exposureFromJson, toJson: _exposureToJson)
      Exposure exposure,
      int eventCount,
      List<String> channels,
      DateTime createdAt,
      DateTime updatedAt,
      bool isActive});

  $ExposureCopyWith<$Res> get exposure;
}

/// @nodoc
class _$CampaignCopyWithImpl<$Res, $Val extends Campaign>
    implements $CampaignCopyWith<$Res> {
  _$CampaignCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Campaign
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? riskScore = null,
    Object? riskLevel = null,
    Object? categories = null,
    Object? stageHistory = null,
    Object? velocitySeconds = freezed,
    Object? exposure = null,
    Object? eventCount = null,
    Object? channels = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? isActive = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      riskScore: null == riskScore
          ? _value.riskScore
          : riskScore // ignore: cast_nullable_to_non_nullable
              as int,
      riskLevel: null == riskLevel
          ? _value.riskLevel
          : riskLevel // ignore: cast_nullable_to_non_nullable
              as String,
      categories: null == categories
          ? _value.categories
          : categories // ignore: cast_nullable_to_non_nullable
              as List<String>,
      stageHistory: null == stageHistory
          ? _value.stageHistory
          : stageHistory // ignore: cast_nullable_to_non_nullable
              as List<StageTransition>,
      velocitySeconds: freezed == velocitySeconds
          ? _value.velocitySeconds
          : velocitySeconds // ignore: cast_nullable_to_non_nullable
              as double?,
      exposure: null == exposure
          ? _value.exposure
          : exposure // ignore: cast_nullable_to_non_nullable
              as Exposure,
      eventCount: null == eventCount
          ? _value.eventCount
          : eventCount // ignore: cast_nullable_to_non_nullable
              as int,
      channels: null == channels
          ? _value.channels
          : channels // ignore: cast_nullable_to_non_nullable
              as List<String>,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }

  /// Create a copy of Campaign
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ExposureCopyWith<$Res> get exposure {
    return $ExposureCopyWith<$Res>(_value.exposure, (value) {
      return _then(_value.copyWith(exposure: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CampaignImplCopyWith<$Res>
    implements $CampaignCopyWith<$Res> {
  factory _$$CampaignImplCopyWith(
          _$CampaignImpl value, $Res Function(_$CampaignImpl) then) =
      __$$CampaignImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      int riskScore,
      String riskLevel,
      List<String> categories,
      List<StageTransition> stageHistory,
      double? velocitySeconds,
      @JsonKey(fromJson: _exposureFromJson, toJson: _exposureToJson)
      Exposure exposure,
      int eventCount,
      List<String> channels,
      DateTime createdAt,
      DateTime updatedAt,
      bool isActive});

  @override
  $ExposureCopyWith<$Res> get exposure;
}

/// @nodoc
class __$$CampaignImplCopyWithImpl<$Res>
    extends _$CampaignCopyWithImpl<$Res, _$CampaignImpl>
    implements _$$CampaignImplCopyWith<$Res> {
  __$$CampaignImplCopyWithImpl(
      _$CampaignImpl _value, $Res Function(_$CampaignImpl) _then)
      : super(_value, _then);

  /// Create a copy of Campaign
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? riskScore = null,
    Object? riskLevel = null,
    Object? categories = null,
    Object? stageHistory = null,
    Object? velocitySeconds = freezed,
    Object? exposure = null,
    Object? eventCount = null,
    Object? channels = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? isActive = null,
  }) {
    return _then(_$CampaignImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      riskScore: null == riskScore
          ? _value.riskScore
          : riskScore // ignore: cast_nullable_to_non_nullable
              as int,
      riskLevel: null == riskLevel
          ? _value.riskLevel
          : riskLevel // ignore: cast_nullable_to_non_nullable
              as String,
      categories: null == categories
          ? _value._categories
          : categories // ignore: cast_nullable_to_non_nullable
              as List<String>,
      stageHistory: null == stageHistory
          ? _value._stageHistory
          : stageHistory // ignore: cast_nullable_to_non_nullable
              as List<StageTransition>,
      velocitySeconds: freezed == velocitySeconds
          ? _value.velocitySeconds
          : velocitySeconds // ignore: cast_nullable_to_non_nullable
              as double?,
      exposure: null == exposure
          ? _value.exposure
          : exposure // ignore: cast_nullable_to_non_nullable
              as Exposure,
      eventCount: null == eventCount
          ? _value.eventCount
          : eventCount // ignore: cast_nullable_to_non_nullable
              as int,
      channels: null == channels
          ? _value._channels
          : channels // ignore: cast_nullable_to_non_nullable
              as List<String>,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CampaignImpl implements _Campaign {
  const _$CampaignImpl(
      {required this.id,
      required this.riskScore,
      required this.riskLevel,
      required final List<String> categories,
      required final List<StageTransition> stageHistory,
      this.velocitySeconds,
      @JsonKey(fromJson: _exposureFromJson, toJson: _exposureToJson)
      required this.exposure,
      this.eventCount = 0,
      required final List<String> channels,
      required this.createdAt,
      required this.updatedAt,
      this.isActive = true})
      : _categories = categories,
        _stageHistory = stageHistory,
        _channels = channels;

  factory _$CampaignImpl.fromJson(Map<String, dynamic> json) =>
      _$$CampaignImplFromJson(json);

  @override
  final String id;
  @override
  final int riskScore;
  @override
  final String riskLevel;
  final List<String> _categories;
  @override
  List<String> get categories {
    if (_categories is EqualUnmodifiableListView) return _categories;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_categories);
  }

  final List<StageTransition> _stageHistory;
  @override
  List<StageTransition> get stageHistory {
    if (_stageHistory is EqualUnmodifiableListView) return _stageHistory;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_stageHistory);
  }

  @override
  final double? velocitySeconds;
  @override
  @JsonKey(fromJson: _exposureFromJson, toJson: _exposureToJson)
  final Exposure exposure;
  @override
  @JsonKey()
  final int eventCount;
  final List<String> _channels;
  @override
  List<String> get channels {
    if (_channels is EqualUnmodifiableListView) return _channels;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_channels);
  }

  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  @JsonKey()
  final bool isActive;

  @override
  String toString() {
    return 'Campaign(id: $id, riskScore: $riskScore, riskLevel: $riskLevel, categories: $categories, stageHistory: $stageHistory, velocitySeconds: $velocitySeconds, exposure: $exposure, eventCount: $eventCount, channels: $channels, createdAt: $createdAt, updatedAt: $updatedAt, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CampaignImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.riskScore, riskScore) ||
                other.riskScore == riskScore) &&
            (identical(other.riskLevel, riskLevel) ||
                other.riskLevel == riskLevel) &&
            const DeepCollectionEquality()
                .equals(other._categories, _categories) &&
            const DeepCollectionEquality()
                .equals(other._stageHistory, _stageHistory) &&
            (identical(other.velocitySeconds, velocitySeconds) ||
                other.velocitySeconds == velocitySeconds) &&
            (identical(other.exposure, exposure) ||
                other.exposure == exposure) &&
            (identical(other.eventCount, eventCount) ||
                other.eventCount == eventCount) &&
            const DeepCollectionEquality().equals(other._channels, _channels) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      riskScore,
      riskLevel,
      const DeepCollectionEquality().hash(_categories),
      const DeepCollectionEquality().hash(_stageHistory),
      velocitySeconds,
      exposure,
      eventCount,
      const DeepCollectionEquality().hash(_channels),
      createdAt,
      updatedAt,
      isActive);

  /// Create a copy of Campaign
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CampaignImplCopyWith<_$CampaignImpl> get copyWith =>
      __$$CampaignImplCopyWithImpl<_$CampaignImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CampaignImplToJson(
      this,
    );
  }
}

abstract class _Campaign implements Campaign {
  const factory _Campaign(
      {required final String id,
      required final int riskScore,
      required final String riskLevel,
      required final List<String> categories,
      required final List<StageTransition> stageHistory,
      final double? velocitySeconds,
      @JsonKey(fromJson: _exposureFromJson, toJson: _exposureToJson)
      required final Exposure exposure,
      final int eventCount,
      required final List<String> channels,
      required final DateTime createdAt,
      required final DateTime updatedAt,
      final bool isActive}) = _$CampaignImpl;

  factory _Campaign.fromJson(Map<String, dynamic> json) =
      _$CampaignImpl.fromJson;

  @override
  String get id;
  @override
  int get riskScore;
  @override
  String get riskLevel;
  @override
  List<String> get categories;
  @override
  List<StageTransition> get stageHistory;
  @override
  double? get velocitySeconds;
  @override
  @JsonKey(fromJson: _exposureFromJson, toJson: _exposureToJson)
  Exposure get exposure;
  @override
  int get eventCount;
  @override
  List<String> get channels;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  bool get isActive;

  /// Create a copy of Campaign
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CampaignImplCopyWith<_$CampaignImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

StageTransition _$StageTransitionFromJson(Map<String, dynamic> json) {
  return _StageTransition.fromJson(json);
}

/// @nodoc
mixin _$StageTransition {
  String get stage => throw _privateConstructorUsedError;
  String get label => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;
  double get confidence => throw _privateConstructorUsedError;

  /// Serializes this StageTransition to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StageTransition
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StageTransitionCopyWith<StageTransition> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StageTransitionCopyWith<$Res> {
  factory $StageTransitionCopyWith(
          StageTransition value, $Res Function(StageTransition) then) =
      _$StageTransitionCopyWithImpl<$Res, StageTransition>;
  @useResult
  $Res call(
      {String stage, String label, DateTime timestamp, double confidence});
}

/// @nodoc
class _$StageTransitionCopyWithImpl<$Res, $Val extends StageTransition>
    implements $StageTransitionCopyWith<$Res> {
  _$StageTransitionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StageTransition
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? stage = null,
    Object? label = null,
    Object? timestamp = null,
    Object? confidence = null,
  }) {
    return _then(_value.copyWith(
      stage: null == stage
          ? _value.stage
          : stage // ignore: cast_nullable_to_non_nullable
              as String,
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      confidence: null == confidence
          ? _value.confidence
          : confidence // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$StageTransitionImplCopyWith<$Res>
    implements $StageTransitionCopyWith<$Res> {
  factory _$$StageTransitionImplCopyWith(_$StageTransitionImpl value,
          $Res Function(_$StageTransitionImpl) then) =
      __$$StageTransitionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String stage, String label, DateTime timestamp, double confidence});
}

/// @nodoc
class __$$StageTransitionImplCopyWithImpl<$Res>
    extends _$StageTransitionCopyWithImpl<$Res, _$StageTransitionImpl>
    implements _$$StageTransitionImplCopyWith<$Res> {
  __$$StageTransitionImplCopyWithImpl(
      _$StageTransitionImpl _value, $Res Function(_$StageTransitionImpl) _then)
      : super(_value, _then);

  /// Create a copy of StageTransition
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? stage = null,
    Object? label = null,
    Object? timestamp = null,
    Object? confidence = null,
  }) {
    return _then(_$StageTransitionImpl(
      stage: null == stage
          ? _value.stage
          : stage // ignore: cast_nullable_to_non_nullable
              as String,
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      confidence: null == confidence
          ? _value.confidence
          : confidence // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$StageTransitionImpl implements _StageTransition {
  const _$StageTransitionImpl(
      {required this.stage,
      required this.label,
      required this.timestamp,
      this.confidence = 1.0});

  factory _$StageTransitionImpl.fromJson(Map<String, dynamic> json) =>
      _$$StageTransitionImplFromJson(json);

  @override
  final String stage;
  @override
  final String label;
  @override
  final DateTime timestamp;
  @override
  @JsonKey()
  final double confidence;

  @override
  String toString() {
    return 'StageTransition(stage: $stage, label: $label, timestamp: $timestamp, confidence: $confidence)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StageTransitionImpl &&
            (identical(other.stage, stage) || other.stage == stage) &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.confidence, confidence) ||
                other.confidence == confidence));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, stage, label, timestamp, confidence);

  /// Create a copy of StageTransition
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StageTransitionImplCopyWith<_$StageTransitionImpl> get copyWith =>
      __$$StageTransitionImplCopyWithImpl<_$StageTransitionImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StageTransitionImplToJson(
      this,
    );
  }
}

abstract class _StageTransition implements StageTransition {
  const factory _StageTransition(
      {required final String stage,
      required final String label,
      required final DateTime timestamp,
      final double confidence}) = _$StageTransitionImpl;

  factory _StageTransition.fromJson(Map<String, dynamic> json) =
      _$StageTransitionImpl.fromJson;

  @override
  String get stage;
  @override
  String get label;
  @override
  DateTime get timestamp;
  @override
  double get confidence;

  /// Create a copy of StageTransition
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StageTransitionImplCopyWith<_$StageTransitionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
