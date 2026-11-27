import '../models/clinic.dart';
import '../repositories/clinic_repository.dart';
import 'fake_store.dart';

class FakeClinicRepository implements ClinicRepository {
  FakeClinicRepository(this._s);

  final FakeStore _s;

  @override
  Stream<List<Clinic>> watchClinics() => _s.watch(() => _s.clinics.values.toList());

  @override
  Future<Clinic?> getClinic(String clinicId) async => _s.clinics[clinicId];
}
