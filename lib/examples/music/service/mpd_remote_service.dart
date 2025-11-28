import 'dart:async';

import 'package:dart_mpd/dart_mpd.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_leopard_demo/examples/music/service/settings.dart';

/// 连接状态（用于更细粒度的 UI 展示）
enum MpdConnectionState {
  idle,
  connecting,
  connected,
  reconnecting,
  failed,
}

/// MPD 远程服务（单例）
/// - 管理连接 / 自动重连（指数退避）
/// - 监听状态变化（idle）
/// - 暴露当前歌曲 / 播放列表 / 播放进度
class MpdRemoteService with WidgetsBindingObserver {
  // ==========================================
  // SINGLETON PATTERN
  // ==========================================

  MpdRemoteService._();
  static final MpdRemoteService _instance = MpdRemoteService._();
  static MpdRemoteService get instance => _instance;

  // ==========================================
  // PRIVATE FIELDS
  // ==========================================

  // MPD Connection
  MpdClient? _client;
  MpdClient? _statusClient;
  String? _host;
  int? _port;

  // State Management
  bool _isInitialized = false;
  bool _isPolling = false;
  bool _isAppInBackground = false;
  bool _isDisposed = false;

  /// 是否需要在恢复前台时优先尝试重连
  bool _needsReconnectionOnResume = true;

  Timer? _elapsedTimer;
  Timer? _reconnectionTimer;
  AppLifecycleListener? _lifecycleListener;
  Completer<void>? _pollingCancellationCompleter;

  /// 重连次数，用于指数退避
  int _reconnectAttempt = 0;

  /// 最近一次错误（用于调试 / UI 提示）
  Object? _lastError;

  static const int _baseReconnectDelaySeconds = 5;
  static const int _maxReconnectDelaySeconds = 60;

  // ==========================================
  // PUBLIC NOTIFIERS
  // ==========================================

  /// 当前播放的歌曲（无歌 / 断开时为 null）
  final ValueNotifier<MpdSong?> currentSong = ValueNotifier(null);

  /// 是否已连接（简单布尔）
  final ValueNotifier<bool> isConnected = ValueNotifier(false);

  /// 播放器状态（播放 / 暂停）
  final ValueNotifier<bool> isPlaying = ValueNotifier(false);

  /// 当前播放队列
  final ValueNotifier<List<MpdSong>> currentPlaylist = ValueNotifier([]);

  /// 当前歌曲已播放时间
  final ValueNotifier<Duration?> elapsed = ValueNotifier(null);

  /// 收藏歌单
  final ValueNotifier<List<MpdSong>> favoriteSongList = ValueNotifier([]);

  /// 连接状态（更细粒度）
  final ValueNotifier<MpdConnectionState> connectionState =
  ValueNotifier(MpdConnectionState.idle);

  // ==========================================
  // PUBLIC API - GETTERS
  // ==========================================

  /// 是否已初始化
  bool get isInitialized => _isInitialized;

  /// 当前 MPD 主机名
  String? get host => _host;

  /// 当前 MPD 端口
  int? get port => _port;

  /// App 是否在后台
  bool get isAppInBackground => _isAppInBackground;

  /// 是否可以安全使用 _client
  bool get _canUseClient =>
      !_isDisposed &&
          !_isAppInBackground &&
          _isInitialized &&
          _client != null;

  /// 下一次重连延迟（5,10,20,40,60,... 秒）
  Duration get _nextReconnectDelay {
    final seconds = _baseReconnectDelaySeconds * (1 << _reconnectAttempt);
    final clamped =
    seconds > _maxReconnectDelaySeconds ? _maxReconnectDelaySeconds : seconds;
    return Duration(seconds: clamped);
  }

  // ==========================================
  // PUBLIC API - INITIALIZATION
  // ==========================================

