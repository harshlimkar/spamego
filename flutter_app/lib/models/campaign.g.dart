// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'campaign.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CampaignImpl _$$CampaignImplFromJson(Map<String, dynamic> json) =>
    _$CampaignImpl(
      id: json['id'] as String,
      riskScore: (json['riskScore'] as num).toInt(),
      riskLevel: json['riskLevel'] as String,
      categories: (json['categories'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      stageHistory: (json['stageHistory'] as List<dynamic>)
          .map((e) => StageTransition.fromJson(e as Map<String, dynamic>))
          .toList(),
      velocitySeconds: (json['velocitySeconds'] as num?)?.toDouble(),
      exposure: _exposureFromJson(json['exposure'] as Map<String, dynamic>),
      eventCount: (json['eventCount'] as num?)?.toInt() ?? 0,
      channels:
          (json['channels'] as List<dynamic>).map((e) => e as String).toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isActive: json['isActive'] as bool? ?? true,
    );

Map<String, dynamic> _$$CampaignImplToJson(_$CampaignImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'riskScore': instance.riskScore,
      'riskLevel': instance.riskLevel,
      'categories': instance.categories,
      'stageHistory': instance.stageHistory,
      'velocitySeconds': instance.velocitySeconds,
      'exposure': _exposureToJson(instance.exposure),
      'eventCount': instance.eventCount,
      'channels': instance.channels,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'isActive': instance.isActive,
    };

_$StageTransitionImpl _$$StageTransitionImplFromJson(
        Map<String, dynamic> json) =>
    _$StageTransitionImpl(
      stage: json['stage'] as String,
      label: json['label'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      confidence: (json['confidence'] as num?)?.toDouble() ?? 1.0,
    );

Map<String, dynamic> _$$StageTransitionImplToJson(
        _$StageTransitionImpl instance) =>
    <String, dynamic>{
      'stage': instance.stage,
      'label': instance.label,
      'timestamp': instance.timestamp.toIso8601String(),
      'confidence': instance.confidence,
    };
