import 'package:flutter/material.dart';
import '../../models/job-entity.dart';
import '../../utils/app_colors.dart';
class JobCard extends StatelessWidget {
  final JobEntity job;
  const JobCard({Key? key, required this.job}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final logoUrl = job.company?.logoUrl;

    // 🔥 FIX LỖI: Kiểm tra URL
    final bool hasValidLogo = logoUrl != null &&
        logoUrl.isNotEmpty &&
        logoUrl.startsWith('http');

    return Container(
      // ... decoration ...
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo
              Container(
                width: 60, height: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: hasValidLogo
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    logoUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (ctx, err, stack) => const Icon(Icons.business, color: Colors.grey),
                  ),
                )
                    : const Icon(Icons.business, color: Colors.grey),
              ),
              // ...
            ],
          ),
          // ...
        ],
      ),
    );
  }
}