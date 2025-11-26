import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'sign_up_form_divider.dart';
import 'sign_up_form_field.dart';
import 'sign_up_password_field.dart';

class SignUpForm extends StatelessWidget {
  const SignUpForm({
    super.key,
    required this.focusNodeName,
    required this.focusNodeEmail,
    required this.focusNodePassword,
    required this.focusNodeConfirmPassword,
    required this.signupNameController,
    required this.signupEmailController,
    required this.signupPasswordController,
    required this.signupConfirmPasswordController,
    required this.obscureTextPassword,
    required this.obscureTextConfirmPassword,
    required this.togglePasswordVisibility,
    required this.toggleConfirmPasswordVisibility,
    required this.onSubmit,
  });

  final FocusNode focusNodeName;
  final FocusNode focusNodeEmail;
  final FocusNode focusNodePassword;
  final FocusNode focusNodeConfirmPassword;

  final TextEditingController signupEmailController;
  final TextEditingController signupNameController;
  final TextEditingController signupPasswordController;
  final TextEditingController signupConfirmPasswordController;

  final bool obscureTextPassword;
  final bool obscureTextConfirmPassword;

  final VoidCallback togglePasswordVisibility;
  final VoidCallback toggleConfirmPasswordVisibility;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: SizedBox(
        width: 300.0,
        height: 360.0,
        child: Column(
          children: <Widget>[
            SignUpFormField(
              focusNode: focusNodeName,
              controller: signupNameController,
              keyboardType: TextInputType.text,
              textCapitalization: TextCapitalization.words,
              hintText: 'Name',
              icon: const Icon(
                FontAwesomeIcons.user,
                color: Colors.black,
              ),
              onSubmitted: () => focusNodeEmail.requestFocus(),
            ),
            const SignUpFormDivider(),
            SignUpFormField(
              focusNode: focusNodeEmail,
              controller: signupEmailController,
              keyboardType: TextInputType.emailAddress,
              hintText: 'Email Address',
              icon: const Icon(
                FontAwesomeIcons.envelope,
                color: Colors.black,
              ),
              onSubmitted: () => focusNodePassword.requestFocus(),
            ),
            const SignUpFormDivider(),
            SignUpPasswordField(
              focusNode: focusNodePassword,
              controller: signupPasswordController,
              obscureText: obscureTextPassword,
              hintText: 'Password',
              onSubmitted: () => focusNodeConfirmPassword.requestFocus(),
              onTogglePasswordVisibility: togglePasswordVisibility,
            ),
            const SignUpFormDivider(),
            SignUpPasswordField(
              focusNode: focusNodeConfirmPassword,
              controller: signupConfirmPasswordController,
              obscureText: obscureTextConfirmPassword,
              hintText: 'Confirmation',
              onSubmitted: onSubmit,
              textInputAction: TextInputAction.go,
              onTogglePasswordVisibility: toggleConfirmPasswordVisibility,
            ),
          ],
        ),
      ),
    );
  }
}
