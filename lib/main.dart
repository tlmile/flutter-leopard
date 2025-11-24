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
          ],
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
  int _counter = 0;

  // initState：State 被插入到 Element 树时调用，一次性初始化。此时可以订阅、初始化控制器等。
  @override
  void initState() {
    super.initState();
    debugPrint('initState：State 被创建并插入 Element 树时调用');
  }

  // didChangeDependencies：依赖的 InheritedWidget 发生变化或首次 build 前调用。
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    debugPrint('didChangeDependencies：依赖的上下文/InheritedWidget 变化时调用');
  }

  // build：根据当前状态构建 Widget 树。每次 setState 之后都会重新执行。
  @override
  Widget build(BuildContext context) {
    debugPrint('build：根据当前状态构建 Widget');

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
            'StatefulWidget 示例',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('特性：有独立的 State 对象，通过 setState 修改状态并触发重新 build。'),
          const SizedBox(height: 8),
          Text('计数：$_counter'),
          const SizedBox(height: 12),
          Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    // setState 会标记此 State 所在的 Element 需要重新构建；
                    // 重新 build 时会创建新的 Widget，并在需要时更新 RenderObject。
                    _counter++;
                  });
                },
                child: const Text('setState 触发重新 build'),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () {
                  // 触发更新父级的 StatefulWidget（模拟 didUpdateWidget 调用），
                  // 实际运行中可以在热重载或父 Widget 传参变化时观察日志。
                  setState(() {
                    _counter = 0;
                  });
                },
                child: const Text('重置计数'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text('生命周期顺序常见为：initState -> didChangeDependencies -> build -> '
              '（setState -> build） -> deactivate -> dispose'),
        ],
      ),
    );
  }

  // didUpdateWidget：当父 Widget 重新 build 且配置发生变化时调用，用于响应新旧 Widget 差异。
  @override
  void didUpdateWidget(covariant _StatefulSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    debugPrint('didUpdateWidget：父 Widget 触发重建，新的 Widget 配置传入时调用');
  }

  // deactivate：当 State 从树中暂时移除时调用（例如重排、导航离开但尚未销毁）。
  @override
  void deactivate() {
    debugPrint('deactivate：State 从 Element 树暂时移除');
    super.deactivate();
  }

  // dispose：当 State 永久移除时调用，用于释放资源、取消订阅。
  @override
  void dispose() {
    debugPrint('dispose：State 永久移除，释放资源');
    super.dispose();
  }
}
