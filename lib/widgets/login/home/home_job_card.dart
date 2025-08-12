import 'package:flutter/material.dart';

class HomeJobCard extends StatelessWidget {
  const HomeJobCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildJobCard('UI/UX Designer', 'Google', '\$6k/mo', false),
        const SizedBox(height: 12),
        _buildJobCard('Product Manager', 'Facebook', '\$8k/mo', true),
      ],
    );
  }

  Widget _buildJobCard(
      String role, String company, String salary, bool bookmarked) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              blurRadius: 6, color: Colors.grey.withOpacity(0.08))
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
              child: const Icon(Icons.work),
              backgroundColor: Colors.deepPurple[100]),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(role, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(company, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          Column(
            children: [
              Text(salary,
                  style: const TextStyle(color: Colors.deepOrange)),
              Icon(
                  bookmarked ? Icons.bookmark : Icons.bookmark_outline),
            ],
          )
        ],
      ),
    );
  }
}
