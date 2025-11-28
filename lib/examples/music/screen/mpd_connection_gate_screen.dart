import 'package:flutter_leopard_demo/examples/music/screen/main_screen.dart';
import 'package:flutter_leopard_demo/examples/music/service/mpd_remote_service.dart';
import 'package:flutter_leopard_demo/examples/music/widgets/connecting_state_widget.dart';
import 'package:flutter_leopard_demo/examples/music/widgets/connection_dialog.dart';
import 'package:flutter_leopard_demo/examples/music/widgets/error_overlay_widget.dart';
import 'package:flutter_leopard_demo/examples/music/widgets/idle_state_widget.dart';
import 'package:flutter_leopard_demo/examples/music/widgets/loading_state_widget.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_leopard_demo/examples/music/screen/main_screen.dart';
import 'package:flutter_leopard_demo/examples/music/service/mpd_remote_service.dart';
import 'package:flutter_leopard_demo/examples/music/widgets/connecting_state_widget.dart';
import 'package:flutter_leopard_demo/examples/music/widgets/connection_dialog.dart';
import 'package:flutter_leopard_demo/examples/music/widgets/error_overlay_widget.dart';
import 'package:flutter_leopard_demo/examples/music/widgets/idle_state_widget.dart';
import 'package:flutter_leopard_demo/examples/music/widgets/loading_state_widget.dart';

/// 页面所处的阶段：初始化 / 空闲 / 连接中
enum _ConnectionPhase {
  initializing,
  idle,
  connecting,
}

/// First screen users see; it restores saved MPD settings and handles the
/// connection flow before handing off to the main application.
class MpdConnectionGateScreen extends StatefulWidget {
  const MpdConnectionGateScreen({super.key});

  @override
  State<MpdConnectionGateScreen> createState() =>
      _MpdConnectionGateScreenState();
}

