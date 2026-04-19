import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rescue_now_app/src/patient.dart';
import 'package:rescue_now_app/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ---------------------------------------------------------------------------
// Constants
// ---------------------------------------------------------------------------

class _ProfileDimensions {
  static const double avatarWidth = 144;
  static const double avatarHeight = 159.58;
  static const double avatarBorderRadius = 45;
  static const double titleFontSize = 28;
  static const double nameFontSize = 24;
  static const double fieldFontSize = 24;
  static const double backIconSize = 32;
  static const double buttonBorderRadius = 24;
  static const double buttonFontSize = 18;
}

// ---------------------------------------------------------------------------
// Shared style helper
// ---------------------------------------------------------------------------

TextStyle _profileTextStyle({
  required Color color,
  double fontSize = _ProfileDimensions.fieldFontSize,
  FontWeight fontWeight = FontWeight.bold,
}) =>
    TextStyle(
      fontFamily: 'Source Sans Pro',
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

/// A screen that displays and allows editing of the current patient's profile.
class ProfileScreen extends StatefulWidget {
  /// Creates a [ProfileScreen].
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Patient _patient;
  bool _isEditing = false;
  bool _isLoading = true;

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _bloodGroupController = TextEditingController();
  final TextEditingController _allergiesController = TextEditingController();
  final TextEditingController _conditionsController = TextEditingController();
  final TextEditingController _medicalHistoryController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    unawaited(_loadPatientData());
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _ageController.dispose();
    _bloodGroupController.dispose();
    _allergiesController.dispose();
    _conditionsController.dispose();
    _medicalHistoryController.dispose();
    super.dispose();
  }

  Future<void> _loadPatientData() async {
    var prefs = await SharedPreferences.getInstance();
    var patientJson = prefs.getString('patientData');

    _patient = patientJson != null
        ? Patient.fromJson(json.decode(patientJson) as Map<String, dynamic>)
        : const Patient(
            id: '1',
            firstName: 'Antonel',
            lastName: 'Ionescu',
            age: 21,
            bloodGroup: 'A-',
            knownAllergies: <String>['Eggs', 'Cat hair'],
            conditions: <String>['Diabetes'],
            medicalHistory: <String>['Appendectomy'],
          );

    _firstNameController.text = _patient.firstName;
    _lastNameController.text = _patient.lastName;
    _ageController.text = _patient.age.toString();
    _bloodGroupController.text = _patient.bloodGroup;
    _allergiesController.text = _patient.knownAllergies.join(', ');
    _conditionsController.text = _patient.conditions.join(', ');
    _medicalHistoryController.text = _patient.medicalHistory.join(', ');

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _savePatientData() async {
    _patient = _patient.copyWith(
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      age: int.tryParse(_ageController.text) ?? _patient.age,
      bloodGroup: _bloodGroupController.text,
      knownAllergies: _allergiesController.text
          .split(',')
          .map((e) => e.trim())
          .toList(),
      conditions: _conditionsController.text
          .split(',')
          .map((e) => e.trim())
          .toList(),
      medicalHistory: _medicalHistoryController.text
          .split(',')
          .map((e) => e.trim())
          .toList(),
    );

    var prefs = await SharedPreferences.getInstance();
    await prefs.setString('patientData', json.encode(_patient.toJson()));
  }

  Future<void> _toggleEditMode() async {
    if (_isEditing) {
      await _savePatientData();
    }
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.colors.background,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.colors.background,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            const SizedBox(height: 16),
            _ProfileHeader(onBack: () => Navigator.pop(context)),
            const SizedBox(height: 40),
            const _ProfileAvatar(),
            const SizedBox(height: 20),
            _ProfileName(
              isEditing: _isEditing,
              patient: _patient,
              firstNameController: _firstNameController,
              lastNameController: _lastNameController,
            ),
            const SizedBox(height: 40),
            Expanded(
              child: _ProfileFieldList(
                isEditing: _isEditing,
                ageController: _ageController,
                bloodGroupController: _bloodGroupController,
                allergiesController: _allergiesController,
                conditionsController: _conditionsController,
                medicalHistoryController: _medicalHistoryController,
              ),
            ),
            _EditButton(isEditing: _isEditing, onPressed: _toggleEditMode),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sub-widgets
// ---------------------------------------------------------------------------

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(ObjectFlagProperty<VoidCallback>.has('onBack', onBack));
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Stack(
          children: <Widget>[
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back),
                color: AppTheme.colors.menuButtons,
                iconSize: _ProfileDimensions.backIconSize,
                onPressed: onBack,
              ),
            ),
            Align(
              child: Text(
                'Profile',
                style: _profileTextStyle(
                  color: AppTheme.colors.menuButtons,
                  fontSize: _ProfileDimensions.titleFontSize,
                ),
              ),
            ),
          ],
        ),
      );
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar();

  @override
  Widget build(BuildContext context) => Center(
        child: ClipRRect(
          borderRadius:
              BorderRadius.circular(_ProfileDimensions.avatarBorderRadius),
          child: Container(
            width: _ProfileDimensions.avatarWidth,
            height: _ProfileDimensions.avatarHeight,
            color: Colors.black,
            child: Image.asset(
              'assets/profile_pic.jpg',
              fit: BoxFit.cover,
            ),
          ),
        ),
      );
}

