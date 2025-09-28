import 'package:flutter/material.dart';

class RecruiterStatisticCard extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;

  const RecruiterStatisticCard({
    required this.label,
    required this.value,
    required this.icon,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32),
            SizedBox(height: 8),
            Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
            Text("$value", style: TextStyle(fontSize: 24)),
          ],
        ),
      ),
    );
  }
}
