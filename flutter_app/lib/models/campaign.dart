// Campaign and related models
import 'package:freezed_annotation/freezed_annotation.dart';
import 'scam_event.dart';

part 'campaign.freezed.dart';
part 'campaign.g.dart';

@freezed
class Campaign with _$Campaign {
  const factory Campaign({
    required String id,
    required int riskScore,
    required String riskLevel,
    required List<String> categories,
    required List<StageTransition> stageHistory,
    double? velocitySeconds,
    @JsonKey(fromJson: _exposureFromJson, toJson: _exposureToJson)
    required Exposure exposure,
    @Default(0) int eventCount,
    required List<String> channels,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default(true) bool isActive,
  }) = _Campaign;

  factory Campaign.fromJson(Map<String, dynamic> json) => _$CampaignFromJson(json);
}

Exposure _exposureFromJson(Map<String, dynamic> json) => Exposure.fromJson(json);
Map<String, dynamic> _exposureToJson(Exposure exposure) => exposure.toJson();

@freezed
class StageTransition with _$StageTransition {
  const factory StageTransition({
    required String stage,
    required String label,
    required DateTime timestamp,
    @Default(1.0) double confidence,
  }) = _StageTransition;

  factory StageTransition.fromJson(Map<String, dynamic> json) => _$StageTransitionFromJson(json);
}