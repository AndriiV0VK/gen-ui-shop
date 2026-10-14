import 'package:flutter/material.dart';

enum AlertType { info, warning, success }

class AppAlertBanner extends StatelessWidget {
  final String message;
  final AlertType type;
  final IconData? icon;

  const AppAlertBanner({
    super.key,
    required this.message,
    this.type = AlertType.info,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final (bg, fg, defaultIcon) = switch (type) {
      AlertType.success => (
          Colors.green.shade50,
          Colors.green.shade800,
          Icons.check_circle_outline,
        ),
      AlertType.warning => (
          Colors.orange.shade50,
          Colors.orange.shade900,
          Icons.warning_amber_rounded,
        ),
      AlertType.info => (
          Colors.blue.shade50,
          Colors.blue.shade800,
          Icons.info_outline,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: fg.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon ?? defaultIcon, color: fg, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: fg,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}