import 'package:flutter/material.dart';

/// Flutter 启动入口：Widget 树的根节点从这里开始
void main() {
  // runApp 会创建一个 Widget 树，并由框架为每个 Widget 创建对应的 Element（Element Tree）
  // Element 再创建/持有 RenderObject（RenderObject Tree）完成布局、绘制等工作。
  runApp(const TeachingDemoApp());
}

/// StatelessWidget：不可变，仅由构造参数决定 UI。
/// 这是一个 Widget 层的节点：它本身不直接持有渲染能力，而是描述 UI 结构。
class TeachingDemoApp extends StatelessWidget {
  const TeachingDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter 三棵树 + 生命周期 Demo',
      theme: ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true),
      // MaterialApp 也是 Widget 层，框架会为它创建一个 ComponentElement。
      // ComponentElement 里会在需要渲染的地方创建 RenderObject。
      home: const TreeAndLifecyclePage(),
    );
  }
}

/// 这个页面用于演示 Widget / Element / RenderObject 三层关系
/// 同时放置 Stateless 与 Stateful 的示例。
class TreeAndLifecyclePage extends StatelessWidget {
  const TreeAndLifecyclePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Scaffold、AppBar、Column 等都是 Widget，它们描述 UI 结构（Widget Tree）。
    // Flutter 框架会基于这些 Widget 创建对应的 Element（如 StatelessElement、StatefulElement）。
    // 一些 Widget（如 Text、RenderObjectWidget 的子类）会在对应的 Element 中创建 RenderObject，
    // RenderObject 负责布局、绘制、命中测试（RenderObject Tree）。
    return Scaffold(
      appBar: AppBar(
        title: const Text('三棵树 + 生命周期 Demo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              _TreeExplainer(),
              SizedBox(height: 16),
              Divider(),
              SizedBox(height: 16),
              _StatelessSection(),
              SizedBox(height: 16),
              _StatefulSection(),
              SizedBox(height: 16),
              Divider(),
              SizedBox(height: 16),
              _LayoutShowcase(),
            ],
          ),
        ),
      ),
    );
  }
}

/// 解释三棵树关系的静态说明 Widget（Stateless：无状态，仅依赖构造参数）。
class _TreeExplainer extends StatelessWidget {
  const _TreeExplainer();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Widget / Element / RenderObject 三棵树',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text(
          '• Widget 树：声明式 UI。这里的每个类（如 Text、Column）都是 Widget，描述“想要的界面”。\n'
          '• Element 树：Widget 的实例树。每个 Widget 创建自己的 Element（StatelessElement/StatefulElement等），\n'
          '  负责管理 Widget 的生命周期和与 RenderObject 的桥接。\n'
          '• RenderObject 树：真正执行布局、绘制、命中测试。RenderObjectWidget（如 Text、Container、RenderObjectWidget 自己）\n'
          '  会在对应 Element 中创建/持有 RenderObject。Element 会把 RenderObject 连接成树并触发布局/绘制。',
        ),
      ],
    );
  }
}

/// Stateless 示例：不可变，无内部状态，UI 只依赖构造参数。
class _StatelessSection extends StatelessWidget {
  const _StatelessSection();

  @override
  Widget build(BuildContext context) {
    // StatelessWidget -> 创建 StatelessElement（Element Tree 中的节点）
    // StatelessElement 不会创建 RenderObject；需要渲染的子 Widget（如 Text）是 RenderObjectWidget，
    // 它们的 Element（LeafRenderObjectElement 等）会创建 RenderObject 并挂到 RenderObject Tree。
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'StatelessWidget 示例',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text('特性：不可变、无内部状态，UI 仅由构造参数决定。'),
          SizedBox(height: 8),
          Text('本 Widget 的 Element 类型为 StatelessElement，不会持有自己的 RenderObject，'
              '但子 Widget（例如 Text）是 RenderObjectWidget，会创建 RenderObject 用于布局/绘制。'),
        ],
      ),
    );
  }
}

/// Stateful 示例：有独立的 State 对象，State 可以通过 setState 更新，触发重新 build。
class _StatefulSection extends StatefulWidget {
  const _StatefulSection();

  @override
  State<_StatefulSection> createState() => _StatefulSectionState();
}

class _StatefulSectionState extends State<_StatefulSection> {
  static const _maxEventCount = 50;

  final ValueNotifier<List<_LifecycleEvent>> _eventLog =
      ValueNotifier<List<_LifecycleEvent>>(<_LifecycleEvent>[]);

