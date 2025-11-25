
---

# 📘 Flutter & Dart 快捷键大全（Live Templates）

**适用于：Android Studio / IntelliJ IDEA / VSCode**

> 本文整理 Flutter 开发中最常用、最高频、最省时间的代码模板（Live Templates）。
> 使用方式：输入关键字 → 按 Tab/Enter 自动生成结构代码。

---

# 📑 目录

* [1. Flutter 基础 Widget 模板](#1-flutter-基础-widget-模板)
* [2. Flutter 页面与路由模板](#2-flutter-页面与路由模板)
* [3. Flutter 布局模板（Layout Widgets）](#3-flutter-布局模板layout-widgets)
* [4. Flutter 常用组件模板](#4-flutter-常用组件模板)
* [5. State 生命周期模板](#5-state-生命周期模板)
* [6. Dart 语言基础模板](#6-dart-语言基础模板)
* [7. Dart 流程控制模板](#7-dart-流程控制模板)
* [8. Dart 集合与遍历模板](#8-dart-集合与遍历模板)
* [9. Dart 类/构造函数/方法模板](#9-dart-类构造函数方法模板)
* [10. 异步 async / Future / Stream 模板](#10-异步-async--future--stream-模板)
* [11. 常用工作流模板](#11-常用工作流模板)
* [12. 推荐记住的 20 个核心快捷键](#12-推荐记住的-20-个核心快捷键)

---

# # 1. Flutter 基础 Widget 模板

### ✔ StatefulWidget

`stful`

```dart
class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}
```

---

### ✔ StatelessWidget

`stless`

```dart
class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
```

---

### ✔ StatefulWidget + AnimationController

`stanim`

```dart
class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  Widget build(BuildContext context) => Container();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
```

---

# # 2. Flutter 页面与路由模板

### ✔ MaterialApp

`mateapp`

```dart
return MaterialApp(
  debugShowCheckedModeBanner: false,
  home: Container(),
);
```

---

### ✔ Scaffold

`scaf`

```dart
Scaffold(
  appBar: AppBar(title: const Text('Title')),
  body: Container(),
);
```

---

### ✔ Navigator.push（跳转页面）

`nps`

```dart
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const NextPage()),
);
```

---

### ✔ Navigator.pop（返回上一页）

`npop`

```dart
Navigator.pop(context);
```

---

# # 3. Flutter 布局模板（Layout Widgets）

### ✔ Column

`col`

```dart
Column(
  children: <Widget>[],
)
```

---

### ✔ Row

`row`

```dart
Row(
  children: <Widget>[],
)
```

---

### ✔ Padding

`pad`

```dart
Padding(
  padding: const EdgeInsets.all(8.0),
  child: null,
)
```

---

### ✔ Container

`cont`

```dart
Container(
  child: null,
)
```

---

### ✔ Center

`cent`

```dart
Center(child: null)
```

---

### ✔ SizedBox

`sb`

```dart
const SizedBox();
```

---

# # 4. Flutter 常用组件模板

### ✔ Text

`tex`

```dart
Text(''),
```

---

### ✔ ListView.builder

`lvb`

```dart
ListView.builder(
  itemCount: 0,
  itemBuilder: (context, index) => Container(),
)
```

---

### ✔ FutureBuilder

`fub`

```dart
FutureBuilder(
  future: null,
  builder: (context, snapshot) => Container(),
);
```

---

### ✔ StreamBuilder

`strb`

```dart
StreamBuilder(
  stream: null,
  builder: (context, snapshot) => Container(),
);
```

---

### ✔ MediaQuery 获取屏幕尺寸

`mq`

```dart
MediaQuery.of(context).size;
```

---

# # 5. State 生命周期模板

### ✔ initState

`ini`

```dart
@override
void initState() {
  super.initState();
}
```

---

### ✔ dispose

`dis`

```dart
@override
void dispose() {
  super.dispose();
}
```

---

### ✔ build

`bui`

```dart
@override
Widget build(BuildContext context) => Container();
```

---

# # 6. Dart 语言基础模板

### ✔ class

`cla`

```dart
class MyClass {

}
```

---

### ✔ abstract class

`abcls`

```dart
abstract class MyClass {

}
```

---

### ✔ enum

`enum`

```dart
enum MyEnum {
  a, b,
}
```

---

### ✔ mixin

`mix`

```dart
mixin MyMixin {

}
```

---

# # 7. Dart 流程控制模板

### ✔ if

`if`

```dart
if (condition) {}
```

---

### ✔ if-else

`ife`

```dart
if (condition) {

} else {

}
```

---

### ✔ switch

`sw`

```dart
switch (value) {
  case 1:
    break;
  default:
}
```

---

### ✔ for

`fori`

```dart
for (var i = 0; i < length; i++) {

}
```

---

# # 8. Dart 集合与遍历模板

### ✔ list.forEach

`fore`

```dart
list.forEach((item) {

});
```

---

# # 9. Dart 类/构造函数/方法模板

### ✔ 构造函数（最简）

`cons`

```dart
MyClass(this.value);
```

---

### ✔ 构造函数（完整）

`cst`

```dart
MyClass() {

}
```

---

### ✔ 方法模板

`mth`

```dart
returnType methodName() {

}
```

---

### ✔ Getter

`get`

```dart
get value => _value;
```

---

### ✔ Setter

`set`

```dart
set value(val) => _value = val;
```

---

# # 10. 异步 async / Future / Stream 模板

### ✔ async

`async`

```dart
void method() async {

}
```

---

### ✔ Future

`fut`

```dart
Future<void> method() async {

}
```

---

# # 11. 常用工作流模板

### ✔ main()

`main`

```dart
void main() {
  runApp(const MyApp());
}
```

---

### ✔ try/catch

`tryc`

```dart
try {

} catch (e) {

}
```

---

# # 12. 推荐记住的 20 个核心快捷键

### ⭐ Flutter Widget

`stful` / `stless` / `stanim`

### ⭐ State 生命周期

`ini` / `dis` / `bui`

### ⭐ 布局组件

`scaf` / `col` / `row` / `cont` / `pad` / `tex`

### ⭐ 页面跳转

`nps` / `npop`

### ⭐ 列表与异步

`lvb` / `fub` / `strb`

### ⭐ Dart 基础

`cla` / `enum` / `if` / `fori` / `tryc`

---

