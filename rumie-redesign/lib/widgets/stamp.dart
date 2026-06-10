import 'package:flutter/material.dart';

class Stamp extends StatelessWidget {
  final String text;
  final Color color;

  const Stamp({super.key, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: text == 'LIKE' ? -0.35 : 0.35,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: color.withAlpha(20),
          border: Border.all(color: color, width: 3),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: color.withAlpha(40),
              blurRadius: 12,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Text(
          text,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w900,
            fontSize: 26,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }
}