  bool _showLifecycleCard = true;
  int _version = 1;

  @override
  void dispose() {
    _eventLog.dispose();
    super.dispose();
  }

  void _recordEvent(
    String label, {
    required Color color,
    required IconData icon,
  }) {
    final List<_LifecycleEvent> updated = List<_LifecycleEvent>.from(
      _eventLog.value,
    )
      ..add(
        _LifecycleEvent(
          label: label,
          color: color,
          icon: icon,
          timestamp: DateTime.now(),
        ),
      );

    if (updated.length > _maxEventCount) {
      updated.removeRange(0, updated.length - _maxEventCount);
    }

    _eventLog.value = updated;
  }

  void _clearEventLog() {
    _eventLog.value = <_LifecycleEvent>[];
  }

  void _rebuildChild() {
    setState(() {
      _version++;
    });
    _recordEvent(
      '父组件 setState（version $_version）：触发子组件 didUpdateWidget + build',
      color: Colors.teal,
      icon: Icons.refresh,
    );
  }

  void _toggleChild() {
    setState(() {
      _showLifecycleCard = !_showLifecycleCard;
    });
    _recordEvent(
      _showLifecycleCard ? '重新挂载组件：会重新走 initState' : '卸载组件：触发 deactivate -> dispose',
      color: _showLifecycleCard ? Colors.indigo : Colors.red,
      icon: _showLifecycleCard ? Icons.play_circle : Icons.stop_circle,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'StatefulWidget 生命周期演示',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            '通过挂载/卸载、父组件 setState、子组件内部 setState，多角度观察 initState → build → dispose 等生命周期。',
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              _LifecycleStageChip(label: 'initState', color: Colors.indigo),
              _LifecycleStageChip(label: 'didChangeDependencies', color: Colors.deepPurple),
              _LifecycleStageChip(label: 'build', color: Colors.blue),
              _LifecycleStageChip(label: 'didUpdateWidget', color: Colors.teal),
              _LifecycleStageChip(label: 'setState → build', color: Colors.orange),
              _LifecycleStageChip(label: 'deactivate', color: Colors.grey),
              _LifecycleStageChip(label: 'dispose', color: Colors.red),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: _rebuildChild,
                icon: const Icon(Icons.refresh),
                label: const Text('父组件 setState（+1 版本）'),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: _toggleChild,
                icon: Icon(_showLifecycleCard ? Icons.visibility_off : Icons.visibility),
                label: Text(_showLifecycleCard ? '卸载子组件 (dispose)' : '重新挂载 (initState)'),
              ),
              const SizedBox(width: 12),
              TextButton(
                onPressed: _clearEventLog,
                child: const Text('清空日志'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: _showLifecycleCard
                ? _LifecycleDemoCard(
                    key: ValueKey<int>(_version),
                    version: _version,
                    onEvent: _recordEvent,
                  )
                : const _LifecyclePlaceholder(),
          ),
          const SizedBox(height: 12),
          _LifecycleEventPanel(eventLog: _eventLog),
        ],
      ),
    );
  }
}

class _LifecycleDemoCard extends StatefulWidget {
  const _LifecycleDemoCard({
    super.key,
    required this.version,
    required this.onEvent,
  });

  final int version;
  final void Function(String label, {required Color color, required IconData icon})
      onEvent;

  @override
  State<_LifecycleDemoCard> createState() => _LifecycleDemoCardState();
}

class _LifecycleDemoCardState extends State<_LifecycleDemoCard> {
  int _counter = 0;

  void _log(String text, Color color, IconData icon) {
    widget.onEvent(text, color: color, icon: icon);
  }

  @override
  void initState() {
    super.initState();
    _log('initState：State 被创建并插入树', Colors.indigo, Icons.play_arrow);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _log('didChangeDependencies：首次或依赖变化时触发', Colors.deepPurple, Icons.link);
  }

