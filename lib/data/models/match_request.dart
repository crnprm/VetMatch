enum MatchStatus { pending, accepted, rejected, cancelled, withdrawn }

/// `matchRequests/{fromPetId}_{toPetId}`. A resend overwrites this document.
class MatchRequest {
  const MatchRequest({
    required this.fromPetId,
    required this.toPetId,
    required this.fromOwnerId,
    required this.toOwnerId,
    required this.status,
    required this.createdAt,
    required this.resendAllowed,
    required this.sendCount,
    required this.windowStart,
    this.rejectedAt,
  });

  final String fromPetId;
  final String toPetId;
  final String fromOwnerId;
  final String toOwnerId;
  final MatchStatus status;
  final DateTime createdAt;
  final DateTime? rejectedAt;

  /// Set by the receiver to lift the 30-day resend wait after a rejection.
  final bool resendAllowed;

  /// Sends of this pet pair inside the 3-minute spam window.
  final int sendCount;
  final DateTime windowStart;

  String get id => idFor(fromPetId, toPetId);

  static String idFor(String fromPetId, String toPetId) =>
      '${fromPetId}_$toPetId';

  factory MatchRequest.fromMap(Map<String, dynamic> map) => MatchRequest(
        fromPetId: map['fromPetId'] as String,
        toPetId: map['toPetId'] as String,
        fromOwnerId: map['fromOwnerId'] as String,
        toOwnerId: map['toOwnerId'] as String,
        status: MatchStatus.values.byName(map['status'] as String),
        createdAt: map['createdAt'] as DateTime,
        rejectedAt: map['rejectedAt'] as DateTime?,
        resendAllowed: map['resendAllowed'] as bool,
        sendCount: map['sendCount'] as int,
        windowStart: map['windowStart'] as DateTime,
      );

  Map<String, dynamic> toMap() => {
        'fromPetId': fromPetId,
        'toPetId': toPetId,
        'fromOwnerId': fromOwnerId,
        'toOwnerId': toOwnerId,
        'status': status.name,
        'createdAt': createdAt,
        if (rejectedAt != null) 'rejectedAt': rejectedAt,
        'resendAllowed': resendAllowed,
        'sendCount': sendCount,
        'windowStart': windowStart,
      };

  MatchRequest copyWith({
    MatchStatus? status,
    DateTime? createdAt,
    DateTime? rejectedAt,
    bool? resendAllowed,
    int? sendCount,
    DateTime? windowStart,
  }) =>
      MatchRequest(
        fromPetId: fromPetId,
        toPetId: toPetId,
        fromOwnerId: fromOwnerId,
        toOwnerId: toOwnerId,
        status: status ?? this.status,
        createdAt: createdAt ?? this.createdAt,
        rejectedAt: rejectedAt ?? this.rejectedAt,
        resendAllowed: resendAllowed ?? this.resendAllowed,
        sendCount: sendCount ?? this.sendCount,
        windowStart: windowStart ?? this.windowStart,
      );
}
