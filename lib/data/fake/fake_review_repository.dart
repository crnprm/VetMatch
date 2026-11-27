import '../models/review.dart';
import '../repositories/review_repository.dart';
import 'fake_store.dart';

class FakeReviewRepository implements ReviewRepository {
  FakeReviewRepository(this._s);

  final FakeStore _s;

  @override
  Stream<List<Review>> watchReviews(String clinicId) =>
      _s.watch(() => (_s.reviews[clinicId] ?? {}).values.toList());

  @override
  Future<void> saveReview(Review review) async {
    (_s.reviews[review.clinicId] ??= {})[review.authorId] = review;
    _s.notify();
  }
}
