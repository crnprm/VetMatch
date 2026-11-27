import '../models/app_user.dart';

abstract interface class UserRepository {
  Stream<AppUser?> watchUser(String uid);

  /// Used to find the receiver of a pet transfer.
  Future<AppUser?> findByShareCode(String shareCode);

  Stream<List<AppUser>> watchVetsOfClinic(String clinicId);

  /// The phone of [uid], or null if the signed-in user may not see it
  /// (no accepted match between them).
  Future<String?> getPhone(String uid);
}
