import 'package:flutter/material.dart';

class SignInForgotPassword extends StatelessWidget {
  const SignInForgotPassword({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: TextButton(
        onPressed: () {},
        child: const Text(
          'Forgot Password?',
          style: TextStyle(
              decoration: TextDecoration.underline,
              color: Colors.white,
              fontSize: 16.0,
              fontFamily: 'WorkSansMedium'),
        ),
      ),
    );
  }
}
