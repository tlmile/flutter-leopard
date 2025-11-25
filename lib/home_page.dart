import 'package:flutter/material.dart';
import 'examples/deeplink_store/main_deeplinkstore.dart';
import 'examples/login/main_login.dart';
import 'examples/movie/main_movie.dart';
import 'examples/food/main_food.dart';
import 'examples/compass_app/main_compass.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final examples = <(String, Widget)>[
      ('深度商品连接', const DeeplinkStoreApp()),
      ('登录示例', const LoginExampleApp()),
      ('电影示例', const MovieExampleApp()),
      ('美食示例', const FoodExampleApp()),
      ('Compass 示例', const CompassExampleApp()),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leopard 示例集合'),
      ),
      body: ListView.builder(
        itemCount: examples.length,
        itemBuilder: (context, index) {
          final (title, widget) = examples[index];
          return ListTile(
            title: Text(title),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => widget),
              );
            },
          );
        },
      ),
    );
  }
}
