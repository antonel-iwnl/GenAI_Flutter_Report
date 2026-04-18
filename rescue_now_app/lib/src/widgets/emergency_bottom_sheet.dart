import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rescue_now_app/src/home/emergency_service.dart';
import 'package:rescue_now_app/theme/app_theme.dart';

class EmergencyBottomSheet extends StatelessWidget {
  const EmergencyBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.colors.menuButtons,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(50.0)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _DragHandle(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                _EmergencyOptionButton(
                  label: 'Send Emergency Text',
                  onTap: () {
                    EmergencyService.sendEmergencyText(context);
                    Navigator.pop(context);
                  },
                ),
                _EmergencyOptionButton(
                  label: 'Voice Emergency Call',
                  onTap: () {
                    EmergencyService.startVoiceCall(context);
                    Navigator.pop(context);
                  },
                ),
                _EmergencyOptionButton(
                  label: 'Video Emergency Call',
                  onTap: () {
                    EmergencyService.startVideoCall(context);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const _DisclaimerRow(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _DragHandle extends StatelessWidget {
  const _DragHandle();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0, bottom: 20.0),
      child: Container(
        width: 50,
        height: 5,
        decoration: BoxDecoration(
          color: AppTheme.colors.text,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}

class _EmergencyOptionButton extends StatelessWidget {
  const _EmergencyOptionButton({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.colors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 15),
          fixedSize: const Size(277, 55),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: AppTheme.colors.text,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}

class _DisclaimerRow extends StatelessWidget {
  const _DisclaimerRow();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 40,
            width: 40,
            child: SvgPicture.asset('assets/info svg-2.svg'),
          ),
          const SizedBox(width: 2),
          Expanded(
            child: Text(
              'Initiating any kind of help request will also alert emergency contacts.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.colors.text,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
