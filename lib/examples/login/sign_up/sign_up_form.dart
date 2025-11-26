import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
            Padding(
              padding: const EdgeInsets.only(
                  top: 20.0, bottom: 20.0, left: 25.0, right: 25.0),
              child: TextField(
                focusNode: focusNodeName,
                controller: signupNameController,
                keyboardType: TextInputType.text,
                textCapitalization: TextCapitalization.words,
                autocorrect: false,
                style: const TextStyle(
                    fontFamily: 'WorkSansSemiBold',
                    fontSize: 16.0,
                    color: Colors.black),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  icon: Icon(
                    FontAwesomeIcons.user,
                    color: Colors.black,
                  ),
                  hintText: 'Name',
                  hintStyle:
                      TextStyle(fontFamily: 'WorkSansSemiBold', fontSize: 16.0),
                ),
                onSubmitted: (_) {
                  focusNodeEmail.requestFocus();
                },
              ),
            ),
            Container(
              width: 250.0,
              height: 1.0,
              color: Colors.grey[400],
            ),
            Padding(
              padding: const EdgeInsets.only(
                  top: 20.0, bottom: 20.0, left: 25.0, right: 25.0),
              child: TextField(
                focusNode: focusNodeEmail,
                controller: signupEmailController,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                style: const TextStyle(
                    fontFamily: 'WorkSansSemiBold',
                    fontSize: 16.0,
                    color: Colors.black),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  icon: Icon(
                    FontAwesomeIcons.envelope,
                    color: Colors.black,
                  ),
                  hintText: 'Email Address',
                  hintStyle:
                      TextStyle(fontFamily: 'WorkSansSemiBold', fontSize: 16.0),
                ),
                onSubmitted: (_) {
                  focusNodePassword.requestFocus();
                },
              ),
            ),
            Container(
              width: 250.0,
              height: 1.0,
              color: Colors.grey[400],
            ),
            Padding(
              padding: const EdgeInsets.only(
                  top: 20.0, bottom: 20.0, left: 25.0, right: 25.0),
              child: TextField(
                focusNode: focusNodePassword,
                controller: signupPasswordController,
                obscureText: obscureTextPassword,
                autocorrect: false,
                style: const TextStyle(
                    fontFamily: 'WorkSansSemiBold',
                    fontSize: 16.0,
                    color: Colors.black),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  icon: const Icon(
                    FontAwesomeIcons.lock,
                    color: Colors.black,
                  ),
                  hintText: 'Password',
                  hintStyle: const TextStyle(
                      fontFamily: 'WorkSansSemiBold', fontSize: 16.0),
                  suffixIcon: GestureDetector(
                    onTap: togglePasswordVisibility,
                    child: Icon(
                      obscureTextPassword
                          ? FontAwesomeIcons.eye
                          : FontAwesomeIcons.eyeSlash,
                      size: 15.0,
                      color: Colors.black,
                    ),
                  ),
                ),
                onSubmitted: (_) {
                  focusNodeConfirmPassword.requestFocus();
                },
              ),
            ),
            Container(
              width: 250.0,
              height: 1.0,
              color: Colors.grey[400],
            ),
            Padding(
              padding: const EdgeInsets.only(
                  top: 20.0, bottom: 20.0, left: 25.0, right: 25.0),
              child: TextField(
                focusNode: focusNodeConfirmPassword,
                controller: signupConfirmPasswordController,
                obscureText: obscureTextConfirmPassword,
                autocorrect: false,
                style: const TextStyle(
                    fontFamily: 'WorkSansSemiBold',
                    fontSize: 16.0,
                    color: Colors.black),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  icon: const Icon(
                    FontAwesomeIcons.lock,
                    color: Colors.black,
                  ),
                  hintText: 'Confirmation',
                  hintStyle: const TextStyle(
                      fontFamily: 'WorkSansSemiBold', fontSize: 16.0),
                  suffixIcon: GestureDetector(
                    onTap: toggleConfirmPasswordVisibility,
                    child: Icon(
                      obscureTextConfirmPassword
                          ? FontAwesomeIcons.eye
                          : FontAwesomeIcons.eyeSlash,
                      size: 15.0,
                      color: Colors.black,
                    ),
                  ),
                ),
                onSubmitted: (_) {
                  onSubmit();
                },
                textInputAction: TextInputAction.go,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
