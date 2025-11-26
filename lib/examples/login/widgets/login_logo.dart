import 'package:flutter/material.dart';

class LoginLogo extends StatelessWidget {
  const LoginLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 75.0),
      child: Image(
        height: MediaQuery.of(context).size.height > 800 ? 191.0 : 150,
        fit: BoxFit.fill,
        image: const AssetImage(
          'lib/examples/login/assets/img/login_logo.png',
        ),
      ),
    );
  }
}
