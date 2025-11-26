import 'package:flutter/material.dart';
import 'package:flutter_leopard_demo/examples/login/sign_in/sign_in.dart';
import 'package:flutter_leopard_demo/examples/login/themes/theme.dart';

void main() {
  runApp(const LoginExampleApp());
}

class LoginExampleApp extends StatelessWidget {
  const LoginExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: true,
      home: const _LoginPage(),
    );
  }
}

class _LoginPage extends StatelessWidget {
  const _LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('登录示例')),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: CustomTheme.primaryGradient,
        ),
        child: const SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
            child: Center(child: SignIn()),
          ),
        ),
      ),
    );
  }
}
