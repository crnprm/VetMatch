/// `healthDocuments/{recordId}`: the compressed JPEG as base64 (ADR-001).
/// Readable only by the owner and the selected vet.
class HealthDocument {
  const HealthDocument({
    required this.recordId,
    required this.ownerId,
    required this.vetId,
    required this.imageBase64,
  });

  final String recordId;
  final String ownerId;
  final String vetId;
  final String imageBase64;

  factory HealthDocument.fromMap(String recordId, Map<String, dynamic> map) =>
      HealthDocument(
        recordId: recordId,
        ownerId: map['ownerId'] as String,
        vetId: map['vetId'] as String,
        imageBase64: map['imageBase64'] as String,
      );

  Map<String, dynamic> toMap() => {
        'ownerId': ownerId,
        'vetId': vetId,
        'imageBase64': imageBase64,
      };
}
