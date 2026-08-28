// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scam_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ScamEventImpl _$$ScamEventImplFromJson(Map<String, dynamic> json) =>
    _$ScamEventImpl(
      id: json['id'] as String,
      channel: json['channel'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      sender: json['sender'] as String,
      text: json['text'] as String,
      normalized: json['normalized'] as String,
      language: json['language'] as String,
      verdict: json['verdict'] as String,
      headline: json['headline'] as String,
      risk: RiskResult.fromJson(json['risk'] as Map<String, dynamic>),
      campaign: CampaignInfo.fromJson(json['campaign'] as Map<String, dynamic>),
      intervention:
          Intervention.fromJson(json['intervention'] as Map<String, dynamic>),
      familyAlert: FamilyAlertDecision.fromJson(
          json['familyAlert'] as Map<String, dynamic>),
      recovery: json['recovery'] == null
          ? null
          : RecoveryPlan.fromJson(json['recovery'] as Map<String, dynamic>),
      supportSms: json['supportSms'] as String?,
      entities: json['entities'] as Map<String, dynamic>?,
      intents: (json['intents'] as List<dynamic>?)
          ?.map((e) => Intent.fromJson(e as Map<String, dynamic>))
          .toList(),
      stage: json['stage'] == null
          ? null
          : ScamStage.fromJson(json['stage'] as Map<String, dynamic>),
      linkFindings: (json['linkFindings'] as List<dynamic>?)
          ?.map((e) => LinkFinding.fromJson(e as Map<String, dynamic>))
          .toList(),
      otp: json['otp'] == null
          ? null
          : OtpFinding.fromJson(json['otp'] as Map<String, dynamic>),
      verification: json['verification'] == null
          ? null
          : Verification.fromJson(json['verification'] as Map<String, dynamic>),
      ml: json['ml'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$ScamEventImplToJson(_$ScamEventImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'channel': instance.channel,
      'timestamp': instance.timestamp.toIso8601String(),
      'sender': instance.sender,
      'text': instance.text,
      'normalized': instance.normalized,
      'language': instance.language,
      'verdict': instance.verdict,
      'headline': instance.headline,
      'risk': instance.risk,
      'campaign': instance.campaign,
      'intervention': instance.intervention,
      'familyAlert': instance.familyAlert,
      'recovery': instance.recovery,
      'supportSms': instance.supportSms,
      'entities': instance.entities,
      'intents': instance.intents,
      'stage': instance.stage,
      'linkFindings': instance.linkFindings,
      'otp': instance.otp,
      'verification': instance.verification,
      'ml': instance.ml,
    };

_$RiskResultImpl _$$RiskResultImplFromJson(Map<String, dynamic> json) =>
    _$RiskResultImpl(
      score: (json['score'] as num).toInt(),
      level: json['level'] as String,
      edgeScore: (json['edgeScore'] as num?)?.toInt() ?? 0,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      isLegitimateSignal: json['isLegitimateSignal'] as bool? ?? false,
      factors: json['factors'] as Map<String, dynamic>?,
      explanations: (json['explanations'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$$RiskResultImplToJson(_$RiskResultImpl instance) =>
    <String, dynamic>{
      'score': instance.score,
      'level': instance.level,
      'edgeScore': instance.edgeScore,
      'confidence': instance.confidence,
      'isLegitimateSignal': instance.isLegitimateSignal,
      'factors': instance.factors,
      'explanations': instance.explanations,
    };

_$CampaignInfoImpl _$$CampaignInfoImplFromJson(Map<String, dynamic> json) =>
    _$CampaignInfoImpl(
      campaignId: json['campaignId'] as String? ?? '',
      riskScore: (json['riskScore'] as num?)?.toInt() ?? 0,
      riskLevel: json['riskLevel'] as String? ?? 'safe',
      categories: (json['categories'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      stageHistory: (json['stageHistory'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList(),
      velocitySeconds: (json['velocitySeconds'] as num?)?.toDouble(),
      progressionLabels: (json['progressionLabels'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      exposure: json['exposure'] == null
          ? null
          : Exposure.fromJson(json['exposure'] as Map<String, dynamic>),
      eventCount: (json['eventCount'] as num?)?.toInt() ?? 0,
      channels: (json['channels'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      createdAt: json['createdAt'] as String? ?? '',
      updatedAt: json['updatedAt'] as String? ?? '',
      isNew: json['isNew'] as bool? ?? false,
    );

Map<String, dynamic> _$$CampaignInfoImplToJson(_$CampaignInfoImpl instance) =>
    <String, dynamic>{
      'campaignId': instance.campaignId,
      'riskScore': instance.riskScore,
      'riskLevel': instance.riskLevel,
      'categories': instance.categories,
      'stageHistory': instance.stageHistory,
      'velocitySeconds': instance.velocitySeconds,
      'progressionLabels': instance.progressionLabels,
      'exposure': instance.exposure,
      'eventCount': instance.eventCount,
      'channels': instance.channels,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
      'isNew': instance.isNew,
    };

_$ExposureImpl _$$ExposureImplFromJson(Map<String, dynamic> json) =>
    _$ExposureImpl(
      moneyInr: (json['moneyInr'] as num?)?.toDouble() ?? 0.0,
      credentialRisk: json['credentialRisk'] as String? ?? 'none',
      otpRequested: json['otpRequested'] as bool? ?? false,
      deviceAccessRequested: json['deviceAccessRequested'] as bool? ?? false,
      accountAccessPossible: json['accountAccessPossible'] as bool? ?? false,
      description: json['description'] as String? ?? '',
    );

Map<String, dynamic> _$$ExposureImplToJson(_$ExposureImpl instance) =>
    <String, dynamic>{
      'moneyInr': instance.moneyInr,
      'credentialRisk': instance.credentialRisk,
      'otpRequested': instance.otpRequested,
      'deviceAccessRequested': instance.deviceAccessRequested,
      'accountAccessPossible': instance.accountAccessPossible,
      'description': instance.description,
    };

_$InterventionImpl _$$InterventionImplFromJson(Map<String, dynamic> json) =>
    _$InterventionImpl(
      action: json['action'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      buttons: (json['buttons'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$InterventionImplToJson(_$InterventionImpl instance) =>
    <String, dynamic>{
      'action': instance.action,
      'title': instance.title,
      'message': instance.message,
      'buttons': instance.buttons,
    };

_$FamilyAlertDecisionImpl _$$FamilyAlertDecisionImplFromJson(
        Map<String, dynamic> json) =>
    _$FamilyAlertDecisionImpl(
      alertSent: json['alertSent'] as bool? ?? false,
      recipient: json['recipient'] as String? ?? '',
      risk: json['risk'] as String? ?? '',
      messagePreview: json['messagePreview'] as String? ?? '',
    );

Map<String, dynamic> _$$FamilyAlertDecisionImplToJson(
        _$FamilyAlertDecisionImpl instance) =>
    <String, dynamic>{
      'alertSent': instance.alertSent,
      'recipient': instance.recipient,
      'risk': instance.risk,
      'messagePreview': instance.messagePreview,
    };

_$RecoveryPlanImpl _$$RecoveryPlanImplFromJson(Map<String, dynamic> json) =>
    _$RecoveryPlanImpl(
      title: json['title'] as String,
      intro: json['intro'] as String,
      verifiedContacts: (json['verifiedContacts'] as List<dynamic>?)
          ?.map((e) => VerifiedContact.fromJson(e as Map<String, dynamic>))
          .toList(),
      recoverySteps: (json['recoverySteps'] as List<dynamic>?)
          ?.map((e) => RecoveryStep.fromJson(e as Map<String, dynamic>))
          .toList(),
      reportingSteps: (json['reportingSteps'] as List<dynamic>?)
          ?.map((e) => ReportingStep.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$RecoveryPlanImplToJson(_$RecoveryPlanImpl instance) =>
    <String, dynamic>{
      'title': instance.title,
      'intro': instance.intro,
      'verifiedContacts': instance.verifiedContacts,
      'recoverySteps': instance.recoverySteps,
      'reportingSteps': instance.reportingSteps,
    };

_$VerifiedContactImpl _$$VerifiedContactImplFromJson(
        Map<String, dynamic> json) =>
    _$VerifiedContactImpl(
      name: json['name'] as String,
      channel: json['channel'] as String,
      value: json['value'] as String,
      note: json['note'] as String,
    );

Map<String, dynamic> _$$VerifiedContactImplToJson(
        _$VerifiedContactImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'channel': instance.channel,
      'value': instance.value,
      'note': instance.note,
    };

_$RecoveryStepImpl _$$RecoveryStepImplFromJson(Map<String, dynamic> json) =>
    _$RecoveryStepImpl(
      order: (json['order'] as num).toInt(),
      title: json['title'] as String,
      text: json['text'] as String,
    );

Map<String, dynamic> _$$RecoveryStepImplToJson(_$RecoveryStepImpl instance) =>
    <String, dynamic>{
      'order': instance.order,
      'title': instance.title,
      'text': instance.text,
    };

_$ReportingStepImpl _$$ReportingStepImplFromJson(Map<String, dynamic> json) =>
    _$ReportingStepImpl(
      order: (json['order'] as num).toInt(),
      title: json['title'] as String,
      text: json['text'] as String,
    );

Map<String, dynamic> _$$ReportingStepImplToJson(_$ReportingStepImpl instance) =>
    <String, dynamic>{
      'order': instance.order,
      'title': instance.title,
      'text': instance.text,
    };

_$IntentImpl _$$IntentImplFromJson(Map<String, dynamic> json) => _$IntentImpl(
      name: json['name'] as String,
      label: json['label'] as String,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 1.0,
      signals:
          (json['signals'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );

Map<String, dynamic> _$$IntentImplToJson(_$IntentImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'label': instance.label,
      'confidence': instance.confidence,
      'signals': instance.signals,
    };

_$ScamStageImpl _$$ScamStageImplFromJson(Map<String, dynamic> json) =>
    _$ScamStageImpl(
      stage: json['stage'] as String,
      label: json['label'] as String,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 1.0,
      detectedAt: json['detectedAt'] as String?,
    );

Map<String, dynamic> _$$ScamStageImplToJson(_$ScamStageImpl instance) =>
    <String, dynamic>{
      'stage': instance.stage,
      'label': instance.label,
      'confidence': instance.confidence,
      'detectedAt': instance.detectedAt,
    };

_$LinkFindingImpl _$$LinkFindingImplFromJson(Map<String, dynamic> json) =>
    _$LinkFindingImpl(
      url: json['url'] as String,
      normalizedUrl: json['normalizedUrl'] as String,
      domain: json['domain'] as String,
      registrableDomain: json['registrableDomain'] as String,
      isSuspicious: json['isSuspicious'] as bool,
      reason: json['reason'] as String? ?? '',
      matchesTrusted: json['matchesTrusted'] as bool? ?? false,
      verdict: json['verdict'] as String? ?? 'unchecked',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 1.0,
    );

Map<String, dynamic> _$$LinkFindingImplToJson(_$LinkFindingImpl instance) =>
    <String, dynamic>{
      'url': instance.url,
      'normalizedUrl': instance.normalizedUrl,
      'domain': instance.domain,
      'registrableDomain': instance.registrableDomain,
      'isSuspicious': instance.isSuspicious,
      'reason': instance.reason,
      'matchesTrusted': instance.matchesTrusted,
      'verdict': instance.verdict,
      'confidence': instance.confidence,
    };

_$OtpFindingImpl _$$OtpFindingImplFromJson(Map<String, dynamic> json) =>
    _$OtpFindingImpl(
      context: json['context'] as String,
      label: json['label'] as String,
      isRisky: json['isRisky'] as bool? ?? false,
      reason: json['reason'] as String? ?? '',
      valuePresent: json['valuePresent'] as bool? ?? false,
    );

Map<String, dynamic> _$$OtpFindingImplToJson(_$OtpFindingImpl instance) =>
    <String, dynamic>{
      'context': instance.context,
      'label': instance.label,
      'isRisky': instance.isRisky,
      'reason': instance.reason,
      'valuePresent': instance.valuePresent,
    };

_$VerificationImpl _$$VerificationImplFromJson(Map<String, dynamic> json) =>
    _$VerificationImpl(
      status: json['status'] as String,
      labels:
          (json['labels'] as List<dynamic>?)?.map((e) => e as String).toList(),
      riskModifier: (json['riskModifier'] as num?)?.toInt() ?? 0,
      organization: json['organization'] as String? ?? '',
      details: json['details'] as String? ?? '',
    );

Map<String, dynamic> _$$VerificationImplToJson(_$VerificationImpl instance) =>
    <String, dynamic>{
      'status': instance.status,
      'labels': instance.labels,
      'riskModifier': instance.riskModifier,
      'organization': instance.organization,
      'details': instance.details,
    };