class _MpdConnectionGateScreenState extends State<MpdConnectionGateScreen>
    with TickerProviderStateMixin {
  static const _prefsHostKey = 'mpd_ip';
  static const _prefsPortKey = 'mpd_port';
  static const _defaultPort = 6600;

  final TextEditingController _ipController = TextEditingController();
  final TextEditingController _portController =
  TextEditingController(text: '$_defaultPort');
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  _ConnectionPhase _phase = _ConnectionPhase.initializing;
  String? _errorMessage;

  late final AnimationController _pulseController;
  late final AnimationController _errorController;
  late final AnimationController _loadingController;

  bool get _isInitializing => _phase == _ConnectionPhase.initializing;
  bool get _isConnecting => _phase == _ConnectionPhase.connecting;
  bool get _hasError => _errorMessage != null && _errorMessage!.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeAndConnect();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _errorController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _loadingController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(); // 初始化阶段先转起来
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _errorController.dispose();
    _loadingController.dispose();
    _ipController.dispose();
    _portController.dispose();
    super.dispose();
  }

  Future<void> _initializeAndConnect() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedIp = prefs.getString(_prefsHostKey);
      final savedPort = prefs.getInt(_prefsPortKey);

      if (!mounted) return;

      if (savedIp != null &&
          savedIp.isNotEmpty &&
          savedPort != null &&
          savedPort > 0) {
        await _attemptAutoConnect(savedIp, savedPort);
      } else {
        _enterIdleStateAndShowDialog();
      }
    } catch (e, stack) {
      debugPrint('Failed to load MPD settings: $e\n$stack');
      if (!mounted) return;
      _enterIdleStateAndShowDialog();
    }
  }

  void _enterIdleStateAndShowDialog() {
    setState(() {
      _phase = _ConnectionPhase.idle;
      _loadingController.stop();
    });

    // 稍微延迟一下，避免界面一闪而过（UX 考量）
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      _showConnectionDialog();
    });
  }

  Future<void> _attemptAutoConnect(String ip, int port) async {
    setState(() {
      _ipController.text = ip;
      _portController.text = port.toString();
      _phase = _ConnectionPhase.connecting;
      _loadingController.stop();
      _pulseController.repeat(reverse: true);
      _errorMessage = null;
    });

    try {
      await MpdRemoteService.instance.initialize(host: ip, port: port);
      if (!mounted) return;
      _navigateToMainScreen();
    } catch (e) {
      if (!mounted) return;
      _handleConnectionError(e);
    }
  }

  Future<void> _attemptConnection() async {
    if (!_formKey.currentState!.validate()) return;

    final host = _ipController.text.trim();
    final portText = _portController.text.trim();
    final port = int.tryParse(portText);

    if (port == null || port < 1 || port > 65535) {
      _showError('Please enter a valid port number (1-65535)');
      return;
    }

    setState(() {
      _phase = _ConnectionPhase.connecting;
      _errorMessage = null;
      _pulseController.repeat(reverse: true);
    });

    try {
      await _saveConnectionSettings(host, port);
      await MpdRemoteService.instance.initialize(host: host, port: port);
      if (!mounted) return;
      _navigateToMainScreen();
    } catch (e) {
      if (!mounted) return;
      _handleConnectionError(e);
    }
  }

  Future<void> _saveConnectionSettings(String host, int port) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsHostKey, host);
      await prefs.setInt(_prefsPortKey, port);
    } catch (e, stack) {
      // 配置保存失败不阻止连接，只做日志记录
      debugPrint('Failed to save MPD settings: $e\n$stack');
    }
  }

  void _handleConnectionError(Object error) {
    final host = MpdRemoteService.instance.host;
    final port = MpdRemoteService.instance.port;
    final target = host != null && port != null ? ' ($host:$port)' : '';
    debugPrint('MPD connection failed$target: $error');

    setState(() {
      _phase = _ConnectionPhase.idle;
      _pulseController.stop();
      _errorMessage = _buildErrorMessage(error);
    });

    _errorController
      ..reset()
      ..forward();
  }

  void _showError(String message) {
    setState(() {
      _phase = _ConnectionPhase.idle;
      _pulseController.stop();
      _errorMessage = message;
    });

    _errorController
      ..reset()
      ..forward();
  }

  String _buildErrorMessage(Object error) {
    // 先按类型分，再 fallback 到字符串匹配
    if (error is SocketException) {
      return 'Network error. Please check your connection settings.';
    }
    if (error is TimeoutException) {
      return 'Connection timed out. Please check your network connection.';
    }

    final errorStr = error.toString();

    if (errorStr.contains('Connection refused')) {
      return 'Connection refused. Please check if MPD is running on the specified address.';
    } else if (errorStr.contains('No route to host')) {
      return 'Cannot reach the host. Please check the IP address and network connectivity.';
    } else if (errorStr.toLowerCase().contains('timeout')) {
      return 'Connection timed out. Please check your network connection.';
    } else {
      return 'Failed to connect to MPD server. Please check your settings and try again.';
    }
  }

  void _showConnectionDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => ConnectionDialog(
        formKey: _formKey,
        ipController: _ipController,
        portController: _portController,
        isConnecting: _isConnecting,
        onConnect: () async {
          Navigator.of(dialogContext).pop();
          await _attemptConnection();
        },
        onCancel: () => Navigator.of(dialogContext).pop(),
      ),
    );
  }

  void _dismissError() {
    setState(() {
      _errorMessage = null;
    });
    _errorController.reset();
  }

  void _navigateToMainScreen() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => const MainScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            if (_isInitializing)
              LoadingStateWidget(animation: _loadingController)
            else if (_isConnecting)
              ConnectingStateWidget(
                animation: _pulseController,
                host: _ipController.text,
                port: _portController.text,
              )
            else
              IdleStateWidget(onConfigurePressed: _showConnectionDialog),

            if (_hasError)
              ErrorOverlayWidget(
                animation: _errorController,
                errorMessage: _errorMessage!,
                onTryAgain: () {
                  _dismissError();
                  _showConnectionDialog();
                },
                onCancel: _dismissError,
              ),
          ],
        ),
      ),
    );
  }
}
