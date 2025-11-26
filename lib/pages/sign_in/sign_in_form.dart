import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SignInForm extends StatelessWidget {
  const SignInForm({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.emailFocusNode,
    required this.passwordFocusNode,
    required this.obscureTextPassword,
    required this.onTogglePasswordVisibility,
    required this.onPasswordSubmitted,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;
  final FocusNode emailFocusNode;
  final FocusNode passwordFocusNode;
  final bool obscureTextPassword;
  final VoidCallback onTogglePasswordVisibility;
  final VoidCallback onPasswordSubmitted;

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
        height: 190.0,
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(
                  top: 20.0, bottom: 20.0, left: 25.0, right: 25.0),
              child: TextField(
                focusNode: emailFocusNode,
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(
                    fontFamily: 'WorkSansSemiBold',
                    fontSize: 16.0,
                    color: Colors.black),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  icon: Icon(
                    FontAwesomeIcons.envelope,
                    color: Colors.black,
                    size: 22.0,
                  ),
                  hintText: 'Email Address',
                  hintStyle:
                      TextStyle(fontFamily: 'WorkSansSemiBold', fontSize: 17.0),
                ),
                onSubmitted: (_) {
                  passwordFocusNode.requestFocus();
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
                focusNode: passwordFocusNode,
                controller: passwordController,
                obscureText: obscureTextPassword,
                style: const TextStyle(
                    fontFamily: 'WorkSansSemiBold',
                    fontSize: 16.0,
                    color: Colors.black),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  icon: const Icon(
                    FontAwesomeIcons.lock,
                    size: 22.0,
                    color: Colors.black,
                  ),
                  hintText: 'Password',
                  hintStyle:
                      const TextStyle(fontFamily: 'WorkSansSemiBold', fontSize: 17.0),
                  suffixIcon: GestureDetector(
                    onTap: onTogglePasswordVisibility,
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
                  onPasswordSubmitted();
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
