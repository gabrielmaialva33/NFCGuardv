import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/user_entity.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel extends UserEntity {
  @JsonKey(name: 'nome_completo')
  @override
  final String fullName;

  @JsonKey(name: 'telefone')
  @override
  final String phone;

  @JsonKey(name: 'data_nascimento')
  @override
  final DateTime birthDate;

  @JsonKey(name: 'sexo')
  @override
  final String gender;

  @JsonKey(name: 'cep')
  @override
  final String zipCode;

  @JsonKey(name: 'endereco')
  @override
  final String address;

  @JsonKey(name: 'bairro')
  @override
  final String neighborhood;

  @JsonKey(name: 'cidade')
  @override
  final String city;

  @JsonKey(name: 'uf')
  @override
  final String state;

  @JsonKey(name: 'codigo_8_digitos')
  @override
  final String eightDigitCode;

  @JsonKey(name: 'created_at')
  @override
  final DateTime createdAt;

  const UserModel({
    required super.id,
    required this.fullName,
    required super.cpf,
    required super.email,
    required this.phone,
    required this.birthDate,
    required this.gender,
    required this.zipCode,
    required this.address,
    required this.neighborhood,
    required this.city,
    required this.state,
    required this.eightDigitCode,
    required this.createdAt,
  }) : super(
          fullName: fullName,
          phone: phone,
          birthDate: birthDate,
          gender: gender,
          zipCode: zipCode,
          address: address,
          neighborhood: neighborhood,
          city: city,
          state: state,
          eightDigitCode: eightDigitCode,
          createdAt: createdAt,
        );

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
