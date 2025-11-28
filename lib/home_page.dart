import 'package:flutter/material.dart';

import 'examples/deeplink_store/main_deeplinkstore.dart';
import 'examples/login/login_page.dart';
import 'examples/movie/main_movie.dart';
import 'examples/food/main_food.dart';
import 'examples/compass_app/main_compass.dart';
import 'examples/music/screen/mpd_connection_gate_screen.dart';
import 'theme/app_theme.dart';
import 'theme/theme_controller.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.themeController});

  final ThemeController themeController;

  @override
  Widget build(BuildContext context) {
    final examples = <(String, Widget)>[
      ('深度商品连接', const DeeplinkStoreApp()),
      ('登录示例', const LoginPage()),
      ('音乐播放器', const MpdConnectionGateScreen()),
      // ('美食示例', const FoodExampleApp()),
      // ('Compass 示例', const CompassExampleApp()),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leopard 示例集合'),
        actions: [
          AnimatedBuilder(
            animation: themeController,
            builder: (context, _) {
              return PopupMenuButton<int>(
                tooltip: '切换主题色',
                initialValue: themeController.themeIndex,
                onSelected: themeController.setThemeIndex,
                itemBuilder: (context) {
                  return AppTheme.themes.asMap().entries.map((entry) {
                    final index = entry.key;
                    final theme = entry.value;
                    return PopupMenuItem<int>(
                      value: index,
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 10,
                            backgroundColor: theme.seedColor,
                          ),
                          const SizedBox(width: 8),
                          Text(theme.name),
                        ],
                      ),
                    );
                  }).toList();
                },
                icon: const Icon(Icons.palette_outlined),
              );
            },
          ),
          AnimatedBuilder(
            animation: themeController,
            builder: (context, _) {
              final isDark = themeController.mode == ThemeMode.dark;
              return IconButton(
                tooltip: isDark ? '切换到浅色模式' : '切换到深色模式',
                icon: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
                onPressed: themeController.toggleThemeMode,
              );
            },
          ),
        ],
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
