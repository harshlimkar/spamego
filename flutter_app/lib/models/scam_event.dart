// Core data models for ScameGo
import 'package:freezed_annotation/freezed_annotation.dart';

part 'scam_event.freezed.dart';
part 'scam_event.g.dart';

@freezed
class ScamEvent with _$ScamEvent {
  const factory ScamEvent({
    required String id,
    required String channel,
    required DateTime timestamp,
    required String sender,
    required String text,
    required String normalized,
    required String language,
    required String verdict,
    required String headline,
    required RiskResult risk,
    required CampaignInfo campaign,
    required Intervention intervention,
    required FamilyAlertDecision familyAlert,
    RecoveryPlan? recovery,
    String? supportSms,
    Map<String, dynamic>? entities,
    List<Intent>? intents,
    ScamStage? stage,
    List<LinkFinding>? linkFindings,
    OtpFinding? otp,
    Verification? verification,
    Map<String, dynamic>? ml,
  }) = _ScamEvent;

  factory ScamEvent.fromJson(Map<String, dynamic> json) => _$ScamEventFromJson(json);
}

@freezed
class RiskResult with _$RiskResult {
  const factory RiskResult({
    required int score,
    required String level,
    @Default(0) int edgeScore,
    @Default(0.0) double confidence,
    @Default(false) bool isLegitimateSignal,
    Map<String, dynamic>? factors,
    List<String>? explanations,
  }) = _RiskResult;

  factory RiskResult.fromJson(Map<String, dynamic> json) => _$RiskResultFromJson(json);
}

@freezed
class CampaignInfo with _$CampaignInfo {
  const factory CampaignInfo({
    @Default('') String campaignId,
    @Default(0) int riskScore,
    @Default('safe') String riskLevel,
    List<String>? categories,
    List<Map<String, dynamic>>? stageHistory,
    double? velocitySeconds,
    List<String>? progressionLabels,
    Exposure? exposure,
    @Default(0) int eventCount,
    List<String>? channels,
    @Default('') String createdAt,
    @Default('') String updatedAt,
    @Default(false) bool isNew,
  }) = _CampaignInfo;

  factory CampaignInfo.fromJson(Map<String, dynamic> json) => _$CampaignInfoFromJson(json);
}

@freezed
class Exposure with _$Exposure {
  const factory Exposure({
    @Default(0.0) double moneyInr,
    @Default('none') String credentialRisk,
    @Default(false) bool otpRequested,
    @Default(false) bool deviceAccessRequested,
    @Default(false) bool accountAccessPossible,
    @Default('') String description,
  }) = _Exposure;

  factory Exposure.fromJson(Map<String, dynamic> json) => _$ExposureFromJson(json);
}

@freezed
class Intervention with _$Intervention {
  const factory Intervention({
    required String action,
    required String title,
    required String message,
    @Default([]) List<String> buttons,
  }) = _Intervention;

  factory Intervention.fromJson(Map<String, dynamic> json) => _$InterventionFromJson(json);
}

@freezed
class FamilyAlertDecision with _$FamilyAlertDecision {
  const factory FamilyAlertDecision({
    @Default(false) bool alertSent,
    @Default('') String recipient,
    @Default('') String risk,
    @Default('') String messagePreview,
  }) = _FamilyAlertDecision;

  factory FamilyAlertDecision.fromJson(Map<String, dynamic> json) => _$FamilyAlertDecisionFromJson(json);
}

@freezed
class RecoveryPlan with _$RecoveryPlan {
  const factory RecoveryPlan({
    required String title,
    required String intro,
    List<VerifiedContact>? verifiedContacts,
    List<RecoveryStep>? recoverySteps,
    List<ReportingStep>? reportingSteps,
  }) = _RecoveryPlan;

  factory RecoveryPlan.fromJson(Map<String, dynamic> json) => _$RecoveryPlanFromJson(json);
}

@freezed
class VerifiedContact with _$VerifiedContact {
  const factory VerifiedContact({
    required String name,
    required String channel,
    required String value,
    required String note,
  }) = _VerifiedContact;

  factory VerifiedContact.fromJson(Map<String, dynamic> json) => _$VerifiedContactFromJson(json);
}

@freezed
class RecoveryStep with _$RecoveryStep {
  const factory RecoveryStep({
    required int order,
    required String title,
    required String text,
  }) = _RecoveryStep;

  factory RecoveryStep.fromJson(Map<String, dynamic> json) => _$RecoveryStepFromJson(json);
}

@freezed
class ReportingStep with _$ReportingStep {
  const factory ReportingStep({
    required int order,
    required String title,
    required String text,
  }) = _ReportingStep;

  factory ReportingStep.fromJson(Map<String, dynamic> json) => _$ReportingStepFromJson(json);
}

@freezed
class Intent with _$Intent {
  const factory Intent({
    required String name,
    required String label,
    @Default(1.0) double confidence,
    List<String>? signals,
  }) = _Intent;

  factory Intent.fromJson(Map<String, dynamic> json) => _$IntentFromJson(json);
}

@freezed
class ScamStage with _$ScamStage {
  const factory ScamStage({
    required String stage,
    required String label,
    @Default(1.0) double confidence,
    String? detectedAt,
  }) = _ScamStage;

  factory ScamStage.fromJson(Map<String, dynamic> json) => _$ScamStageFromJson(json);
}

@freezed
class LinkFinding with _$LinkFinding {
  const factory LinkFinding({
    required String url,
    required String normalizedUrl,
    required String domain,
    required String registrableDomain,
    required bool isSuspicious,
    @Default('') String reason,
    @Default(false) bool matchesTrusted,
    @Default('unchecked') String verdict,
    @Default(1.0) double confidence,
  }) = _LinkFinding;

  factory LinkFinding.fromJson(Map<String, dynamic> json) => _$LinkFindingFromJson(json);
}

@freezed
class OtpFinding with _$OtpFinding {
  const factory OtpFinding({
    required String context,
    required String label,
    @Default(false) bool isRisky,
    @Default('') String reason,
    @Default(false) bool valuePresent,
  }) = _OtpFinding;

  factory OtpFinding.fromJson(Map<String, dynamic> json) => _$OtpFindingFromJson(json);
}

@freezed
class Verification with _$Verification {
  const factory Verification({
    required String status,
    List<String>? labels,
    @Default(0) int riskModifier,
    @Default('') String organization,
    @Default('') String details,
  }) = _Verification;

  factory Verification.fromJson(Map<String, dynamic> json) => _$VerificationFromJson(json);
}