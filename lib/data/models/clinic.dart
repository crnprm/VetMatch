import 'package:latlong2/latlong.dart';

import 'species.dart';

/// `clinics/{clinicId}`
class Clinic {
  const Clinic({
    required this.id,
    required this.name,
    required this.location,
    required this.species,
    required this.capabilities,
  });

  final String id;
  final String name;
  final LatLng location;
  final List<Species> species;

  /// Capability keys such as `echocardiography`; labels live in the UI.
  final List<String> capabilities;

  factory Clinic.fromMap(String id, Map<String, dynamic> map) => Clinic(
        id: id,
        name: map['name'] as String,
        location: map['location'] as LatLng,
        species: [
          for (final s in map['species'] as List) Species.values.byName(s as String),
        ],
        capabilities: List<String>.from(map['capabilities'] as List),
      );

  Map<String, dynamic> toMap() => {
        'name': name,
        'location': location,
        'species': [for (final s in species) s.name],
        'capabilities': capabilities,
      };
}
