import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool outlined;
  final bool highlighted;

  const CustomButton({required this.text, required this.onPressed, this.outlined = false, this.highlighted = false, super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(
            highlighted ? Colors.amber : (outlined ? Colors.white : Colors.deepPurple)
        ),
        foregroundColor: MaterialStateProperty.all(
            outlined ? Colors.deepPurple : Colors.white
        ),
        side: MaterialStateProperty.all(
            outlined ? BorderSide(color: Colors.deepPurple) : BorderSide.none
        ),
        shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        padding: MaterialStateProperty.all(const EdgeInsets.symmetric(vertical: 16)),
      ),
      onPressed: onPressed,
      child: Text(text, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }
}
