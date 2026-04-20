// main.dart

import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'src/crash_detection.dart';
import 'src/firebase_options.dart';
import 'src/location_management.dart';
import 'src/profile_screen.dart';
import 'theme/app_theme.dart';

/// Entry point of the application.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

/// Root widget of the application.
class MyApp extends StatelessWidget {
  /// Creates a [MyApp] instance.
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Emergency SOS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.brown,
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Home Page'),
    );
  }
}

/// Home page of the application.
class MyHomePage extends StatefulWidget {
  /// Title displayed in the app.
  final String title;

  /// Creates a [MyHomePage] instance.
  const MyHomePage({super.key, required this.title});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

/// State for [MyHomePage].
class _MyHomePageState extends State<MyHomePage> {
  double _buttonSize = 145;
  Timer? _timer;
  bool _isHolding = false;

  final EmergencyService _service = EmergencyService();

  /// Handles long press start on SOS button.
  void _onLongPressStart() {
    setState(() {
      _isHolding = true;
      _buttonSize = 160;
    });

    _timer = Timer(const Duration(seconds: 1), () {
      if (_isHolding) {
        _service.sendSOS();
        _showEmergencyDialog();
      }
    });
  }

  /// Handles long press end on SOS button.
  void _onLongPressEnd() {
    setState(() {
      _isHolding = false;
      _buttonSize = 145;
    });
    _timer?.cancel();
  }

  /// Displays emergency confirmation dialog.
  void _showEmergencyDialog() {
    showDialog<void>(
      context: context,
      builder: (_) => const AlertDialog(
        title: Text('Emergency'),
        content: Text('Calling Emergency Something...'),
      ),
    );
  }

  /// Opens bottom sheet with emergency options.
  void _openBottomSheet() {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(50)),
      ),
      builder: (_) => EmergencyBottomSheet(service: _service),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.colors.background,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const <Widget>[
            TopMenuBar(),
            // SOSButton is not const due to dynamic size
            _SOSButtonWrapper(),
            // HelpButton needs callback → not const
          ],
        ),
      ),
      bottomNavigationBar: HelpButtonWrapper(onPressed: _openBottomSheet),
    );
  }
}

/// Wrapper to keep build method const-friendly.
class _SOSButtonWrapper extends StatefulWidget {
  const _SOSButtonWrapper();

  @override
  State<_SOSButtonWrapper> createState() => _SOSButtonWrapperState();
}

class _SOSButtonWrapperState extends State<_SOSButtonWrapper> {
  double _buttonSize = 145;
  Timer? _timer;
  bool _isHolding = false;

  final EmergencyService _service = EmergencyService();

  void _onLongPressStart() {
    setState(() {
      _isHolding = true;
      _buttonSize = 160;
    });

    _timer = Timer(const Duration(seconds: 1), () {
      if (_isHolding) {
        _service.sendSOS();
      }
    });
  }

  void _onLongPressEnd() {
    setState(() {
      _isHolding = false;
      _buttonSize = 145;
    });
    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return SOSButton(
      size: _buttonSize,
      onStart: _onLongPressStart,
      onEnd: _onLongPressEnd,
    );
  }
}

/// Top menu bar widget.
class TopMenuBar extends StatelessWidget {
  /// Creates a [TopMenuBar].
  const TopMenuBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        children: <Widget>[
          const SizedBox(width: 16),
          MenuIconButton(
            asset: 'assets/emergency-contacts.svg',
            label: 'Contacts',
            onTap: () {},
          ),
          const SizedBox(width: 24),
          MenuIconButton(
            asset: 'assets/crash.svg',
            label: 'Crash test',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute<CrashDetectionScreen>(
                  builder: (_) => CrashDetectionScreen(),
                ),
              );
            },
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: MenuIconButton(
              asset: 'assets/profile.svg',
              label: 'Profile',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute<ProfileScreen>(
                    builder: (_) => const ProfileScreen(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Icon button used in the top menu.
class MenuIconButton extends StatelessWidget {
  /// Asset path for icon.
  final String asset;

  /// Label displayed below icon.
  final String label;

  /// Tap callback.
  final VoidCallback onTap;

  /// Creates a [MenuIconButton].
  const MenuIconButton({
    super.key,
    required this.asset,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: <Widget>[
          SvgPicture.asset(asset, height: 40, width: 40),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: AppTheme.colors.menuButtons,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// SOS button widget.
class SOSButton extends StatelessWidget {
  /// Size of the button.
  final double size;

  /// Callback when long press starts.
  final VoidCallback onStart;

  /// Callback when long press ends.
  final VoidCallback onEnd;

  /// Creates a [SOSButton].
  const SOSButton({
    super.key,
    required this.size,
    required this.onStart,
    required this.onEnd,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (_) => onStart(),
      onLongPressEnd: (_) => onEnd(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: size,
        width: size,
        decoration: BoxDecoration(
          color: AppTheme.colors.primary,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: SvgPicture.asset('assets/sos_button.svg'),
        ),
      ),
    );
  }
}

/// Help button widget.
class HelpButtonWrapper extends StatelessWidget {
  /// Callback for button press.
  final VoidCallback onPressed;

  /// Creates a [HelpButtonWrapper].
  const HelpButtonWrapper({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.colors.menuButtons,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        ),
        child: Text(
          'Help options',
          style: TextStyle(
            color: AppTheme.colors.text,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

/// Bottom sheet with emergency actions.
class EmergencyBottomSheet extends StatelessWidget {
  /// Emergency service instance.
  final EmergencyService service;

  /// Creates an [EmergencyBottomSheet].
  const EmergencyBottomSheet({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.colors.menuButtons,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(50)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const SizedBox(height: 20),
          _buildAction(context, 'Send Emergency Text', () {
            service.sendSOS();
            service.sendText();
            Navigator.pop(context);
          }),
          _buildAction(context, 'Voice Emergency Call', () {
            service.sendSOS();
            service.voiceCall();
            Navigator.pop(context);
          }),
          _buildAction(context, 'Video Emergency Call', () {
            service.sendSOS();
            service.videoCall();
            Navigator.pop(context);
          }),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  /// Builds an action button.
  Widget _buildAction(
    BuildContext context,
    String label,
    VoidCallback onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ElevatedButton(
        onPressed: onTap,
        child: Text(label),
      ),
    );
  }
}

/// Service responsible for emergency actions.
class EmergencyService {
  /// Sends SOS signal.
  void sendSOS() {
    getAndSendLocation();
  }

  /// Sends emergency text.
  void sendText() {}

  /// Initiates voice call.
  void voiceCall() {}

  /// Initiates video call.
  void videoCall() {}
}
