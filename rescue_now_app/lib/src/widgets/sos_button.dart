import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rescue_now_app/theme/app_theme.dart';

class SosButton extends StatefulWidget {
  const SosButton({super.key, required this.onActivated});

  /// Called when the user holds the button long enough to trigger SOS.
  final VoidCallback onActivated;

  @override
  State<SosButton> createState() => _SosButtonState();
}

class _SosButtonState extends State<SosButton> {
  static const double _defaultSize = 145.0;
  static const double _pressedSize = 160.0;
  static const Duration _holdDuration = Duration(seconds: 1);
  static const Duration _animationDuration = Duration(milliseconds: 200);

  double _buttonSize = _defaultSize;
  bool _isHolding = false;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _onLongPressStart() {
    setState(() {
      _isHolding = true;
      _buttonSize = _pressedSize;
    });

    _timer = Timer(_holdDuration, () {
      if (_isHolding) {
        widget.onActivated();
        _showConfirmationDialog();
      }
    });
  }

  void _onLongPressEnd() {
    setState(() {
      _isHolding = false;
      _buttonSize = _defaultSize;
    });
    _timer?.cancel();
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Emergency'),
        content: const Text('SOS alert sent. Help is on the way.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (_) => _onLongPressStart(),
      onLongPressEnd: (_) => _onLongPressEnd(),
      child: AnimatedContainer(
        duration: _animationDuration,
        height: _buttonSize,
        width: _buttonSize,
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
