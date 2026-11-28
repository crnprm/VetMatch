enum TransferStatus { pending, accepted, rejected, cancelled }

/// `transferRequests/{petId}`: at most one open transfer per pet.
class TransferRequest {
  const TransferRequest({
    required this.petId,
    required this.fromOwnerId,
    required this.toOwnerId,
    required this.status,
    required this.createdAt,
  });

  final String petId;
  final String fromOwnerId;
  final String toOwnerId;
  final TransferStatus status;
  final DateTime createdAt;

  factory TransferRequest.fromMap(String petId, Map<String, dynamic> map) =>
      TransferRequest(
        petId: petId,
        fromOwnerId: map['fromOwnerId'] as String,
        toOwnerId: map['toOwnerId'] as String,
        status: TransferStatus.values.byName(map['status'] as String),
        createdAt: map['createdAt'] as DateTime,
      );

  Map<String, dynamic> toMap() => {
        'petId': petId,
        'fromOwnerId': fromOwnerId,
        'toOwnerId': toOwnerId,
        'status': status.name,
        'createdAt': createdAt,
      };

  TransferRequest copyWith({TransferStatus? status}) => TransferRequest(
        petId: petId,
        fromOwnerId: fromOwnerId,
        toOwnerId: toOwnerId,
        status: status ?? this.status,
        createdAt: createdAt,
      );
}
