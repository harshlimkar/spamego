// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'trusted_contact.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

TrustedContact _$TrustedContactFromJson(Map<String, dynamic> json) {
  return _TrustedContact.fromJson(json);
}

/// @nodoc
mixin _$TrustedContact {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get phoneNumber => throw _privateConstructorUsedError;
  String get relationship => throw _privateConstructorUsedError;
  int get priority => throw _privateConstructorUsedError;
  bool get consent => throw _privateConstructorUsedError;
  bool get isPrimary => throw _privateConstructorUsedError;
  DateTime? get addedAt => throw _privateConstructorUsedError;

  /// Serializes this TrustedContact to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TrustedContact
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TrustedContactCopyWith<TrustedContact> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TrustedContactCopyWith<$Res> {
  factory $TrustedContactCopyWith(
          TrustedContact value, $Res Function(TrustedContact) then) =
      _$TrustedContactCopyWithImpl<$Res, TrustedContact>;
  @useResult
  $Res call(
      {String id,
      String name,
      String phoneNumber,
      String relationship,
      int priority,
      bool consent,
      bool isPrimary,
      DateTime? addedAt});
}

/// @nodoc
class _$TrustedContactCopyWithImpl<$Res, $Val extends TrustedContact>
    implements $TrustedContactCopyWith<$Res> {
  _$TrustedContactCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TrustedContact
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? phoneNumber = null,
    Object? relationship = null,
    Object? priority = null,
    Object? consent = null,
    Object? isPrimary = null,
    Object? addedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      phoneNumber: null == phoneNumber
          ? _value.phoneNumber
          : phoneNumber // ignore: cast_nullable_to_non_nullable
              as String,
      relationship: null == relationship
          ? _value.relationship
          : relationship // ignore: cast_nullable_to_non_nullable
              as String,
      priority: null == priority
          ? _value.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as int,
      consent: null == consent
          ? _value.consent
          : consent // ignore: cast_nullable_to_non_nullable
              as bool,
      isPrimary: null == isPrimary
          ? _value.isPrimary
          : isPrimary // ignore: cast_nullable_to_non_nullable
              as bool,
      addedAt: freezed == addedAt
          ? _value.addedAt
          : addedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TrustedContactImplCopyWith<$Res>
    implements $TrustedContactCopyWith<$Res> {
  factory _$$TrustedContactImplCopyWith(_$TrustedContactImpl value,
          $Res Function(_$TrustedContactImpl) then) =
      __$$TrustedContactImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String phoneNumber,
      String relationship,
      int priority,
      bool consent,
      bool isPrimary,
      DateTime? addedAt});
}

/// @nodoc
class __$$TrustedContactImplCopyWithImpl<$Res>
    extends _$TrustedContactCopyWithImpl<$Res, _$TrustedContactImpl>
    implements _$$TrustedContactImplCopyWith<$Res> {
  __$$TrustedContactImplCopyWithImpl(
      _$TrustedContactImpl _value, $Res Function(_$TrustedContactImpl) _then)
      : super(_value, _then);

  /// Create a copy of TrustedContact
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? phoneNumber = null,
    Object? relationship = null,
    Object? priority = null,
    Object? consent = null,
    Object? isPrimary = null,
    Object? addedAt = freezed,
  }) {
    return _then(_$TrustedContactImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      phoneNumber: null == phoneNumber
          ? _value.phoneNumber
          : phoneNumber // ignore: cast_nullable_to_non_nullable
              as String,
      relationship: null == relationship
          ? _value.relationship
          : relationship // ignore: cast_nullable_to_non_nullable
              as String,
      priority: null == priority
          ? _value.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as int,
      consent: null == consent
          ? _value.consent
          : consent // ignore: cast_nullable_to_non_nullable
              as bool,
      isPrimary: null == isPrimary
          ? _value.isPrimary
          : isPrimary // ignore: cast_nullable_to_non_nullable
              as bool,
      addedAt: freezed == addedAt
          ? _value.addedAt
          : addedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TrustedContactImpl implements _TrustedContact {
  const _$TrustedContactImpl(
      {required this.id,
      required this.name,
      required this.phoneNumber,
      required this.relationship,
      this.priority = 1,
      this.consent = true,
      this.isPrimary = false,
      this.addedAt});

  factory _$TrustedContactImpl.fromJson(Map<String, dynamic> json) =>
      _$$TrustedContactImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String phoneNumber;
  @override
  final String relationship;
  @override
  @JsonKey()
  final int priority;
  @override
  @JsonKey()
  final bool consent;
  @override
  @JsonKey()
  final bool isPrimary;
  @override
  final DateTime? addedAt;

  @override
  String toString() {
    return 'TrustedContact(id: $id, name: $name, phoneNumber: $phoneNumber, relationship: $relationship, priority: $priority, consent: $consent, isPrimary: $isPrimary, addedAt: $addedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TrustedContactImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.phoneNumber, phoneNumber) ||
                other.phoneNumber == phoneNumber) &&
            (identical(other.relationship, relationship) ||
                other.relationship == relationship) &&
            (identical(other.priority, priority) ||
                other.priority == priority) &&
            (identical(other.consent, consent) || other.consent == consent) &&
            (identical(other.isPrimary, isPrimary) ||
                other.isPrimary == isPrimary) &&
            (identical(other.addedAt, addedAt) || other.addedAt == addedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, phoneNumber,
      relationship, priority, consent, isPrimary, addedAt);

  /// Create a copy of TrustedContact
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TrustedContactImplCopyWith<_$TrustedContactImpl> get copyWith =>
      __$$TrustedContactImplCopyWithImpl<_$TrustedContactImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TrustedContactImplToJson(
      this,
    );
  }
}

abstract class _TrustedContact implements TrustedContact {
  const factory _TrustedContact(
      {required final String id,
      required final String name,
      required final String phoneNumber,
      required final String relationship,
      final int priority,
      final bool consent,
      final bool isPrimary,
      final DateTime? addedAt}) = _$TrustedContactImpl;

  factory _TrustedContact.fromJson(Map<String, dynamic> json) =
      _$TrustedContactImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get phoneNumber;
  @override
  String get relationship;
  @override
  int get priority;
  @override
  bool get consent;
  @override
  bool get isPrimary;
  @override
  DateTime? get addedAt;

  /// Create a copy of TrustedContact
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TrustedContactImplCopyWith<_$TrustedContactImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
