import 'package:flutter/material.dart';
import 'package:flutter_leopard_demo/examples/login/widgets/snackbar.dart';

import 'sign_in_forgot_password.dart';
import 'sign_in_form.dart';
import 'sign_in_login_button.dart';
import 'sign_in_or_divider.dart';
import 'sign_in_social_buttons.dart';

/// 登录页
class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<StatefulWidget> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final TextEditingController loginEmailController = TextEditingController();
  final TextEditingController loginPasswordController = TextEditingController();

  final FocusNode focusNodeEmail = FocusNode();
  final FocusNode focusNodePassword = FocusNode();

  bool _obscureTextPassword = true;

  @override
  void dispose() {
    loginEmailController.dispose();
    loginPasswordController.dispose();
    focusNodeEmail.dispose();
    focusNodePassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 23.0),
      child: Column(
        children: <Widget>[
          Stack(
            alignment: Alignment.topCenter,
            children: <Widget>[
              SignInForm(
                emailController: loginEmailController,
                passwordController: loginPasswordController,
                emailFocusNode: focusNodeEmail,
                passwordFocusNode: focusNodePassword,
                obscureTextPassword: _obscureTextPassword,
                onTogglePasswordVisibility: _toggleLogin,
                onPasswordSubmitted: _toggleSignInButton,
              ),
              SignInLoginButton(onPressed: _toggleSignInButton),
            ],
          ),
          const SignInForgotPassword(),
          const SignInOrDivider(),
          SignInSocialButtons(
            onFacebookTap: () =>
                CustomSnackBar(context, const Text('Facebook button pressed')),
            onGoogleTap: () =>
                CustomSnackBar(context, const Text('Google button pressed')),
          ),
        ],
      ),
    );
  }

  void _toggleSignInButton() {
    CustomSnackBar(context, const Text('Login button pressed'));
  }

  void _toggleLogin() {
    setState(() {
      _obscureTextPassword = !_obscureTextPassword;
    });
  }
}
