enum UserRole { owner, vet }

/// `users/{uid}`
class AppUser {
  const AppUser({
    required this.id,
    required this.role,
    required this.name,
    required this.shareCode,
    this.clinicId,
  });

  final String id;
  final UserRole role;
  final String name;
  final String shareCode;

  /// Only set for vets.
  final String? clinicId;

  factory AppUser.fromMap(String id, Map<String, dynamic> map) => AppUser(
        id: id,
        role: UserRole.values.byName(map['role'] as String),
        name: map['name'] as String,
        shareCode: map['shareCode'] as String,
        clinicId: map['clinicId'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'role': role.name,
        'name': name,
        'shareCode': shareCode,
        if (clinicId != null) 'clinicId': clinicId,
      };
}
