import 'package:flutter/material.dart';

class FilterChipButton extends StatelessWidget {
  final String label;
  final bool highlighted;
  const FilterChipButton({required this.label, this.highlighted = false, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: highlighted ? Colors.orange : Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(label, style: TextStyle(
        color: highlighted ? Colors.white : Colors.grey[800],
        fontWeight: highlighted ? FontWeight.bold : FontWeight.normal,
      )),
    );
  }
}
