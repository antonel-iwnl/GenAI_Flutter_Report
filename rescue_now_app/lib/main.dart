// main.dart (refactored)

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:async';

import 'src/firebase_options.dart';
import 'src/profile_screen.dart';
import 'src/crash_detection.dart';
import 'theme/app_theme.dart';
import 'src/location_management.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
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

// ======================= HOME PAGE =======================

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
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
        _showEmergencyDialog();
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

  void _showEmergencyDialog() {
    showDialog(
      context: context,
      builder: (_) => const AlertDialog(
        title: Text("Emergency"),
        content: Text("Calling Emergency Something..."),
      ),
    );
  }

  void _openBottomSheet() {
    showModalBottomSheet(
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
          children: [
            TopMenuBar(),
            SOSButton(
              size: _buttonSize,
              onStart: _onLongPressStart,
              onEnd: _onLongPressEnd,
            ),
            HelpButton(onPressed: _openBottomSheet),
          ],
        ),
      ),
    );
  }
}

// ======================= COMPONENTS =======================

class TopMenuBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        children: [
          const SizedBox(width: 16),

          MenuIconButton(
            asset: 'assets/emergency-contacts.svg',
            label: 'Contacts',
            onTap: () => print('Contacts tapped'),
          ),

          const SizedBox(width: 24),

          MenuIconButton(
            asset: 'assets/crash.svg',
            label: 'Crash test',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
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
                  MaterialPageRoute(
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

class MenuIconButton extends StatelessWidget {
  final String asset;
  final String label;
  final VoidCallback onTap;

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
        children: [
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

class SOSButton extends StatelessWidget {
  final double size;
  final VoidCallback onStart;
  final VoidCallback onEnd;

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
          boxShadow: const [
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

class HelpButton extends StatelessWidget {
  final VoidCallback onPressed;

  const HelpButton({super.key, required this.onPressed});

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

// ======================= BOTTOM SHEET =======================

class EmergencyBottomSheet extends StatelessWidget {
  final EmergencyService service;

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
        children: [
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

  Widget _buildAction(BuildContext context, String label, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ElevatedButton(
        onPressed: onTap,
        child: Text(label),
      ),
    );
  }
}

// ======================= SERVICE =======================

class EmergencyService {
  void sendSOS() {
    getAndSendLocation();
  }

  void sendText() {
    print("Send emergency text...");
  }

  void voiceCall() {
    print("Voice call...");
  }

  void videoCall() {
    print("Video call...");
  }
}