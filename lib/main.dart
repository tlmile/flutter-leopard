import 'package:flutter/material.dart';

void main() {
  runApp(const LeopardApp());
}

class LeopardApp extends StatelessWidget {
  const LeopardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Leopard Demo',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const AuthPage(),
    );
  }
}

/// 你的登录/注册 UI 将写在这里
class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          '准备开始写登录 / 注册界面…',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
