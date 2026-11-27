import '../models/review.dart';

abstract interface class ReviewRepository {
  Stream<List<Review>> watchReviews(String clinicId);

  /// Creates or replaces the author's single review of the clinic.
  Future<void> saveReview(Review review);
}
