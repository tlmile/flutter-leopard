# Day04 – Login Module Notes（入门）

本篇文档带你从零了解 **flutter-leopard** 登录模块的页面结构、常用组件、基础状态管理，以及为什么要进行组件化重构。内容以新手友好的方式讲解，便于对照代码快速上手。

---

## A. UI 结构（从外到内）
1. **Column**：纵向堆叠整体内容，让背景、标题、表单、按钮按顺序排列。
2. **Stack**：在 Column 内部使用 Stack 叠放背景渐变、插画等装饰层，再放置主要卡片区域。
3. **Card**：承载登录表单的容器，提供阴影与圆角，让表单与背景分层。
4. **TextField**：输入框，用于邮箱、密码等输入。
5. **Button**（`MaterialButton` 或 `ElevatedButton`）：触发登录或注册操作。
6. **PageView**：用于在同一屏幕左右切换「Sign In / Sign Up」，保证体验一致。
7. **PageController**：控制 PageView 的当前页面，支持跳页或动画切换，例如点击「注册」按钮时切换到注册页。

**为什么使用 PageView？**
- Sign In 和 Sign Up 的布局类似，放在 PageView 内可复用背景和头部元素。
- 手势左右滑动或按钮触发切换，交互自然。
- PageController 可以在逻辑层控制跳转（如登录后自动回到 Sign In）。

---

## B. Widgets 使用要点
- **TextField**
  - `controller`：读写输入内容，例如 `emailController.text` 获取邮箱。
  - `focusNode`：控制焦点，便于在输入完成后自动跳到下一个字段。
  - `obscureText`：密码输入设为 `true`，隐藏实际字符。
- **MaterialButton / ElevatedButton**
  - 绑定 `onPressed` 执行登录或注册逻辑。
  - 使用 `style` 或 `color`、`shape` 设置主色、圆角和阴影。
- **渐变背景（Gradient）**
  - 常用 `Container` + `BoxDecoration(gradient: LinearGradient(...))` 实现顶部或全屏渐变。
  - 与 Stack 搭配可以让背景与卡片分层。
- **CustomSnackBar**
  - 用于反馈错误或成功信息。调用方式类似 `CustomSnackBar.show(context, '登录成功');`
  - 优点是风格统一，比 `ScaffoldMessenger` 默认样式更贴合整体设计。

---

## C. 简单状态管理
- **为什么用 `setState`**：登录页交互相对简单，使用 StatefulWidget + `setState` 就能满足刷新按钮状态、显示/隐藏密码等需求，无需引入复杂框架。
- **`_obscureTextPassword` 的作用**：布尔值，控制密码 TextField 的 `obscureText`。当用户点击「小眼睛」图标时切换显示/隐藏。
- **FocusNode 的焦点切换**：
  - 为每个 TextField 创建对应的 `FocusNode`。
  - 在 `onFieldSubmitted` 中调用 `FocusScope.of(context).requestFocus(nextFocusNode);` 让光标跳到下一个输入框。
  - 提升输入流畅度，尤其是移动端键盘操作。

---

## D. 重构后的目录结构
原始登录页代码较长、职责混杂，重构后拆分为更清晰的组件：

```
lib/
└── login/
    ├── sign_in/
    │   ├── sign_in.dart
    │   ├── sign_in_form.dart
    │   ├── sign_in_login_button.dart
    │   └── sign_in_forgot_password.dart
    ├── sign_up/  （如有注册页，可放在此处）
    └── widgets/  （通用的小组件，如背景、装饰、输入框包装等）
```

**拆分带来的好处**
- **易维护**：每个文件职责单一，修改登录按钮逻辑时只需打开 `sign_in_login_button.dart`。
- **可读性**：表单、按钮、忘记密码入口分开，初学者可以按功能逐个理解。
- **可复用**：通用组件放在 `widgets/`，方便在注册页或其他表单场景复用。

---

## E. 示例代码片段（可直接套用）

### 1) 切换密码可见性
```dart
bool _obscureTextPassword = true;

Widget _buildPasswordField() {
  return TextField(
    obscureText: _obscureTextPassword,
    decoration: InputDecoration(
      labelText: 'Password',
      suffixIcon: IconButton(
        icon: Icon(_obscureTextPassword ? Icons.visibility_off : Icons.visibility),
        onPressed: () {
          setState(() {
            _obscureTextPassword = !_obscureTextPassword;
          });
        },
      ),
    ),
  );
}
```

### 2) 输入完成后自动聚焦下一个字段
```dart
final emailFocus = FocusNode();
final passwordFocus = FocusNode();

TextField(
  focusNode: emailFocus,
  textInputAction: TextInputAction.next,
  onSubmitted: (_) {
    FocusScope.of(context).requestFocus(passwordFocus);
  },
  decoration: const InputDecoration(labelText: 'Email'),
);

TextField(
  focusNode: passwordFocus,
  decoration: const InputDecoration(labelText: 'Password'),
);
```

### 3) 使用 PageController 切换 Sign In / Sign Up
```dart
final PageController _pageController = PageController(initialPage: 0);

@override
void dispose() {
  _pageController.dispose();
  super.dispose();
}

Widget build(BuildContext context) {
  return Column(
    children: [
      Expanded(
        child: PageView(
          controller: _pageController,
          children: const [
            SignInPage(),
            SignUpPage(),
          ],
        ),
      ),
      ElevatedButton(
        onPressed: () => _pageController.animateToPage(
          1,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        ),
        child: const Text('去注册'),
      ),
    ],
  );
}
```

### 4) 显示 SnackBar 提示
```dart
ElevatedButton(
  onPressed: () {
    CustomSnackBar.show(context, '登录成功');
  },
  child: const Text('Login'),
);
```

---

## 总结
- 先理解 UI 结构（Column/Stack/Card），再熟悉 TextField 和按钮等基础组件。
- 使用 PageView + PageController 管理登录/注册切换，体验更流畅。
- 通过 `setState` 和布尔变量控制简单状态（如密码可见性），用 FocusNode 改善输入体验。
- 组件化拆分让代码更干净，便于学习和维护。
