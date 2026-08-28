// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'campaign_alert.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CampaignAlert _$CampaignAlertFromJson(Map<String, dynamic> json) {
  return _CampaignAlert.fromJson(json);
}

/// @nodoc
mixin _$CampaignAlert {
  String get campaignId => throw _privateConstructorUsedError;
  int get cumulativeRisk => throw _privateConstructorUsedError;
  String get threatLevel => throw _privateConstructorUsedError;
  String get plainLanguageWarning => throw _privateConstructorUsedError;
  DateTime? get timestamp => throw _privateConstructorUsedError;
  String? get source => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;

  /// Serializes this CampaignAlert to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CampaignAlert
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CampaignAlertCopyWith<CampaignAlert> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CampaignAlertCopyWith<$Res> {
  factory $CampaignAlertCopyWith(
          CampaignAlert value, $Res Function(CampaignAlert) then) =
      _$CampaignAlertCopyWithImpl<$Res, CampaignAlert>;
  @useResult
  $Res call(
      {String campaignId,
      int cumulativeRisk,
      String threatLevel,
      String plainLanguageWarning,
      DateTime? timestamp,
      String? source,
      Map<String, dynamic>? metadata});
}

/// @nodoc
class _$CampaignAlertCopyWithImpl<$Res, $Val extends CampaignAlert>
    implements $CampaignAlertCopyWith<$Res> {
  _$CampaignAlertCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CampaignAlert
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? campaignId = null,
    Object? cumulativeRisk = null,
    Object? threatLevel = null,
    Object? plainLanguageWarning = null,
    Object? timestamp = freezed,
    Object? source = freezed,
    Object? metadata = freezed,
  }) {
    return _then(_value.copyWith(
      campaignId: null == campaignId
          ? _value.campaignId
          : campaignId // ignore: cast_nullable_to_non_nullable
              as String,
      cumulativeRisk: null == cumulativeRisk
          ? _value.cumulativeRisk
          : cumulativeRisk // ignore: cast_nullable_to_non_nullable
              as int,
      threatLevel: null == threatLevel
          ? _value.threatLevel
          : threatLevel // ignore: cast_nullable_to_non_nullable
              as String,
      plainLanguageWarning: null == plainLanguageWarning
          ? _value.plainLanguageWarning
          : plainLanguageWarning // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: freezed == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      source: freezed == source
          ? _value.source
          : source // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: freezed == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CampaignAlertImplCopyWith<$Res>
    implements $CampaignAlertCopyWith<$Res> {
  factory _$$CampaignAlertImplCopyWith(
          _$CampaignAlertImpl value, $Res Function(_$CampaignAlertImpl) then) =
      __$$CampaignAlertImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String campaignId,
      int cumulativeRisk,
      String threatLevel,
      String plainLanguageWarning,
      DateTime? timestamp,
      String? source,
      Map<String, dynamic>? metadata});
}

/// @nodoc
class __$$CampaignAlertImplCopyWithImpl<$Res>
    extends _$CampaignAlertCopyWithImpl<$Res, _$CampaignAlertImpl>
    implements _$$CampaignAlertImplCopyWith<$Res> {
  __$$CampaignAlertImplCopyWithImpl(
      _$CampaignAlertImpl _value, $Res Function(_$CampaignAlertImpl) _then)
      : super(_value, _then);

  /// Create a copy of CampaignAlert
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? campaignId = null,
    Object? cumulativeRisk = null,
    Object? threatLevel = null,
    Object? plainLanguageWarning = null,
    Object? timestamp = freezed,
    Object? source = freezed,
    Object? metadata = freezed,
  }) {
    return _then(_$CampaignAlertImpl(
      campaignId: null == campaignId
          ? _value.campaignId
          : campaignId // ignore: cast_nullable_to_non_nullable
              as String,
      cumulativeRisk: null == cumulativeRisk
          ? _value.cumulativeRisk
          : cumulativeRisk // ignore: cast_nullable_to_non_nullable
              as int,
      threatLevel: null == threatLevel
          ? _value.threatLevel
          : threatLevel // ignore: cast_nullable_to_non_nullable
              as String,
      plainLanguageWarning: null == plainLanguageWarning
          ? _value.plainLanguageWarning
          : plainLanguageWarning // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: freezed == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      source: freezed == source
          ? _value.source
          : source // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: freezed == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CampaignAlertImpl implements _CampaignAlert {
  const _$CampaignAlertImpl(
      {required this.campaignId,
      required this.cumulativeRisk,
      required this.threatLevel,
      required this.plainLanguageWarning,
      this.timestamp,
      this.source,
      final Map<String, dynamic>? metadata})
      : _metadata = metadata;

  factory _$CampaignAlertImpl.fromJson(Map<String, dynamic> json) =>
      _$$CampaignAlertImplFromJson(json);

  @override
  final String campaignId;
  @override
  final int cumulativeRisk;
  @override
  final String threatLevel;
  @override
  final String plainLanguageWarning;
  @override
  final DateTime? timestamp;
  @override
  final String? source;
  final Map<String, dynamic>? _metadata;
  @override
  Map<String, dynamic>? get metadata {
    final value = _metadata;
    if (value == null) return null;
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'CampaignAlert(campaignId: $campaignId, cumulativeRisk: $cumulativeRisk, threatLevel: $threatLevel, plainLanguageWarning: $plainLanguageWarning, timestamp: $timestamp, source: $source, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CampaignAlertImpl &&
            (identical(other.campaignId, campaignId) ||
                other.campaignId == campaignId) &&
            (identical(other.cumulativeRisk, cumulativeRisk) ||
                other.cumulativeRisk == cumulativeRisk) &&
            (identical(other.threatLevel, threatLevel) ||
                other.threatLevel == threatLevel) &&
            (identical(other.plainLanguageWarning, plainLanguageWarning) ||
                other.plainLanguageWarning == plainLanguageWarning) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.source, source) || other.source == source) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      campaignId,
      cumulativeRisk,
      threatLevel,
      plainLanguageWarning,
      timestamp,
      source,
      const DeepCollectionEquality().hash(_metadata));

  /// Create a copy of CampaignAlert
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CampaignAlertImplCopyWith<_$CampaignAlertImpl> get copyWith =>
      __$$CampaignAlertImplCopyWithImpl<_$CampaignAlertImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CampaignAlertImplToJson(
      this,
    );
  }
}

abstract class _CampaignAlert implements CampaignAlert {
  const factory _CampaignAlert(
      {required final String campaignId,
      required final int cumulativeRisk,
      required final String threatLevel,
      required final String plainLanguageWarning,
      final DateTime? timestamp,
      final String? source,
      final Map<String, dynamic>? metadata}) = _$CampaignAlertImpl;

  factory _CampaignAlert.fromJson(Map<String, dynamic> json) =
      _$CampaignAlertImpl.fromJson;

  @override
  String get campaignId;
  @override
  int get cumulativeRisk;
  @override
  String get threatLevel;
  @override
  String get plainLanguageWarning;
  @override
  DateTime? get timestamp;
  @override
  String? get source;
  @override
  Map<String, dynamic>? get metadata;

  /// Create a copy of CampaignAlert
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CampaignAlertImplCopyWith<_$CampaignAlertImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
