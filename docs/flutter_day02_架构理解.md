
---

## 一、`main.dart` 代码示例

```dart
import 'package:flutter/material.dart';

/// 程序入口：Dart/Flutter 一定从 main() 开始执行
void main() {
  // runApp 会创建 Widget 树的根节点，并挂到屏幕上
  runApp(const LeopardApp());
}

/// 整个 App 的根 Widget：
/// - 所有页面、控件都挂在它下面
/// - 提供主题 / 路由 / 首页面 等全局配置
class LeopardApp extends StatelessWidget {
  const LeopardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // 右上角是否显示 “DEBUG” 角标（开发阶段可以开，发布一般关掉）
      debugShowCheckedModeBanner: true,
      // App 标题：Android 最近任务列表、Web 浏览器 Tab 使用
      title: 'Leopard Demo',
      // 全局主题：颜色、字体、组件样式等
      theme: ThemeData(
        colorSchemeSeed: Colors.deepPurple, // 主题主色种子（Material3）
        useMaterial3: true,                 // 使用 Material Design 3
        // 全局输入框样式：所有 TextField / TextFormField 默认都有外边框
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      // App 首次打开时展示的页面
      home: const HomePage(),
    );
  }
}

/// 从 HomePage 开始，可以一点点练习搭界面。
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leopard 学习页'),
      ),
      body: const Center(
        child: Text(
          '这里是一个空页面。\n从这里开始一点点加控件吧～',
          textAlign: TextAlign.center,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: 以后可以在这里加点击逻辑，比如 setState 计数
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// Widget 架构调用链：
///
/// main()
///  └─ runApp(LeopardApp)
///       └─ LeopardApp.build()
///            └─ return MaterialApp
///                  └─ home: HomePage
///                        └─ HomePage.build() -> Scaffold -> ...
///
```

---

## 二、架构理解：从 `main` 到 `HomePage`

> **High-level idea：**
> 一个 Flutter App 本质上是一棵巨大的 Widget 树。
> `main()` 负责启动，`runApp()` 把根 Widget 挂到屏幕上，`MaterialApp` + `HomePage` 构成了 UI 的根部结构。

### 2.1 调用链结构

根据上面的代码，可以画出如下调用链：

```text
main()
 └─ runApp(const LeopardApp())
      └─ LeopardApp.build()
           └─ return MaterialApp(
                home: const HomePage(),
              )
                 └─ HomePage.build()
                      └─ return Scaffold(
                           appBar: AppBar(...)
                           body: Center(
                             child: Text(...)
                           )
                           floatingActionButton: FloatingActionButton(...)
                         )
```

* `main()`：程序入口。
* `runApp()`：告诉 Flutter “从这个根 Widget 开始渲染整个界面”。
* `LeopardApp`：**根 Widget**，负责整个 App 的：

    * 主题（`theme`）
    * 路由系统（后续可以添加 `routes`）
    * 首页面（`home`）
* `HomePage`：实际展示的“第一页”界面。
* `Scaffold`：一个典型的页面框架（带 `AppBar`、`body`、`FloatingActionButton` 等）。

---

## 三、Widget / Element / Render 三棵树关系

> **核心总结：**
> Flutter UI 有三层结构：
>
> * Widget：描述
> * Element：桥梁（管理节点）
> * RenderObject：真正负责布局和绘制

### 3.1 三者分别是什么？

#### 3.1.1 Widget Tree（部件树）

* **你写的就是 Widget。**
* 例如：`MaterialApp` / `HomePage` / `Scaffold` / `AppBar` / `Text` / `Icon` 等。
* 特点：

    * 轻量、不可变（immutable）。
    * 只负责“描述 UI 长什么样”和“配置参数”。
    * 每次 `build()` 执行时，实际上是创建了一批新的 Widget 对象。

#### 3.1.2 Element Tree（元素树）

* **框架内部使用，看不到，但非常重要。**
* 每个 Widget 会对应一个 Element，例如：

    * `StatelessWidget` → `StatelessElement`
    * `StatefulWidget` → `StatefulElement`
* 职责：

    * 把 Widget 挂到正确的位置上，维护树结构。
    * 持有 Widget、以及（如果有）对应的 State 引用。
    * 决定 Widget 更新时，是否复用下面的 RenderObject。

可以理解为：

> **Element 是“管理节点”和“调度中心”。**

#### 3.1.3 RenderObject Tree（渲染树）

* 真正负责：

    * 布局（layout）
    * 绘制（paint）
    * 命中测试（hit test，点击检测）
* 例如：

    * `RenderView`（根）
    * `RenderFlex`（`Column` / `Row` 背后）
    * `RenderParagraph`（`Text` 背后）
