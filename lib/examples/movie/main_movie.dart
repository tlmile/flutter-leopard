import 'package:flutter/material.dart';

void main() {
  runApp(const MovieExampleApp());
}

class MovieExampleApp extends StatelessWidget {
  const MovieExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: true,
      home: _MoviePage(),
    );
  }
}

class _MoviePage extends StatelessWidget {
  const _MoviePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: AppBar(title: Text('电影示例')),
      body: Center(
        child: Text('这里将来是电影列表 / 详情的 UI 示例'),
      ),
    );
  }
}
