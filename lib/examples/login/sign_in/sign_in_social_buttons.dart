import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SignInSocialButtons extends StatelessWidget {
  const SignInSocialButtons({
    super.key,
    required this.onFacebookTap,
    required this.onGoogleTap,
  });

  final VoidCallback onFacebookTap;
  final VoidCallback onGoogleTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 10.0, right: 40.0),
          child: GestureDetector(
            onTap: onFacebookTap,
            child: Container(
              padding: const EdgeInsets.all(15.0),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: const Icon(
                FontAwesomeIcons.facebookF,
                color: Color(0xFF0084ff),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: GestureDetector(
            onTap: onGoogleTap,
            child: Container(
              padding: const EdgeInsets.all(15.0),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: const Icon(
                FontAwesomeIcons.google,
                color: Color(0xFF0084ff),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