  /// 初始化 MPD 服务
  ///
  /// [host] - MPD 主机
  /// [port] - MPD 端口（通常 6600）
  Future<void> initialize({required String host, required int port}) async {
    if (_isInitialized) {
      throw StateError('MpdRemoteService is already initialized');
    }

    _host = host;
    _port = port;
    _isDisposed = false;
    _reconnectAttempt = 0;
    _lastError = null;
    connectionState.value = MpdConnectionState.connecting;

    // Setup lifecycle observers
    _setupLifecycleObservers();

    try {
      await _createClients(host, port);
      await _initializeState();
      _isInitialized = true;

      if (!_isAppInBackground) {
        _startStatusPolling();
      }

      connectionState.value = MpdConnectionState.connected;
      debugPrint('MPD Service initialized successfully ($host:$port)');
    } catch (e) {
      debugPrint('MPD Service initialization failed ($host:$port): $e');
      isConnected.value = false;
      connectionState.value = MpdConnectionState.failed;
      _cleanup();
      rethrow;
    }
  }

  /// 重新连接（使用同一 host/port）
  ///
  /// 通常由内部重连逻辑调用，也可以手动触发
  Future<void> reconnect() async {
    if (_host == null || _port == null) {
      throw StateError('Cannot reconnect: service was never initialized');
    }
    if (_isDisposed) {
      debugPrint('Skip reconnect: service disposed');
      return;
    }

    debugPrint('Reconnecting MPD service...');
    connectionState.value = MpdConnectionState.reconnecting;
    _pauseOperations();

    try {
      await _createClients(_host!, _port!);
      await _initializeState();

      if (!_isAppInBackground && !_isDisposed) {
        _resumeOperations();
      }

      _onReconnectSuccess();
      debugPrint('MPD service reconnected successfully');
    } catch (e) {
      debugPrint('MPD service reconnection failed: $e');
      isConnected.value = false;
      connectionState.value = MpdConnectionState.failed;
      rethrow;
    }
  }

  /// 释放服务（彻底关闭）
  ///
  /// 调用后如需再次使用，需要重新 initialize()
  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;

    // Remove lifecycle observers
    _cleanupLifecycleObservers();

    _isInitialized = false;
    _cleanup();

    // Dispose ValueNotifiers
    currentSong.dispose();
    isConnected.dispose();
    isPlaying.dispose();
    currentPlaylist.dispose();
    elapsed.dispose();
    favoriteSongList.dispose();
    connectionState.dispose();

