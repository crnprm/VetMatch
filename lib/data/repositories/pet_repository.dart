import '../models/pet.dart';

abstract interface class PetRepository {
  /// Active and inactive pets of [ownerId].
  Stream<List<Pet>> watchPetsOfOwner(String ownerId);

  Future<Pet?> getPet(String petId);

  /// Active pets of a breed; candidate filtering happens on the phone.
  Stream<List<Pet>> watchActivePetsOfBreed(String breed);

  /// Returns the new pet id. [pet]'s id is ignored.
  Future<String> addPet(Pet pet);

  Future<void> updatePet(Pet pet);

  /// Sets `active: false` and cancels the pet's pending match requests in
  /// the same batch.
  Future<void> deactivatePet(String petId);
}
