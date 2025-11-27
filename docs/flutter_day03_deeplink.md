# Day03 – Deeplink Basics（入门）

欢迎来到 Deeplink 入门指南！本文用最容易理解的方式告诉你：什么是 Deeplink、在 Flutter 中如何处理、以及在 **flutter-leopard** 项目里能做什么。

---

## A. 什么是 Deeplink？
- **定义**：Deeplink 就是一个链接，点击后不仅能打开应用，还能直接跳到应用内的某个页面或数据。例如在手机浏览器输入 `myapp://product/123`，会尝试直接打开你 App 的商品详情页，而不是先停留在首页。
- **URI Scheme vs. Universal Links**：
  - **自定义 URI Scheme**：使用自定义协议（如 `myapp://`）。实现简单，但如果用户没有安装 App，点击后会提示无法打开链接。
  - **Universal Links / App Links**：使用真实的 HTTPS 地址（如 `https://myapp.com/product/123`）。系统先打开网页，再根据配置跳转到 App。体验更自然，且适配性更好。
- **常见场景示例**：
  - 活动推送：`myapp://promo/spring` 直接跳到活动页。
  - 唤起 App 后定位到具体内容：`myapp://chat/room/42` 打开聊天房间。
  - Web 链接到 App：`https://myapp.com/login` 先打开网页，再转到 App 的登录界面。

---

## B. Deeplink 在 Flutter 中如何工作？
1. **接收链接**：平台层（iOS/Android）捕获传入的链接，再交给 Flutter。
2. **解析链接**：在 Flutter 中读取链接字符串，解析路径与参数。
3. **路由跳转**：使用 `Navigator` 或 `GoRouter` 等导航工具跳转到对应页面。

### 核心 API 简介
- **`onGenerateRoute`**：集中处理路由生成逻辑，便于根据路径动态返回页面。
- **`Navigator`**：Flutter 内置的导航栈，`Navigator.push` / `pop` 控制页面切换。
- **解析传入的链接**：可用 `Uri.parse(link)` 拆解 path、query 参数，然后决定跳转目标。

### 常用 Deeplink 相关包
- [`uni_links`](https://pub.dev/packages/uni_links)：监听传入的 URI Scheme 或 Universal Links，适合简单场景。
- [`firebase_dynamic_links`](https://pub.dev/packages/firebase_dynamic_links)：结合 Firebase 后台生成可跟踪的链接，支持未安装时跳转到商店。

---

## C. 平台基础配置
- **iOS（Info.plist）**：
  - 在 `CFBundleURLTypes` 中声明自定义 Scheme，如 `myapp`。
  - 或在 `Associated Domains` 中配置 Universal Links（形如 `applinks:myapp.com`）。
- **Android（AndroidManifest.xml）**：
  - 在 `intent-filter` 中声明 `<data android:scheme="myapp" />` 来支持自定义 Scheme。
  - 若使用 App Links，则添加 `android:host="myapp.com"` 和 `android:scheme="https"`，并为域名配置 Digital Asset Links。

---

## D. flutter-leopard 中的 Deeplink 使用思路
- **直接跳转到登录页**：当收到登录相关链接（如 `myapp://login`），在启动时解析链接并跳到登录页面，减少用户操作。
- **打开子页面**：若链接包含资源 ID（如 `myapp://product/123`），解析 `123` 并跳转到对应详情页。

### 示例：监听并处理 Deeplink
```dart
// 伪代码示例：在 main.dart 中处理 Deeplink
import 'package:flutter/material.dart';
import 'package:uni_links/uni_links.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? _initialLink;

  @override
  void initState() {
    super.initState();
    _listenDeeplink();
  }

  void _listenDeeplink() async {
    // 获取 App 冷启动时的链接
    _initialLink = await getInitialLink();
    if (_initialLink != null) {
      _handleLink(_initialLink!);
    }

    // 监听运行时的链接
    linkStream.listen((String? link) {
      if (link != null) {
        _handleLink(link);
      }
    });
  }

  void _handleLink(String link) {
    final uri = Uri.parse(link);

    if (uri.pathSegments.isNotEmpty && uri.pathSegments.first == 'login') {
      // 例如 myapp://login?redirect=/profile
      Navigator.of(context).pushNamed('/login', arguments: {
        'redirect': uri.queryParameters['redirect'],
      });
    } else if (uri.pathSegments.length >= 2 && uri.pathSegments.first == 'product') {
      // 例如 myapp://product/123
      final id = uri.pathSegments[1];
      Navigator.of(context).pushNamed('/product', arguments: {'id': id});
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Leopard',
      onGenerateRoute: _onGenerateRoute,
      home: const Placeholder(),
    );
  }
}

Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
  // 根据 settings.name 和 arguments 返回不同页面
  // 示例：/login 或 /product
  return null;
}
```

### 小结
- 先在 iOS/Android 配置 Deeplink，再在 Flutter 中解析并导航。
- 使用 `onGenerateRoute` 集中管理路由，便于按路径分发页面。
- 利用第三方包（`uni_links`、`firebase_dynamic_links`）可以减少平台细节的处理，适合初学者快速上手。
