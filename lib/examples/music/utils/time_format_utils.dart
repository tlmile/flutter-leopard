/// 格式化总秒数为时间字符串。
///
/// - 输入为总秒数（可以是负数，如 -5）
/// - >=1 小时：返回 "HH:MM:SS"
/// - < 1 小时：返回 "MM:SS"
String secondsToTimeString(int totalSeconds) {
  // 处理负数，统一用 Duration 做解析
  final isNegative = totalSeconds < 0;
  final duration = Duration(seconds: totalSeconds.abs());

  final hours = duration.inHours;
  final minutes = duration.inMinutes % 60;
  final seconds = duration.inSeconds % 60;

  final hh = hours.toString().padLeft(2, '0');
  final mm = minutes.toString().padLeft(2, '0');
  final ss = seconds.toString().padLeft(2, '0');

  final core = hours > 0 ? '$hh:$mm:$ss' : '$mm:$ss';
  return isNegative ? '-$core' : core;
}
