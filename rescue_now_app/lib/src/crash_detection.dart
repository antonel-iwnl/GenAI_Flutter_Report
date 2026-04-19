// ignore_for_file: avoid_print
// The print statements in this file are intentional debug/diagnostic output
// for crash detection events during development and testing.

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:rescue_now_app/theme/app_theme.dart';
import 'package:sensors_plus/sensors_plus.dart';

/// A screen that monitors accelerometer data to detect potential crashes
/// and initiates an emergency response when a crash is detected.
class CrashDetectionScreen extends StatefulWidget {
  /// Creates a [CrashDetectionScreen].
  const CrashDetectionScreen({super.key});

  @override
  State<CrashDetectionScreen> createState() => _CrashDetectionScreenState();
}

class _CrashDetectionScreenState extends State<CrashDetectionScreen> {
  static const double _crashThreshold = 45;
  static const double _gravitationalConstant = 9.8;

  double _accelerationMagnitude = 0;
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  bool _crashDetected = false;
  Timer? _confirmationTimer;

  @override
  void initState() {
    super.initState();
    _startAccelerometerListener();
  }

  @override
  void dispose() {
    unawaited(_accelerometerSubscription?.cancel());
    _confirmationTimer?.cancel();
    super.dispose();
  }

  double _calculateMagnitude(AccelerometerEvent event) =>
      sqrt(event.x * event.x + event.y * event.y + event.z * event.z);

  void _startAccelerometerListener() {
    _accelerometerSubscription =
        accelerometerEventStream().listen((event) {
      var accelerationMagnitude = _calculateMagnitude(event);
      var adjustedMagnitude =
          (accelerationMagnitude - _gravitationalConstant).abs();

      if (mounted) {
        setState(() {
          _accelerationMagnitude = adjustedMagnitude;
        });
      }

      if (adjustedMagnitude > _crashThreshold && !_crashDetected) {
        _crashDetected = true;
        _showCrashDetectedDialog();
        print(adjustedMagnitude);
        _initiateEmergencyResponse();
      }
    });
  }

  void _showCrashDetectedDialog() {
    unawaited(showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Possible Crash Detected'),
        content: const Text(
          'It seems like a crash may have occurred. '
          'Press "Cancel" if this is not correct.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              setState(() {
                _crashDetected = false;
              });
              Navigator.of(context).pop();
              _confirmationTimer?.cancel();
            },
            child: const Text('Cancel'),
          ),
        ],
      ),
    ));

    _confirmationTimer = Timer(const Duration(seconds: 5), () {
      if (_crashDetected && mounted) {
        _initiateEmergencyResponse();
        Navigator.of(context).pop();
      }
    });
  }

  void _initiateEmergencyResponse() {
    if (mounted) {
      print('Emergency response initiated.');
      setState(() {
        _crashDetected = false;
      });
    }
  }

  void _simulateCrash() {
    unawaited(_accelerometerSubscription?.cancel());

    var simulatedX = 95;
    var simulatedY = 0;
    var simulatedZ = 0;
    var simulatedMagnitude = sqrt(
      simulatedX * simulatedX +
          simulatedY * simulatedY +
          simulatedZ * simulatedZ,
    );
    var adjustedMagnitude =
        (simulatedMagnitude - _gravitationalConstant).abs();

    if (mounted) {
      setState(() {
        _accelerationMagnitude = adjustedMagnitude;
      });
    }

    if (adjustedMagnitude > _crashThreshold && !_crashDetected) {
      _crashDetected = true;
      _showCrashDetectedDialog();
    }

    unawaited(Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _startAccelerometerListener();
      }
    }));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Stack(
          children: <Widget>[
            // Background
            Positioned.fill(
              child: Container(
                color: AppTheme.colors.background,
              ),
            ),
            // Icon at the top
            Positioned(
              top: 150,
              left: 0,
              right: 0,
              child: Icon(
                Icons.car_crash,
                size: 120,
                color: AppTheme.colors.primary,
              ),
            ),
            // Acceleration data and status
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    '${_accelerationMagnitude.toStringAsFixed(2)} G',
                    style: TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.colors.menuButtons,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _crashDetected ? 'Crash Detected!' : 'Monitoring...',
                    style: TextStyle(
                      fontSize: 18,
                      color: _crashDetected ? Colors.red : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            // Simulate Crash Button
            Positioned(
              bottom: 70,
              left: 0,
              right: 0,
              child: Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.colors.menuButtons,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 15,
                    ),
                  ),
                  onPressed: _simulateCrash,
                  child: Text(
                    'Simulate Crash',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.colors.text,
                    ),
                  ),
                ),
              ),
            ),
            // Back button
            Positioned(
              top: 60,
              left: 15,
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: Color(0xFF5D4037),
                ),
                iconSize: 40,
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      );
}
