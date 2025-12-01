import 'package:flutter/material.dart';

class PositionPickerPage extends StatefulWidget {
  const PositionPickerPage({super.key});

  @override
  State<PositionPickerPage> createState() => _PositionPickerPageState();
}

class _PositionPickerPageState extends State<PositionPickerPage> {
  Offset? _currentTap;

  // 配置：点击次数、间隔、执行时间（秒）
  int _clickCount = 1;
  int _intervalMs = 100;
  int _durationSeconds = 5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('选择点击位置'),
        actions: [
          TextButton(
            onPressed: () {
              // 这里是“完成”按钮的逻辑
              if (_currentTap == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('请先在屏幕上点一下，选择位置')),
                );
                return;
              }

              // 现在先返回坐标 + 配置，用于上一级页面调试
              Navigator.pop(context, {
                'position': _currentTap,
                'count': _clickCount,
                'intervalMs': _intervalMs,
                'durationSeconds': _durationSeconds,
              });

              // ⚠ 真正要做到“应用退到后台 + 系统级原点悬浮”
              // 需要 Android 原生 + 悬浮窗权限 + 无障碍服务，这里先不做。
            },
            child: const Text(
              '完成',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (details) {
          setState(() {
            _currentTap = details.localPosition;
          });
        },
        child: Stack(
          children: [
            // 背景（现在用浅灰色，你以后可以换成目标界面截图）
            Container(
              color: Colors.grey[200],
            ),

            // 显示选中的点（原点），并且可以点击它弹出配置卡片
            if (_currentTap != null)
              Positioned(
                left: _currentTap!.dx - 16,
                top: _currentTap!.dy - 16,
                child: GestureDetector(
                  onTap: _showConfigSheet, // 点原点，弹出小卡片
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.9),
                      border: Border.all(color: Colors.blue, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.touch_app,
                      size: 18,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ),

            // 底部提示区域
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(12),
                color: Colors.black.withOpacity(0.6),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _currentTap == null
                          ? '轻触屏幕任意位置以选择坐标'
                          : '当前选择：(${_currentTap!.dx.toStringAsFixed(0)}, ${_currentTap!.dy.toStringAsFixed(0)})',
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white),
                            ),
                            onPressed: () {
                              Navigator.pop(context); // 不返回坐标
                            },
                            child: const Text('取消'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _currentTap == null
                                ? null
                                : () {
                              // 这里相当于“快速确认一次”
                              _showConfigSheet();
                            },
                            child: const Text('配置并应用'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 点击原点 / 底部按钮，弹出的配置卡片
  void _showConfigSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        // 为了在 bottomSheet 里也能实时刷新，用 StatefulBuilder
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: StatefulBuilder(
            builder: (context, setSheetState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '自动点击配置',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 点击次数
                  TextField(
                    decoration: const InputDecoration(
                      labelText: '点击次数',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    controller: TextEditingController(
                      text: _clickCount.toString(),
                    ),
                    onChanged: (value) {
                      final v = int.tryParse(value);
                      setSheetState(() {
                        _clickCount = (v == null || v <= 0) ? 1 : v;
                      });
                    },
                  ),
                  const SizedBox(height: 12),

                  // 间隔时间
                  TextField(
                    decoration: const InputDecoration(
                      labelText: '间隔时间 (毫秒)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    controller: TextEditingController(
                      text: _intervalMs.toString(),
                    ),
                    onChanged: (value) {
                      final v = int.tryParse(value);
                      setSheetState(() {
                        _intervalMs = (v == null || v <= 0) ? 100 : v;
                      });
                    },
                  ),
                  const SizedBox(height: 12),

                  // 执行总时长
                  TextField(
                    decoration: const InputDecoration(
                      labelText: '执行时间 (秒)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    controller: TextEditingController(
                      text: _durationSeconds.toString(),
                    ),
                    onChanged: (value) {
                      final v = int.tryParse(value);
                      setSheetState(() {
                        _durationSeconds = (v == null || v <= 0) ? 5 : v;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context); // 关闭卡片
                          },
                          child: const Text('取消'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // 这里先用 debugPrint 模拟“开始自动点击”
                            debugPrint(
                                '开始自动点击：位置=$_currentTap, 次数=$_clickCount, '
                                    '间隔=${_intervalMs}ms, 时长=${_durationSeconds}s');

                            Navigator.pop(context); // 关闭 bottom sheet

                            ScaffoldMessenger.of(this.context).showSnackBar(
                              const SnackBar(
                                content: Text('已应用配置（当前为模拟打印）'),
                              ),
                            );

                            // ⚠ 真正要在其他应用里自动点击，需要：
                            // 1. Android 悬浮窗权限 (SYSTEM_ALERT_WINDOW)
                            // 2. 无障碍服务 (AccessibilityService) 模拟点击
                            // 这些要在原生层写，我们可以后面专门拆一轮聊。
                          },
                          child: const Text('应用'),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
