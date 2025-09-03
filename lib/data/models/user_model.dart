import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/user_entity.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.nomeCompleto,
    required super.cpf,
    required super.email,
    required super.telefone,
    required super.dataNascimento,
    required super.sexo,
    required super.cep,
    required super.endereco,
    required super.bairro,
    required super.cidade,
    required super.uf,
    required super.codigo8Digitos,
    required super.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      nomeCompleto: entity.nomeCompleto,
      cpf: entity.cpf,
      email: entity.email,
      telefone: entity.telefone,
      dataNascimento: entity.dataNascimento,
      sexo: entity.sexo,
      cep: entity.cep,
      endereco: entity.endereco,
      bairro: entity.bairro,
      cidade: entity.cidade,
      uf: entity.uf,
      codigo8Digitos: entity.codigo8Digitos,
      createdAt: entity.createdAt,
    );
  }
}