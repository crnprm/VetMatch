/// "Expired" is not a status: an approved record with `validUntil` in the
/// past is shown as expired.
enum HealthStatus { pending, approved, rejected, withdrawn }

/// `healthRecords/{recordId}`. The image lives in `healthDocuments/{recordId}`.
class HealthRecord {
  const HealthRecord({
    required this.id,
    required this.petId,
    required this.ownerId,
    required this.testType,
    required this.vetId,
    required this.clinicId,
    required this.status,
    required this.createdAt,
    this.rejectionReason,
    this.approvedAt,
    this.validUntil,
  });

  final String id;
  final String petId;
  final String ownerId;

  /// Test key from the breed rule (e.g. `hcm_echo`).
  final String testType;
  final String vetId;
  final String clinicId;
  final HealthStatus status;
  final DateTime createdAt;
  final String? rejectionReason;
  final DateTime? approvedAt;
  final DateTime? validUntil;

  factory HealthRecord.fromMap(String id, Map<String, dynamic> map) =>
      HealthRecord(
        id: id,
        petId: map['petId'] as String,
        ownerId: map['ownerId'] as String,
        testType: map['testType'] as String,
        vetId: map['vetId'] as String,
        clinicId: map['clinicId'] as String,
        status: HealthStatus.values.byName(map['status'] as String),
        createdAt: map['createdAt'] as DateTime,
        rejectionReason: map['rejectionReason'] as String?,
        approvedAt: map['approvedAt'] as DateTime?,
        validUntil: map['validUntil'] as DateTime?,
      );

  Map<String, dynamic> toMap() => {
        'petId': petId,
        'ownerId': ownerId,
        'testType': testType,
        'vetId': vetId,
        'clinicId': clinicId,
        'status': status.name,
        'createdAt': createdAt,
        if (rejectionReason != null) 'rejectionReason': rejectionReason,
        if (approvedAt != null) 'approvedAt': approvedAt,
        if (validUntil != null) 'validUntil': validUntil,
      };

  HealthRecord copyWith({
    String? ownerId,
    HealthStatus? status,
    String? rejectionReason,
    DateTime? approvedAt,
    DateTime? validUntil,
  }) =>
      HealthRecord(
        id: id,
        petId: petId,
        ownerId: ownerId ?? this.ownerId,
        testType: testType,
        vetId: vetId,
        clinicId: clinicId,
        status: status ?? this.status,
        createdAt: createdAt,
        rejectionReason: rejectionReason ?? this.rejectionReason,
        approvedAt: approvedAt ?? this.approvedAt,
        validUntil: validUntil ?? this.validUntil,
      );
}
