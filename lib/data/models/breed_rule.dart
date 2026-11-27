import 'species.dart';

class RequiredTest {
  const RequiredTest({required this.testType, required this.validityMonths});

  final String testType;
  final int validityMonths;

  factory RequiredTest.fromMap(Map<String, dynamic> map) => RequiredTest(
        testType: map['testType'] as String,
        validityMonths: map['validityMonths'] as int,
      );

  Map<String, dynamic> toMap() => {
        'testType': testType,
        'validityMonths': validityMonths,
      };
}

/// `breedRules/{breedId}`
class BreedRule {
  const BreedRule({
    required this.id,
    required this.species,
    required this.breed,
    required this.requiredTests,
    required this.minAgeMonths,
    required this.maxAgeMonths,
  });

  /// Breed id, e.g. `sphynx`.
  final String id;
  final Species species;

  /// Display name, e.g. `Sfenks`.
  final String breed;
  final List<RequiredTest> requiredTests;
  final int minAgeMonths;
  final int maxAgeMonths;

  factory BreedRule.fromMap(String id, Map<String, dynamic> map) => BreedRule(
        id: id,
        species: Species.values.byName(map['species'] as String),
        breed: map['breed'] as String,
        requiredTests: [
          for (final t in map['requiredTests'] as List)
            RequiredTest.fromMap(Map<String, dynamic>.from(t as Map)),
        ],
        minAgeMonths: map['minAgeMonths'] as int,
        maxAgeMonths: map['maxAgeMonths'] as int,
      );

  Map<String, dynamic> toMap() => {
        'species': species.name,
        'breed': breed,
        'requiredTests': [for (final t in requiredTests) t.toMap()],
        'minAgeMonths': minAgeMonths,
        'maxAgeMonths': maxAgeMonths,
      };
}
