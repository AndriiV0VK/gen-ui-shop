import 'package:flutter/material.dart';

class AppStatusChip extends StatelessWidget {
  final String status;

  const AppStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final isDone = status == 'Виконане';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDone ? Colors.green.shade50 : Colors.amber.shade50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: isDone ? Colors.green.shade300 : Colors.amber.shade400),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: isDone ? Colors.green.shade800 : Colors.amber.shade900,
        ),
      ),
    );
  }
}