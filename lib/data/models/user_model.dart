import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/user_entity.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    @JsonKey(name: 'full_name') required super.fullName,
    required super.cpf,
    required super.email,
    required super.phone,
    @JsonKey(name: 'birth_date') required super.birthDate,
    required super.gender,
    @JsonKey(name: 'zip_code') required super.zipCode,
    required super.address,
    required super.neighborhood,
    required super.city,
    required super.state,
    @JsonKey(name: 'eight_digit_code') required super.eightDigitCode,
    @JsonKey(name: 'created_at') required super.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      fullName: entity.fullName,
      cpf: entity.cpf,
      email: entity.email,
      phone: entity.phone,
      birthDate: entity.birthDate,
      gender: entity.gender,
      zipCode: entity.zipCode,
      address: entity.address,
      neighborhood: entity.neighborhood,
      city: entity.city,
      state: entity.state,
      eightDigitCode: entity.eightDigitCode,
      createdAt: entity.createdAt,
    );
  }
}
