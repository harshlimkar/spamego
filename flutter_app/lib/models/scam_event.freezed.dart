// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'scam_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ScamEvent _$ScamEventFromJson(Map<String, dynamic> json) {
  return _ScamEvent.fromJson(json);
}

/// @nodoc
mixin _$ScamEvent {
  String get id => throw _privateConstructorUsedError;
  String get channel => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;
  String get sender => throw _privateConstructorUsedError;
  String get text => throw _privateConstructorUsedError;
  String get normalized => throw _privateConstructorUsedError;
  String get language => throw _privateConstructorUsedError;
  String get verdict => throw _privateConstructorUsedError;
  String get headline => throw _privateConstructorUsedError;
  RiskResult get risk => throw _privateConstructorUsedError;
  CampaignInfo get campaign => throw _privateConstructorUsedError;
  Intervention get intervention => throw _privateConstructorUsedError;
  FamilyAlertDecision get familyAlert => throw _privateConstructorUsedError;
  RecoveryPlan? get recovery => throw _privateConstructorUsedError;
  String? get supportSms => throw _privateConstructorUsedError;
  Map<String, dynamic>? get entities => throw _privateConstructorUsedError;
  List<Intent>? get intents => throw _privateConstructorUsedError;
  ScamStage? get stage => throw _privateConstructorUsedError;
  List<LinkFinding>? get linkFindings => throw _privateConstructorUsedError;
  OtpFinding? get otp => throw _privateConstructorUsedError;
  Verification? get verification => throw _privateConstructorUsedError;
  Map<String, dynamic>? get ml => throw _privateConstructorUsedError;

  /// Serializes this ScamEvent to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ScamEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ScamEventCopyWith<ScamEvent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ScamEventCopyWith<$Res> {
  factory $ScamEventCopyWith(ScamEvent value, $Res Function(ScamEvent) then) =
      _$ScamEventCopyWithImpl<$Res, ScamEvent>;
  @useResult
  $Res call(
      {String id,
      String channel,
      DateTime timestamp,
      String sender,
      String text,
      String normalized,
      String language,
      String verdict,
      String headline,
      RiskResult risk,
      CampaignInfo campaign,
      Intervention intervention,
      FamilyAlertDecision familyAlert,
      RecoveryPlan? recovery,
      String? supportSms,
      Map<String, dynamic>? entities,
      List<Intent>? intents,
      ScamStage? stage,
      List<LinkFinding>? linkFindings,
      OtpFinding? otp,
      Verification? verification,
      Map<String, dynamic>? ml});

  $RiskResultCopyWith<$Res> get risk;
  $CampaignInfoCopyWith<$Res> get campaign;
  $InterventionCopyWith<$Res> get intervention;
  $FamilyAlertDecisionCopyWith<$Res> get familyAlert;
  $RecoveryPlanCopyWith<$Res>? get recovery;
  $ScamStageCopyWith<$Res>? get stage;
  $OtpFindingCopyWith<$Res>? get otp;
  $VerificationCopyWith<$Res>? get verification;
}

