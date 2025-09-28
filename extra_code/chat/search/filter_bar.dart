// lib/screens/search/widgets/filter_bar.dart
import 'package:flutter/material.dart';

class FilterBar extends StatelessWidget {
  const FilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF181340),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.tune, color: Colors.white),
          ),
          const SizedBox(width: 8),
          const FilterChipWidget(label: 'Full-time', isSelected: true),
          const SizedBox(width: 8),
          const FilterChipWidget(label: 'Remote', isSelected: false),
          const SizedBox(width: 8),
          const FilterChipWidget(label: 'Senior', isSelected: false),
        ],
      ),
    );
  }
}

class FilterChipWidget extends StatelessWidget {
  final String label;
  final bool isSelected;

  const FilterChipWidget({
    super.key,
    required this.label,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? const Color(0xFFECEEFF) : Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xFF4B3DFE) : Colors.black87,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
