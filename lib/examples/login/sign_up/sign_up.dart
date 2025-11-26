import 'package:flutter/material.dart';
import 'package:flutter_leopard_demo/examples/login/sign_up/sign_up_button.dart';
import 'package:flutter_leopard_demo/examples/login/sign_up/sign_up_form.dart';
import 'package:flutter_leopard_demo/examples/login/widgets/snackbar.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final FocusNode focusNodePassword = FocusNode();
  final FocusNode focusNodeConfirmPassword = FocusNode();
  final FocusNode focusNodeEmail = FocusNode();
  final FocusNode focusNodeName = FocusNode();

  bool _obscureTextPassword = true;
  bool _obscureTextConfirmPassword = true;

  final TextEditingController signupEmailController = TextEditingController();
  final TextEditingController signupNameController = TextEditingController();
  final TextEditingController signupPasswordController = TextEditingController();
  final TextEditingController signupConfirmPasswordController =
      TextEditingController();

  @override
  void dispose() {
    focusNodePassword.dispose();
    focusNodeConfirmPassword.dispose();
    focusNodeEmail.dispose();
    focusNodeName.dispose();
    signupEmailController.dispose();
    signupNameController.dispose();
    signupPasswordController.dispose();
    signupConfirmPasswordController.dispose();
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
              SignUpForm(
                focusNodeName: focusNodeName,
                focusNodeEmail: focusNodeEmail,
                focusNodePassword: focusNodePassword,
                focusNodeConfirmPassword: focusNodeConfirmPassword,
                signupNameController: signupNameController,
                signupEmailController: signupEmailController,
                signupPasswordController: signupPasswordController,
                signupConfirmPasswordController:
                    signupConfirmPasswordController,
                obscureTextPassword: _obscureTextPassword,
                obscureTextConfirmPassword: _obscureTextConfirmPassword,
                togglePasswordVisibility: _toggleSignup,
                toggleConfirmPasswordVisibility: _toggleSignupConfirm,
                onSubmit: _toggleSignUpButton,
              ),
              SignUpButton(onPressed: _toggleSignUpButton),
            ],
          ),
        ],
      ),
    );
  }

  void _toggleSignUpButton() {
    CustomSnackBar(context, const Text('SignUp button pressed'));
  }

  void _toggleSignup() {
    setState(() {
      _obscureTextPassword = !_obscureTextPassword;
    });
  }

  void _toggleSignupConfirm() {
    setState(() {
      _obscureTextConfirmPassword = !_obscureTextConfirmPassword;
    });
  }
}