class _ProfileName extends StatelessWidget {
  const _ProfileName({
    required this.isEditing,
    required this.patient,
    required this.firstNameController,
    required this.lastNameController,
  });

  final bool isEditing;
  final Patient patient;
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<bool>('isEditing', isEditing))
      ..add(DiagnosticsProperty<Patient>('patient', patient))
      ..add(DiagnosticsProperty<TextEditingController>(
        'firstNameController',
        firstNameController,
      ))
      ..add(DiagnosticsProperty<TextEditingController>(
        'lastNameController',
        lastNameController,
      ));
  }

  @override
  Widget build(BuildContext context) {
    var nameStyle = _profileTextStyle(
      color: AppTheme.colors.menuButtons,
      fontSize: _ProfileDimensions.nameFontSize,
    );

    if (!isEditing) {
      return Center(
        child: Text(
          '${patient.firstName} ${patient.lastName}',
          style: nameStyle,
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Flexible(
          child: TextField(
            controller: firstNameController,
            textAlign: TextAlign.center,
            style: nameStyle,
            decoration: const InputDecoration(
              border: UnderlineInputBorder(),
              hintText: 'First Name',
            ),
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: TextField(
            controller: lastNameController,
            textAlign: TextAlign.center,
            style: nameStyle,
            decoration: const InputDecoration(
              border: UnderlineInputBorder(),
              hintText: 'Last Name',
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileFieldList extends StatelessWidget {
  const _ProfileFieldList({
    required this.isEditing,
    required this.ageController,
    required this.bloodGroupController,
    required this.allergiesController,
    required this.conditionsController,
    required this.medicalHistoryController,
  });

  final bool isEditing;
  final TextEditingController ageController;
  final TextEditingController bloodGroupController;
  final TextEditingController allergiesController;
  final TextEditingController conditionsController;
  final TextEditingController medicalHistoryController;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<bool>('isEditing', isEditing))
      ..add(DiagnosticsProperty<TextEditingController>(
        'ageController',
        ageController,
      ))
      ..add(DiagnosticsProperty<TextEditingController>(
        'bloodGroupController',
        bloodGroupController,
      ))
      ..add(DiagnosticsProperty<TextEditingController>(
        'allergiesController',
        allergiesController,
      ))
      ..add(DiagnosticsProperty<TextEditingController>(
        'conditionsController',
        conditionsController,
      ))
      ..add(DiagnosticsProperty<TextEditingController>(
        'medicalHistoryController',
        medicalHistoryController,
      ));
  }

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        children: <Widget>[
          _ProfileField(
            label: 'Age',
            controller: ageController,
            isEditing: isEditing,
            isNumber: true,
          ),
          const SizedBox(height: 20),
          _ProfileField(
            label: 'Blood Type',
            controller: bloodGroupController,
            isEditing: isEditing,
          ),
          const SizedBox(height: 20),
          _ProfileField(
            label: 'Allergies',
            controller: allergiesController,
            isEditing: isEditing,
          ),
          const SizedBox(height: 20),
          _ProfileField(
            label: 'Conditions',
            controller: conditionsController,
            isEditing: isEditing,
          ),
          const SizedBox(height: 20),
          _ProfileField(
            label: 'Medical History',
            controller: medicalHistoryController,
            isEditing: isEditing,
          ),
        ],
      );
}

class _ProfileField extends StatelessWidget {
  const _ProfileField({
    required this.label,
    required this.controller,
    required this.isEditing,
    this.isNumber = false,
  });

  final String label;
  final TextEditingController controller;
  final bool isEditing;
  final bool isNumber;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('label', label))
      ..add(DiagnosticsProperty<TextEditingController>(
        'controller',
        controller,
      ))
      ..add(DiagnosticsProperty<bool>('isEditing', isEditing))
      ..add(DiagnosticsProperty<bool>('isNumber', isNumber));
  }

  @override
  Widget build(BuildContext context) {
    var fieldStyle = _profileTextStyle(color: AppTheme.colors.menuButtons);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          flex: 2,
          child: Text('$label: ', style: fieldStyle),
        ),
        Expanded(
          flex: 3,
          child: isEditing
              ? TextField(
                  controller: controller,
                  keyboardType:
                      isNumber ? TextInputType.number : TextInputType.text,
                  style: fieldStyle,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                  ),
                )
              : Text(
                  controller.text,
                  style: fieldStyle,
                ),
        ),
      ],
    );
  }
}

class _EditButton extends StatelessWidget {
  const _EditButton({required this.isEditing, required this.onPressed});

  final bool isEditing;
  final VoidCallback onPressed;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<bool>('isEditing', isEditing))
      ..add(ObjectFlagProperty<VoidCallback>.has('onPressed', onPressed));
  }

  @override
  Widget build(BuildContext context) => Center(
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.colors.menuButtons,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                _ProfileDimensions.buttonBorderRadius,
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 30),
          ),
          child: Text(
            isEditing ? 'Save Changes' : 'Edit',
            style: const TextStyle(
              fontSize: _ProfileDimensions.buttonFontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      );
}
