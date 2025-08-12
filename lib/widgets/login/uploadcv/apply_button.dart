import 'package:flutter/material.dart';

class ApplyButton extends StatelessWidget {
  final VoidCallback? onPressed;
  const ApplyButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurple,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
      child: const Text('APPLY NOW'),
    );
  }
}
