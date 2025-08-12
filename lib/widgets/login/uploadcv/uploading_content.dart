import 'package:flutter/material.dart';

class UploadingView extends StatelessWidget {
  const UploadingView({super.key});
  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(color: Colors.deepPurple),
        SizedBox(height: 24),
        Text('Submitting your application...', style: TextStyle(fontWeight: FontWeight.bold)),
      ],
    ),
  );
}
