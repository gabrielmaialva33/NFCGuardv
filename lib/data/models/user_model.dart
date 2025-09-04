import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/user_entity.dart';

part 'user_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    @JsonKey(name: 'nome_completo') required super.fullName,
    required super.cpf,
    required super.email,
    @JsonKey(name: 'telefone') required super.phone,
    @JsonKey(name: 'data_nascimento') required super.birthDate,
    @JsonKey(name: 'sexo') required super.gender,
    @JsonKey(name: 'cep') required super.zipCode,
    @JsonKey(name: 'endereco') required super.address,
    @JsonKey(name: 'bairro') required super.neighborhood,
    @JsonKey(name: 'cidade') required super.city,
    @JsonKey(name: 'uf') required super.state,
    @JsonKey(name: 'codigo_8_digitos') required super.eightDigitCode,
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
