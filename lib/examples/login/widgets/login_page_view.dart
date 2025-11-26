import 'package:flutter/material.dart';

class LoginPageView extends StatelessWidget {
  const LoginPageView({
    super.key,
    required this.pageController,
    required this.onPageChanged,
    required this.children,
  });

  final PageController pageController;
  final ValueChanged<int> onPageChanged;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 2,
      child: PageView(
        controller: pageController,
        physics: const ClampingScrollPhysics(),
        onPageChanged: onPageChanged,
        children: children
            .map(
              (Widget child) => ConstrainedBox(
                constraints: const BoxConstraints.expand(),
                child: child,
              ),
            )
            .toList(),
      ),
    );
  }
}
