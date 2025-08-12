import 'package:flutter/material.dart';

class WelcomeWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Spacer(),
            Text(
              "Find Your\nDream Job\nHere!",
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              "Explore all the most exciting job roles based on your interest and study major.",
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            Spacer(),
            Align(
              alignment: Alignment.bottomRight,
              child: CircleAvatar(
                radius: 28,
                backgroundColor: Color(0xFF140087),
                child: Icon(Icons.arrow_forward, color: Colors.white, size: 32),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
