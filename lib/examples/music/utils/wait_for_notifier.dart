import 'dart:async';
import 'package:flutter/foundation.dart';

/// 等待一个 [ValueListenable] 满足指定条件后，返回其当前值。
///
/// 典型用途：
/// - 等待某个异步状态就绪，例如：`isConnected == true`
/// - 代替手写 `addListener / removeListener / Completer` 的重复样板代码
///
/// 行为规则：
/// 1. 如果 [condition] 为 `null`：
///    - 表示“等待下一次任意变更”，不关心新值是否满足某个特定条件；
///    - 即：只要 notifier 的值发生一次变化，Future 就会完成。
///
/// 2. 如果 [condition] 不为 `null`：
///    - 调用时会**先检查当前值**：
///      - 若当前值已满足条件，**立即返回一个已完成的 Future**；
///      - 若当前值不满足，则开始监听，直到条件第一次为 true；
///    - 监听过程中，当值每次变化时，会调用 [condition] 检查；
///      - 一旦返回 true，则移除监听并完成 Future。
///
/// 3. [timeout] 可选：
///    - 若指定了超时时间，在此时间内条件始终不满足，则 Future 会抛出 [TimeoutException]；
///    - 超时后会自动移除监听，避免内存泄漏。
///
/// 注意：
/// - 本函数接受的是 [ValueListenable]，因此既兼容 [ValueNotifier]，
///   也兼容其它实现了该接口的状态类型（例如 ValueListenableBuilder 使用的那种）。
Future<T> waitForNotifier<T>(
    ValueListenable<T> notifier, {
      bool Function(T value)? condition,
      Duration? timeout,
    }) {
  // 1. 如果有条件，并且当前值已经满足，则直接同步返回一个已完成的 Future
  //    这样可以避免先 addListener 再立刻 complete 导致的 double-complete 问题。
  if (condition != null && condition(notifier.value)) {
    return Future.value(notifier.value);
  }

  final completer = Completer<T>();
  bool done = false; // 用于防止多次 complete
  Timer? timer;

  late VoidCallback listener;

  /// 安全地完成 Future，并清理监听和超时定时器。
  void completeSafely(T value) {
    if (done) return; // 已经完成过了，直接返回
    done = true;

    notifier.removeListener(listener);
    timer?.cancel();

    if (!completer.isCompleted) {
      completer.complete(value);
    }
  }

  // 监听函数：每次值发生变化时被调用
  listener = () {
    final val = notifier.value;

    // condition == null 表示“只要变更一次就行”
    if (condition == null || condition(val)) {
      completeSafely(val);
    }
  };

  // 2. 添加监听，等待后续变化
  notifier.addListener(listener);

  // 3. 配置可选超时逻辑
  if (timeout != null) {
    timer = Timer(timeout, () {
      if (done) return; // 已经完成，不再处理超时

      done = true;
      notifier.removeListener(listener);

      if (!completer.isCompleted) {
        completer.completeError(
          TimeoutException(
            'waitForNotifier timed out after ${timeout.inMilliseconds} ms',
          ),
        );
      }
    });
  }

  return completer.future;
}

/// 为 [ValueListenable] 提供一些“等待状态变化”的便捷方法。
///
/// 有了这个扩展之后：
/// - 你可以在任意 ValueNotifier / ValueListenable 上直接调用 `.wait()`
/// - 写法更贴近“在等待这个状态”的语义，IDE 也更容易自动提示。
extension ValueListenableWaitExtension<T> on ValueListenable<T> {
  /// 等待当前 [ValueListenable] 满足 [condition] 条件后，返回其当前值。
  ///
  /// 示例：等待连接状态变为 true：
  /// ```dart
  /// await isConnected.wait(condition: (v) => v == true);
  /// ```
  ///
  /// - [condition] 为 null 时：表示“等待下一次任意变更”
  /// - [timeout] 超时时，会抛出 [TimeoutException]
  Future<T> wait({
    bool Function(T value)? condition,
    Duration? timeout,
  }) {
    return waitForNotifier<T>(
      this,
      condition: condition,
      timeout: timeout,
    );
  }

  /// 等待下一次值发生变化（不关心变成什么），然后返回新值。
  ///
  /// 示例：只关心某个 notifier 的下一次变化（比如等 UI 动画结束 / 某个 flag 被改动）：
  /// ```dart
  /// final newValue = await someNotifier.nextChange();
  /// ```
  ///
  /// - [timeout] 超时时，会抛出 [TimeoutException]
  Future<T> nextChange({Duration? timeout}) {
    // 这里不传 condition，表示“下一次变更就返回”
    return waitForNotifier<T>(
      this,
      timeout: timeout,
    );
  }
}
