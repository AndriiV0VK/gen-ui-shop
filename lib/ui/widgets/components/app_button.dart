import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? color;
  final IconData? icon;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[Icon(icon, size: 18), const SizedBox(width: 8)],
            Text(text, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}