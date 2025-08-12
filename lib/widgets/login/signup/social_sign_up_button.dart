import 'package:flutter/material.dart';

class SocialSignUpButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final String assetImagePath;

  const SocialSignUpButton({
    super.key,
    required this.label,
    required this.onPressed,
    required this.assetImagePath,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFEAE6FB),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          foregroundColor: Colors.black,
        ),
        onPressed: onPressed,
        icon: Image.asset(assetImagePath, height: 24),
        label: Text(label),
      ),
    );
  }
}
