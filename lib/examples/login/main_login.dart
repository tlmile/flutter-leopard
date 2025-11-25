import 'package:flutter/material.dart';

void main() {
  runApp(const LoginExampleApp());
}

class LoginExampleApp extends StatelessWidget {
  const LoginExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: true,
      home: _LoginPage(),
    );
  }
}

class _LoginPage extends StatelessWidget {
  const _LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: AppBar(title: Text('登录示例')),
      body: Center(
        child: Text('这里将来是登录页面的 UI 示例'),
      ),
    );
  }
}
