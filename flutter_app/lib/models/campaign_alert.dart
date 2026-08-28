import 'package:freezed_annotation/freezed_annotation.dart';

part 'campaign_alert.freezed.dart';
part 'campaign_alert.g.dart';

@freezed
class CampaignAlert with _$CampaignAlert {
  const factory CampaignAlert({
    required String campaignId,
    required int cumulativeRisk,
    required String threatLevel,
    required String plainLanguageWarning,
    DateTime? timestamp,
    String? source,
    Map<String, dynamic>? metadata,
  }) = _CampaignAlert;

  factory CampaignAlert.fromJson(Map<String, dynamic> json) => _$CampaignAlertFromJson(json);
}
