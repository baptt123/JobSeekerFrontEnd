import 'package:flutter/material.dart';

class CustomCheckbox extends StatefulWidget {
  final bool checked;
  const CustomCheckbox({this.checked = false, super.key});

  @override
  State<CustomCheckbox> createState() => _CustomCheckboxState();
}

class _CustomCheckboxState extends State<CustomCheckbox> {
  late bool _checked;

  @override
  void initState() {
    super.initState();
    _checked = widget.checked;
  }

  @override
  Widget build(BuildContext context) {
    return Checkbox(
      value: _checked,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(3),
      ),
      onChanged: (val) {
        setState(() {
          _checked = val ?? false;
        });
      },
    );
  }
}
