/// `users/{receiverUid}/spamSenders/{senderUid}`. Readable only by the receiver.
class SpamSender {
  const SpamSender({required this.senderUid, required this.flaggedAt});

  final String senderUid;
  final DateTime flaggedAt;

  factory SpamSender.fromMap(String senderUid, Map<String, dynamic> map) =>
      SpamSender(senderUid: senderUid, flaggedAt: map['flaggedAt'] as DateTime);

  Map<String, dynamic> toMap() => {'flaggedAt': flaggedAt};
}
