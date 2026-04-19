import 'package:flutter/material.dart';
import 'package:rescue_now_app/src/location_management.dart';

/// Handles all emergency-related actions.
/// UI widgets should call these methods rather than implementing logic themselves.
class EmergencyService {
  EmergencyService._(); // Prevent instantiation

  static Future<void> sendSOSAlert(BuildContext context) async {
    getAndSendLocation();
  }

  static Future<void> sendEmergencyText(BuildContext context) async {
    await sendSOSAlert(context);
    _textEmergencyContacts();
  }

  static Future<void> startVoiceCall(BuildContext context) async {
    await sendSOSAlert(context);
    _initiateVoiceCall();
  }

  static Future<void> startVideoCall(BuildContext context) async {
    await sendSOSAlert(context);
    _initiateVideoCall();
  }

  // --- Private implementations (swap these out for real integrations) ---

  static void _textEmergencyContacts() {
    // TODO: Integrate SMS / push notification service
  }

  static void _initiateVoiceCall() {
    // TODO: Integrate VoIP / telephony service
  }

  static void _initiateVideoCall() {
    // TODO: Integrate video-call service
  }
}
