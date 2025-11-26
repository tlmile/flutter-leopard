import 'dart:ui';
import 'package:flutter/cupertino.dart';

class CustomTheme {
  const CustomTheme();

  static const Color loginGradientStart = Color(0xFFfbab66);
  static const Color loginGradientEnd = Color(0xFFf7418c);

  static const Color White = Color(0xFFFFFFFF);
  static const Color Black = Color(0xFF000000);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: <Color>[
      CustomTheme.loginGradientStart,
      CustomTheme.loginGradientEnd,
    ],
    stops: <double>[0.0,1.0],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}