  @override
  void didUpdateWidget(covariant _LifecycleDemoCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.version != widget.version) {
      _log('didUpdateWidget：父组件传入 version ${widget.version}', Colors.teal, Icons.system_update_alt);
    }
  }

  @override
  void deactivate() {
    _log('deactivate：暂时从树中移除', Colors.grey, Icons.pause_circle);
    super.deactivate();
  }

  @override
  void dispose() {
    _log('dispose：永久移除，释放资源', Colors.red, Icons.stop_circle);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _log('build：根据当前状态构建 UI（version ${widget.version}）', Colors.blue, Icons.architecture);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.science, color: Colors.green.shade700),
              const SizedBox(width: 8),
              Text(
                '子组件版本：${widget.version}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(Icons.memory, size: 16, color: Colors.orange.shade700),
                    const SizedBox(width: 4),
                    Text('State 存活计数：$_counter'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            '点击按钮模拟 setState：会触发 build，并在事件面板看到日志。',
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _counter++;
                    _log('setState：计数 +1（$_counter）', Colors.orange, Icons.add);
                  });
                },
                icon: const Icon(Icons.add),
                label: const Text('子组件 setState'),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _counter = 0;
                    _log('setState：计数归零', Colors.orange, Icons.restart_alt);
                  });
                },
                icon: const Icon(Icons.refresh),
                label: const Text('重置计数'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LifecycleEventPanel extends StatelessWidget {
  const _LifecycleEventPanel({required this.eventLog});

  final ValueNotifier<List<_LifecycleEvent>> eventLog;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.timeline, color: Colors.blue.shade700),
              const SizedBox(width: 6),
              const Text(
                '生命周期事件面板',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              const Text('init → build → dispose 全流程'),
            ],
          ),
          const SizedBox(height: 8),
          ValueListenableBuilder<List<_LifecycleEvent>>(
            valueListenable: eventLog,
            builder: (context, events, _) {
              if (events.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: const [
                      Icon(Icons.info_outline, color: Colors.grey),
                      SizedBox(width: 6),
                      Text('暂无事件，请点击上方按钮或切换挂载状态。'),
                    ],
                  ),
                );
              }

              final List<_LifecycleEvent> reversed = events.reversed.toList();
              return Column(
                children: [
                  for (final _LifecycleEvent event in reversed)
                    _LifecycleEventTile(event: event),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _LifecycleEventTile extends StatelessWidget {
  const _LifecycleEventTile({required this.event});

  final _LifecycleEvent event;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: event.color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(event.icon, size: 18, color: event.color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.label,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  event.formattedTime,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LifecyclePlaceholder extends StatelessWidget {
  const _LifecyclePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.25)),
      ),
      child: Row(
        children: const [
          Icon(Icons.visibility_off, color: Colors.grey),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              '子组件已卸载，生命周期将停止在 dispose。点击上方“重新挂载”重新体验 init → build → dispose。',
            ),
          ),
        ],
      ),
    );
  }
}

class _LifecycleStageChip extends StatelessWidget {
  const _LifecycleStageChip({
    required this.label,
    required this.color,
  });

  final String label;
  final MaterialColor color;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      backgroundColor: color.withOpacity(0.08),
      labelStyle: TextStyle(color: color.shade700),
      avatar: CircleAvatar(
        backgroundColor: color,
        child: const Icon(Icons.bolt, size: 14, color: Colors.white),
      ),
    );
  }
}

class _LifecycleEvent {
  const _LifecycleEvent({
    required this.label,
    required this.color,
    required this.icon,
    required this.timestamp,
  });

  final String label;
  final Color color;
  final IconData icon;
  final DateTime timestamp;

  String get formattedTime {
    final DateTime local = timestamp.toLocal();
    final String twoDigits(int value) => value.toString().padLeft(2, '0');
    final String hours = twoDigits(local.hour);
    final String minutes = twoDigits(local.minute);
    final String seconds = twoDigits(local.second);
    return '$hours:$minutes:$seconds';
  }
}

/// 三种常见布局方式的对比展示：Flex / Stack / LayoutBuilder。
class _LayoutShowcase extends StatelessWidget {
  const _LayoutShowcase();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '布局示例：Flex、Stack、LayoutBuilder',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        const Text(
          '下面的三个卡片分别展示了：\n'
          '1) Flex（Row）的 Expanded / Flexible 以及父约束对主轴的影响；\n'
          '2) Stack 叠层布局，并使用 Positioned 控制绝对/相对偏移；\n'
          '3) LayoutBuilder 自适应布局，根据最大宽度切换横排/竖排。',
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: const [
            _FlexCard(),
            _StackCard(),
            _LayoutBuilderCard(),
          ],
        ),
      ],
    );
  }
}

class _FlexCard extends StatelessWidget {
  const _FlexCard();

