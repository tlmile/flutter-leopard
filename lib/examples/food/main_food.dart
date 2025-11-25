import 'package:flutter/material.dart';

void main() {
  runApp(const FoodExampleApp());
}

class FoodExampleApp extends StatelessWidget {
  const FoodExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: true,
      home: _FoodPage(),
    );
  }
}

class _FoodPage extends StatelessWidget {
  const _FoodPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('美食示例')),
      body: Center(
        child: Text('这里将来是美食推荐 / 列表等 UI 示例'),
      ),
    );
  }
}
