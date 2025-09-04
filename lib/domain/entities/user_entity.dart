class UserEntity {
  final String id;
  final String nomeCompleto;
  final String cpf;
  final String email;
  final String telefone;
  final DateTime dataNascimento;
  final String sexo;
  final String cep;
  final String endereco;
  final String bairro;
  final String cidade;
  final String uf;
  final String codigo8Digitos;
  final DateTime createdAt;

  const UserEntity({
    required this.id,
    required this.nomeCompleto,
    required this.cpf,
    required this.email,
    required this.telefone,
    required this.dataNascimento,
    required this.sexo,
    required this.cep,
    required this.endereco,
    required this.bairro,
    required this.cidade,
    required this.uf,
    required this.codigo8Digitos,
    required this.createdAt,
  });

  UserEntity copyWith({
    String? id,
    String? nomeCompleto,
    String? cpf,
    String? email,
    String? telefone,
    DateTime? dataNascimento,
    String? sexo,
    String? cep,
    String? endereco,
    String? bairro,
    String? cidade,
    String? uf,
    String? codigo8Digitos,
    DateTime? createdAt,
  }) {
    return UserEntity(
      id: id ?? this.id,
      nomeCompleto: nomeCompleto ?? this.nomeCompleto,
      cpf: cpf ?? this.cpf,
      email: email ?? this.email,
      telefone: telefone ?? this.telefone,
      dataNascimento: dataNascimento ?? this.dataNascimento,
      sexo: sexo ?? this.sexo,
      cep: cep ?? this.cep,
      endereco: endereco ?? this.endereco,
      bairro: bairro ?? this.bairro,
      cidade: cidade ?? this.cidade,
      uf: uf ?? this.uf,
      codigo8Digitos: codigo8Digitos ?? this.codigo8Digitos,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
