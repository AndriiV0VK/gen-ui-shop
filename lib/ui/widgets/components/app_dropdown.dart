import 'package:flutter/material.dart';

class AppDropdown<T> extends StatelessWidget {
  final String label;
  final IconData prefixIcon;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  const AppDropdown({
    super.key,
    required this.label,
    required this.prefixIcon,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      isExpanded: true, 
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(prefixIcon, size: 20),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      items: items,
      onChanged: onChanged,
    );
  }
}