* 持有 size、位置信息、绘制逻辑，是最终在 GPU 上真正“画东西”的那一层。

---

### 3.2 用当前代码举例：三棵树大致长什么样？

#### 3.2.1 Widget 树（你写出来的这层）

```text
LeopardApp (StatelessWidget)
 └─ MaterialApp
     └─ HomePage (StatelessWidget)
         └─ Scaffold
             ├─ AppBar
             │   └─ Text('Leopard 学习页')
             ├─ Center
             │   └─ Text('这里是一个空页面...')
             └─ FloatingActionButton
                 └─ Icon(Icons.add)
```

#### 3.2.2 Element 树（框架内部维护）

大致对应为：

```text
StatelessElement (LeopardApp)
 └─ StatefulElement / StatelessElement (MaterialApp)
     └─ StatelessElement (HomePage)
         └─ StatefulElement (Scaffold)
             ├─ StatefulElement (AppBar)
             │   └─ StatelessElement (Text)
             ├─ StatelessElement (Center)
             │   └─ StatelessElement (Text)
             └─ StatefulElement (FloatingActionButton)
                 └─ StatelessElement (Icon)
```

> 注意：`MaterialApp` / `Scaffold` / `AppBar` / `FloatingActionButton` 内部自己可能是 Stateful，因此对应 `StatefulElement`。

#### 3.2.3 RenderObject 树（真实布局与绘制）

大致对应为：

```text
RenderView
 └─ RenderFlex / RenderBox (Scaffold 的根布局)
     ├─ RenderFlex (AppBar 内部)
     │   └─ RenderParagraph (标题 Text)
     ├─ RenderPositionedBox / RenderParagraph (Center + Text)
     └─ RenderPhysicalShape / RenderBox (FloatingActionButton + Icon)
```

---

### 3.3 为什么要了解三棵树？有什么实际意义？

1. **理解 `setState` 只会局部重建**

    * 当某个 `StatefulWidget` 调用 `setState()` 时：

        * 它下面那一小棵 Widget 子树会重新 `build()`。
        * Element 尽量复用（保证 State 不丢）。
        * RenderObject 尽量只更新属性，而不是整棵 UI 全部重建。
    * 这就是 Flutter 高效的关键之一。

2. **理解性能优化方向**

    * StatelessWidget 多没关系，Widget 本身非常轻量。
    * 真正需要注意的是：

        * 不要频繁创建复杂、昂贵的 RenderObject。
        * 避免过度深层嵌套导致布局复杂度太高。

3. **理解 Key 的作用（后续 ListView / 动画中很重要）**

    * Key 本质上是辅助 Element 树在重建时，正确“匹配”对应的 Widget / State。
    * 尤其在列表中插入 / 删除 / 重新排序时非常重要。

> **一句话记忆：**
> Widget 是“长相描述”，Element 是“树的骨架和管理者”，RenderObject 是“干活的工人”。

---

## 四、Stateless 与 Stateful 本质区别

> **核心问题：可变状态（会变化的数据）存在哪里，由谁管理？**

### 4.1 StatelessWidget：没有内部可变状态的 UI 描述

在当前代码里：

```dart
class LeopardApp extends StatelessWidget { ... }

class HomePage extends StatelessWidget { ... }
```

这两个都是 **StatelessWidget**。

**特点：**

* 接收外部参数（构造函数里的 `final` 字段）。
* 所有 UI 只由 **当前参数 + 上下文（如 Theme）** 决定。
* 内部不会“记住一个会变的值”，本身是不可变的。
* 要更新界面，只能靠父级重新创建它，从外部传入新数据。

**典型适用场景：**

* 纯展示页面（静态内容）。
* UI 完全依赖父组件传入的数据。
* 不需要自己维护计数器、表单输入、动画状态、Tab 状态等“随时间变化的状态”。

---

### 4.2 StatefulWidget：把“可变状态”交给 State 对象管理

如果你想让右下角的 `FloatingActionButton` 点击后数字 +1，就需要 `StatefulWidget` 了，例如：

```dart
class CounterFab extends StatefulWidget {
  const CounterFab({super.key});

  @override
  State<CounterFab> createState() => _CounterFabState();
}

class _CounterFabState extends State<CounterFab> {
  int _count = 0; // 可变状态，保存在 State 中

  void _increment() {
    setState(() {
      _count++; // 修改状态
    });
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: _increment,
      child: Text('$_count'),
    );
  }
}
```

在 `HomePage` 中使用：

```dart
floatingActionButton: const CounterFab(),
```

**这里发生了什么？**

* `CounterFab`（StatefulWidget）本身基本上只是一个壳 + 配置：

    * 核心职责是：实现 `createState()`，创建对应的 State。
