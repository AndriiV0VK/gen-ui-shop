import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppPriceText extends StatelessWidget {
  final double price;
  final double fontSize;
  final Color color;

  const AppPriceText({
    super.key,
    required this.price,
    this.fontSize = 15,
    this.color = Colors.green,
  });

  @override
  Widget build(BuildContext context) {
    final format = NumberFormat.currency(locale: 'uk_UA', symbol: 'грн', decimalDigits: 0);
    return Text(
      format.format(price),
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: fontSize,
        color: color,
      ),
    );
  }
}