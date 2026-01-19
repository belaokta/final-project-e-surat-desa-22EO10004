class UserAccount {
  final String id; // UID dari Firebase Auth
  final String nama;
  final String nik;
  final String email;
  final String role; // admin / user
  final bool isVerified;

  UserAccount({
    required this.id,
    required this.nama,
    required this.nik,
    required this.email,
    required this.role,
    required this.isVerified,
  });

  /// dari Firestore ke Object
  factory UserAccount.fromMap(String id, Map<String, dynamic> map) {
    return UserAccount(
      id: id,
      nama: map['nama'] ?? '',
      nik: map['nik'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'user',
      isVerified: map['isVerified'] ?? false,
    );
  }

  /// dari Object ke Firestore
  Map<String, dynamic> toMap() {
    return {
      'nama': nama,
      'nik': nik,
      'email': email,
      'role': role,
      'isVerified': isVerified,
    };
  }
}
