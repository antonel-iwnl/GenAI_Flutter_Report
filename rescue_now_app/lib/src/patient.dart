import "package:flutter/foundation.dart";

/// A patient record containing personal and medical information.
@immutable
class Patient {
  /// Creates a [Patient] with the given personal and medical details.
  ///
  /// [age] must be between 0 and 150 (inclusive).
  const Patient({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.age,
    required this.bloodGroup,
    this.knownAllergies = const <String>[],
    this.conditions = const <String>[],
    this.medicalHistory = const <String>[],
  }) : assert(age >= 0 && age <= 150, "Age must be between 0 and 150");

  /// The unique identifier for this patient.
  final String id;

  /// The patient's first name.
  final String firstName;

  /// The patient's last name.
  final String lastName;

  /// The patient's age in years. Must be between 0 and 150.
  final int age;

  /// The patient's ABO/Rh blood group (e.g. A+, O-).
  final String bloodGroup;

  /// A list of substances or conditions the patient is allergic to.
  final List<String> knownAllergies;

  /// A list of active medical conditions the patient has been diagnosed with.
  final List<String> conditions;

  /// A chronological record of past medical events for this patient.
  final List<String> medicalHistory;

  /// Returns a copy of this [Patient] with the given fields replaced.
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

  /// Serialises this [Patient] to a JSON-compatible map.
  Map<String, dynamic> toJson() => <String, dynamic>{
        "id": id,
        "firstName": firstName,
        "lastName": lastName,
        "age": age,
        "bloodGroup": bloodGroup,
        "knownAllergies": List<String>.unmodifiable(knownAllergies),
        "conditions": List<String>.unmodifiable(conditions),
        "medicalHistory": List<String>.unmodifiable(medicalHistory),
      };

  /// Creates a [Patient] from a JSON-compatible map.
  ///
  /// Throws an [ArgumentError] if required fields are missing or malformed.
  factory Patient.fromJson(Map<String, dynamic> json) {
    var id = json["id"];
    var firstName = json["firstName"];
    var lastName = json["lastName"];
    var age = json["age"];
    var bloodGroup = json["bloodGroup"];

    if (id is! String || id.isEmpty) {
      throw ArgumentError("Patient: id must be a non-empty string.");
    }
    if (firstName is! String || firstName.isEmpty) {
      throw ArgumentError("Patient: firstName must be non-empty.");
    }
    if (lastName is! String || lastName.isEmpty) {
      throw ArgumentError("Patient: lastName must be non-empty.");
    }
    if (age is! int) {
      throw ArgumentError("Patient: age must be an integer.");
    }
    if (bloodGroup is! String || bloodGroup.isEmpty) {
      throw ArgumentError("Patient: bloodGroup must be non-empty.");
    }

    return Patient(
      id: id,
      firstName: firstName,
      lastName: lastName,
      age: age,
      bloodGroup: bloodGroup,
      knownAllergies: _parseStringList(json, "knownAllergies"),
      conditions: _parseStringList(json, "conditions"),
      medicalHistory: _parseStringList(json, "medicalHistory"),
    );
  }

  static List<String> _parseStringList(
    Map<String, dynamic> json,
    String key,
  ) {
    var value = json[key];
    if (value == null) {
      return const <String>[];
    }
    if (value is! List) {
      throw ArgumentError("Patient: $key must be a list.");
    }
    return List<String>.unmodifiable(
      value.whereType<String>(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is Patient &&
        other.id == id &&
        other.firstName == firstName &&
        other.lastName == lastName &&
        other.age == age &&
        other.bloodGroup == bloodGroup &&
        listEquals(other.knownAllergies, knownAllergies) &&
        listEquals(other.conditions, conditions) &&
        listEquals(other.medicalHistory, medicalHistory);
  }

  @override
  int get hashCode => Object.hash(
        id,
        firstName,
        lastName,
        age,
        bloodGroup,
        Object.hashAll(knownAllergies),
        Object.hashAll(conditions),
        Object.hashAll(medicalHistory),
      );

  @override
  String toString() => "Patient("
      "id: $id, "
      "firstName: $firstName, "
      "lastName: $lastName, "
      "age: $age, "
      "bloodGroup: $bloodGroup, "
      "knownAllergies: $knownAllergies, "
      "conditions: $conditions, "
      "medicalHistory: $medicalHistory"
      ")";
}
