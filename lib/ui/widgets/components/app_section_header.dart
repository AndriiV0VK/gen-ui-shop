import 'package:flutter/material.dart';

class AppSectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color? iconColor;
  final Widget? trailing;

  const AppSectionHeader({
    super.key,
    required this.title,
    required this.icon,
    this.iconColor,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: iconColor ?? Theme.of(context).primaryColor),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        ?trailing, 
      ],
    );
  }
}