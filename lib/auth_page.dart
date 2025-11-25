import 'package:flutter/material.dart';

enum AuthMode { login, signup }

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  AuthMode _mode = AuthMode.login;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  Widget _buildSegmentedControl() {
    final isLogin = _mode == AuthMode.login;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _mode = AuthMode.login),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isLogin ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(28),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Existing',
                  style: TextStyle(
                    color: isLogin ? Colors.orange : Colors.white.withOpacity(0.8),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _mode = AuthMode.signup),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isLogin ? Colors.transparent : Colors.white,
                  borderRadius: BorderRadius.circular(28),
                ),
                alignment: Alignment.center,
                child: Text(
                  'New',
                  style: TextStyle(
                    color: isLogin ? Colors.white.withOpacity(0.8) : Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.grey[700]),
      suffixIcon: suffix,
      border: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
      focusedBorder:
          const UnderlineInputBorder(borderSide: BorderSide(color: Colors.deepOrange)),
    );
  }

  Widget _buildLoginFields() {
    return Column(
      children: [
        TextField(
          decoration: _inputDecoration(label: 'Email Address', icon: Icons.mail_outline),
        ),
        const SizedBox(height: 16),
        TextField(
          obscureText: _obscurePassword,
          decoration: _inputDecoration(
            label: 'Password',
            icon: Icons.lock_outline,
            suffix: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey[700],
              ),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignupFields() {
    return Column(
      children: [
        TextField(
          decoration: _inputDecoration(label: 'Name', icon: Icons.person_outline),
        ),
        const SizedBox(height: 16),
        TextField(
          decoration: _inputDecoration(label: 'Email Address', icon: Icons.mail_outline),
        ),
        const SizedBox(height: 16),
        TextField(
          obscureText: _obscurePassword,
          decoration: _inputDecoration(
            label: 'Password',
            icon: Icons.lock_outline,
            suffix: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey[700],
              ),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          obscureText: _obscureConfirm,
          decoration: _inputDecoration(
            label: 'Confirmation',
            icon: Icons.lock_outline,
            suffix: IconButton(
              icon: Icon(
                _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey[700],
              ),
              onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton() {
    final isLogin = _mode == AuthMode.login;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFFFF8C3B), Color(0xFFFF5E8A)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        onPressed: () {},
        child: Text(
          isLogin ? 'LOGIN' : 'SIGN UP',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildSocialButtons() {
    Widget _socialButton(IconData icon) {
      return Container(
        width: 56,
        height: 56,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.grey[800]),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _socialButton(Icons.facebook),
        const SizedBox(width: 24),
        _socialButton(Icons.g_translate),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLogin = _mode == AuthMode.login;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFF8C3B), Color(0xFFFF5E8A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 24),
                  Center(
                    child: Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Center(child: Text('Illustration')),
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildSegmentedControl(),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        isLogin ? _buildLoginFields() : _buildSignupFields(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildActionButton(),
                  if (isLogin) ...[
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    children: const [
                      Expanded(
                        child: Divider(
                          color: Colors.white54,
                          thickness: 1,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'Or',
                          style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: Colors.white54,
                          thickness: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildSocialButtons(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
