import 'package:flutter/material.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14.0),
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: color ?? Colors.white,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
  }
}