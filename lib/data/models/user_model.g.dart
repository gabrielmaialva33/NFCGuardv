// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  id: json['id'] as String,
  fullName: json['full_name'] as String,
  cpf: json['cpf'] as String,
  email: json['email'] as String,
  phone: json['phone'] as String,
  birthDate: DateTime.parse(json['birth_date'] as String),
  gender: json['gender'] as String,
  zipCode: json['zip_code'] as String,
  address: json['address'] as String,
  neighborhood: json['neighborhood'] as String,
  city: json['city'] as String,
  state: json['state'] as String,
  eightDigitCode: json['eight_digit_code'] as String,
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'id': instance.id,
  'full_name': instance.fullName,
  'cpf': instance.cpf,
  'email': instance.email,
  'phone': instance.phone,
  'birth_date': instance.birthDate.toIso8601String(),
  'gender': instance.gender,
  'zip_code': instance.zipCode,
  'address': instance.address,
  'neighborhood': instance.neighborhood,
  'city': instance.city,
  'state': instance.state,
  'eight_digit_code': instance.eightDigitCode,
  'created_at': instance.createdAt.toIso8601String(),
};
