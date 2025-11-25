import 'package:flutter/material.dart';

void main() {
  runApp(const CompassExampleApp());
}

class CompassExampleApp extends StatelessWidget {
  const CompassExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: true,
      home: _CompassPage(),
    );
  }
}

class _CompassPage extends StatelessWidget {
  const _CompassPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Compass 示例')),
      body: Center(
        child: Text('这里将来是 compass_app 的 UI / 布局示例'),
      ),
    );
  }
}
