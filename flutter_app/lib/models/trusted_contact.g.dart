// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trusted_contact.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TrustedContactImpl _$$TrustedContactImplFromJson(Map<String, dynamic> json) =>
    _$TrustedContactImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      phoneNumber: json['phoneNumber'] as String,
      relationship: json['relationship'] as String,
      priority: (json['priority'] as num?)?.toInt() ?? 1,
      consent: json['consent'] as bool? ?? true,
      isPrimary: json['isPrimary'] as bool? ?? false,
      addedAt: json['addedAt'] == null
          ? null
          : DateTime.parse(json['addedAt'] as String),
    );

Map<String, dynamic> _$$TrustedContactImplToJson(
        _$TrustedContactImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'phoneNumber': instance.phoneNumber,
      'relationship': instance.relationship,
      'priority': instance.priority,
      'consent': instance.consent,
      'isPrimary': instance.isPrimary,
      'addedAt': instance.addedAt?.toIso8601String(),
    };
