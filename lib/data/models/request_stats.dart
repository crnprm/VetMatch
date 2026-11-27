/// `requestStats/{fromUid}_{toUid}`: sends from one user to all pets of
/// another user inside the 10-minute spam window. Directional.
class RequestStats {
  const RequestStats({
    required this.fromUid,
    required this.toUid,
    required this.sendCount,
    required this.windowStart,
  });

  final String fromUid;
  final String toUid;
  final int sendCount;
  final DateTime windowStart;

  String get id => idFor(fromUid, toUid);

  static String idFor(String fromUid, String toUid) => '${fromUid}_$toUid';

  factory RequestStats.fromMap(Map<String, dynamic> map) => RequestStats(
        fromUid: map['fromUid'] as String,
        toUid: map['toUid'] as String,
        sendCount: map['sendCount'] as int,
        windowStart: map['windowStart'] as DateTime,
      );

  Map<String, dynamic> toMap() => {
        'fromUid': fromUid,
        'toUid': toUid,
        'sendCount': sendCount,
        'windowStart': windowStart,
      };
}
