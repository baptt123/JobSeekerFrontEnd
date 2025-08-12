// lib/screens/search/widgets/job_card.dart
import 'package:flutter/material.dart';

class JobCard extends StatelessWidget {
  final IconData logo;
  final Color colorLogo;
  final String title;
  final String company;
  final String location;
  final List<String> tags;
  final String salary;

  const JobCard({
    super.key,
    required this.logo,
    required this.colorLogo,
    required this.title,
    required this.company,
    required this.location,
    required this.tags,
    required this.salary,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      elevation: 1.5,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: colorLogo.withOpacity(0.1),
                  child: Icon(logo, color: colorLogo),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      Text('$company • $location',
                          style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                    ],
                  ),
                ),
                const Icon(Icons.bookmark_border, color: Colors.black45),
              ],
            ),
            const SizedBox(height: 16),
            Row(
                children: tags
                    .map((tag) => Container(
                  margin: const EdgeInsets.only(right: 7),
                  padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4FE),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    tag,
                    style: const TextStyle(color: Color(0xFF4B3DFE), fontSize: 13),
                  ),
                ))
                    .toList()),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('25 minutes ago',
                    style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                Text('\$$salary / Month',
                    style: const TextStyle(
                      color: Color(0xFF181340),
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
