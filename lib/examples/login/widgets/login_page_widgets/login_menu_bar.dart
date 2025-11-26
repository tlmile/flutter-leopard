import 'package:flutter/material.dart';
import 'package:flutter_leopard_demo/examples/login/utils/bubble_indicator_painter.dart';

class LoginMenuBar extends StatelessWidget {
  const LoginMenuBar({
    super.key,
    required this.pageController,
    required this.leftColor,
    required this.rightColor,
    required this.onSignIn,
    required this.onSignUp,
  });

  final PageController pageController;
  final Color leftColor;
  final Color rightColor;
  final VoidCallback onSignIn;
  final VoidCallback onSignUp;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300.0,
      height: 50.0,
      decoration: const BoxDecoration(
        color: Color(0x552B2B2B),
        borderRadius: BorderRadius.all(Radius.circular(25.0)),
      ),
      child: CustomPaint(
        painter: BubbleIndicatorPainter(pageController: pageController),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Expanded(
              child: TextButton(
                style: ButtonStyle(
                  overlayColor: MaterialStateProperty.all(Colors.transparent),
                ),
                onPressed: onSignIn,
                child: Text(
                  'Existing',
                  style: TextStyle(
                    color: leftColor,
                    fontSize: 16.0,
                    fontFamily: 'WorkSansSemiBold',
                  ),
                ),
              ),
            ),
            Expanded(
              child: TextButton(
                style: ButtonStyle(
                  overlayColor: MaterialStateProperty.all(Colors.transparent),
                ),
                onPressed: onSignUp,
                child: Text(
                  'New',
                  style: TextStyle(
                    color: rightColor,
                    fontSize: 16.0,
                    fontFamily: 'WorkSansSemiBold',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
