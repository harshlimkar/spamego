// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'campaign_alert.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CampaignAlertImpl _$$CampaignAlertImplFromJson(Map<String, dynamic> json) =>
    _$CampaignAlertImpl(
      campaignId: json['campaignId'] as String,
      cumulativeRisk: (json['cumulativeRisk'] as num).toInt(),
      threatLevel: json['threatLevel'] as String,
      plainLanguageWarning: json['plainLanguageWarning'] as String,
      timestamp: json['timestamp'] == null
          ? null
          : DateTime.parse(json['timestamp'] as String),
      source: json['source'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$CampaignAlertImplToJson(_$CampaignAlertImpl instance) =>
    <String, dynamic>{
      'campaignId': instance.campaignId,
      'cumulativeRisk': instance.cumulativeRisk,
      'threatLevel': instance.threatLevel,
      'plainLanguageWarning': instance.plainLanguageWarning,
      'timestamp': instance.timestamp?.toIso8601String(),
      'source': instance.source,
      'metadata': instance.metadata,
    };
