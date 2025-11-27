import 'package:flutter/material.dart';
import 'package:flutter_leopard_demo/examples/login/sign_in/sign_in.dart';
import 'package:flutter_leopard_demo/examples/login/sign_up/sign_up.dart';
import 'package:flutter_leopard_demo/examples/login/widgets/login_page_widgets/login_background.dart';
import 'package:flutter_leopard_demo/examples/login/widgets/login_page_widgets/login_logo.dart';
import 'package:flutter_leopard_demo/examples/login/widgets/login_page_widgets/login_menu_bar.dart';
import 'package:flutter_leopard_demo/examples/login/widgets/login_page_widgets/login_page_view.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final PageController _pageController = PageController();
  bool _isSignIn = true;

  Color get _leftColor => _isSignIn ? Colors.black : Colors.white;

  Color get _rightColor => _isSignIn ? Colors.white : Colors.black;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LoginBackground(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            const LoginLogo(),
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: LoginMenuBar(
                pageController: _pageController,
                leftColor: _leftColor,
                rightColor: _rightColor,
                onSignIn: _onSignInButtonPress,
                onSignUp: _onSignUpButtonPress,
              ),
            ),
            LoginPageView(
              pageController: _pageController,
              onPageChanged: _onPageChanged,
              children: const <Widget>[
                SignIn(),
                SignUp(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _onSignInButtonPress() {
    _animateToPage(0);
  }

  void _onSignUpButtonPress() {
    _animateToPage(1);
  }

  void _onPageChanged(int page) {
    FocusScope.of(context).requestFocus(FocusNode());
    setState(() {
      _isSignIn = page == 0;
    });
  }

  void _animateToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 500),
      curve: Curves.decelerate,
    );
  }
}
