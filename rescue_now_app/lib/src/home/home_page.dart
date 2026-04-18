import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rescue_now_app/src/crash_detection.dart';
import 'package:rescue_now_app/src/profile_screen.dart';
import 'package:rescue_now_app/src/home/emergency_service.dart';
import 'package:rescue_now_app/src/widgets/nav_icon_button.dart';
import 'package:rescue_now_app/src/widgets/sos_button.dart';
import 'package:rescue_now_app/src/widgets/emergency_bottom_sheet.dart';
import 'package:rescue_now_app/theme/app_theme.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
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
            _TopNavBar(
              onContactsTap: () {},
              onCrashTestTap: () =>
                  _navigateTo(context, CrashDetectionScreen()),
              onProfileTap: () =>
                  _navigateTo(context, const ProfileScreen()),
            ),
            SosButton(
              onActivated: () => EmergencyService.sendSOSAlert(context),
            ),
            _HelpOptionsButton(
              onTap: () => showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(50.0),
                  ),
                ),
                builder: (_) => const EmergencyBottomSheet(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopNavBar extends StatelessWidget {
  const _TopNavBar({
    required this.onContactsTap,
    required this.onCrashTestTap,
    required this.onProfileTap,
  });

  final VoidCallback onContactsTap;
  final VoidCallback onCrashTestTap;
  final VoidCallback onProfileTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Row(
        children: [
          const SizedBox(width: 16),
          NavIconButton(
            icon: SvgPicture.asset('assets/emergency-contacts.svg',
                height: 40, width: 40),
            label: 'Contacts',
            onTap: onContactsTap,
          ),
          const SizedBox(width: 24),
          NavIconButton(
            icon: SvgPicture.asset('assets/crash.svg', height: 40, width: 40),
            label: 'Crash test',
            onTap: onCrashTestTap,
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: NavIconButton(
              icon: SvgPicture.asset(
                'assets/profile.svg',
                color: AppTheme.colors.menuButtons,
                height: 40,
                width: 40,
              ),
              label: 'Profile',
              onTap: onProfileTap,
            ),
          ),
        ],
      ),
    );
  }
}

class _HelpOptionsButton extends StatelessWidget {
  const _HelpOptionsButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.colors.menuButtons,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
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
      ),
    );
  }
}
