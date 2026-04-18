import 'package:flutter/material.dart';
import 'package:rescue_now_app/src/patient.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Patient patient;
  bool isEditing = false;
  bool isLoading = true;

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final ageController = TextEditingController();
  final bloodGroupController = TextEditingController();
  final allergiesController = TextEditingController();
  final conditionsController = TextEditingController();
  final medicalHistoryController = TextEditingController();

  TextStyle get _textStyle => TextStyle(
        fontFamily: 'Source Sans Pro',
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppTheme.colors.menuButtons,
      );

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

    if (patientJson != null) {
      patient = Patient.fromJson(json.decode(patientJson));
    } else {
      patient = Patient(
        id: '1',
        firstName: 'Antonel',
        lastName: 'Ionescu',
        age: 21,
        bloodGroup: 'A-',
        knownAllergies: ['Eggs', 'Cat hair'],
        conditions: ['Diabetes'],
        medicalHistory: ['Appendectomy'],
      );
    }

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

  void toggleEditMode() {
    setState(() {
      isEditing = !isEditing;
      if (!isEditing) _savePatientData();
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
            _Header(onBack: () => Navigator.pop(context)),
            const SizedBox(height: 40),
            const _ProfileImage(),
            const SizedBox(height: 20),
            _NameSection(
              isEditing: isEditing,
              firstNameController: firstNameController,
              lastNameController: lastNameController,
              patient: patient,
              textStyle: _textStyle,
            ),
            const SizedBox(height: 40),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                children: [
                  _buildEditableField('Age', ageController, isNumber: true),
                  const SizedBox(height: 20),
                  _buildEditableField('Blood Type', bloodGroupController),
                  const SizedBox(height: 20),
                  _buildEditableField('Allergies', allergiesController),
                  const SizedBox(height: 20),
                  _buildEditableField('Conditions', conditionsController),
                  const SizedBox(height: 20),
                  _buildEditableField('Medical History', medicalHistoryController),
                ],
              ),
            ),
            _EditButton(
              isEditing: isEditing,
              onPressed: toggleEditMode,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableField(String label, TextEditingController controller,
      {bool isNumber = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text("$label: ", style: _textStyle),
        ),
        Expanded(
          flex: 3,
          child: isEditing
              ? TextField(
                  controller: controller,
                  keyboardType:
                      isNumber ? TextInputType.number : TextInputType.text,
                  style: _textStyle,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                  ),
                )
              : Text(
                  controller.text,
                  style: _textStyle,
                  maxLines: null,
                  softWrap: true,
                ),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  final VoidCallback onBack;

  const _Header({required this.onBack});

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
              iconSize: 32,
              onPressed: onBack,
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Text(
              'Profile',
              style: TextStyle(
                fontFamily: 'Source Sans Pro',
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppTheme.colors.menuButtons,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileImage extends StatelessWidget {
  const _ProfileImage();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(45),
        child: Container(
          width: 144,
          height: 159.58,
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

class _NameSection extends StatelessWidget {
  final bool isEditing;
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final Patient patient;
  final TextStyle textStyle;

  const _NameSection({
    required this.isEditing,
    required this.firstNameController,
    required this.lastNameController,
    required this.patient,
    required this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    if (isEditing) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: TextField(
              controller: firstNameController,
              textAlign: TextAlign.center,
              style: textStyle,
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
              style: textStyle,
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                hintText: 'Last Name',
              ),
            ),
          ),
        ],
      );
    }

    return Text(
      '${patient.firstName} ${patient.lastName}',
      style: textStyle,
    );
  }
}

class _EditButton extends StatelessWidget {
  final bool isEditing;
  final VoidCallback onPressed;

  const _EditButton({
    required this.isEditing,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.colors.menuButtons,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          padding:
              const EdgeInsets.symmetric(vertical: 12, horizontal: 30),
        ),
        child: Text(
          isEditing ? 'Save Changes' : 'Edit',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}