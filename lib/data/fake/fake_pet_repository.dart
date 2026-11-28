import '../models/pet.dart';
import '../repositories/pet_repository.dart';
import 'fake_store.dart';

class FakePetRepository implements PetRepository {
  FakePetRepository(this._s);

  final FakeStore _s;

  @override
  Stream<List<Pet>> watchPetsOfOwner(String ownerId) => _s.watch(
      () => [for (final p in _s.pets.values) if (p.ownerId == ownerId) p]);

  @override
  Future<Pet?> getPet(String petId) async => _s.pets[petId];

  @override
  Stream<List<Pet>> watchActivePetsOfBreed(String breed) => _s.watch(() => [
        for (final p in _s.pets.values)
          if (p.active && p.breed == breed) p,
      ]);

  @override
  Future<String> addPet(Pet pet) async {
    final id = _s.newId('pet');
    _s.pets[id] = Pet.fromMap(id, pet.toMap());
    _s.notify();
    return id;
  }

  @override
  Future<void> updatePet(Pet pet) async {
    _s.pets[pet.id] = pet;
    _s.notify();
  }

  @override
  Future<void> deactivatePet(String petId) async {
    final pet = _s.pets[petId];
    if (pet == null) return;
    _s.pets[petId] = pet.copyWith(active: false);
    _s.cancelPendingRequests((r) => r.fromPetId == petId || r.toPetId == petId);
    _s.notify();
  }
}
