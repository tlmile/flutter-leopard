import 'package:flutter/material.dart';

/// 页面占位符 例如：有跳转新页面的地方，可以先使用这个，表示该页面待完善
class TodoScreen extends StatelessWidget {
  final String title;
  final String? message;

  const TodoScreen({
    super.key,
    required this.title,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.build, color: Colors.grey, size: 48),
            const SizedBox(height: 16),
            Text(
              message ?? "This feature is not implemented yet.",
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
