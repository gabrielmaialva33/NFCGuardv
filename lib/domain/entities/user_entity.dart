class UserEntity {
  final String id;
  final String fullName;
  final String cpf;
  final String email;
  final String phone;
  final DateTime birthDate;
  final String gender;
  final String zipCode;
  final String address;
  final String neighborhood;
  final String city;
  final String state;
  final String eightDigitCode;
  final DateTime createdAt;

  const UserEntity({
    required this.id,
    required this.fullName,
    required this.cpf,
    required this.email,
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
  });

  UserEntity copyWith({
    String? id,
    String? fullName,
    String? cpf,
    String? email,
    String? phone,
    DateTime? birthDate,
    String? gender,
    String? zipCode,
    String? address,
    String? neighborhood,
    String? city,
    String? state,
    String? eightDigitCode,
    DateTime? createdAt,
  }) {
    return UserEntity(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      cpf: cpf ?? this.cpf,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      zipCode: zipCode ?? this.zipCode,
      address: address ?? this.address,
      neighborhood: neighborhood ?? this.neighborhood,
      city: city ?? this.city,
      state: state ?? this.state,
      eightDigitCode: eightDigitCode ?? this.eightDigitCode,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
