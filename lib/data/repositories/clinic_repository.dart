import '../models/clinic.dart';

abstract interface class ClinicRepository {
  /// All clinics; filtering and distance are done on the phone.
  Stream<List<Clinic>> watchClinics();

  Future<Clinic?> getClinic(String clinicId);
}
