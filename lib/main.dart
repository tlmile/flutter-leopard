import 'package:flutter/material.dart';
import 'home_page.dart';

void main() {
  runApp(const LeopardDemo());
}

class LeopardDemo extends StatelessWidget {
  const LeopardDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: true,
      home: HomePage(),
    );
  }
}
