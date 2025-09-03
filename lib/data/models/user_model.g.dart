// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  id: json['id'] as String,
  nomeCompleto: json['nomeCompleto'] as String,
  cpf: json['cpf'] as String,
  email: json['email'] as String,
  telefone: json['telefone'] as String,
  dataNascimento: DateTime.parse(json['dataNascimento'] as String),
  sexo: json['sexo'] as String,
  cep: json['cep'] as String,
  endereco: json['endereco'] as String,
  bairro: json['bairro'] as String,
  cidade: json['cidade'] as String,
  uf: json['uf'] as String,
  codigo8Digitos: json['codigo8Digitos'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'id': instance.id,
  'nomeCompleto': instance.nomeCompleto,
  'cpf': instance.cpf,
  'email': instance.email,
  'telefone': instance.telefone,
  'dataNascimento': instance.dataNascimento.toIso8601String(),
  'sexo': instance.sexo,
  'cep': instance.cep,
  'endereco': instance.endereco,
  'bairro': instance.bairro,
  'cidade': instance.cidade,
  'uf': instance.uf,
  'codigo8Digitos': instance.codigo8Digitos,
  'createdAt': instance.createdAt.toIso8601String(),
};
