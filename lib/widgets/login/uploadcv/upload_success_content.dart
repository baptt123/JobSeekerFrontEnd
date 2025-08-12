import 'package:flutter/material.dart';

class UploadSuccessView extends StatelessWidget {
  final String fileName;
  final VoidCallback? onFindSimilar;
  final VoidCallback? onBackHome;
  const UploadSuccessView({
    super.key,
    required this.fileName,
    this.onFindSimilar,
    this.onBackHome,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        // ... giống hướng dẫn trước, bạn có thể bổ sung lại phần header và file info
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.verified, size: 90, color: Colors.green),
          SizedBox(height: 24),
          Text("Successful", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
          SizedBox(height: 8),
          Text("Congratulations, your application has been sent", textAlign: TextAlign.center),
          SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: onFindSimilar,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.purple[100], foregroundColor: Colors.deepPurple),
                  child: const Text("FIND A SIMILAR JOB"),
                ),
              ),
              SizedBox(width: 14),
              Expanded(
                child: ElevatedButton(
                  onPressed: onBackHome,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, foregroundColor: Colors.white),
                  child: const Text("BACK TO HOME"),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
