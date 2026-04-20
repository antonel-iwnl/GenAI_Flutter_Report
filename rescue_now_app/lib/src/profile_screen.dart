import "dart:convert";

import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:rescue_now_app/src/patient.dart";
import "package:shared_preferences/shared_preferences.dart";

import "../theme/app_theme.dart";

/// Screen that displays and edits patient profile data.
class ProfileScreen extends StatefulWidget {
  /// Creates a [ProfileScreen].
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

/// State for [ProfileScreen].
class _ProfileScreenState extends State<ProfileScreen> {
  late Patient patient;

  bool isEditing = false;
  bool isLoading = true;

  final TextEditingController firstNameController =
      TextEditingController();
  final TextEditingController lastNameController =
      TextEditingController();
  final TextEditingController ageController =
      TextEditingController();
  final TextEditingController bloodGroupController =
      TextEditingController();
  final TextEditingController allergiesController =
      TextEditingController();
  final TextEditingController conditionsController =
      TextEditingController();
  final TextEditingController medicalHistoryController =
      TextEditingController();

  TextStyle get _textStyle => TextStyle(
        fontFamily: "Source Sans Pro",
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

  /// Loads patient data from local storage.
  Future<void> _loadPatientData() async {
    var prefs = await SharedPreferences.getInstance();
    var patientJson = prefs.getString("patientData");

    if (patientJson != null) {
      patient = Patient.fromJson(json.decode(patientJson));
    } else {
      patient = const Patient(
        id: "1",
        firstName: "Antonel",
        lastName: "Ionescu",
        age: 21,
        bloodGroup: "A-",
        knownAllergies: <String>["Eggs", "Cat hair"],
        conditions: <String>["Diabetes"],
        medicalHistory: <String>["Appendectomy"],
      );
    }

    firstNameController.text = patient.firstName;
    lastNameController.text = patient.lastName;
    ageController.text = patient.age.toString();
    bloodGroupController.text = patient.bloodGroup;
    allergiesController.text = patient.knownAllergies.join(", ");
    conditionsController.text = patient.conditions.join(", ");
    medicalHistoryController.text =
        patient.medicalHistory.join(", ");

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });
  }

  /// Saves patient data to local storage.
  Future<void> _savePatientData() async {
    var prefs = await SharedPreferences.getInstance();

    patient = patient.copyWith(
      firstName: firstNameController.text,
      lastName: lastNameController.text,
      age: int.tryParse(ageController.text) ?? patient.age,
      bloodGroup: bloodGroupController.text,
      knownAllergies: _splitList(allergiesController.text),
      conditions: _splitList(conditionsController.text),
      medicalHistory:
          _splitList(medicalHistoryController.text),
    );

    await prefs.setString(
      "patientData",
      json.encode(patient.toJson()),
    );
  }

  /// Splits comma-separated input into a cleaned list.
  List<String> _splitList(String input) =>
      input.trim().isEmpty
          ? <String>[]
          : input.split(",").map((e) => e.trim()).toList();

  /// Toggles edit mode and saves when exiting edit mode.
  void toggleEditMode() {
    setState(() {
      isEditing = !isEditing;
    });

    if (!isEditing) {
      _savePatientData();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.colors.background,
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.colors.background,
      body: SafeArea(
        child: Column(
          children: <Widget>[
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 32),
                children: <Widget>[
                  _buildEditableField(
                    "Age",
                    ageController,
                    isNumber: true,
                  ),
                  const SizedBox(height: 20),
                  _buildEditableField(
                    "Blood Type",
                    bloodGroupController,
                  ),
                  const SizedBox(height: 20),
                  _buildEditableField(
                    "Allergies",
                    allergiesController,
                  ),
                  const SizedBox(height: 20),
                  _buildEditableField(
                    "Conditions",
                    conditionsController,
                  ),
                  const SizedBox(height: 20),
                  _buildEditableField(
                    "Medical History",
                    medicalHistoryController,
                  ),
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

  /// Builds an editable or read-only field.
  Widget _buildEditableField(
    String label,
    TextEditingController controller, {
    bool isNumber = false,
  }) =>
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Text("$label: ", style: _textStyle),
          ),
          Expanded(
            flex: 3,
            child: isEditing
                ? TextField(
                    controller: controller,
                    keyboardType: isNumber
                        ? TextInputType.number
                        : TextInputType.text,
                    style: _textStyle,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 10,
                      ),
                    ),
                  )
                : Text(
                    controller.text,
                    style: _textStyle,
                    maxLines: null,
                  ),
          ),
        ],
      );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(FlagProperty("isEditing", value: isEditing))
      ..add(FlagProperty("isLoading", value: isLoading));
  }
}

/// Header with back button.
class _Header extends StatelessWidget {
  /// Callback when back button is pressed.
  final VoidCallback onBack;

  /// Creates a [_Header].
  const _Header({required this.onBack});

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
                iconSize: 32,
                onPressed: onBack,
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Text(
                "Profile",
                style: TextStyle(
                  fontFamily: "Source Sans Pro",
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.colors.menuButtons,
                ),
              ),
            ),
          ],
        ),
      );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      ObjectFlagProperty<VoidCallback>.has("onBack", onBack),
    );
  }
}

/// Profile image widget.
class _ProfileImage extends StatelessWidget {
  /// Creates a [_ProfileImage].
  const _ProfileImage();

  @override
  Widget build(BuildContext context) => Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(45),
          child: SizedBox(
            width: 144,
            height: 159.58,
            child: Image.asset(
              "assets/profile_pic.jpg",
              fit: BoxFit.cover,
            ),
          ),
        ),
      );
}

/// Displays and edits the patient's name.
class _NameSection extends StatelessWidget {
  /// Whether editing mode is active.
  final bool isEditing;

  /// First name controller.
  final TextEditingController firstNameController;

  /// Last name controller.
  final TextEditingController lastNameController;

  /// Patient model.
  final Patient patient;

  /// Text style used.
  final TextStyle textStyle;

  /// Creates a [_NameSection].
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
        children: <Widget>[
          Flexible(
            child: TextField(
              controller: firstNameController,
              textAlign: TextAlign.center,
              style: textStyle,
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                hintText: "First Name",
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
                hintText: "Last Name",
              ),
            ),
          ),
        ],
      );
    }

    return Text(
      "${patient.firstName} ${patient.lastName}",
      style: textStyle,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(FlagProperty("isEditing", value: isEditing))
      ..add(StringProperty("firstName", patient.firstName))
      ..add(StringProperty("lastName", patient.lastName));
  }
}

/// Edit/save button.
class _EditButton extends StatelessWidget {
  /// Whether editing mode is active.
  final bool isEditing;

  /// Button callback.
  final VoidCallback onPressed;

  /// Creates an [_EditButton].
  const _EditButton({
    required this.isEditing,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) => Center(
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.colors.menuButtons,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            padding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 30,
            ),
          ),
          child: Text(
            isEditing ? "Save Changes" : "Edit",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(FlagProperty("isEditing", value: isEditing));
  }
}