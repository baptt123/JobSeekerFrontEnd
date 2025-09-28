import 'package:flutter/material.dart';

class JobCard extends StatelessWidget {
  final Map<String, dynamic> job;
  final VoidCallback onOptionsTap;

  const JobCard({Key? key, required this.job, required this.onOptionsTap}) : super(key: key);

  Widget _logo(String type) {
    switch (type) {
      case 'google':
        return CircleAvatar(backgroundColor: Colors.white, child: Image.network('https://upload.wikimedia.org/wikipedia/commons/2/2f/Google_2015_logo.svg', height: 24), radius: 16);
      case 'dribbble':
        return CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.sports_basketball, color: Colors.pink, size: 28), radius: 16);
      case 'twitter':
        return CircleAvatar(backgroundColor: Colors.white, child: Image.network('https://cdn-icons-png.flaticon.com/512/733/733579.png', height: 24), radius: 16);
      default:
        return CircleAvatar(child: Icon(Icons.work));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 9, horizontal: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 14, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _logo(job['companyLogo']),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(job['title'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                      SizedBox(height: 4),
                      Text('${job['company']} ・ ${job['location']}', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                    ],
                  ),
                ),
                IconButton(icon: Icon(Icons.more_vert, color: Colors.grey[700]), onPressed: onOptionsTap),
              ],
            ),
            SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: List<Widget>.from(
                (job['tags'] as List).map((tag) => Chip(
                  label: Text(tag, style: TextStyle(fontSize: 12)),
                  backgroundColor: Colors.grey[100],
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                )),
              ),
            ),
            SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('25 minute ago', style: TextStyle(fontSize: 12, color: Colors.grey)),
                Text(job['salary'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