* 真正保存可变数据的是 `_CounterFabState`：

    * `_count` 在这里。
    * `setState()` 在这里。
    * `build()` 也在这里。
* 每次调用 `setState()`：

    * Flutter 会重新调用 `_CounterFabState.build()`，重新构建这一小块子树。
    * 但 `_CounterFabState` 实例本身被复用，不会丢失 `_count` 的历史值。

---

### 4.3 Stateless vs Stateful：本质对比

| 对比项            | StatelessWidget    | StatefulWidget + State     |
| -------------- | ------------------ | -------------------------- |
| 是否有内部可变状态      | ❌ 没有               | ✅ 有（状态保存在 State 对象中）       |
| 数据存放位置         | 构造函数参数 / 父组件传入     | `State` 对象中的字段             |
| UI 是否会随时间变化    | 只能靠父组件重建整棵 Subtree | 自己内部可以通过 `setState()` 局部重建 |
| `build()` 调用次数 | 可被多次调用             | 同样可多次调用，但 State 持续存在       |
| 典型使用场景         | 静态 UI、展示型组件        | 计数器、表单输入、动画、Tab 切换等        |

> 当前的 `HomePage` 是 Stateless 完全没问题，等你需要“状态变化”（比如点击计数、Tab 切换）时再改为 Stateful 即可。

---

## 五、State 生命周期：`init → build → dispose`

> **一句话：**
> State 被创建一次，可以 build 很多次，最终在从树上移除时会被 `dispose` 掉。

下面用一个典型例子说明：

```dart
class TimerDemo extends StatefulWidget {
  const TimerDemo({super.key});

  @override
  State<TimerDemo> createState() => _TimerDemoState();
}

class _TimerDemoState extends State<TimerDemo> {
  late int _count;

  @override
  void initState() {
    super.initState();
    // 只在 State 第一次创建时调用一次
    _count = 0;
    print('initState');
  }

  @override
  Widget build(BuildContext context) {
    print('build: count = $_count');
    return Scaffold(
      appBar: AppBar(title: const Text('State 生命周期示例')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            setState(() {
              _count++;
            });
          },
          child: Text('点击：$_count'),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // 在 State 从树上永久移除前调用一次
    print('dispose');
    super.dispose();
  }
}
```

你可以临时把 `home: const HomePage()` 改成：

```dart
home: const TimerDemo(),
```

然后运行，看控制台打印的生命周期顺序。

---

### 5.1 生命周期时间线（简化版）

```text
createState()
   ↓
initState()       // 只调用一次：做初始化
   ↓
build()           // 可以调用很多次：渲染 UI
   ↓
setState() -> build()
   ↓
... 重复 ...
   ↓
dispose()         // 最后一次：释放资源
```

---

### 5.2 三个关键阶段：做什么 / 不该做什么

#### ① `initState()`

> *Called exactly once when the State object is first created.*

**适合做：**

* 初始化变量。
* 创建 `AnimationController`、`TabController` 等。
* 创建 `TextEditingController`。
* 订阅 Stream、启动 Timer 等。

**不适合做：**

* 复杂依赖 BuildContext 的逻辑（某些情况推荐挪到 `didChangeDependencies()`）。

**示例：**

```dart
@override
void initState() {
  super.initState();
  _controller = TextEditingController();
}
```

---

#### ② `build()`

> *Called many times. Must be fast and pure (no side effects).*

**适合：**

* 根据当前 State 构建 UI：

    * 读取字段、条件判断、拼 Widget 树。

**不适合：**

* 做耗时操作（网络请求、复杂计算）。
* 在 `build` 中创建一次性对象却不缓存（比如 AnimationController）。
* 在 `build` 中调用 `setState()`（会造成死循环）。

> 你当前所有 Stateless 的 `build()`，本质就是：
> “根据当前数据 → 返回一棵 Widget 子树”。

---

#### ③ `dispose()`

> *Called once when this State object will never build again.*

**适合：**

* 释放各种资源：

    * `controller.dispose()`
    * `scrollController.dispose()`
    * `subscription.cancel()`
    * `timer.cancel()`

**不要做：**

* 再调用 `setState()`（组件已经要销毁，不允许再触发重建）。

**示例：**

```dart
@override
void dispose() {
  _controller.dispose();
  super.dispose();
}
```

---

### 5.3 再和三棵树串一下关系

* **State 对象是挂在 Element 树上的**（`StatefulElement`）。
* Widget 每次 `build` 都可能是新实例（不可变描述）。
* RenderObject 尽量被复用，只更新需要改变的属性。
* 生命周期管理的是：
  **State 在 Element 树里的创建 → 使用 → 销毁。**

---
