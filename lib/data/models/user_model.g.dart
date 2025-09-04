// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  id: json['id'] as String,
  fullName: json['fullName'] as String,
  cpf: json['cpf'] as String,
  email: json['email'] as String,
  phone: json['phone'] as String,
  birthDate: DateTime.parse(json['birthDate'] as String),
  gender: json['gender'] as String,
  zipCode: json['zipCode'] as String,
  address: json['address'] as String,
  neighborhood: json['neighborhood'] as String,
  city: json['city'] as String,
  state: json['state'] as String,
  eightDigitCode: json['eightDigitCode'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'id': instance.id,
  'fullName': instance.fullName,
  'cpf': instance.cpf,
  'email': instance.email,
  'phone': instance.phone,
  'birthDate': instance.birthDate.toIso8601String(),
  'gender': instance.gender,
  'zipCode': instance.zipCode,
  'address': instance.address,
  'neighborhood': instance.neighborhood,
  'city': instance.city,
  'state': instance.state,
  'eightDigitCode': instance.eightDigitCode,
  'createdAt': instance.createdAt.toIso8601String(),
};
