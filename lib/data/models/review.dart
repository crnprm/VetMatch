/// `clinics/{clinicId}/reviews/{authorId}`: one review per user per clinic.
class Review {
  const Review({
    required this.clinicId,
    required this.authorId,
    required this.authorName,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  final String clinicId;
  final String authorId;
  final String authorName;

  /// 1 to 5.
  final int rating;
  final String comment;
  final DateTime createdAt;

  factory Review.fromMap(
    String clinicId,
    String authorId,
    Map<String, dynamic> map,
  ) =>
      Review(
        clinicId: clinicId,
        authorId: authorId,
        authorName: map['authorName'] as String,
        rating: map['rating'] as int,
        comment: map['comment'] as String,
        createdAt: map['createdAt'] as DateTime,
      );

  Map<String, dynamic> toMap() => {
        'authorName': authorName,
        'rating': rating,
        'comment': comment,
        'createdAt': createdAt,
      };
}
