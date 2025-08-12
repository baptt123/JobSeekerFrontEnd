import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SkillItem extends StatelessWidget {
  final String skill;
  final bool selected;

  const SkillItem({required this.skill, this.selected = false, super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      skill,
      style: TextStyle(
        fontSize: 16,
        color: selected ? Colors.deepPurple : Colors.grey.shade800,
        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}