  @override
  Widget build(BuildContext context) {
    return _ShowcaseCard(
      title: 'Flex：Expanded / Flexible / 约束',
      description:
          '主轴空间由父组件（下方的灰色容器）给出。Expanded 会强制填满剩余主轴空间，Flexible 可以按 flex 比例占据但允许子控件自定义尺寸。',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: const [
                Expanded(
                  child: _FlexBox(
                    label: 'Expanded\n(flex=2)',
                    color: Colors.blue,
                    flex: 2,
                  ),
                ),
                SizedBox(width: 8),
                Flexible(
                  flex: 1,
                  child: _FlexBox(
                    label: 'Flexible\n(flex=1)',
                    color: Colors.teal,
                    flex: 1,
                  ),
                ),
                SizedBox(width: 8),
                Flexible(
                  flex: 2,
                  child: _FlexBox(
                    label: 'Flexible\n(flex=2)\n可换行文本',
                    color: Colors.orange,
                    flex: 2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '提示：Row/Column 的主轴尺寸受父级约束，Expanded 会拉伸充满剩余空间；Flexible 则在剩余空间内按比例分配，但允许内部根据内容自适应高度/宽度。',
          ),
        ],
      ),
    );
  }
}

class _StackCard extends StatelessWidget {
  const _StackCard();

  @override
  Widget build(BuildContext context) {
    return _ShowcaseCard(
      title: 'Stack：叠层 + Positioned',
      description: 'Stack 允许子组件按照声明顺序层叠；Positioned 可用于绝对或相对定位。未定位的子组件默认放在左上角。',
      child: SizedBox(
        width: 320,
        height: 180,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const Positioned(
              left: 16,
              top: 16,
              child: _StackBadge(label: '左上角'),
            ),
            const Positioned(
              right: 16,
              bottom: 16,
              child: _StackBadge(label: '右下角'),
            ),
            Positioned(
              left: 60,
              top: 50,
              child: Transform.rotate(
                angle: -0.1,
                child: const _StackBadge(label: '旋转贴纸'),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withOpacity(0.12),
                      blurRadius: 10,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.layers, color: Colors.purple),
                    SizedBox(height: 6),
                    Text('Stack 叠层'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LayoutBuilderCard extends StatelessWidget {
  const _LayoutBuilderCard();

  @override
  Widget build(BuildContext context) {
    return _ShowcaseCard(
      title: 'LayoutBuilder：自适应布局',
      description:
          'LayoutBuilder 在 build 时会把父组件的约束（BoxConstraints）传入 builder，便于根据最大宽度/高度切换不同布局。',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool isWide = constraints.maxWidth > 400;
          final Widget info = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isWide ? Icons.desktop_mac : Icons.phone_android,
                color: isWide ? Colors.green : Colors.blue,
              ),
              const SizedBox(width: 8),
              Text('maxWidth: ${constraints.maxWidth.toStringAsFixed(0)}'),
            ],
          );

          return AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Flex(
              direction: isWide ? Axis.horizontal : Axis.vertical,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment:
                  isWide ? CrossAxisAlignment.center : CrossAxisAlignment.stretch,
              children: [
                Flexible(
                  child: _AdaptiveTile(
                    color: Colors.green.shade100,
                    label: '宽屏模式：横向排列\n窄屏模式：纵向堆叠',
                  ),
                ),
                const SizedBox(width: 12, height: 12),
                Flexible(
                  child: _AdaptiveTile(
                    color: Colors.blue.shade100,
                    label: '使用 LayoutBuilder 的 builder 获取约束',
                  ),
                ),
                const SizedBox(width: 12, height: 12),
                Flexible(
                  child: _AdaptiveTile(
                    color: Colors.orange.shade100,
                    label: '当前：${isWide ? '横向 Flex' : '纵向 Flex'}',
                    trailing: info,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ShowcaseCard extends StatelessWidget {
  const _ShowcaseCard({
    required this.title,
    required this.description,
    required this.child,
  });

  final String title;
  final String description;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 520),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.view_quilt, color: Colors.blue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(description),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _FlexBox extends StatelessWidget {
  const _FlexBox({
    required this.label,
    required this.color,
    required this.flex,
  });

  final String label;
  final Color color;
  final int flex;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Icon(Icons.crop_16_9, color: color),
          const SizedBox(height: 6),
          Text(label, textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text('flex=$flex', style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

class _StackBadge extends StatelessWidget {
  const _StackBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.purple.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple.shade200),
      ),
      child: Text(
        label,
        style: TextStyle(color: Colors.purple.shade700),
      ),
    );
  }
}

class _AdaptiveTile extends StatelessWidget {
  const _AdaptiveTile({
    required this.color,
    required this.label,
    this.trailing,
  });

  final Color color;
  final String label;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          if (trailing != null) ...[
            const SizedBox(height: 8),
            trailing!,
          ],
        ],
      ),
    );
  }
}
