import 'package:flutter/material.dart';

class SuggestionList extends StatelessWidget {
  final List<String> suggestions;
  final Function(String) onTap;

  const SuggestionList({required this.suggestions, required this.onTap});

  @override
  Widget build(BuildContext context) {
    if (suggestions.isEmpty) return SizedBox.shrink();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: suggestions.map((s) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: ActionChip(
              label: Text(s),
              onPressed: () => onTap(s),
            ),
          );
        }).toList(),
      ),
    );
  }
}
