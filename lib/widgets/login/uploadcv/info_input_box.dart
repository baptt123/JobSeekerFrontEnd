import 'package:flutter/material.dart';

class InfoInputBox extends StatelessWidget {
  final TextEditingController controller;
  const InfoInputBox({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Information', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey[50],
              border: Border.all(color: Colors.grey.shade300)
          ),
          child: TextField(
            controller: controller,
            maxLines: 5,
            decoration: InputDecoration(
                hintText: 'Explain why you are the right person for this job',
                contentPadding: EdgeInsets.all(12),
                border: InputBorder.none),
          ),
        ),
      ],
    );
  }
}
