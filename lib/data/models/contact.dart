/// `users/{uid}/private/contact`
class Contact {
  const Contact({required this.uid, required this.phone});

  final String uid;
  final String phone;

  factory Contact.fromMap(String uid, Map<String, dynamic> map) =>
      Contact(uid: uid, phone: map['phone'] as String);

  Map<String, dynamic> toMap() => {'phone': phone};
}
