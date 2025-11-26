import 'package:flutter/material.dart';

class SignUpFormField extends StatelessWidget {
  const SignUpFormField({
    super.key,
    required this.focusNode,
    required this.controller,
    required this.hintText,
    required this.icon,
    this.textCapitalization = TextCapitalization.none,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
    this.onSubmitted,
    this.textInputAction,
  });

  final FocusNode focusNode;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final bool obscureText;
  final Widget icon;
  final String hintText;
  final Widget? suffixIcon;
  final VoidCallback? onSubmitted;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          top: 20.0, bottom: 20.0, left: 25.0, right: 25.0),
      child: TextField(
        focusNode: focusNode,
        controller: controller,
        keyboardType: keyboardType,
        textCapitalization: textCapitalization,
        obscureText: obscureText,
        autocorrect: false,
        style: const TextStyle(
            fontFamily: 'WorkSansSemiBold', fontSize: 16.0, color: Colors.black),
        decoration: InputDecoration(
          border: InputBorder.none,
          icon: icon,
          hintText: hintText,
          hintStyle:
              const TextStyle(fontFamily: 'WorkSansSemiBold', fontSize: 16.0),
          suffixIcon: suffixIcon,
        ),
        onSubmitted: (_) => onSubmitted?.call(),
        textInputAction: textInputAction,
      ),
    );
  }
}