    debugPrint('MPD Service disposed');
  }

  // ==========================================
  // APP LIFECYCLE HANDLING
  // ==========================================

  void _setupLifecycleObservers() {
    // 优先使用 AppLifecycleListener（Flutter 3.13+）
    try {
      _lifecycleListener = AppLifecycleListener(
        onShow: _handleAppForeground,
        onHide: _handleAppBackground,
        onResume: _handleAppForeground,
        onPause: _handleAppBackground,
        onDetach: _handleAppBackground,
      );
      debugPrint('Using modern AppLifecycleListener');
    } catch (_) {
      // 旧版本 fallback 到 WidgetsBindingObserver
      WidgetsBinding.instance.addObserver(this);
      debugPrint('Using WidgetsBindingObserver fallback');
    }
  }

  void _cleanupLifecycleObservers() {
    _lifecycleListener?.dispose();
    _lifecycleListener = null;

    // 即便没 add 过，removeObserver 也安全
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (_isDisposed) return;

    debugPrint('App lifecycle state changed: $state');

    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        debugPrint('App going to background - pausing MPD operations');
        _handleAppBackground();
        break;

      case AppLifecycleState.resumed:
        debugPrint('App resumed - resuming MPD operations');
        _handleAppForeground();
        break;

      case AppLifecycleState.inactive:
      // 不在 inactive 做切换，这是过渡态
        debugPrint('App inactive - not changing MPD operations');
        break;
    }
  }

  /// App 进入后台
  void _handleAppBackground() {
    if (_isAppInBackground || _isDisposed) return;

    debugPrint('Handling app background');
    _isAppInBackground = true;
    _pauseOperations();
  }

  /// App 回到前台
  void _handleAppForeground() {
    if (!_isAppInBackground || _isDisposed) return;

    debugPrint('Handling app foreground');
    _isAppInBackground = false;

    if (_isInitialized) {
      // 恢复 statusClient（避免旧连接残留）
      _statusClient = MpdClient(
        connectionDetails: MpdConnectionDetails(host: _host!, port: _port!),
      );

      if (_needsReconnectionOnResume) {
        debugPrint('Attempting deferred reconnection on app resume');
        _needsReconnectionOnResume = false;

        // 稍微延迟，确保界面完全恢复
        Timer(const Duration(milliseconds: 1000), () {
          if (!_isAppInBackground && _isInitialized && !_isDisposed) {
            reconnect().catchError((e) {
              debugPrint('Failed to reconnect on app resume: $e');
              _handleConnectionError(e);
            });
          }
        });
      } else {
        _resumeOperations();
      }
    }
  }

  /// 暂停后台操作
  void _pauseOperations() {
    debugPrint('Pausing MPD operations');
    _isPolling = false;
    _stopElapsedTimer();

    _reconnectionTimer?.cancel();
    _reconnectionTimer = null;

    if (_pollingCancellationCompleter != null &&
        !_pollingCancellationCompleter!.isCompleted) {
      _pollingCancellationCompleter!.complete();
    }

    _closeConnections();
  }

  /// 恢复后台操作
  void _resumeOperations() {
    debugPrint('Resuming MPD operations');

    if (_isInitialized && !_isAppInBackground && !_isDisposed) {
      _testConnectionAndResume();
    }
  }

  /// 测试连接，成功则恢复 polling / timer，失败则走重连逻辑
  void _testConnectionAndResume() {
    if (_client == null) {
      debugPrint('Client is null, scheduling reconnection');
      _needsReconnectionOnResume = true;
      _scheduleReconnection();
      return;
    }

    connectionState.value = MpdConnectionState.connecting;

    _client!
        .ping()
        .then((_) {
      debugPrint('Connection test successful, resuming operations');
      isConnected.value = true;
      connectionState.value = MpdConnectionState.connected;
      _startStatusPolling();
      _startElapsedTimer();

      // 恢复后刷新一次状态
      Future.microtask(() async {
        try {
          await refreshPlayerStatus();
          await refreshCurrentSong();
        } catch (e) {
          debugPrint('Failed to refresh state on resume: $e');
        }
      });
    })
        .catchError((e) {
      debugPrint('Connection test failed: $e');
      isConnected.value = false;
      _handleConnectionError(e);
    });
  }

  // ==========================================
  // PUBLIC API - CLIENT ACCESS
  // ==========================================

  /// 主 MPD client（发送命令用）
  MpdClient get client {
    if (!_isInitialized || _client == null) {
      throw StateError(
        'MpdRemoteService not initialized. Call initialize() first.',
      );
    }
    return _client!;
  }

  // ==========================================
  // PUBLIC API - PLAYBACK CONTROL
  // ==========================================

  /// 跳转到指定时间
  Future<void> seekToPosition(Duration position) async {
    if (_client == null) {
      throw StateError('MpdRemoteService not initialized');
    }

    try {
      await _client!.seekcur(position.inSeconds.toString());
      elapsed.value = position; // 立即更新 UI
      debugPrint('Seeked to position: ${position.inSeconds}s');
    } catch (e) {
      debugPrint('Failed to seek to position $position: $e');
      _handleConnectionError(e);
      rethrow;
    }
  }

  /// 相对跳转（正为快进，负为快退）
  Future<void> seekRelative(Duration offset) async {
    if (_client == null) {
      throw StateError('MpdRemoteService not initialized');
    }

    try {
      final currentElapsed = elapsed.value ?? Duration.zero;
      final newPosition = currentElapsed + offset;

      if (newPosition.isNegative) {
        await seekToPosition(Duration.zero);
      } else {
        await seekToPosition(newPosition);
      }
    } catch (e) {
      debugPrint('Failed to seek by relative offset $offset: $e');
      _handleConnectionError(e);
      rethrow;
    }
  }

  // ==========================================
  // PUBLIC API - MANUAL REFRESH
  // ==========================================

  Future<void> refreshPlaylist() async => _updateCurrentPlaylist();

  Future<void> refreshCurrentSong() async => _updateCurrentSong();

  Future<void> refreshPlayerStatus() async => _updatePlayerStatus();

  // ==========================================
  // PRIVATE - INITIALIZATION HELPERS
  // ==========================================

  Future<void> _createClients(String host, int port) async {
    final connectionDetails = MpdConnectionDetails(host: host, port: port);

    _closeConnections();

    _client = MpdClient(connectionDetails: connectionDetails);
    _statusClient = MpdClient(connectionDetails: connectionDetails);
  }

  Future<void> _initializeState() async {
    if (_client == null) return;

    try {
      currentSong.value = await _client!.currentsong();
      isConnected.value = _client!.connection.isConnected;
      await _updatePlayerStatus();
      await _updateCurrentPlaylist();
      await refreshStoredPlaylist();
    } catch (e) {
      final host = _host;
      final port = _port;
      final target = host != null && port != null ? ' ($host:$port)' : '';
      debugPrint('Failed to initialize state$target: $e');
      isConnected.value = false;
      rethrow;
    }
  }

  void _closeConnections() {
    try {
      _statusClient?.connection.close();
      _client?.connection.close();
    } catch (e) {
      debugPrint('Error closing connections: $e');
    }
  }

  // ==========================================
  // PRIVATE - STATUS POLLING
  // ==========================================

  void _startStatusPolling() {
    if (_isPolling || _isAppInBackground || _isDisposed) {
      debugPrint(
        'Not starting polling: isPolling=$_isPolling, isBackground=$_isAppInBackground, disposed=$_isDisposed',
      );
      return;
    }

    if (_statusClient == null) {
      debugPrint('No statusClient, cannot start polling');
      return;
    }

    debugPrint('Starting status polling');
    _isPolling = true;
    _pollingCancellationCompleter = Completer<void>();

    runZonedGuarded(() async {
      await Future.any([
        _statusPollingLoop(),
        _pollingCancellationCompleter!.future,
      ]);
    }, (error, stackTrace) {
      debugPrint('Status polling crashed: $error');
      debugPrint('$stackTrace');
    });
  }

  Future<void> _statusPollingLoop() async {
    debugPrint('Status polling loop started');

    while (_isInitialized &&
        _statusClient != null &&
        _isPolling &&
        !_isAppInBackground &&
        !_isDisposed) {
      try {
        debugPrint('Waiting for MPD idle...');
        final changes = await _statusClient!.idle();

        if (!_isInitialized || !_isPolling || _isAppInBackground || _isDisposed) {
          debugPrint(
            'Breaking polling loop: initialized=$_isInitialized, polling=$_isPolling, '
                'background=$_isAppInBackground, disposed=$_isDisposed',
          );
          break;
        }

        isConnected.value = true;
        connectionState.value = MpdConnectionState.connected;
        await _handleSubsystemChanges(changes);
      } catch (e) {
        debugPrint('MPD polling error: $e');
        isConnected.value = false;
        _handleConnectionError(e);
        break;
      }
    }

    debugPrint('Status polling loop ended');
  }

  Future<void> _handleSubsystemChanges(Set<MpdSubsystem> changes) async {
    for (final change in changes) {
      debugPrint('MPD subsystem changed: $change');

      switch (change) {
        case MpdSubsystem.player:
          await _updateCurrentSong();
          await _updatePlayerStatus();
          break;

        case MpdSubsystem.playlist:
          await _updateCurrentPlaylist();
          break;

        case MpdSubsystem.update:
        case MpdSubsystem.storedPlaylist:
          refreshStoredPlaylist();
          break;

        case MpdSubsystem.database:
        case MpdSubsystem.mixer:
        case MpdSubsystem.output:
        case MpdSubsystem.options:
        case MpdSubsystem.partition:
        case MpdSubsystem.sticker:
        case MpdSubsystem.subscription:
        case MpdSubsystem.message:
        case MpdSubsystem.neighbor:
        case MpdSubsystem.mount:
          debugPrint('MPD subsystem $change changed (not handled)');
          break;
      }
    }
  }

  // ==========================================
  // PRIVATE - STATE UPDATES
  // ==========================================

  /// 统一封装与 MPD 交互（减少重复 try/catch）
  Future<void> _safeClientCall(
      String tag,
      Future<void> Function(MpdClient client) action,
      ) async {
    if (!_canUseClient) return;
    try {
      await action(_client!);
    } catch (e) {
      debugPrint('$tag failed: $e');
      _handleConnectionError(e);
    }
  }

  Future<void> _updateCurrentSong() async {
    await _safeClientCall('Update current song', (c) async {
      currentSong.value = await c.currentsong();
    });
  }

  Future<void> _updateCurrentPlaylist() async {
    await _safeClientCall('Update current playlist', (c) async {
      currentPlaylist.value = await c.playlistid();
    });
  }

  Future<void> _updatePlayerStatus() async {
    await _safeClientCall('Update player status', (c) async {
      final serverStatus = await c.status();
      final wasPlaying = isPlaying.value;

      isPlaying.value = serverStatus.state == MpdState.play;
      elapsed.value = serverStatus.elapsed != null
          ? Duration(
        seconds: serverStatus.elapsed!.toInt(),
        milliseconds: ((serverStatus.elapsed! % 1) * 1000).toInt(),
      )
          : null;

      if (isPlaying.value && !wasPlaying && !_isAppInBackground) {
        _startElapsedTimer();
      } else if (!isPlaying.value && wasPlaying) {
        _stopElapsedTimer();
      }
    });
  }

  Future<void> refreshStoredPlaylist() async {
    if (_client == null) return;
    try {
      favoriteSongList.value = await _client!.listplaylistinfo(
        Settings.defaultFavoritePlaylistName,
      );
    } catch (_) {
      debugPrint(
        "Favorite playlist doesn't exist. It will be created when user adds a song to favorite",
      );
    }
  }

  // ==========================================
  // PRIVATE - ELAPSED TIME MANAGEMENT
  // ==========================================

  /// 播放进度定时器（50ms 一次，足够流畅且省 CPU）
  void _startElapsedTimer() {
    _stopElapsedTimer();
    if (_isAppInBackground || _isDisposed) return;

    int previousTimestamp = DateTime.now().millisecondsSinceEpoch;

    _elapsedTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!isPlaying.value ||
          elapsed.value == null ||
          _isAppInBackground ||
          _isDisposed) {
        _stopElapsedTimer();
        return;
      }

      final currentElapsed = elapsed.value!;
      final songDuration = currentSong.value?.time != null
          ? Duration(seconds: currentSong.value!.time!)
          : null;

      final currentTimestamp = DateTime.now().millisecondsSinceEpoch;
      final timeDifference = currentTimestamp - previousTimestamp;
      previousTimestamp = currentTimestamp;

      final newElapsed =
          currentElapsed + Duration(milliseconds: timeDifference);

      if (songDuration != null && newElapsed >= songDuration) {
        elapsed.value = songDuration;
        _stopElapsedTimer();
      } else {
        elapsed.value = newElapsed;
      }
    });
  }

  void _stopElapsedTimer() {
    _elapsedTimer?.cancel();
    _elapsedTimer = null;
  }

  // ==========================================
  // PRIVATE - CONNECTION MANAGEMENT
  // ==========================================

  void _handleConnectionError(Object error) {
    debugPrint('Handling connection error: $error');

    _lastError = error;

    if (_isAppInBackground || _isDisposed || !_isInitialized) {
      debugPrint('App in background / disposed / not initialized, '
          'deferring or skipping reconnection');
      if (_isAppInBackground) {
        _needsReconnectionOnResume = true;
      }
      return;
    }

    isConnected.value = false;

    // 致命错误直接失败，不再自动重连
    if (_isFatalError(error)) {
      debugPrint('Fatal error detected, will not attempt to reconnect automatically');
      connectionState.value = MpdConnectionState.failed;
      return;
    }

    _reconnectAttempt++;
    connectionState.value = MpdConnectionState.reconnecting;
    _scheduleReconnection();
  }

  /// 简单判断“致命错误”，例如认证 / 密码 / 权限问题
  bool _isFatalError(Object error) {
    final msg = error.toString().toLowerCase();

    if (msg.contains('authentication') ||
        msg.contains('auth') ||
        msg.contains('password') ||
        msg.contains('permission') ||
        msg.contains('denied')) {
      return true;
    }

    // 将来可以在这里根据 MPD 库的具体异常类型扩展：
    // if (error is MpdAuthException) return true; 等
    return false;
  }

  void _scheduleReconnection() {
    if (_isAppInBackground || _isDisposed || !_isInitialized) {
      debugPrint(
        'Not scheduling reconnection: background=$_isAppInBackground, '
            'disposed=$_isDisposed, initialized=$_isInitialized',
      );
      return;
    }

    if (_reconnectionTimer != null) {
      debugPrint('Not scheduling reconnection: timer already exists');
      return;
    }

    final delay = _nextReconnectDelay;
    debugPrint(
      'Scheduling reconnection in ${delay.inSeconds} seconds '
          '(attempt=$_reconnectAttempt)',
    );

    _reconnectionTimer = Timer(delay, () {
      _reconnectionTimer = null;
      if (!_isAppInBackground && _isInitialized && !_isDisposed) {
        _attemptReconnection();
      } else {
        debugPrint(
          'Reconnection timer fired but conditions not met: '
              'background=$_isAppInBackground, initialized=$_isInitialized, disposed=$_isDisposed',
        );
      }
    });
  }

  Future<void> _attemptReconnection() async {
    if (_host == null ||
        _port == null ||
        _isAppInBackground ||
        _isDisposed ||
        !_isInitialized) {
      debugPrint(
        'Cannot attempt reconnection: host=$_host, port=$_port, '
            'background=$_isAppInBackground, disposed=$_isDisposed, initialized=$_isInitialized',
      );
      return;
    }

    try {
      debugPrint('Attempting to reconnect to MPD...');
      await reconnect();
      debugPrint('Successfully reconnected to MPD');
    } catch (e) {
      debugPrint('MPD reconnection failed (attempt=$_reconnectAttempt): $e');
      _scheduleReconnection();
    }
  }

  void _onReconnectSuccess() {
    isConnected.value = true;
    connectionState.value = MpdConnectionState.connected;
    _reconnectAttempt = 0;
    _lastError = null;
  }

  /// 清理内部资源（不释放 ValueNotifier）
  void _cleanup() {
    debugPrint('Cleaning up MPD service resources');
    _isPolling = false;
    _stopElapsedTimer();

    _reconnectionTimer?.cancel();
    _reconnectionTimer = null;

    if (_pollingCancellationCompleter != null &&
        !_pollingCancellationCompleter!.isCompleted) {
      _pollingCancellationCompleter!.complete();
    }
    _pollingCancellationCompleter = null;

    _closeConnections();

    _client = null;
    _statusClient = null;
  }
}
