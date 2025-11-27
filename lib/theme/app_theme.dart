import 'package:flutter/material.dart';

class ThemeChoice {
  const ThemeChoice({required this.name, required this.seedColor, this.description});

  final String name;
  final Color seedColor;
  final String? description;
}

class AppTheme {
  static final List<ThemeChoice> themes = [
    const ThemeChoice(name: '海洋蓝', seedColor: Colors.blue),
    const ThemeChoice(name: '青草绿', seedColor: Colors.green),
    const ThemeChoice(name: '夕阳橙', seedColor: Colors.deepOrange),
    const ThemeChoice(name: '薰衣紫', seedColor: Colors.deepPurple),
    const ThemeChoice(name: '星光青', seedColor: Colors.teal),
    const ThemeChoice(name: '柠檬黄', seedColor: Colors.amber),
  ];

  static ThemeData themeData(int index, Brightness brightness) {
    final choice = themes[index % themes.length];
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: choice.seedColor,
        brightness: brightness,
      ),
      useMaterial3: true,
      brightness: brightness,
    );
  }
}
