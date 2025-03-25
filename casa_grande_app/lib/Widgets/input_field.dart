import 'package:flutter/cupertino.dart';

class InputField extends StatelessWidget {
  final String placeholder;
  final String? label;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final bool obscureText;

  const InputField({
    Key? key,
    required this.placeholder,
    required this.controller,
    this.label,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoTextField(
      controller: controller,
      keyboardType: keyboardType,
      placeholder: placeholder,
      padding: const EdgeInsets.all(12),
      obscureText: obscureText,
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}