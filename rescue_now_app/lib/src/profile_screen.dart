import 'package:flutter/material.dart';
import 'package:rescue_now_app/src/patient.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../theme/app_theme.dart';

// ---------------------------------------------------------------------------
// Constants
// ---------------------------------------------------------------------------

class _ProfileDimensions {
  static const double avatarWidth = 144.0;
  static const double avatarHeight = 159.58;
  static const double avatarBorderRadius = 45.0;
  static const double titleFontSize = 28.0;
  static const double nameFontSize = 24.0;
  static const double fieldFontSize = 24.0;
  static const double backIconSize = 32.0;
  static const double buttonBorderRadius = 24.0;
  static const double buttonFontSize = 18.0;
}

// ---------------------------------------------------------------------------
// Shared style helper
// ---------------------------------------------------------------------------

TextStyle _profileTextStyle({
  required Color color,
  double fontSize = _ProfileDimensions.fieldFontSize,
  FontWeight fontWeight = FontWeight.bold,
}) {
  return TextStyle(
    fontFamily: 'Source Sans Pro',
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color,
  );
}

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Patient patient;
  bool isEditing = false;
  bool isLoading = true;

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController bloodGroupController = TextEditingController();
  final TextEditingController allergiesController = TextEditingController();
  final TextEditingController conditionsController = TextEditingController();
  final TextEditingController medicalHistoryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPatientData();
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    ageController.dispose();
    bloodGroupController.dispose();
    allergiesController.dispose();
    conditionsController.dispose();
    medicalHistoryController.dispose();
    super.dispose();
  }

  Future<void> _loadPatientData() async {
    final prefs = await SharedPreferences.getInstance();
    final patientJson = prefs.getString('patientData');

    patient = patientJson != null
        ? Patient.fromJson(json.decode(patientJson))
        : Patient(
            id: '1',
            firstName: 'Antonel',
            lastName: 'Ionescu',
            age: 21,
            bloodGroup: 'A-',
            knownAllergies: ['Eggs', 'Cat hair'],
            conditions: ['Diabetes'],
            medicalHistory: ['Appendectomy'],
          );

    firstNameController.text = patient.firstName;
    lastNameController.text = patient.lastName;
    ageController.text = patient.age.toString();
    bloodGroupController.text = patient.bloodGroup;
    allergiesController.text = patient.knownAllergies.join(', ');
    conditionsController.text = patient.conditions.join(', ');
    medicalHistoryController.text = patient.medicalHistory.join(', ');

    setState(() => isLoading = false);
  }

  Future<void> _savePatientData() async {
    final prefs = await SharedPreferences.getInstance();

    patient
      ..firstName = firstNameController.text
      ..lastName = lastNameController.text
      ..age = int.tryParse(ageController.text) ?? patient.age
      ..bloodGroup = bloodGroupController.text
      ..knownAllergies =
          allergiesController.text.split(',').map((e) => e.trim()).toList()
      ..conditions =
          conditionsController.text.split(',').map((e) => e.trim()).toList()
      ..medicalHistory =
          medicalHistoryController.text.split(',').map((e) => e.trim()).toList();

    await prefs.setString('patientData', json.encode(patient.toJson()));
  }

  void _toggleEditMode() {
    setState(() {
      if (isEditing) _savePatientData();
      isEditing = !isEditing;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.colors.background,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.colors.background,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            _ProfileHeader(onBack: () => Navigator.pop(context)),
            const SizedBox(height: 40),
            const _ProfileAvatar(),
            const SizedBox(height: 20),
            _ProfileName(
              isEditing: isEditing,
              patient: patient,
              firstNameController: firstNameController,
              lastNameController: lastNameController,
            ),
            const SizedBox(height: 40),
            Expanded(
              child: _ProfileFieldList(
                isEditing: isEditing,
                ageController: ageController,
                bloodGroupController: bloodGroupController,
                allergiesController: allergiesController,
                conditionsController: conditionsController,
                medicalHistoryController: medicalHistoryController,
              ),
            ),
            _EditButton(isEditing: isEditing, onPressed: _toggleEditMode),
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
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Stack(
        children: [
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
            alignment: Alignment.center,
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
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar();

  @override
  Widget build(BuildContext context) {
    return Center(
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
  Widget build(BuildContext context) {
    final nameStyle = _profileTextStyle(
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
      children: [
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
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      children: [
        _ProfileField(
            label: 'Age', controller: ageController, isEditing: isEditing, isNumber: true),
        const SizedBox(height: 20),
        _ProfileField(
            label: 'Blood Type', controller: bloodGroupController, isEditing: isEditing),
        const SizedBox(height: 20),
        _ProfileField(
            label: 'Allergies', controller: allergiesController, isEditing: isEditing),
        const SizedBox(height: 20),
        _ProfileField(
            label: 'Conditions', controller: conditionsController, isEditing: isEditing),
        const SizedBox(height: 20),
        _ProfileField(
            label: 'Medical History',
            controller: medicalHistoryController,
            isEditing: isEditing),
      ],
    );
  }
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
  Widget build(BuildContext context) {
    final fieldStyle = _profileTextStyle(color: AppTheme.colors.menuButtons);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                  maxLines: null,
                  softWrap: true,
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
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.colors.menuButtons,
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(_ProfileDimensions.buttonBorderRadius),
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
}