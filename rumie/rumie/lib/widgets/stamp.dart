import 'package:flutter/material.dart';

/// The "MATCH!" / "PASS" stamp that fades in over a card as you drag.
class Stamp extends StatelessWidget {
  final String text;
  final Color color;
  const Stamp({super.key, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: color, width: 3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w900,
          fontSize: 22,
          letterSpacing: 1,
        ),
      ),
    );
  }
}
