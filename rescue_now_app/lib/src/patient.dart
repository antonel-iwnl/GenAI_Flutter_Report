/// Represents a patient in the system.
class Patient {
  /// Unique identifier of the patient.
  final String id;

  /// Patient's first name.
  final String firstName;

  /// Patient's last name.
  final String lastName;

  /// Patient's age.
  final int age;

  /// Patient's blood group.
  final String bloodGroup;

  /// Known allergies of the patient.
  final List<String> knownAllergies;

  /// Known medical conditions of the patient.
  final List<String> conditions;

  /// Patient's medical history records.
  final List<String> medicalHistory;

  /// Creates a new [Patient] instance.
  const Patient({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.age,
    required this.bloodGroup,
    this.knownAllergies = const <String>[],
    this.conditions = const <String>[],
    this.medicalHistory = const <String>[],
  });

  /// Creates a copy of this patient with optional updated fields.
  Patient copyWith({
    String? id,
    String? firstName,
    String? lastName,
    int? age,
    String? bloodGroup,
    List<String>? knownAllergies,
    List<String>? conditions,
    List<String>? medicalHistory,
  }) =>
      Patient(
        id: id ?? this.id,
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        age: age ?? this.age,
        bloodGroup: bloodGroup ?? this.bloodGroup,
        knownAllergies: knownAllergies ?? this.knownAllergies,
        conditions: conditions ?? this.conditions,
        medicalHistory: medicalHistory ?? this.medicalHistory,
      );

  /// Converts this patient into a JSON map.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'firstName': firstName,
        'lastName': lastName,
        'age': age,
        'bloodGroup': bloodGroup,
        'knownAllergies': knownAllergies,
        'conditions': conditions,
        'medicalHistory': medicalHistory,
      };

  /// Creates a [Patient] from a JSON map.
  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      age: json['age'] as int,
      bloodGroup: json['bloodGroup'] as String,
      knownAllergies: _parseStringList(json['knownAllergies']),
      conditions: _parseStringList(json['conditions']),
      medicalHistory: _parseStringList(json['medicalHistory']),
    );
  }

  /// Safely parses a dynamic value into a list of strings.
  static List<String> _parseStringList(dynamic value) {
    if (value is List) {
      return value.map((dynamic e) => e.toString()).toList();
    }
    return const <String>[];
  }

  @override
  String toString() =>
      'Patient(id: $id, name: $firstName $lastName, age: $age)';
}