/// `contactShares/{uidA}_{uidB}`: lets two users read each other's phone.
class ContactShare {
  const ContactShare({
    required this.userIds,
    required this.matchRequestId,
    required this.createdAt,
  });

  /// Sorted pair of uids.
  final List<String> userIds;
  final String matchRequestId;
  final DateTime createdAt;

  String get id => idFor(userIds[0], userIds[1]);

  /// Document id for a pair of users, independent of argument order.
  static String idFor(String a, String b) =>
      a.compareTo(b) < 0 ? '${a}_$b' : '${b}_$a';

  factory ContactShare.fromMap(Map<String, dynamic> map) => ContactShare(
        userIds: List<String>.from(map['userIds'] as List),
        matchRequestId: map['matchRequestId'] as String,
        createdAt: map['createdAt'] as DateTime,
      );

  Map<String, dynamic> toMap() => {
        'userIds': userIds,
        'matchRequestId': matchRequestId,
        'createdAt': createdAt,
      };
}
