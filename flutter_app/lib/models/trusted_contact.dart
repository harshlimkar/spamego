// Trusted contact model
import 'package:freezed_annotation/freezed_annotation.dart';

part 'trusted_contact.freezed.dart';
part 'trusted_contact.g.dart';

@freezed
class TrustedContact with _$TrustedContact {
  const factory TrustedContact({
    required String id,
    required String name,
    required String phoneNumber,
    required String relationship,
    @Default(1) int priority,
    @Default(true) bool consent,
    @Default(false) bool isPrimary,
    DateTime? addedAt,
  }) = _TrustedContact;

  factory TrustedContact.fromJson(Map<String, dynamic> json) => _$TrustedContactFromJson(json);
}

extension TrustedContactExtension on TrustedContact {
  String get displayName => '$name ($relationship)';
  
  String get formattedPhone {
    final cleaned = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    if (cleaned.startsWith('+91') && cleaned.length == 13) {
      return '+91 ${cleaned.substring(3, 8)} ${cleaned.substring(8)}';
    }
    return phoneNumber;
  }
}