/// @nodoc
class _$ScamEventCopyWithImpl<$Res, $Val extends ScamEvent>
    implements $ScamEventCopyWith<$Res> {
  _$ScamEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ScamEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? channel = null,
    Object? timestamp = null,
    Object? sender = null,
    Object? text = null,
    Object? normalized = null,
    Object? language = null,
    Object? verdict = null,
    Object? headline = null,
    Object? risk = null,
    Object? campaign = null,
    Object? intervention = null,
    Object? familyAlert = null,
    Object? recovery = freezed,
    Object? supportSms = freezed,
    Object? entities = freezed,
    Object? intents = freezed,
    Object? stage = freezed,
    Object? linkFindings = freezed,
    Object? otp = freezed,
    Object? verification = freezed,
    Object? ml = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      channel: null == channel
          ? _value.channel
          : channel // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      sender: null == sender
          ? _value.sender
          : sender // ignore: cast_nullable_to_non_nullable
              as String,
      text: null == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      normalized: null == normalized
          ? _value.normalized
          : normalized // ignore: cast_nullable_to_non_nullable
              as String,
      language: null == language
          ? _value.language
          : language // ignore: cast_nullable_to_non_nullable
              as String,
      verdict: null == verdict
          ? _value.verdict
          : verdict // ignore: cast_nullable_to_non_nullable
              as String,
      headline: null == headline
          ? _value.headline
          : headline // ignore: cast_nullable_to_non_nullable
              as String,
      risk: null == risk
          ? _value.risk
          : risk // ignore: cast_nullable_to_non_nullable
              as RiskResult,
      campaign: null == campaign
          ? _value.campaign
          : campaign // ignore: cast_nullable_to_non_nullable
              as CampaignInfo,
      intervention: null == intervention
          ? _value.intervention
          : intervention // ignore: cast_nullable_to_non_nullable
              as Intervention,
      familyAlert: null == familyAlert
          ? _value.familyAlert
          : familyAlert // ignore: cast_nullable_to_non_nullable
              as FamilyAlertDecision,
      recovery: freezed == recovery
          ? _value.recovery
          : recovery // ignore: cast_nullable_to_non_nullable
              as RecoveryPlan?,
      supportSms: freezed == supportSms
          ? _value.supportSms
          : supportSms // ignore: cast_nullable_to_non_nullable
              as String?,
      entities: freezed == entities
          ? _value.entities
          : entities // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      intents: freezed == intents
          ? _value.intents
          : intents // ignore: cast_nullable_to_non_nullable
              as List<Intent>?,
      stage: freezed == stage
          ? _value.stage
          : stage // ignore: cast_nullable_to_non_nullable
              as ScamStage?,
      linkFindings: freezed == linkFindings
          ? _value.linkFindings
          : linkFindings // ignore: cast_nullable_to_non_nullable
              as List<LinkFinding>?,
      otp: freezed == otp
          ? _value.otp
          : otp // ignore: cast_nullable_to_non_nullable
              as OtpFinding?,
      verification: freezed == verification
          ? _value.verification
          : verification // ignore: cast_nullable_to_non_nullable
              as Verification?,
      ml: freezed == ml
          ? _value.ml
          : ml // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
  }

  /// Create a copy of ScamEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $RiskResultCopyWith<$Res> get risk {
    return $RiskResultCopyWith<$Res>(_value.risk, (value) {
      return _then(_value.copyWith(risk: value) as $Val);
    });
  }

  /// Create a copy of ScamEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CampaignInfoCopyWith<$Res> get campaign {
    return $CampaignInfoCopyWith<$Res>(_value.campaign, (value) {
      return _then(_value.copyWith(campaign: value) as $Val);
    });
  }

  /// Create a copy of ScamEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $InterventionCopyWith<$Res> get intervention {
    return $InterventionCopyWith<$Res>(_value.intervention, (value) {
      return _then(_value.copyWith(intervention: value) as $Val);
    });
  }

  /// Create a copy of ScamEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $FamilyAlertDecisionCopyWith<$Res> get familyAlert {
    return $FamilyAlertDecisionCopyWith<$Res>(_value.familyAlert, (value) {
      return _then(_value.copyWith(familyAlert: value) as $Val);
    });
  }

  /// Create a copy of ScamEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $RecoveryPlanCopyWith<$Res>? get recovery {
    if (_value.recovery == null) {
      return null;
    }

    return $RecoveryPlanCopyWith<$Res>(_value.recovery!, (value) {
      return _then(_value.copyWith(recovery: value) as $Val);
    });
  }

  /// Create a copy of ScamEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ScamStageCopyWith<$Res>? get stage {
    if (_value.stage == null) {
      return null;
    }

    return $ScamStageCopyWith<$Res>(_value.stage!, (value) {
      return _then(_value.copyWith(stage: value) as $Val);
    });
  }

  /// Create a copy of ScamEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $OtpFindingCopyWith<$Res>? get otp {
    if (_value.otp == null) {
      return null;
    }

    return $OtpFindingCopyWith<$Res>(_value.otp!, (value) {
      return _then(_value.copyWith(otp: value) as $Val);
    });
  }

  /// Create a copy of ScamEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $VerificationCopyWith<$Res>? get verification {
    if (_value.verification == null) {
      return null;
    }

    return $VerificationCopyWith<$Res>(_value.verification!, (value) {
      return _then(_value.copyWith(verification: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ScamEventImplCopyWith<$Res>
    implements $ScamEventCopyWith<$Res> {
  factory _$$ScamEventImplCopyWith(
          _$ScamEventImpl value, $Res Function(_$ScamEventImpl) then) =
      __$$ScamEventImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String channel,
      DateTime timestamp,
      String sender,
      String text,
      String normalized,
      String language,
      String verdict,
      String headline,
      RiskResult risk,
      CampaignInfo campaign,
      Intervention intervention,
      FamilyAlertDecision familyAlert,
      RecoveryPlan? recovery,
      String? supportSms,
      Map<String, dynamic>? entities,
      List<Intent>? intents,
      ScamStage? stage,
      List<LinkFinding>? linkFindings,
      OtpFinding? otp,
      Verification? verification,
      Map<String, dynamic>? ml});

  @override
  $RiskResultCopyWith<$Res> get risk;
  @override
  $CampaignInfoCopyWith<$Res> get campaign;
  @override
  $InterventionCopyWith<$Res> get intervention;
  @override
  $FamilyAlertDecisionCopyWith<$Res> get familyAlert;
  @override
  $RecoveryPlanCopyWith<$Res>? get recovery;
  @override
  $ScamStageCopyWith<$Res>? get stage;
  @override
  $OtpFindingCopyWith<$Res>? get otp;
  @override
  $VerificationCopyWith<$Res>? get verification;
}

/// @nodoc
class __$$ScamEventImplCopyWithImpl<$Res>
    extends _$ScamEventCopyWithImpl<$Res, _$ScamEventImpl>
    implements _$$ScamEventImplCopyWith<$Res> {
  __$$ScamEventImplCopyWithImpl(
      _$ScamEventImpl _value, $Res Function(_$ScamEventImpl) _then)
      : super(_value, _then);

  /// Create a copy of ScamEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? channel = null,
    Object? timestamp = null,
    Object? sender = null,
    Object? text = null,
    Object? normalized = null,
    Object? language = null,
    Object? verdict = null,
    Object? headline = null,
    Object? risk = null,
    Object? campaign = null,
    Object? intervention = null,
    Object? familyAlert = null,
    Object? recovery = freezed,
    Object? supportSms = freezed,
    Object? entities = freezed,
    Object? intents = freezed,
    Object? stage = freezed,
    Object? linkFindings = freezed,
    Object? otp = freezed,
    Object? verification = freezed,
    Object? ml = freezed,
  }) {
    return _then(_$ScamEventImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      channel: null == channel
          ? _value.channel
          : channel // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      sender: null == sender
          ? _value.sender
          : sender // ignore: cast_nullable_to_non_nullable
              as String,
      text: null == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      normalized: null == normalized
          ? _value.normalized
          : normalized // ignore: cast_nullable_to_non_nullable
              as String,
      language: null == language
          ? _value.language
          : language // ignore: cast_nullable_to_non_nullable
              as String,
      verdict: null == verdict
          ? _value.verdict
          : verdict // ignore: cast_nullable_to_non_nullable
              as String,
      headline: null == headline
          ? _value.headline
          : headline // ignore: cast_nullable_to_non_nullable
              as String,
      risk: null == risk
          ? _value.risk
          : risk // ignore: cast_nullable_to_non_nullable
              as RiskResult,
      campaign: null == campaign
          ? _value.campaign
          : campaign // ignore: cast_nullable_to_non_nullable
              as CampaignInfo,
      intervention: null == intervention
          ? _value.intervention
          : intervention // ignore: cast_nullable_to_non_nullable
              as Intervention,
      familyAlert: null == familyAlert
          ? _value.familyAlert
          : familyAlert // ignore: cast_nullable_to_non_nullable
              as FamilyAlertDecision,
      recovery: freezed == recovery
          ? _value.recovery
          : recovery // ignore: cast_nullable_to_non_nullable
              as RecoveryPlan?,
      supportSms: freezed == supportSms
          ? _value.supportSms
          : supportSms // ignore: cast_nullable_to_non_nullable
              as String?,
      entities: freezed == entities
          ? _value._entities
          : entities // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      intents: freezed == intents
          ? _value._intents
          : intents // ignore: cast_nullable_to_non_nullable
              as List<Intent>?,
      stage: freezed == stage
          ? _value.stage
          : stage // ignore: cast_nullable_to_non_nullable
              as ScamStage?,
      linkFindings: freezed == linkFindings
          ? _value._linkFindings
          : linkFindings // ignore: cast_nullable_to_non_nullable
              as List<LinkFinding>?,
      otp: freezed == otp
          ? _value.otp
          : otp // ignore: cast_nullable_to_non_nullable
              as OtpFinding?,
      verification: freezed == verification
          ? _value.verification
          : verification // ignore: cast_nullable_to_non_nullable
              as Verification?,
      ml: freezed == ml
          ? _value._ml
          : ml // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ScamEventImpl implements _ScamEvent {
  const _$ScamEventImpl(
      {required this.id,
      required this.channel,
      required this.timestamp,
      required this.sender,
      required this.text,
      required this.normalized,
      required this.language,
      required this.verdict,
      required this.headline,
      required this.risk,
      required this.campaign,
      required this.intervention,
      required this.familyAlert,
      this.recovery,
      this.supportSms,
      final Map<String, dynamic>? entities,
      final List<Intent>? intents,
      this.stage,
      final List<LinkFinding>? linkFindings,
      this.otp,
      this.verification,
      final Map<String, dynamic>? ml})
      : _entities = entities,
        _intents = intents,
        _linkFindings = linkFindings,
        _ml = ml;

  factory _$ScamEventImpl.fromJson(Map<String, dynamic> json) =>
      _$$ScamEventImplFromJson(json);

  @override
  final String id;
  @override
  final String channel;
  @override
  final DateTime timestamp;
  @override
  final String sender;
  @override
  final String text;
  @override
  final String normalized;
  @override
  final String language;
  @override
  final String verdict;
  @override
  final String headline;
  @override
  final RiskResult risk;
  @override
  final CampaignInfo campaign;
  @override
  final Intervention intervention;
  @override
  final FamilyAlertDecision familyAlert;
  @override
  final RecoveryPlan? recovery;
  @override
  final String? supportSms;
  final Map<String, dynamic>? _entities;
  @override
  Map<String, dynamic>? get entities {
    final value = _entities;
    if (value == null) return null;
    if (_entities is EqualUnmodifiableMapView) return _entities;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  final List<Intent>? _intents;
  @override
  List<Intent>? get intents {
    final value = _intents;
    if (value == null) return null;
    if (_intents is EqualUnmodifiableListView) return _intents;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final ScamStage? stage;
  final List<LinkFinding>? _linkFindings;
  @override
  List<LinkFinding>? get linkFindings {
    final value = _linkFindings;
    if (value == null) return null;
    if (_linkFindings is EqualUnmodifiableListView) return _linkFindings;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final OtpFinding? otp;
  @override
  final Verification? verification;
  final Map<String, dynamic>? _ml;
  @override
  Map<String, dynamic>? get ml {
    final value = _ml;
    if (value == null) return null;
    if (_ml is EqualUnmodifiableMapView) return _ml;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'ScamEvent(id: $id, channel: $channel, timestamp: $timestamp, sender: $sender, text: $text, normalized: $normalized, language: $language, verdict: $verdict, headline: $headline, risk: $risk, campaign: $campaign, intervention: $intervention, familyAlert: $familyAlert, recovery: $recovery, supportSms: $supportSms, entities: $entities, intents: $intents, stage: $stage, linkFindings: $linkFindings, otp: $otp, verification: $verification, ml: $ml)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ScamEventImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.channel, channel) || other.channel == channel) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.sender, sender) || other.sender == sender) &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.normalized, normalized) ||
                other.normalized == normalized) &&
            (identical(other.language, language) ||
                other.language == language) &&
            (identical(other.verdict, verdict) || other.verdict == verdict) &&
            (identical(other.headline, headline) ||
                other.headline == headline) &&
            (identical(other.risk, risk) || other.risk == risk) &&
            (identical(other.campaign, campaign) ||
                other.campaign == campaign) &&
            (identical(other.intervention, intervention) ||
                other.intervention == intervention) &&
            (identical(other.familyAlert, familyAlert) ||
                other.familyAlert == familyAlert) &&
            (identical(other.recovery, recovery) ||
                other.recovery == recovery) &&
            (identical(other.supportSms, supportSms) ||
                other.supportSms == supportSms) &&
            const DeepCollectionEquality().equals(other._entities, _entities) &&
            const DeepCollectionEquality().equals(other._intents, _intents) &&
            (identical(other.stage, stage) || other.stage == stage) &&
            const DeepCollectionEquality()
                .equals(other._linkFindings, _linkFindings) &&
            (identical(other.otp, otp) || other.otp == otp) &&
            (identical(other.verification, verification) ||
                other.verification == verification) &&
            const DeepCollectionEquality().equals(other._ml, _ml));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        channel,
        timestamp,
        sender,
        text,
        normalized,
        language,
        verdict,
        headline,
        risk,
        campaign,
        intervention,
        familyAlert,
        recovery,
        supportSms,
        const DeepCollectionEquality().hash(_entities),
        const DeepCollectionEquality().hash(_intents),
        stage,
        const DeepCollectionEquality().hash(_linkFindings),
        otp,
        verification,
        const DeepCollectionEquality().hash(_ml)
      ]);

  /// Create a copy of ScamEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ScamEventImplCopyWith<_$ScamEventImpl> get copyWith =>
      __$$ScamEventImplCopyWithImpl<_$ScamEventImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ScamEventImplToJson(
      this,
    );
  }
}

abstract class _ScamEvent implements ScamEvent {
  const factory _ScamEvent(
      {required final String id,
      required final String channel,
      required final DateTime timestamp,
      required final String sender,
      required final String text,
      required final String normalized,
      required final String language,
      required final String verdict,
      required final String headline,
      required final RiskResult risk,
      required final CampaignInfo campaign,
      required final Intervention intervention,
      required final FamilyAlertDecision familyAlert,
      final RecoveryPlan? recovery,
      final String? supportSms,
      final Map<String, dynamic>? entities,
      final List<Intent>? intents,
      final ScamStage? stage,
      final List<LinkFinding>? linkFindings,
      final OtpFinding? otp,
      final Verification? verification,
      final Map<String, dynamic>? ml}) = _$ScamEventImpl;

  factory _ScamEvent.fromJson(Map<String, dynamic> json) =
      _$ScamEventImpl.fromJson;

  @override
  String get id;
  @override
  String get channel;
  @override
  DateTime get timestamp;
  @override
  String get sender;
  @override
  String get text;
  @override
  String get normalized;
  @override
  String get language;
  @override
  String get verdict;
  @override
  String get headline;
  @override
  RiskResult get risk;
  @override
  CampaignInfo get campaign;
  @override
  Intervention get intervention;
  @override
  FamilyAlertDecision get familyAlert;
  @override
  RecoveryPlan? get recovery;
  @override
  String? get supportSms;
  @override
  Map<String, dynamic>? get entities;
  @override
  List<Intent>? get intents;
  @override
  ScamStage? get stage;
  @override
  List<LinkFinding>? get linkFindings;
  @override
  OtpFinding? get otp;
  @override
  Verification? get verification;
  @override
  Map<String, dynamic>? get ml;

  /// Create a copy of ScamEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ScamEventImplCopyWith<_$ScamEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RiskResult _$RiskResultFromJson(Map<String, dynamic> json) {
  return _RiskResult.fromJson(json);
}

/// @nodoc
mixin _$RiskResult {
  int get score => throw _privateConstructorUsedError;
  String get level => throw _privateConstructorUsedError;
  int get edgeScore => throw _privateConstructorUsedError;
  double get confidence => throw _privateConstructorUsedError;
  bool get isLegitimateSignal => throw _privateConstructorUsedError;
  Map<String, dynamic>? get factors => throw _privateConstructorUsedError;
  List<String>? get explanations => throw _privateConstructorUsedError;

  /// Serializes this RiskResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RiskResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RiskResultCopyWith<RiskResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RiskResultCopyWith<$Res> {
  factory $RiskResultCopyWith(
          RiskResult value, $Res Function(RiskResult) then) =
      _$RiskResultCopyWithImpl<$Res, RiskResult>;
  @useResult
  $Res call(
      {int score,
      String level,
      int edgeScore,
      double confidence,
      bool isLegitimateSignal,
      Map<String, dynamic>? factors,
      List<String>? explanations});
}

/// @nodoc
class _$RiskResultCopyWithImpl<$Res, $Val extends RiskResult>
    implements $RiskResultCopyWith<$Res> {
  _$RiskResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RiskResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? score = null,
    Object? level = null,
    Object? edgeScore = null,
    Object? confidence = null,
    Object? isLegitimateSignal = null,
    Object? factors = freezed,
    Object? explanations = freezed,
  }) {
    return _then(_value.copyWith(
      score: null == score
          ? _value.score
          : score // ignore: cast_nullable_to_non_nullable
              as int,
      level: null == level
          ? _value.level
          : level // ignore: cast_nullable_to_non_nullable
              as String,
      edgeScore: null == edgeScore
          ? _value.edgeScore
          : edgeScore // ignore: cast_nullable_to_non_nullable
              as int,
      confidence: null == confidence
          ? _value.confidence
          : confidence // ignore: cast_nullable_to_non_nullable
              as double,
      isLegitimateSignal: null == isLegitimateSignal
          ? _value.isLegitimateSignal
          : isLegitimateSignal // ignore: cast_nullable_to_non_nullable
              as bool,
      factors: freezed == factors
          ? _value.factors
          : factors // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      explanations: freezed == explanations
          ? _value.explanations
          : explanations // ignore: cast_nullable_to_non_nullable
              as List<String>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RiskResultImplCopyWith<$Res>
    implements $RiskResultCopyWith<$Res> {
  factory _$$RiskResultImplCopyWith(
          _$RiskResultImpl value, $Res Function(_$RiskResultImpl) then) =
      __$$RiskResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int score,
      String level,
      int edgeScore,
      double confidence,
      bool isLegitimateSignal,
      Map<String, dynamic>? factors,
      List<String>? explanations});
}

/// @nodoc
class __$$RiskResultImplCopyWithImpl<$Res>
    extends _$RiskResultCopyWithImpl<$Res, _$RiskResultImpl>
    implements _$$RiskResultImplCopyWith<$Res> {
  __$$RiskResultImplCopyWithImpl(
      _$RiskResultImpl _value, $Res Function(_$RiskResultImpl) _then)
      : super(_value, _then);

  /// Create a copy of RiskResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? score = null,
    Object? level = null,
    Object? edgeScore = null,
    Object? confidence = null,
    Object? isLegitimateSignal = null,
    Object? factors = freezed,
    Object? explanations = freezed,
  }) {
    return _then(_$RiskResultImpl(
      score: null == score
          ? _value.score
          : score // ignore: cast_nullable_to_non_nullable
              as int,
      level: null == level
          ? _value.level
          : level // ignore: cast_nullable_to_non_nullable
              as String,
      edgeScore: null == edgeScore
          ? _value.edgeScore
          : edgeScore // ignore: cast_nullable_to_non_nullable
              as int,
      confidence: null == confidence
          ? _value.confidence
          : confidence // ignore: cast_nullable_to_non_nullable
              as double,
      isLegitimateSignal: null == isLegitimateSignal
          ? _value.isLegitimateSignal
          : isLegitimateSignal // ignore: cast_nullable_to_non_nullable
              as bool,
      factors: freezed == factors
          ? _value._factors
          : factors // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      explanations: freezed == explanations
          ? _value._explanations
          : explanations // ignore: cast_nullable_to_non_nullable
              as List<String>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RiskResultImpl implements _RiskResult {
  const _$RiskResultImpl(
      {required this.score,
      required this.level,
      this.edgeScore = 0,
      this.confidence = 0.0,
      this.isLegitimateSignal = false,
      final Map<String, dynamic>? factors,
      final List<String>? explanations})
      : _factors = factors,
        _explanations = explanations;

  factory _$RiskResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$RiskResultImplFromJson(json);

  @override
  final int score;
  @override
  final String level;
  @override
  @JsonKey()
  final int edgeScore;
  @override
  @JsonKey()
  final double confidence;
  @override
  @JsonKey()
  final bool isLegitimateSignal;
  final Map<String, dynamic>? _factors;
  @override
  Map<String, dynamic>? get factors {
    final value = _factors;
    if (value == null) return null;
    if (_factors is EqualUnmodifiableMapView) return _factors;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  final List<String>? _explanations;
  @override
  List<String>? get explanations {
    final value = _explanations;
    if (value == null) return null;
    if (_explanations is EqualUnmodifiableListView) return _explanations;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'RiskResult(score: $score, level: $level, edgeScore: $edgeScore, confidence: $confidence, isLegitimateSignal: $isLegitimateSignal, factors: $factors, explanations: $explanations)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RiskResultImpl &&
            (identical(other.score, score) || other.score == score) &&
            (identical(other.level, level) || other.level == level) &&
            (identical(other.edgeScore, edgeScore) ||
                other.edgeScore == edgeScore) &&
            (identical(other.confidence, confidence) ||
                other.confidence == confidence) &&
            (identical(other.isLegitimateSignal, isLegitimateSignal) ||
                other.isLegitimateSignal == isLegitimateSignal) &&
            const DeepCollectionEquality().equals(other._factors, _factors) &&
            const DeepCollectionEquality()
                .equals(other._explanations, _explanations));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      score,
      level,
      edgeScore,
      confidence,
      isLegitimateSignal,
      const DeepCollectionEquality().hash(_factors),
      const DeepCollectionEquality().hash(_explanations));

  /// Create a copy of RiskResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RiskResultImplCopyWith<_$RiskResultImpl> get copyWith =>
      __$$RiskResultImplCopyWithImpl<_$RiskResultImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RiskResultImplToJson(
      this,
    );
  }
}

abstract class _RiskResult implements RiskResult {
  const factory _RiskResult(
      {required final int score,
      required final String level,
      final int edgeScore,
      final double confidence,
      final bool isLegitimateSignal,
      final Map<String, dynamic>? factors,
      final List<String>? explanations}) = _$RiskResultImpl;

  factory _RiskResult.fromJson(Map<String, dynamic> json) =
      _$RiskResultImpl.fromJson;

  @override
  int get score;
  @override
  String get level;
  @override
  int get edgeScore;
  @override
  double get confidence;
  @override
  bool get isLegitimateSignal;
  @override
  Map<String, dynamic>? get factors;
  @override
  List<String>? get explanations;

  /// Create a copy of RiskResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RiskResultImplCopyWith<_$RiskResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CampaignInfo _$CampaignInfoFromJson(Map<String, dynamic> json) {
  return _CampaignInfo.fromJson(json);
}

/// @nodoc
mixin _$CampaignInfo {
  String get campaignId => throw _privateConstructorUsedError;
  int get riskScore => throw _privateConstructorUsedError;
  String get riskLevel => throw _privateConstructorUsedError;
  List<String>? get categories => throw _privateConstructorUsedError;
  List<Map<String, dynamic>>? get stageHistory =>
      throw _privateConstructorUsedError;
  double? get velocitySeconds => throw _privateConstructorUsedError;
  List<String>? get progressionLabels => throw _privateConstructorUsedError;
  Exposure? get exposure => throw _privateConstructorUsedError;
  int get eventCount => throw _privateConstructorUsedError;
  List<String>? get channels => throw _privateConstructorUsedError;
  String get createdAt => throw _privateConstructorUsedError;
  String get updatedAt => throw _privateConstructorUsedError;
  bool get isNew => throw _privateConstructorUsedError;

  /// Serializes this CampaignInfo to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CampaignInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CampaignInfoCopyWith<CampaignInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CampaignInfoCopyWith<$Res> {
  factory $CampaignInfoCopyWith(
          CampaignInfo value, $Res Function(CampaignInfo) then) =
      _$CampaignInfoCopyWithImpl<$Res, CampaignInfo>;
  @useResult
  $Res call(
      {String campaignId,
      int riskScore,
      String riskLevel,
      List<String>? categories,
      List<Map<String, dynamic>>? stageHistory,
      double? velocitySeconds,
      List<String>? progressionLabels,
      Exposure? exposure,
      int eventCount,
      List<String>? channels,
      String createdAt,
      String updatedAt,
      bool isNew});

  $ExposureCopyWith<$Res>? get exposure;
}

/// @nodoc
class _$CampaignInfoCopyWithImpl<$Res, $Val extends CampaignInfo>
    implements $CampaignInfoCopyWith<$Res> {
  _$CampaignInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CampaignInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? campaignId = null,
    Object? riskScore = null,
    Object? riskLevel = null,
    Object? categories = freezed,
    Object? stageHistory = freezed,
    Object? velocitySeconds = freezed,
    Object? progressionLabels = freezed,
    Object? exposure = freezed,
    Object? eventCount = null,
    Object? channels = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? isNew = null,
  }) {
    return _then(_value.copyWith(
      campaignId: null == campaignId
          ? _value.campaignId
          : campaignId // ignore: cast_nullable_to_non_nullable
              as String,
      riskScore: null == riskScore
          ? _value.riskScore
          : riskScore // ignore: cast_nullable_to_non_nullable
              as int,
      riskLevel: null == riskLevel
          ? _value.riskLevel
          : riskLevel // ignore: cast_nullable_to_non_nullable
              as String,
      categories: freezed == categories
          ? _value.categories
          : categories // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      stageHistory: freezed == stageHistory
          ? _value.stageHistory
          : stageHistory // ignore: cast_nullable_to_non_nullable
              as List<Map<String, dynamic>>?,
      velocitySeconds: freezed == velocitySeconds
          ? _value.velocitySeconds
          : velocitySeconds // ignore: cast_nullable_to_non_nullable
              as double?,
      progressionLabels: freezed == progressionLabels
          ? _value.progressionLabels
          : progressionLabels // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      exposure: freezed == exposure
          ? _value.exposure
          : exposure // ignore: cast_nullable_to_non_nullable
              as Exposure?,
      eventCount: null == eventCount
          ? _value.eventCount
          : eventCount // ignore: cast_nullable_to_non_nullable
              as int,
      channels: freezed == channels
          ? _value.channels
          : channels // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String,
      isNew: null == isNew
          ? _value.isNew
          : isNew // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }

  /// Create a copy of CampaignInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ExposureCopyWith<$Res>? get exposure {
    if (_value.exposure == null) {
      return null;
    }

    return $ExposureCopyWith<$Res>(_value.exposure!, (value) {
      return _then(_value.copyWith(exposure: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CampaignInfoImplCopyWith<$Res>
    implements $CampaignInfoCopyWith<$Res> {
  factory _$$CampaignInfoImplCopyWith(
          _$CampaignInfoImpl value, $Res Function(_$CampaignInfoImpl) then) =
      __$$CampaignInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String campaignId,
      int riskScore,
      String riskLevel,
      List<String>? categories,
      List<Map<String, dynamic>>? stageHistory,
      double? velocitySeconds,
      List<String>? progressionLabels,
      Exposure? exposure,
      int eventCount,
      List<String>? channels,
      String createdAt,
      String updatedAt,
      bool isNew});

  @override
  $ExposureCopyWith<$Res>? get exposure;
}

/// @nodoc
class __$$CampaignInfoImplCopyWithImpl<$Res>
    extends _$CampaignInfoCopyWithImpl<$Res, _$CampaignInfoImpl>
    implements _$$CampaignInfoImplCopyWith<$Res> {
  __$$CampaignInfoImplCopyWithImpl(
      _$CampaignInfoImpl _value, $Res Function(_$CampaignInfoImpl) _then)
      : super(_value, _then);

  /// Create a copy of CampaignInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? campaignId = null,
    Object? riskScore = null,
    Object? riskLevel = null,
    Object? categories = freezed,
    Object? stageHistory = freezed,
    Object? velocitySeconds = freezed,
    Object? progressionLabels = freezed,
    Object? exposure = freezed,
    Object? eventCount = null,
    Object? channels = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? isNew = null,
  }) {
    return _then(_$CampaignInfoImpl(
      campaignId: null == campaignId
          ? _value.campaignId
          : campaignId // ignore: cast_nullable_to_non_nullable
              as String,
      riskScore: null == riskScore
          ? _value.riskScore
          : riskScore // ignore: cast_nullable_to_non_nullable
              as int,
      riskLevel: null == riskLevel
          ? _value.riskLevel
          : riskLevel // ignore: cast_nullable_to_non_nullable
              as String,
      categories: freezed == categories
          ? _value._categories
          : categories // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      stageHistory: freezed == stageHistory
          ? _value._stageHistory
          : stageHistory // ignore: cast_nullable_to_non_nullable
              as List<Map<String, dynamic>>?,
      velocitySeconds: freezed == velocitySeconds
          ? _value.velocitySeconds
          : velocitySeconds // ignore: cast_nullable_to_non_nullable
              as double?,
      progressionLabels: freezed == progressionLabels
          ? _value._progressionLabels
          : progressionLabels // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      exposure: freezed == exposure
          ? _value.exposure
          : exposure // ignore: cast_nullable_to_non_nullable
              as Exposure?,
      eventCount: null == eventCount
          ? _value.eventCount
          : eventCount // ignore: cast_nullable_to_non_nullable
              as int,
      channels: freezed == channels
          ? _value._channels
          : channels // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String,
      isNew: null == isNew
          ? _value.isNew
          : isNew // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CampaignInfoImpl implements _CampaignInfo {
  const _$CampaignInfoImpl(
      {this.campaignId = '',
      this.riskScore = 0,
      this.riskLevel = 'safe',
      final List<String>? categories,
      final List<Map<String, dynamic>>? stageHistory,
      this.velocitySeconds,
      final List<String>? progressionLabels,
      this.exposure,
      this.eventCount = 0,
      final List<String>? channels,
      this.createdAt = '',
      this.updatedAt = '',
      this.isNew = false})
      : _categories = categories,
        _stageHistory = stageHistory,
        _progressionLabels = progressionLabels,
        _channels = channels;

  factory _$CampaignInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$CampaignInfoImplFromJson(json);

  @override
  @JsonKey()
  final String campaignId;
  @override
  @JsonKey()
  final int riskScore;
  @override
  @JsonKey()
  final String riskLevel;
  final List<String>? _categories;
  @override
  List<String>? get categories {
    final value = _categories;
    if (value == null) return null;
    if (_categories is EqualUnmodifiableListView) return _categories;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<Map<String, dynamic>>? _stageHistory;
  @override
  List<Map<String, dynamic>>? get stageHistory {
    final value = _stageHistory;
    if (value == null) return null;
    if (_stageHistory is EqualUnmodifiableListView) return _stageHistory;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final double? velocitySeconds;
  final List<String>? _progressionLabels;
  @override
  List<String>? get progressionLabels {
    final value = _progressionLabels;
    if (value == null) return null;
    if (_progressionLabels is EqualUnmodifiableListView)
      return _progressionLabels;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final Exposure? exposure;
  @override
  @JsonKey()
  final int eventCount;
  final List<String>? _channels;
  @override
  List<String>? get channels {
    final value = _channels;
    if (value == null) return null;
    if (_channels is EqualUnmodifiableListView) return _channels;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey()
  final String createdAt;
  @override
  @JsonKey()
  final String updatedAt;
  @override
  @JsonKey()
  final bool isNew;

  @override
  String toString() {
    return 'CampaignInfo(campaignId: $campaignId, riskScore: $riskScore, riskLevel: $riskLevel, categories: $categories, stageHistory: $stageHistory, velocitySeconds: $velocitySeconds, progressionLabels: $progressionLabels, exposure: $exposure, eventCount: $eventCount, channels: $channels, createdAt: $createdAt, updatedAt: $updatedAt, isNew: $isNew)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CampaignInfoImpl &&
            (identical(other.campaignId, campaignId) ||
                other.campaignId == campaignId) &&
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
            const DeepCollectionEquality()
                .equals(other._progressionLabels, _progressionLabels) &&
            (identical(other.exposure, exposure) ||
                other.exposure == exposure) &&
            (identical(other.eventCount, eventCount) ||
                other.eventCount == eventCount) &&
            const DeepCollectionEquality().equals(other._channels, _channels) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.isNew, isNew) || other.isNew == isNew));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      campaignId,
      riskScore,
      riskLevel,
      const DeepCollectionEquality().hash(_categories),
      const DeepCollectionEquality().hash(_stageHistory),
      velocitySeconds,
      const DeepCollectionEquality().hash(_progressionLabels),
      exposure,
      eventCount,
      const DeepCollectionEquality().hash(_channels),
      createdAt,
      updatedAt,
      isNew);

  /// Create a copy of CampaignInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CampaignInfoImplCopyWith<_$CampaignInfoImpl> get copyWith =>
      __$$CampaignInfoImplCopyWithImpl<_$CampaignInfoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CampaignInfoImplToJson(
      this,
    );
  }
}

abstract class _CampaignInfo implements CampaignInfo {
  const factory _CampaignInfo(
      {final String campaignId,
      final int riskScore,
      final String riskLevel,
      final List<String>? categories,
      final List<Map<String, dynamic>>? stageHistory,
      final double? velocitySeconds,
      final List<String>? progressionLabels,
      final Exposure? exposure,
      final int eventCount,
      final List<String>? channels,
      final String createdAt,
      final String updatedAt,
      final bool isNew}) = _$CampaignInfoImpl;

  factory _CampaignInfo.fromJson(Map<String, dynamic> json) =
      _$CampaignInfoImpl.fromJson;

  @override
  String get campaignId;
  @override
  int get riskScore;
  @override
  String get riskLevel;
  @override
  List<String>? get categories;
  @override
  List<Map<String, dynamic>>? get stageHistory;
  @override
  double? get velocitySeconds;
  @override
  List<String>? get progressionLabels;
  @override
  Exposure? get exposure;
  @override
  int get eventCount;
  @override
  List<String>? get channels;
  @override
  String get createdAt;
  @override
  String get updatedAt;
  @override
  bool get isNew;

  /// Create a copy of CampaignInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CampaignInfoImplCopyWith<_$CampaignInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Exposure _$ExposureFromJson(Map<String, dynamic> json) {
  return _Exposure.fromJson(json);
}

/// @nodoc
mixin _$Exposure {
  double get moneyInr => throw _privateConstructorUsedError;
  String get credentialRisk => throw _privateConstructorUsedError;
  bool get otpRequested => throw _privateConstructorUsedError;
  bool get deviceAccessRequested => throw _privateConstructorUsedError;
  bool get accountAccessPossible => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;

  /// Serializes this Exposure to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Exposure
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ExposureCopyWith<Exposure> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExposureCopyWith<$Res> {
  factory $ExposureCopyWith(Exposure value, $Res Function(Exposure) then) =
      _$ExposureCopyWithImpl<$Res, Exposure>;
  @useResult
  $Res call(
      {double moneyInr,
      String credentialRisk,
      bool otpRequested,
      bool deviceAccessRequested,
      bool accountAccessPossible,
      String description});
}

/// @nodoc
class _$ExposureCopyWithImpl<$Res, $Val extends Exposure>
    implements $ExposureCopyWith<$Res> {
  _$ExposureCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Exposure
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? moneyInr = null,
    Object? credentialRisk = null,
    Object? otpRequested = null,
    Object? deviceAccessRequested = null,
    Object? accountAccessPossible = null,
    Object? description = null,
  }) {
    return _then(_value.copyWith(
      moneyInr: null == moneyInr
          ? _value.moneyInr
          : moneyInr // ignore: cast_nullable_to_non_nullable
              as double,
      credentialRisk: null == credentialRisk
          ? _value.credentialRisk
          : credentialRisk // ignore: cast_nullable_to_non_nullable
              as String,
      otpRequested: null == otpRequested
          ? _value.otpRequested
          : otpRequested // ignore: cast_nullable_to_non_nullable
              as bool,
      deviceAccessRequested: null == deviceAccessRequested
          ? _value.deviceAccessRequested
          : deviceAccessRequested // ignore: cast_nullable_to_non_nullable
              as bool,
      accountAccessPossible: null == accountAccessPossible
          ? _value.accountAccessPossible
          : accountAccessPossible // ignore: cast_nullable_to_non_nullable
              as bool,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ExposureImplCopyWith<$Res>
    implements $ExposureCopyWith<$Res> {
  factory _$$ExposureImplCopyWith(
          _$ExposureImpl value, $Res Function(_$ExposureImpl) then) =
      __$$ExposureImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {double moneyInr,
      String credentialRisk,
      bool otpRequested,
      bool deviceAccessRequested,
      bool accountAccessPossible,
      String description});
}

/// @nodoc
class __$$ExposureImplCopyWithImpl<$Res>
    extends _$ExposureCopyWithImpl<$Res, _$ExposureImpl>
    implements _$$ExposureImplCopyWith<$Res> {
  __$$ExposureImplCopyWithImpl(
      _$ExposureImpl _value, $Res Function(_$ExposureImpl) _then)
      : super(_value, _then);

  /// Create a copy of Exposure
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? moneyInr = null,
    Object? credentialRisk = null,
    Object? otpRequested = null,
    Object? deviceAccessRequested = null,
    Object? accountAccessPossible = null,
    Object? description = null,
  }) {
    return _then(_$ExposureImpl(
      moneyInr: null == moneyInr
          ? _value.moneyInr
          : moneyInr // ignore: cast_nullable_to_non_nullable
              as double,
      credentialRisk: null == credentialRisk
          ? _value.credentialRisk
          : credentialRisk // ignore: cast_nullable_to_non_nullable
              as String,
      otpRequested: null == otpRequested
          ? _value.otpRequested
          : otpRequested // ignore: cast_nullable_to_non_nullable
              as bool,
      deviceAccessRequested: null == deviceAccessRequested
          ? _value.deviceAccessRequested
          : deviceAccessRequested // ignore: cast_nullable_to_non_nullable
              as bool,
      accountAccessPossible: null == accountAccessPossible
          ? _value.accountAccessPossible
          : accountAccessPossible // ignore: cast_nullable_to_non_nullable
              as bool,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ExposureImpl implements _Exposure {
  const _$ExposureImpl(
      {this.moneyInr = 0.0,
      this.credentialRisk = 'none',
      this.otpRequested = false,
      this.deviceAccessRequested = false,
      this.accountAccessPossible = false,
      this.description = ''});

  factory _$ExposureImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExposureImplFromJson(json);

  @override
  @JsonKey()
  final double moneyInr;
  @override
  @JsonKey()
  final String credentialRisk;
  @override
  @JsonKey()
  final bool otpRequested;
  @override
  @JsonKey()
  final bool deviceAccessRequested;
  @override
  @JsonKey()
  final bool accountAccessPossible;
  @override
  @JsonKey()
  final String description;

  @override
  String toString() {
    return 'Exposure(moneyInr: $moneyInr, credentialRisk: $credentialRisk, otpRequested: $otpRequested, deviceAccessRequested: $deviceAccessRequested, accountAccessPossible: $accountAccessPossible, description: $description)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExposureImpl &&
            (identical(other.moneyInr, moneyInr) ||
                other.moneyInr == moneyInr) &&
            (identical(other.credentialRisk, credentialRisk) ||
                other.credentialRisk == credentialRisk) &&
            (identical(other.otpRequested, otpRequested) ||
                other.otpRequested == otpRequested) &&
            (identical(other.deviceAccessRequested, deviceAccessRequested) ||
                other.deviceAccessRequested == deviceAccessRequested) &&
            (identical(other.accountAccessPossible, accountAccessPossible) ||
                other.accountAccessPossible == accountAccessPossible) &&
            (identical(other.description, description) ||
                other.description == description));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, moneyInr, credentialRisk,
      otpRequested, deviceAccessRequested, accountAccessPossible, description);

  /// Create a copy of Exposure
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExposureImplCopyWith<_$ExposureImpl> get copyWith =>
      __$$ExposureImplCopyWithImpl<_$ExposureImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ExposureImplToJson(
      this,
    );
  }
}

abstract class _Exposure implements Exposure {
  const factory _Exposure(
      {final double moneyInr,
      final String credentialRisk,
      final bool otpRequested,
      final bool deviceAccessRequested,
      final bool accountAccessPossible,
      final String description}) = _$ExposureImpl;

  factory _Exposure.fromJson(Map<String, dynamic> json) =
      _$ExposureImpl.fromJson;

  @override
  double get moneyInr;
  @override
  String get credentialRisk;
  @override
  bool get otpRequested;
  @override
  bool get deviceAccessRequested;
  @override
  bool get accountAccessPossible;
  @override
  String get description;

  /// Create a copy of Exposure
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExposureImplCopyWith<_$ExposureImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Intervention _$InterventionFromJson(Map<String, dynamic> json) {
  return _Intervention.fromJson(json);
}

/// @nodoc
mixin _$Intervention {
  String get action => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;
  List<String> get buttons => throw _privateConstructorUsedError;

  /// Serializes this Intervention to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Intervention
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $InterventionCopyWith<Intervention> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InterventionCopyWith<$Res> {
  factory $InterventionCopyWith(
          Intervention value, $Res Function(Intervention) then) =
      _$InterventionCopyWithImpl<$Res, Intervention>;
  @useResult
  $Res call(
      {String action, String title, String message, List<String> buttons});
}

/// @nodoc
class _$InterventionCopyWithImpl<$Res, $Val extends Intervention>
    implements $InterventionCopyWith<$Res> {
  _$InterventionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Intervention
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? action = null,
    Object? title = null,
    Object? message = null,
    Object? buttons = null,
  }) {
    return _then(_value.copyWith(
      action: null == action
          ? _value.action
          : action // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      buttons: null == buttons
          ? _value.buttons
          : buttons // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$InterventionImplCopyWith<$Res>
    implements $InterventionCopyWith<$Res> {
  factory _$$InterventionImplCopyWith(
          _$InterventionImpl value, $Res Function(_$InterventionImpl) then) =
      __$$InterventionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String action, String title, String message, List<String> buttons});
}

/// @nodoc
class __$$InterventionImplCopyWithImpl<$Res>
    extends _$InterventionCopyWithImpl<$Res, _$InterventionImpl>
    implements _$$InterventionImplCopyWith<$Res> {
  __$$InterventionImplCopyWithImpl(
      _$InterventionImpl _value, $Res Function(_$InterventionImpl) _then)
      : super(_value, _then);

  /// Create a copy of Intervention
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? action = null,
    Object? title = null,
    Object? message = null,
    Object? buttons = null,
  }) {
    return _then(_$InterventionImpl(
      action: null == action
          ? _value.action
          : action // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      buttons: null == buttons
          ? _value._buttons
          : buttons // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$InterventionImpl implements _Intervention {
  const _$InterventionImpl(
      {required this.action,
      required this.title,
      required this.message,
      final List<String> buttons = const []})
      : _buttons = buttons;

  factory _$InterventionImpl.fromJson(Map<String, dynamic> json) =>
      _$$InterventionImplFromJson(json);

  @override
  final String action;
  @override
  final String title;
  @override
  final String message;
  final List<String> _buttons;
  @override
  @JsonKey()
  List<String> get buttons {
    if (_buttons is EqualUnmodifiableListView) return _buttons;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_buttons);
  }

  @override
  String toString() {
    return 'Intervention(action: $action, title: $title, message: $message, buttons: $buttons)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InterventionImpl &&
            (identical(other.action, action) || other.action == action) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.message, message) || other.message == message) &&
            const DeepCollectionEquality().equals(other._buttons, _buttons));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, action, title, message,
      const DeepCollectionEquality().hash(_buttons));

  /// Create a copy of Intervention
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$InterventionImplCopyWith<_$InterventionImpl> get copyWith =>
      __$$InterventionImplCopyWithImpl<_$InterventionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$InterventionImplToJson(
      this,
    );
  }
}

abstract class _Intervention implements Intervention {
  const factory _Intervention(
      {required final String action,
      required final String title,
      required final String message,
      final List<String> buttons}) = _$InterventionImpl;

  factory _Intervention.fromJson(Map<String, dynamic> json) =
      _$InterventionImpl.fromJson;

  @override
  String get action;
  @override
  String get title;
  @override
  String get message;
  @override
  List<String> get buttons;

  /// Create a copy of Intervention
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$InterventionImplCopyWith<_$InterventionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

FamilyAlertDecision _$FamilyAlertDecisionFromJson(Map<String, dynamic> json) {
  return _FamilyAlertDecision.fromJson(json);
}

/// @nodoc
mixin _$FamilyAlertDecision {
  bool get alertSent => throw _privateConstructorUsedError;
  String get recipient => throw _privateConstructorUsedError;
  String get risk => throw _privateConstructorUsedError;
  String get messagePreview => throw _privateConstructorUsedError;

  /// Serializes this FamilyAlertDecision to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FamilyAlertDecision
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FamilyAlertDecisionCopyWith<FamilyAlertDecision> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FamilyAlertDecisionCopyWith<$Res> {
  factory $FamilyAlertDecisionCopyWith(
          FamilyAlertDecision value, $Res Function(FamilyAlertDecision) then) =
      _$FamilyAlertDecisionCopyWithImpl<$Res, FamilyAlertDecision>;
  @useResult
  $Res call(
      {bool alertSent, String recipient, String risk, String messagePreview});
}

/// @nodoc
class _$FamilyAlertDecisionCopyWithImpl<$Res, $Val extends FamilyAlertDecision>
    implements $FamilyAlertDecisionCopyWith<$Res> {
  _$FamilyAlertDecisionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FamilyAlertDecision
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? alertSent = null,
    Object? recipient = null,
    Object? risk = null,
    Object? messagePreview = null,
  }) {
    return _then(_value.copyWith(
      alertSent: null == alertSent
          ? _value.alertSent
          : alertSent // ignore: cast_nullable_to_non_nullable
              as bool,
      recipient: null == recipient
          ? _value.recipient
          : recipient // ignore: cast_nullable_to_non_nullable
              as String,
      risk: null == risk
          ? _value.risk
          : risk // ignore: cast_nullable_to_non_nullable
              as String,
      messagePreview: null == messagePreview
          ? _value.messagePreview
          : messagePreview // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FamilyAlertDecisionImplCopyWith<$Res>
    implements $FamilyAlertDecisionCopyWith<$Res> {
  factory _$$FamilyAlertDecisionImplCopyWith(_$FamilyAlertDecisionImpl value,
          $Res Function(_$FamilyAlertDecisionImpl) then) =
      __$$FamilyAlertDecisionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool alertSent, String recipient, String risk, String messagePreview});
}

/// @nodoc
class __$$FamilyAlertDecisionImplCopyWithImpl<$Res>
    extends _$FamilyAlertDecisionCopyWithImpl<$Res, _$FamilyAlertDecisionImpl>
    implements _$$FamilyAlertDecisionImplCopyWith<$Res> {
  __$$FamilyAlertDecisionImplCopyWithImpl(_$FamilyAlertDecisionImpl _value,
      $Res Function(_$FamilyAlertDecisionImpl) _then)
      : super(_value, _then);

  /// Create a copy of FamilyAlertDecision
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? alertSent = null,
    Object? recipient = null,
    Object? risk = null,
    Object? messagePreview = null,
  }) {
    return _then(_$FamilyAlertDecisionImpl(
      alertSent: null == alertSent
          ? _value.alertSent
          : alertSent // ignore: cast_nullable_to_non_nullable
              as bool,
      recipient: null == recipient
          ? _value.recipient
          : recipient // ignore: cast_nullable_to_non_nullable
              as String,
      risk: null == risk
          ? _value.risk
          : risk // ignore: cast_nullable_to_non_nullable
              as String,
      messagePreview: null == messagePreview
          ? _value.messagePreview
          : messagePreview // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FamilyAlertDecisionImpl implements _FamilyAlertDecision {
  const _$FamilyAlertDecisionImpl(
      {this.alertSent = false,
      this.recipient = '',
      this.risk = '',
      this.messagePreview = ''});

  factory _$FamilyAlertDecisionImpl.fromJson(Map<String, dynamic> json) =>
      _$$FamilyAlertDecisionImplFromJson(json);

  @override
  @JsonKey()
  final bool alertSent;
  @override
  @JsonKey()
  final String recipient;
  @override
  @JsonKey()
  final String risk;
  @override
  @JsonKey()
  final String messagePreview;

  @override
  String toString() {
    return 'FamilyAlertDecision(alertSent: $alertSent, recipient: $recipient, risk: $risk, messagePreview: $messagePreview)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FamilyAlertDecisionImpl &&
            (identical(other.alertSent, alertSent) ||
                other.alertSent == alertSent) &&
            (identical(other.recipient, recipient) ||
                other.recipient == recipient) &&
            (identical(other.risk, risk) || other.risk == risk) &&
            (identical(other.messagePreview, messagePreview) ||
                other.messagePreview == messagePreview));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, alertSent, recipient, risk, messagePreview);

  /// Create a copy of FamilyAlertDecision
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FamilyAlertDecisionImplCopyWith<_$FamilyAlertDecisionImpl> get copyWith =>
      __$$FamilyAlertDecisionImplCopyWithImpl<_$FamilyAlertDecisionImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FamilyAlertDecisionImplToJson(
      this,
    );
  }
}

abstract class _FamilyAlertDecision implements FamilyAlertDecision {
  const factory _FamilyAlertDecision(
      {final bool alertSent,
      final String recipient,
      final String risk,
      final String messagePreview}) = _$FamilyAlertDecisionImpl;

  factory _FamilyAlertDecision.fromJson(Map<String, dynamic> json) =
      _$FamilyAlertDecisionImpl.fromJson;

  @override
  bool get alertSent;
  @override
  String get recipient;
  @override
  String get risk;
  @override
  String get messagePreview;

  /// Create a copy of FamilyAlertDecision
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FamilyAlertDecisionImplCopyWith<_$FamilyAlertDecisionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RecoveryPlan _$RecoveryPlanFromJson(Map<String, dynamic> json) {
  return _RecoveryPlan.fromJson(json);
}

/// @nodoc
mixin _$RecoveryPlan {
  String get title => throw _privateConstructorUsedError;
  String get intro => throw _privateConstructorUsedError;
  List<VerifiedContact>? get verifiedContacts =>
      throw _privateConstructorUsedError;
  List<RecoveryStep>? get recoverySteps => throw _privateConstructorUsedError;
  List<ReportingStep>? get reportingSteps => throw _privateConstructorUsedError;

  /// Serializes this RecoveryPlan to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RecoveryPlan
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RecoveryPlanCopyWith<RecoveryPlan> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RecoveryPlanCopyWith<$Res> {
  factory $RecoveryPlanCopyWith(
          RecoveryPlan value, $Res Function(RecoveryPlan) then) =
      _$RecoveryPlanCopyWithImpl<$Res, RecoveryPlan>;
  @useResult
  $Res call(
      {String title,
      String intro,
      List<VerifiedContact>? verifiedContacts,
      List<RecoveryStep>? recoverySteps,
      List<ReportingStep>? reportingSteps});
}

/// @nodoc
class _$RecoveryPlanCopyWithImpl<$Res, $Val extends RecoveryPlan>
    implements $RecoveryPlanCopyWith<$Res> {
  _$RecoveryPlanCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RecoveryPlan
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? intro = null,
    Object? verifiedContacts = freezed,
    Object? recoverySteps = freezed,
    Object? reportingSteps = freezed,
  }) {
    return _then(_value.copyWith(
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      intro: null == intro
          ? _value.intro
          : intro // ignore: cast_nullable_to_non_nullable
              as String,
      verifiedContacts: freezed == verifiedContacts
          ? _value.verifiedContacts
          : verifiedContacts // ignore: cast_nullable_to_non_nullable
              as List<VerifiedContact>?,
      recoverySteps: freezed == recoverySteps
          ? _value.recoverySteps
          : recoverySteps // ignore: cast_nullable_to_non_nullable
              as List<RecoveryStep>?,
      reportingSteps: freezed == reportingSteps
          ? _value.reportingSteps
          : reportingSteps // ignore: cast_nullable_to_non_nullable
              as List<ReportingStep>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RecoveryPlanImplCopyWith<$Res>
    implements $RecoveryPlanCopyWith<$Res> {
  factory _$$RecoveryPlanImplCopyWith(
          _$RecoveryPlanImpl value, $Res Function(_$RecoveryPlanImpl) then) =
      __$$RecoveryPlanImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String title,
      String intro,
      List<VerifiedContact>? verifiedContacts,
      List<RecoveryStep>? recoverySteps,
      List<ReportingStep>? reportingSteps});
}

/// @nodoc
class __$$RecoveryPlanImplCopyWithImpl<$Res>
    extends _$RecoveryPlanCopyWithImpl<$Res, _$RecoveryPlanImpl>
    implements _$$RecoveryPlanImplCopyWith<$Res> {
  __$$RecoveryPlanImplCopyWithImpl(
      _$RecoveryPlanImpl _value, $Res Function(_$RecoveryPlanImpl) _then)
      : super(_value, _then);

  /// Create a copy of RecoveryPlan
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? intro = null,
    Object? verifiedContacts = freezed,
    Object? recoverySteps = freezed,
    Object? reportingSteps = freezed,
  }) {
    return _then(_$RecoveryPlanImpl(
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      intro: null == intro
          ? _value.intro
          : intro // ignore: cast_nullable_to_non_nullable
              as String,
      verifiedContacts: freezed == verifiedContacts
          ? _value._verifiedContacts
          : verifiedContacts // ignore: cast_nullable_to_non_nullable
              as List<VerifiedContact>?,
      recoverySteps: freezed == recoverySteps
          ? _value._recoverySteps
          : recoverySteps // ignore: cast_nullable_to_non_nullable
              as List<RecoveryStep>?,
      reportingSteps: freezed == reportingSteps
          ? _value._reportingSteps
          : reportingSteps // ignore: cast_nullable_to_non_nullable
              as List<ReportingStep>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RecoveryPlanImpl implements _RecoveryPlan {
  const _$RecoveryPlanImpl(
      {required this.title,
      required this.intro,
      final List<VerifiedContact>? verifiedContacts,
      final List<RecoveryStep>? recoverySteps,
      final List<ReportingStep>? reportingSteps})
      : _verifiedContacts = verifiedContacts,
        _recoverySteps = recoverySteps,
        _reportingSteps = reportingSteps;

  factory _$RecoveryPlanImpl.fromJson(Map<String, dynamic> json) =>
      _$$RecoveryPlanImplFromJson(json);

  @override
  final String title;
  @override
  final String intro;
  final List<VerifiedContact>? _verifiedContacts;
  @override
  List<VerifiedContact>? get verifiedContacts {
    final value = _verifiedContacts;
    if (value == null) return null;
    if (_verifiedContacts is EqualUnmodifiableListView)
      return _verifiedContacts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<RecoveryStep>? _recoverySteps;
  @override
  List<RecoveryStep>? get recoverySteps {
    final value = _recoverySteps;
    if (value == null) return null;
    if (_recoverySteps is EqualUnmodifiableListView) return _recoverySteps;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<ReportingStep>? _reportingSteps;
  @override
  List<ReportingStep>? get reportingSteps {
    final value = _reportingSteps;
    if (value == null) return null;
    if (_reportingSteps is EqualUnmodifiableListView) return _reportingSteps;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'RecoveryPlan(title: $title, intro: $intro, verifiedContacts: $verifiedContacts, recoverySteps: $recoverySteps, reportingSteps: $reportingSteps)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RecoveryPlanImpl &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.intro, intro) || other.intro == intro) &&
            const DeepCollectionEquality()
                .equals(other._verifiedContacts, _verifiedContacts) &&
            const DeepCollectionEquality()
                .equals(other._recoverySteps, _recoverySteps) &&
            const DeepCollectionEquality()
                .equals(other._reportingSteps, _reportingSteps));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      title,
      intro,
      const DeepCollectionEquality().hash(_verifiedContacts),
      const DeepCollectionEquality().hash(_recoverySteps),
      const DeepCollectionEquality().hash(_reportingSteps));

  /// Create a copy of RecoveryPlan
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RecoveryPlanImplCopyWith<_$RecoveryPlanImpl> get copyWith =>
      __$$RecoveryPlanImplCopyWithImpl<_$RecoveryPlanImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RecoveryPlanImplToJson(
      this,
    );
  }
}

abstract class _RecoveryPlan implements RecoveryPlan {
  const factory _RecoveryPlan(
      {required final String title,
      required final String intro,
      final List<VerifiedContact>? verifiedContacts,
      final List<RecoveryStep>? recoverySteps,
      final List<ReportingStep>? reportingSteps}) = _$RecoveryPlanImpl;

  factory _RecoveryPlan.fromJson(Map<String, dynamic> json) =
      _$RecoveryPlanImpl.fromJson;

  @override
  String get title;
  @override
  String get intro;
  @override
  List<VerifiedContact>? get verifiedContacts;
  @override
  List<RecoveryStep>? get recoverySteps;
  @override
  List<ReportingStep>? get reportingSteps;

  /// Create a copy of RecoveryPlan
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RecoveryPlanImplCopyWith<_$RecoveryPlanImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

VerifiedContact _$VerifiedContactFromJson(Map<String, dynamic> json) {
  return _VerifiedContact.fromJson(json);
}

/// @nodoc
mixin _$VerifiedContact {
  String get name => throw _privateConstructorUsedError;
  String get channel => throw _privateConstructorUsedError;
  String get value => throw _privateConstructorUsedError;
  String get note => throw _privateConstructorUsedError;

  /// Serializes this VerifiedContact to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VerifiedContact
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VerifiedContactCopyWith<VerifiedContact> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VerifiedContactCopyWith<$Res> {
  factory $VerifiedContactCopyWith(
          VerifiedContact value, $Res Function(VerifiedContact) then) =
      _$VerifiedContactCopyWithImpl<$Res, VerifiedContact>;
  @useResult
  $Res call({String name, String channel, String value, String note});
}

/// @nodoc
class _$VerifiedContactCopyWithImpl<$Res, $Val extends VerifiedContact>
    implements $VerifiedContactCopyWith<$Res> {
  _$VerifiedContactCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VerifiedContact
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? channel = null,
    Object? value = null,
    Object? note = null,
  }) {
    return _then(_value.copyWith(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      channel: null == channel
          ? _value.channel
          : channel // ignore: cast_nullable_to_non_nullable
              as String,
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as String,
      note: null == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$VerifiedContactImplCopyWith<$Res>
    implements $VerifiedContactCopyWith<$Res> {
  factory _$$VerifiedContactImplCopyWith(_$VerifiedContactImpl value,
          $Res Function(_$VerifiedContactImpl) then) =
      __$$VerifiedContactImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String name, String channel, String value, String note});
}

/// @nodoc
class __$$VerifiedContactImplCopyWithImpl<$Res>
    extends _$VerifiedContactCopyWithImpl<$Res, _$VerifiedContactImpl>
    implements _$$VerifiedContactImplCopyWith<$Res> {
  __$$VerifiedContactImplCopyWithImpl(
      _$VerifiedContactImpl _value, $Res Function(_$VerifiedContactImpl) _then)
      : super(_value, _then);

  /// Create a copy of VerifiedContact
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? channel = null,
    Object? value = null,
    Object? note = null,
  }) {
    return _then(_$VerifiedContactImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      channel: null == channel
          ? _value.channel
          : channel // ignore: cast_nullable_to_non_nullable
              as String,
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as String,
      note: null == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$VerifiedContactImpl implements _VerifiedContact {
  const _$VerifiedContactImpl(
      {required this.name,
      required this.channel,
      required this.value,
      required this.note});

  factory _$VerifiedContactImpl.fromJson(Map<String, dynamic> json) =>
      _$$VerifiedContactImplFromJson(json);

  @override
  final String name;
  @override
  final String channel;
  @override
  final String value;
  @override
  final String note;

  @override
  String toString() {
    return 'VerifiedContact(name: $name, channel: $channel, value: $value, note: $note)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VerifiedContactImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.channel, channel) || other.channel == channel) &&
            (identical(other.value, value) || other.value == value) &&
            (identical(other.note, note) || other.note == note));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, name, channel, value, note);

  /// Create a copy of VerifiedContact
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VerifiedContactImplCopyWith<_$VerifiedContactImpl> get copyWith =>
      __$$VerifiedContactImplCopyWithImpl<_$VerifiedContactImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VerifiedContactImplToJson(
      this,
    );
  }
}

abstract class _VerifiedContact implements VerifiedContact {
  const factory _VerifiedContact(
      {required final String name,
      required final String channel,
      required final String value,
      required final String note}) = _$VerifiedContactImpl;

  factory _VerifiedContact.fromJson(Map<String, dynamic> json) =
      _$VerifiedContactImpl.fromJson;

  @override
  String get name;
  @override
  String get channel;
  @override
  String get value;
  @override
  String get note;

  /// Create a copy of VerifiedContact
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VerifiedContactImplCopyWith<_$VerifiedContactImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RecoveryStep _$RecoveryStepFromJson(Map<String, dynamic> json) {
  return _RecoveryStep.fromJson(json);
}

/// @nodoc
mixin _$RecoveryStep {
  int get order => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get text => throw _privateConstructorUsedError;

  /// Serializes this RecoveryStep to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RecoveryStep
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RecoveryStepCopyWith<RecoveryStep> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RecoveryStepCopyWith<$Res> {
  factory $RecoveryStepCopyWith(
          RecoveryStep value, $Res Function(RecoveryStep) then) =
      _$RecoveryStepCopyWithImpl<$Res, RecoveryStep>;
  @useResult
  $Res call({int order, String title, String text});
}

/// @nodoc
class _$RecoveryStepCopyWithImpl<$Res, $Val extends RecoveryStep>
    implements $RecoveryStepCopyWith<$Res> {
  _$RecoveryStepCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RecoveryStep
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? order = null,
    Object? title = null,
    Object? text = null,
  }) {
    return _then(_value.copyWith(
      order: null == order
          ? _value.order
          : order // ignore: cast_nullable_to_non_nullable
              as int,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      text: null == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RecoveryStepImplCopyWith<$Res>
    implements $RecoveryStepCopyWith<$Res> {
  factory _$$RecoveryStepImplCopyWith(
          _$RecoveryStepImpl value, $Res Function(_$RecoveryStepImpl) then) =
      __$$RecoveryStepImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int order, String title, String text});
}

/// @nodoc
class __$$RecoveryStepImplCopyWithImpl<$Res>
    extends _$RecoveryStepCopyWithImpl<$Res, _$RecoveryStepImpl>
    implements _$$RecoveryStepImplCopyWith<$Res> {
  __$$RecoveryStepImplCopyWithImpl(
      _$RecoveryStepImpl _value, $Res Function(_$RecoveryStepImpl) _then)
      : super(_value, _then);

  /// Create a copy of RecoveryStep
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? order = null,
    Object? title = null,
    Object? text = null,
  }) {
    return _then(_$RecoveryStepImpl(
      order: null == order
          ? _value.order
          : order // ignore: cast_nullable_to_non_nullable
              as int,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      text: null == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RecoveryStepImpl implements _RecoveryStep {
  const _$RecoveryStepImpl(
      {required this.order, required this.title, required this.text});

  factory _$RecoveryStepImpl.fromJson(Map<String, dynamic> json) =>
      _$$RecoveryStepImplFromJson(json);

  @override
  final int order;
  @override
  final String title;
  @override
  final String text;

  @override
  String toString() {
    return 'RecoveryStep(order: $order, title: $title, text: $text)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RecoveryStepImpl &&
            (identical(other.order, order) || other.order == order) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.text, text) || other.text == text));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, order, title, text);

  /// Create a copy of RecoveryStep
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RecoveryStepImplCopyWith<_$RecoveryStepImpl> get copyWith =>
      __$$RecoveryStepImplCopyWithImpl<_$RecoveryStepImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RecoveryStepImplToJson(
      this,
    );
  }
}

abstract class _RecoveryStep implements RecoveryStep {
  const factory _RecoveryStep(
      {required final int order,
      required final String title,
      required final String text}) = _$RecoveryStepImpl;

  factory _RecoveryStep.fromJson(Map<String, dynamic> json) =
      _$RecoveryStepImpl.fromJson;

  @override
  int get order;
  @override
  String get title;
  @override
  String get text;

  /// Create a copy of RecoveryStep
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RecoveryStepImplCopyWith<_$RecoveryStepImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ReportingStep _$ReportingStepFromJson(Map<String, dynamic> json) {
  return _ReportingStep.fromJson(json);
}

/// @nodoc
mixin _$ReportingStep {
  int get order => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get text => throw _privateConstructorUsedError;

  /// Serializes this ReportingStep to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ReportingStep
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReportingStepCopyWith<ReportingStep> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReportingStepCopyWith<$Res> {
  factory $ReportingStepCopyWith(
          ReportingStep value, $Res Function(ReportingStep) then) =
      _$ReportingStepCopyWithImpl<$Res, ReportingStep>;
  @useResult
  $Res call({int order, String title, String text});
}

/// @nodoc
class _$ReportingStepCopyWithImpl<$Res, $Val extends ReportingStep>
    implements $ReportingStepCopyWith<$Res> {
  _$ReportingStepCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ReportingStep
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? order = null,
    Object? title = null,
    Object? text = null,
  }) {
    return _then(_value.copyWith(
      order: null == order
          ? _value.order
          : order // ignore: cast_nullable_to_non_nullable
              as int,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      text: null == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ReportingStepImplCopyWith<$Res>
    implements $ReportingStepCopyWith<$Res> {
  factory _$$ReportingStepImplCopyWith(
          _$ReportingStepImpl value, $Res Function(_$ReportingStepImpl) then) =
      __$$ReportingStepImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int order, String title, String text});
}

/// @nodoc
class __$$ReportingStepImplCopyWithImpl<$Res>
    extends _$ReportingStepCopyWithImpl<$Res, _$ReportingStepImpl>
    implements _$$ReportingStepImplCopyWith<$Res> {
  __$$ReportingStepImplCopyWithImpl(
      _$ReportingStepImpl _value, $Res Function(_$ReportingStepImpl) _then)
      : super(_value, _then);

  /// Create a copy of ReportingStep
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? order = null,
    Object? title = null,
    Object? text = null,
  }) {
    return _then(_$ReportingStepImpl(
      order: null == order
          ? _value.order
          : order // ignore: cast_nullable_to_non_nullable
              as int,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      text: null == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ReportingStepImpl implements _ReportingStep {
  const _$ReportingStepImpl(
      {required this.order, required this.title, required this.text});

  factory _$ReportingStepImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReportingStepImplFromJson(json);

  @override
  final int order;
  @override
  final String title;
  @override
  final String text;

  @override
  String toString() {
    return 'ReportingStep(order: $order, title: $title, text: $text)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReportingStepImpl &&
            (identical(other.order, order) || other.order == order) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.text, text) || other.text == text));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, order, title, text);

  /// Create a copy of ReportingStep
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReportingStepImplCopyWith<_$ReportingStepImpl> get copyWith =>
      __$$ReportingStepImplCopyWithImpl<_$ReportingStepImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReportingStepImplToJson(
      this,
    );
  }
}

abstract class _ReportingStep implements ReportingStep {
  const factory _ReportingStep(
      {required final int order,
      required final String title,
      required final String text}) = _$ReportingStepImpl;

  factory _ReportingStep.fromJson(Map<String, dynamic> json) =
      _$ReportingStepImpl.fromJson;

  @override
  int get order;
  @override
  String get title;
  @override
  String get text;

  /// Create a copy of ReportingStep
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReportingStepImplCopyWith<_$ReportingStepImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Intent _$IntentFromJson(Map<String, dynamic> json) {
  return _Intent.fromJson(json);
}

/// @nodoc
mixin _$Intent {
  String get name => throw _privateConstructorUsedError;
  String get label => throw _privateConstructorUsedError;
  double get confidence => throw _privateConstructorUsedError;
  List<String>? get signals => throw _privateConstructorUsedError;

  /// Serializes this Intent to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Intent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $IntentCopyWith<Intent> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $IntentCopyWith<$Res> {
  factory $IntentCopyWith(Intent value, $Res Function(Intent) then) =
      _$IntentCopyWithImpl<$Res, Intent>;
  @useResult
  $Res call(
      {String name, String label, double confidence, List<String>? signals});
}

/// @nodoc
class _$IntentCopyWithImpl<$Res, $Val extends Intent>
    implements $IntentCopyWith<$Res> {
  _$IntentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Intent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? label = null,
    Object? confidence = null,
    Object? signals = freezed,
  }) {
    return _then(_value.copyWith(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
      confidence: null == confidence
          ? _value.confidence
          : confidence // ignore: cast_nullable_to_non_nullable
              as double,
      signals: freezed == signals
          ? _value.signals
          : signals // ignore: cast_nullable_to_non_nullable
              as List<String>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$IntentImplCopyWith<$Res> implements $IntentCopyWith<$Res> {
  factory _$$IntentImplCopyWith(
          _$IntentImpl value, $Res Function(_$IntentImpl) then) =
      __$$IntentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String name, String label, double confidence, List<String>? signals});
}

/// @nodoc
class __$$IntentImplCopyWithImpl<$Res>
    extends _$IntentCopyWithImpl<$Res, _$IntentImpl>
    implements _$$IntentImplCopyWith<$Res> {
  __$$IntentImplCopyWithImpl(
      _$IntentImpl _value, $Res Function(_$IntentImpl) _then)
      : super(_value, _then);

  /// Create a copy of Intent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? label = null,
    Object? confidence = null,
    Object? signals = freezed,
  }) {
    return _then(_$IntentImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
      confidence: null == confidence
          ? _value.confidence
          : confidence // ignore: cast_nullable_to_non_nullable
              as double,
      signals: freezed == signals
          ? _value._signals
          : signals // ignore: cast_nullable_to_non_nullable
              as List<String>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$IntentImpl implements _Intent {
  const _$IntentImpl(
      {required this.name,
      required this.label,
      this.confidence = 1.0,
      final List<String>? signals})
      : _signals = signals;

  factory _$IntentImpl.fromJson(Map<String, dynamic> json) =>
      _$$IntentImplFromJson(json);

  @override
  final String name;
  @override
  final String label;
  @override
  @JsonKey()
  final double confidence;
  final List<String>? _signals;
  @override
  List<String>? get signals {
    final value = _signals;
    if (value == null) return null;
    if (_signals is EqualUnmodifiableListView) return _signals;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'Intent(name: $name, label: $label, confidence: $confidence, signals: $signals)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$IntentImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.confidence, confidence) ||
                other.confidence == confidence) &&
            const DeepCollectionEquality().equals(other._signals, _signals));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, name, label, confidence,
      const DeepCollectionEquality().hash(_signals));

  /// Create a copy of Intent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$IntentImplCopyWith<_$IntentImpl> get copyWith =>
      __$$IntentImplCopyWithImpl<_$IntentImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$IntentImplToJson(
      this,
    );
  }
}

abstract class _Intent implements Intent {
  const factory _Intent(
      {required final String name,
      required final String label,
      final double confidence,
      final List<String>? signals}) = _$IntentImpl;

  factory _Intent.fromJson(Map<String, dynamic> json) = _$IntentImpl.fromJson;

  @override
  String get name;
  @override
  String get label;
  @override
  double get confidence;
  @override
  List<String>? get signals;

  /// Create a copy of Intent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$IntentImplCopyWith<_$IntentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ScamStage _$ScamStageFromJson(Map<String, dynamic> json) {
  return _ScamStage.fromJson(json);
}

/// @nodoc
mixin _$ScamStage {
  String get stage => throw _privateConstructorUsedError;
  String get label => throw _privateConstructorUsedError;
  double get confidence => throw _privateConstructorUsedError;
  String? get detectedAt => throw _privateConstructorUsedError;

  /// Serializes this ScamStage to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ScamStage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ScamStageCopyWith<ScamStage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ScamStageCopyWith<$Res> {
  factory $ScamStageCopyWith(ScamStage value, $Res Function(ScamStage) then) =
      _$ScamStageCopyWithImpl<$Res, ScamStage>;
  @useResult
  $Res call(
      {String stage, String label, double confidence, String? detectedAt});
}

/// @nodoc
class _$ScamStageCopyWithImpl<$Res, $Val extends ScamStage>
    implements $ScamStageCopyWith<$Res> {
  _$ScamStageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ScamStage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? stage = null,
    Object? label = null,
    Object? confidence = null,
    Object? detectedAt = freezed,
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
      confidence: null == confidence
          ? _value.confidence
          : confidence // ignore: cast_nullable_to_non_nullable
              as double,
      detectedAt: freezed == detectedAt
          ? _value.detectedAt
          : detectedAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ScamStageImplCopyWith<$Res>
    implements $ScamStageCopyWith<$Res> {
  factory _$$ScamStageImplCopyWith(
          _$ScamStageImpl value, $Res Function(_$ScamStageImpl) then) =
      __$$ScamStageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String stage, String label, double confidence, String? detectedAt});
}

/// @nodoc
class __$$ScamStageImplCopyWithImpl<$Res>
    extends _$ScamStageCopyWithImpl<$Res, _$ScamStageImpl>
    implements _$$ScamStageImplCopyWith<$Res> {
  __$$ScamStageImplCopyWithImpl(
      _$ScamStageImpl _value, $Res Function(_$ScamStageImpl) _then)
      : super(_value, _then);

  /// Create a copy of ScamStage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? stage = null,
    Object? label = null,
    Object? confidence = null,
    Object? detectedAt = freezed,
  }) {
    return _then(_$ScamStageImpl(
      stage: null == stage
          ? _value.stage
          : stage // ignore: cast_nullable_to_non_nullable
              as String,
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
      confidence: null == confidence
          ? _value.confidence
          : confidence // ignore: cast_nullable_to_non_nullable
              as double,
      detectedAt: freezed == detectedAt
          ? _value.detectedAt
          : detectedAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ScamStageImpl implements _ScamStage {
  const _$ScamStageImpl(
      {required this.stage,
      required this.label,
      this.confidence = 1.0,
      this.detectedAt});

  factory _$ScamStageImpl.fromJson(Map<String, dynamic> json) =>
      _$$ScamStageImplFromJson(json);

  @override
  final String stage;
  @override
  final String label;
  @override
  @JsonKey()
  final double confidence;
  @override
  final String? detectedAt;

  @override
  String toString() {
    return 'ScamStage(stage: $stage, label: $label, confidence: $confidence, detectedAt: $detectedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ScamStageImpl &&
            (identical(other.stage, stage) || other.stage == stage) &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.confidence, confidence) ||
                other.confidence == confidence) &&
            (identical(other.detectedAt, detectedAt) ||
                other.detectedAt == detectedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, stage, label, confidence, detectedAt);

  /// Create a copy of ScamStage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ScamStageImplCopyWith<_$ScamStageImpl> get copyWith =>
      __$$ScamStageImplCopyWithImpl<_$ScamStageImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ScamStageImplToJson(
      this,
    );
  }
}

abstract class _ScamStage implements ScamStage {
  const factory _ScamStage(
      {required final String stage,
      required final String label,
      final double confidence,
      final String? detectedAt}) = _$ScamStageImpl;

  factory _ScamStage.fromJson(Map<String, dynamic> json) =
      _$ScamStageImpl.fromJson;

  @override
  String get stage;
  @override
  String get label;
  @override
  double get confidence;
  @override
  String? get detectedAt;

  /// Create a copy of ScamStage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ScamStageImplCopyWith<_$ScamStageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LinkFinding _$LinkFindingFromJson(Map<String, dynamic> json) {
  return _LinkFinding.fromJson(json);
}

/// @nodoc
mixin _$LinkFinding {
  String get url => throw _privateConstructorUsedError;
  String get normalizedUrl => throw _privateConstructorUsedError;
  String get domain => throw _privateConstructorUsedError;
  String get registrableDomain => throw _privateConstructorUsedError;
  bool get isSuspicious => throw _privateConstructorUsedError;
  String get reason => throw _privateConstructorUsedError;
  bool get matchesTrusted => throw _privateConstructorUsedError;
  String get verdict => throw _privateConstructorUsedError;
  double get confidence => throw _privateConstructorUsedError;

  /// Serializes this LinkFinding to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LinkFinding
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LinkFindingCopyWith<LinkFinding> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LinkFindingCopyWith<$Res> {
  factory $LinkFindingCopyWith(
          LinkFinding value, $Res Function(LinkFinding) then) =
      _$LinkFindingCopyWithImpl<$Res, LinkFinding>;
  @useResult
  $Res call(
      {String url,
      String normalizedUrl,
      String domain,
      String registrableDomain,
      bool isSuspicious,
      String reason,
      bool matchesTrusted,
      String verdict,
      double confidence});
}

/// @nodoc
class _$LinkFindingCopyWithImpl<$Res, $Val extends LinkFinding>
    implements $LinkFindingCopyWith<$Res> {
  _$LinkFindingCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LinkFinding
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? url = null,
    Object? normalizedUrl = null,
    Object? domain = null,
    Object? registrableDomain = null,
    Object? isSuspicious = null,
    Object? reason = null,
    Object? matchesTrusted = null,
    Object? verdict = null,
    Object? confidence = null,
  }) {
    return _then(_value.copyWith(
      url: null == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      normalizedUrl: null == normalizedUrl
          ? _value.normalizedUrl
          : normalizedUrl // ignore: cast_nullable_to_non_nullable
              as String,
      domain: null == domain
          ? _value.domain
          : domain // ignore: cast_nullable_to_non_nullable
              as String,
      registrableDomain: null == registrableDomain
          ? _value.registrableDomain
          : registrableDomain // ignore: cast_nullable_to_non_nullable
              as String,
      isSuspicious: null == isSuspicious
          ? _value.isSuspicious
          : isSuspicious // ignore: cast_nullable_to_non_nullable
              as bool,
      reason: null == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String,
      matchesTrusted: null == matchesTrusted
          ? _value.matchesTrusted
          : matchesTrusted // ignore: cast_nullable_to_non_nullable
              as bool,
      verdict: null == verdict
          ? _value.verdict
          : verdict // ignore: cast_nullable_to_non_nullable
              as String,
      confidence: null == confidence
          ? _value.confidence
          : confidence // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LinkFindingImplCopyWith<$Res>
    implements $LinkFindingCopyWith<$Res> {
  factory _$$LinkFindingImplCopyWith(
          _$LinkFindingImpl value, $Res Function(_$LinkFindingImpl) then) =
      __$$LinkFindingImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String url,
      String normalizedUrl,
      String domain,
      String registrableDomain,
      bool isSuspicious,
      String reason,
      bool matchesTrusted,
      String verdict,
      double confidence});
}

/// @nodoc
class __$$LinkFindingImplCopyWithImpl<$Res>
    extends _$LinkFindingCopyWithImpl<$Res, _$LinkFindingImpl>
    implements _$$LinkFindingImplCopyWith<$Res> {
  __$$LinkFindingImplCopyWithImpl(
      _$LinkFindingImpl _value, $Res Function(_$LinkFindingImpl) _then)
      : super(_value, _then);

  /// Create a copy of LinkFinding
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? url = null,
    Object? normalizedUrl = null,
    Object? domain = null,
    Object? registrableDomain = null,
    Object? isSuspicious = null,
    Object? reason = null,
    Object? matchesTrusted = null,
    Object? verdict = null,
    Object? confidence = null,
  }) {
    return _then(_$LinkFindingImpl(
      url: null == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      normalizedUrl: null == normalizedUrl
          ? _value.normalizedUrl
          : normalizedUrl // ignore: cast_nullable_to_non_nullable
              as String,
      domain: null == domain
          ? _value.domain
          : domain // ignore: cast_nullable_to_non_nullable
              as String,
      registrableDomain: null == registrableDomain
          ? _value.registrableDomain
          : registrableDomain // ignore: cast_nullable_to_non_nullable
              as String,
      isSuspicious: null == isSuspicious
          ? _value.isSuspicious
          : isSuspicious // ignore: cast_nullable_to_non_nullable
              as bool,
      reason: null == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String,
      matchesTrusted: null == matchesTrusted
          ? _value.matchesTrusted
          : matchesTrusted // ignore: cast_nullable_to_non_nullable
              as bool,
      verdict: null == verdict
          ? _value.verdict
          : verdict // ignore: cast_nullable_to_non_nullable
              as String,
      confidence: null == confidence
          ? _value.confidence
          : confidence // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LinkFindingImpl implements _LinkFinding {
  const _$LinkFindingImpl(
      {required this.url,
      required this.normalizedUrl,
      required this.domain,
      required this.registrableDomain,
      required this.isSuspicious,
      this.reason = '',
      this.matchesTrusted = false,
      this.verdict = 'unchecked',
      this.confidence = 1.0});

  factory _$LinkFindingImpl.fromJson(Map<String, dynamic> json) =>
      _$$LinkFindingImplFromJson(json);

  @override
  final String url;
  @override
  final String normalizedUrl;
  @override
  final String domain;
  @override
  final String registrableDomain;
  @override
  final bool isSuspicious;
  @override
  @JsonKey()
  final String reason;
  @override
  @JsonKey()
  final bool matchesTrusted;
  @override
  @JsonKey()
  final String verdict;
  @override
  @JsonKey()
  final double confidence;

  @override
  String toString() {
    return 'LinkFinding(url: $url, normalizedUrl: $normalizedUrl, domain: $domain, registrableDomain: $registrableDomain, isSuspicious: $isSuspicious, reason: $reason, matchesTrusted: $matchesTrusted, verdict: $verdict, confidence: $confidence)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LinkFindingImpl &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.normalizedUrl, normalizedUrl) ||
                other.normalizedUrl == normalizedUrl) &&
            (identical(other.domain, domain) || other.domain == domain) &&
            (identical(other.registrableDomain, registrableDomain) ||
                other.registrableDomain == registrableDomain) &&
            (identical(other.isSuspicious, isSuspicious) ||
                other.isSuspicious == isSuspicious) &&
            (identical(other.reason, reason) || other.reason == reason) &&
            (identical(other.matchesTrusted, matchesTrusted) ||
                other.matchesTrusted == matchesTrusted) &&
            (identical(other.verdict, verdict) || other.verdict == verdict) &&
            (identical(other.confidence, confidence) ||
                other.confidence == confidence));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      url,
      normalizedUrl,
      domain,
      registrableDomain,
      isSuspicious,
      reason,
      matchesTrusted,
      verdict,
      confidence);

  /// Create a copy of LinkFinding
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LinkFindingImplCopyWith<_$LinkFindingImpl> get copyWith =>
      __$$LinkFindingImplCopyWithImpl<_$LinkFindingImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LinkFindingImplToJson(
      this,
    );
  }
}

abstract class _LinkFinding implements LinkFinding {
  const factory _LinkFinding(
      {required final String url,
      required final String normalizedUrl,
      required final String domain,
      required final String registrableDomain,
      required final bool isSuspicious,
      final String reason,
      final bool matchesTrusted,
      final String verdict,
      final double confidence}) = _$LinkFindingImpl;

  factory _LinkFinding.fromJson(Map<String, dynamic> json) =
      _$LinkFindingImpl.fromJson;

  @override
  String get url;
  @override
  String get normalizedUrl;
  @override
  String get domain;
  @override
  String get registrableDomain;
  @override
  bool get isSuspicious;
  @override
  String get reason;
  @override
  bool get matchesTrusted;
  @override
  String get verdict;
  @override
  double get confidence;

  /// Create a copy of LinkFinding
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LinkFindingImplCopyWith<_$LinkFindingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

OtpFinding _$OtpFindingFromJson(Map<String, dynamic> json) {
  return _OtpFinding.fromJson(json);
}

/// @nodoc
mixin _$OtpFinding {
  String get context => throw _privateConstructorUsedError;
  String get label => throw _privateConstructorUsedError;
  bool get isRisky => throw _privateConstructorUsedError;
  String get reason => throw _privateConstructorUsedError;
  bool get valuePresent => throw _privateConstructorUsedError;

  /// Serializes this OtpFinding to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of OtpFinding
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OtpFindingCopyWith<OtpFinding> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OtpFindingCopyWith<$Res> {
  factory $OtpFindingCopyWith(
          OtpFinding value, $Res Function(OtpFinding) then) =
      _$OtpFindingCopyWithImpl<$Res, OtpFinding>;
  @useResult
  $Res call(
      {String context,
      String label,
      bool isRisky,
      String reason,
      bool valuePresent});
}

/// @nodoc
class _$OtpFindingCopyWithImpl<$Res, $Val extends OtpFinding>
    implements $OtpFindingCopyWith<$Res> {
  _$OtpFindingCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OtpFinding
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? context = null,
    Object? label = null,
    Object? isRisky = null,
    Object? reason = null,
    Object? valuePresent = null,
  }) {
    return _then(_value.copyWith(
      context: null == context
          ? _value.context
          : context // ignore: cast_nullable_to_non_nullable
              as String,
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
      isRisky: null == isRisky
          ? _value.isRisky
          : isRisky // ignore: cast_nullable_to_non_nullable
              as bool,
      reason: null == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String,
      valuePresent: null == valuePresent
          ? _value.valuePresent
          : valuePresent // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$OtpFindingImplCopyWith<$Res>
    implements $OtpFindingCopyWith<$Res> {
  factory _$$OtpFindingImplCopyWith(
          _$OtpFindingImpl value, $Res Function(_$OtpFindingImpl) then) =
      __$$OtpFindingImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String context,
      String label,
      bool isRisky,
      String reason,
      bool valuePresent});
}

/// @nodoc
class __$$OtpFindingImplCopyWithImpl<$Res>
    extends _$OtpFindingCopyWithImpl<$Res, _$OtpFindingImpl>
    implements _$$OtpFindingImplCopyWith<$Res> {
  __$$OtpFindingImplCopyWithImpl(
      _$OtpFindingImpl _value, $Res Function(_$OtpFindingImpl) _then)
      : super(_value, _then);

  /// Create a copy of OtpFinding
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? context = null,
    Object? label = null,
    Object? isRisky = null,
    Object? reason = null,
    Object? valuePresent = null,
  }) {
    return _then(_$OtpFindingImpl(
      context: null == context
          ? _value.context
          : context // ignore: cast_nullable_to_non_nullable
              as String,
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
      isRisky: null == isRisky
          ? _value.isRisky
          : isRisky // ignore: cast_nullable_to_non_nullable
              as bool,
      reason: null == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String,
      valuePresent: null == valuePresent
          ? _value.valuePresent
          : valuePresent // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$OtpFindingImpl implements _OtpFinding {
  const _$OtpFindingImpl(
      {required this.context,
      required this.label,
      this.isRisky = false,
      this.reason = '',
      this.valuePresent = false});

  factory _$OtpFindingImpl.fromJson(Map<String, dynamic> json) =>
      _$$OtpFindingImplFromJson(json);

  @override
  final String context;
  @override
  final String label;
  @override
  @JsonKey()
  final bool isRisky;
  @override
  @JsonKey()
  final String reason;
  @override
  @JsonKey()
  final bool valuePresent;

  @override
  String toString() {
    return 'OtpFinding(context: $context, label: $label, isRisky: $isRisky, reason: $reason, valuePresent: $valuePresent)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OtpFindingImpl &&
            (identical(other.context, context) || other.context == context) &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.isRisky, isRisky) || other.isRisky == isRisky) &&
            (identical(other.reason, reason) || other.reason == reason) &&
            (identical(other.valuePresent, valuePresent) ||
                other.valuePresent == valuePresent));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, context, label, isRisky, reason, valuePresent);

  /// Create a copy of OtpFinding
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OtpFindingImplCopyWith<_$OtpFindingImpl> get copyWith =>
      __$$OtpFindingImplCopyWithImpl<_$OtpFindingImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$OtpFindingImplToJson(
      this,
    );
  }
}

abstract class _OtpFinding implements OtpFinding {
  const factory _OtpFinding(
      {required final String context,
      required final String label,
      final bool isRisky,
      final String reason,
      final bool valuePresent}) = _$OtpFindingImpl;

  factory _OtpFinding.fromJson(Map<String, dynamic> json) =
      _$OtpFindingImpl.fromJson;

  @override
  String get context;
  @override
  String get label;
  @override
  bool get isRisky;
  @override
  String get reason;
  @override
  bool get valuePresent;

  /// Create a copy of OtpFinding
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OtpFindingImplCopyWith<_$OtpFindingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Verification _$VerificationFromJson(Map<String, dynamic> json) {
  return _Verification.fromJson(json);
}

/// @nodoc
mixin _$Verification {
  String get status => throw _privateConstructorUsedError;
  List<String>? get labels => throw _privateConstructorUsedError;
  int get riskModifier => throw _privateConstructorUsedError;
  String get organization => throw _privateConstructorUsedError;
  String get details => throw _privateConstructorUsedError;

  /// Serializes this Verification to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Verification
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VerificationCopyWith<Verification> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VerificationCopyWith<$Res> {
  factory $VerificationCopyWith(
          Verification value, $Res Function(Verification) then) =
      _$VerificationCopyWithImpl<$Res, Verification>;
  @useResult
  $Res call(
      {String status,
      List<String>? labels,
      int riskModifier,
      String organization,
      String details});
}

/// @nodoc
class _$VerificationCopyWithImpl<$Res, $Val extends Verification>
    implements $VerificationCopyWith<$Res> {
  _$VerificationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Verification
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? labels = freezed,
    Object? riskModifier = null,
    Object? organization = null,
    Object? details = null,
  }) {
    return _then(_value.copyWith(
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      labels: freezed == labels
          ? _value.labels
          : labels // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      riskModifier: null == riskModifier
          ? _value.riskModifier
          : riskModifier // ignore: cast_nullable_to_non_nullable
              as int,
      organization: null == organization
          ? _value.organization
          : organization // ignore: cast_nullable_to_non_nullable
              as String,
      details: null == details
          ? _value.details
          : details // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$VerificationImplCopyWith<$Res>
    implements $VerificationCopyWith<$Res> {
  factory _$$VerificationImplCopyWith(
          _$VerificationImpl value, $Res Function(_$VerificationImpl) then) =
      __$$VerificationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String status,
      List<String>? labels,
      int riskModifier,
      String organization,
      String details});
}

/// @nodoc
class __$$VerificationImplCopyWithImpl<$Res>
    extends _$VerificationCopyWithImpl<$Res, _$VerificationImpl>
    implements _$$VerificationImplCopyWith<$Res> {
  __$$VerificationImplCopyWithImpl(
      _$VerificationImpl _value, $Res Function(_$VerificationImpl) _then)
      : super(_value, _then);

  /// Create a copy of Verification
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? labels = freezed,
    Object? riskModifier = null,
    Object? organization = null,
    Object? details = null,
  }) {
    return _then(_$VerificationImpl(
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      labels: freezed == labels
          ? _value._labels
          : labels // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      riskModifier: null == riskModifier
          ? _value.riskModifier
          : riskModifier // ignore: cast_nullable_to_non_nullable
              as int,
      organization: null == organization
          ? _value.organization
          : organization // ignore: cast_nullable_to_non_nullable
              as String,
      details: null == details
          ? _value.details
          : details // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$VerificationImpl implements _Verification {
  const _$VerificationImpl(
      {required this.status,
      final List<String>? labels,
      this.riskModifier = 0,
      this.organization = '',
      this.details = ''})
      : _labels = labels;

  factory _$VerificationImpl.fromJson(Map<String, dynamic> json) =>
      _$$VerificationImplFromJson(json);

  @override
  final String status;
  final List<String>? _labels;
  @override
  List<String>? get labels {
    final value = _labels;
    if (value == null) return null;
    if (_labels is EqualUnmodifiableListView) return _labels;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey()
  final int riskModifier;
  @override
  @JsonKey()
  final String organization;
  @override
  @JsonKey()
  final String details;

  @override
  String toString() {
    return 'Verification(status: $status, labels: $labels, riskModifier: $riskModifier, organization: $organization, details: $details)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VerificationImpl &&
            (identical(other.status, status) || other.status == status) &&
            const DeepCollectionEquality().equals(other._labels, _labels) &&
            (identical(other.riskModifier, riskModifier) ||
                other.riskModifier == riskModifier) &&
            (identical(other.organization, organization) ||
                other.organization == organization) &&
            (identical(other.details, details) || other.details == details));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      status,
      const DeepCollectionEquality().hash(_labels),
      riskModifier,
      organization,
      details);

  /// Create a copy of Verification
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VerificationImplCopyWith<_$VerificationImpl> get copyWith =>
      __$$VerificationImplCopyWithImpl<_$VerificationImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VerificationImplToJson(
      this,
    );
  }
}

abstract class _Verification implements Verification {
  const factory _Verification(
      {required final String status,
      final List<String>? labels,
      final int riskModifier,
      final String organization,
      final String details}) = _$VerificationImpl;

  factory _Verification.fromJson(Map<String, dynamic> json) =
      _$VerificationImpl.fromJson;

  @override
  String get status;
  @override
  List<String>? get labels;
  @override
  int get riskModifier;
  @override
  String get organization;
  @override
  String get details;

  /// Create a copy of Verification
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VerificationImplCopyWith<_$VerificationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
