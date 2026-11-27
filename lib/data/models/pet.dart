import 'species.dart';

enum Sex { male, female }

/// `pets/{petId}`. Never deleted; `active: false` removes the listing.
class Pet {
  const Pet({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.species,
    required this.breed,
    required this.sex,
    required this.birthDate,
    required this.neutered,
    required this.chipNo,
    required this.active,
  });

  final String id;
  final String ownerId;
  final String name;
  final Species species;

  /// Breed id, matching a `breedRules` document id (e.g. `sphynx`).
  final String breed;
  final Sex sex;
  final DateTime birthDate;
  final bool neutered;

  /// 15-digit microchip number.
  final String chipNo;
  final bool active;

  factory Pet.fromMap(String id, Map<String, dynamic> map) => Pet(
        id: id,
        ownerId: map['ownerId'] as String,
        name: map['name'] as String,
        species: Species.values.byName(map['species'] as String),
        breed: map['breed'] as String,
        sex: Sex.values.byName(map['sex'] as String),
        birthDate: map['birthDate'] as DateTime,
        neutered: map['neutered'] as bool,
        chipNo: map['chipNo'] as String,
        active: map['active'] as bool,
      );

  Map<String, dynamic> toMap() => {
        'ownerId': ownerId,
        'name': name,
        'species': species.name,
        'breed': breed,
        'sex': sex.name,
        'birthDate': birthDate,
        'neutered': neutered,
        'chipNo': chipNo,
        'active': active,
      };

  Pet copyWith({
    String? ownerId,
    String? name,
    Sex? sex,
    DateTime? birthDate,
    bool? neutered,
    String? chipNo,
    bool? active,
  }) =>
      Pet(
        id: id,
        ownerId: ownerId ?? this.ownerId,
        name: name ?? this.name,
        species: species,
        breed: breed,
        sex: sex ?? this.sex,
        birthDate: birthDate ?? this.birthDate,
        neutered: neutered ?? this.neutered,
        chipNo: chipNo ?? this.chipNo,
        active: active ?? this.active,
      );
}
