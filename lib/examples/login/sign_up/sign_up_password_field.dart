import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'sign_up_form_field.dart';

class SignUpPasswordField extends StatelessWidget {
  const SignUpPasswordField({
    super.key,
    required this.focusNode,
    required this.controller,
    required this.obscureText,
    required this.hintText,
    required this.onTogglePasswordVisibility,
    this.onSubmitted,
    this.textInputAction,
  });

  final FocusNode focusNode;
  final TextEditingController controller;
  final bool obscureText;
  final String hintText;
  final VoidCallback onTogglePasswordVisibility;
  final VoidCallback? onSubmitted;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    return SignUpFormField(
      focusNode: focusNode,
      controller: controller,
      obscureText: obscureText,
      hintText: hintText,
      icon: const Icon(
        FontAwesomeIcons.lock,
        color: Colors.black,
      ),
      onSubmitted: onSubmitted,
      textInputAction: textInputAction,
      suffixIcon: GestureDetector(
        onTap: onTogglePasswordVisibility,
        child: Icon(
          obscureText ? FontAwesomeIcons.eye : FontAwesomeIcons.eyeSlash,
          size: 15.0,
          color: Colors.black,
        ),
      ),
    );
  }
}
