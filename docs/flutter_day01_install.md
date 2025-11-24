# 📘 Flutter Day 1 · Android 运行环境搭建指南

> **适用平台：macOS**
> **适用场景：仅使用 Android，不涉及 iOS**
> **适用版本：Flutter 3.35.7、Android Studio Narwhal 2025、JDK 17**

---

# 📑 目录

1. 环境版本说明
2. 安装 Flutter SDK
3. 配置 macOS 环境变量
4. 安装并配置 Android Studio
5. Android SDK 自动安装说明
6. Android 开发性能优化（非常关键）
7. Flutter 常用命令
8. 创建 Flutter 项目
9. 启动 Android 模拟器
10. 在模拟器运行你的 Flutter APP
11. 热重载 Hot Reload（必须保持 flutter run 运行）
12. 总结

---

# 🏷 1. 环境版本说明

当前开发环境实际版本如下（与我的电脑保持一致）：

| 组件                 | 版本                                     |
| ------------------ | -------------------------------------- |
| **Flutter SDK**    | 3.35.7                                 |
| **Java JDK**       | 17                                     |
| **Android Studio** | Narwhal 4 Feature Drop · 2025.1.4 RC 2 |
| **Android SDK**    | 36.1.0（含 API 34/33）                    |
| **Gradle**         | 8.12（本地离线版）                            |

---

# 🟦 2. 安装 Flutter SDK（macOS）

## 2.1 下载 Flutter SDK

官方地址：
[https://docs.flutter.dev/get-started/install/macos](https://docs.flutter.dev/get-started/install/macos)

下载稳定版 ZIP：
`flutter_macos_3.35.7-stable.zip`

## 2.2 解压并移动到开发目录

```bash
cd ~/Downloads
unzip flutter_macos_*.zip
mv flutter ~/development
```

推荐目录结构：

```
/Users/****/development/flutter
```

---

# 🟩 3. 配置 macOS 环境变量

编辑 `.zshrc`：

```bash
nano ~/.zshrc
```

添加：

```bash
export PATH="$PATH:$HOME/development/flutter/bin"
```

使其生效：

```bash
source ~/.zshrc
```

检查是否成功：

```bash
flutter --version
```

---

# 🟧 4. 安装 Android Studio（我的实际版本）

下载地址：
[https://developer.android.com/studio](https://developer.android.com/studio)

我当前使用的版本为：

```
Android Studio Narwhal 4 Feature Drop | 2025.1.4 RC 2
```

安装完成后打开即可。

---

# 🟨 5. Android SDK 安装说明（自动安装机制）

> **你无需手动安装所有组件。**
> 因为 Android Studio 第一次启动时已经通过 Setup Wizard 自动安装了以下内容：

* ✔ Android SDK
* ✔ Android SDK Platform（API 34/33）
* ✔ SDK Build-tools
* ✔ SDK Platform-tools
* ✔ Command-line Tools
* ✔ Android Emulator

你之所以没有印象，是因为：

### 👉 这些是 Android Studio **自动安装** 的，而不是需要你手动勾选。

---

# 🟥 6. Android 开发性能优化（强烈推荐）

以下配置会直接提升构建速度、减少错误、让 Flutter 开发更稳定。

---

## 6.1 gradle.properties 优化

路径：

```
android/gradle.properties
```

添加：

```properties
# Gradle 内存优化
org.gradle.jvmargs=-Xmx4G -XX:MaxMetaspaceSize=1G

# 并行 & 守护进程优化
org.gradle.daemon=true
org.gradle.parallel=true
org.gradle.configureondemand=true

# 避免部分缓存引发的构建异常
org.gradle.configuration-cache=false
```

---

## 6.2 国内 Maven 镜像（推荐）

```properties
systemProp.gradle.mavenCentralMirror=https://maven.aliyun.com/repository/central
systemProp.gradle.googleMirror=https://maven.aliyun.com/repository/google
```

---

## 6.3 本地 Gradle 加速（你已经启用，效果极佳）

文件路径：

```
android/gradle/wrapper/gradle-wrapper.properties
```

你的配置如下：

```properties
# remote url
#distributionUrl=https\://services.gradle.org/distributions/gradle-8.12-all.zip

# ali url
#distributionUrl=https\://mirrors.aliyun.com/gradle/distributions/gradle-8.12-all.zip

# local file path (当前使用)
distributionUrl=file:/Users/****/gradle/gradle-8.12-all.zip
```

说明：

✔ 使用本地 Gradle → 构建速度最快
✔ 断网也能构建 → 直播不翻车
✔ 推荐继续保持

---

## 6.4 清理旧 NDK（如遇 NDK 报错）

```bash
rm -rf ~/Library/Android/sdk/ndk/*
```

Android Studio 会自动下载正确版本。

---

## 6.5 模拟器性能优化

```
Tools → Device Manager → (Edit)
```

推荐设置：

* Device：Pixel 6 或 Pixel 7
* Graphics：Hardware - OpenGL
* RAM：≥ 2GB

---

# 🟩 7. Flutter 常用命令（必须掌握）

| 命令                    | 说明     |
| --------------------- | ------ |
| `flutter doctor`      | 查看整体环境 |
| `flutter clean`       | 清理构建缓存 |
| `flutter pub get`     | 拉取依赖   |
| `flutter pub upgrade` | 升级依赖   |
| `flutter run`         | 运行项目   |
| `flutter build apk`   | 构建 APK |
| `flutter devices`     | 查看设备列表 |

### 💡 万能修复三连：

```bash
flutter clean
flutter pub get
flutter run
```

---

# 🟦 8. 创建 Flutter 项目

```bash
flutter create flutter_leopard_demo
cd flutter_leopard_demo
open -a "Android Studio" .
```

---

# 🟪 9. 启动 Android 模拟器（Device Manager）

路径：

```
Tools → Device Manager
```

创建设备：

* Pixel 6 / Pixel 7
* Android 14（API 34）

点击 **▶ RUN** 启动模拟器。

---

# 🟫 10. 在模拟器上运行 Flutter APP

查看设备：

```bash
flutter devices
```

运行：

```bash
flutter run -d emulator-5554
```

首次构建较慢属于正常。

---

# 🟩 11. 热重载 Hot Reload（必须保持 flutter run 运行）

> ❗ **热重载的前提：flutter run 正在运行，不能关闭终端。**

首次运行：

```bash
flutter run -d emulator-5554
```

保持终端不中断（不能 Ctrl+C）。

之后可使用：

* `r` → 热重载（UI 变化立即生效）
* `R` → 热重启（重启 Flutter 引擎）

Android Studio 右上角：

* ⚡ Hot Reload
* 🔁 Hot Restart

---

# 🎉 12. Day 1 环境搭建完成！

现在已经完成：

* Flutter SDK ✔
* Android Studio ✔
* Android SDK ✔
* 模拟器 ✔
* Flutter APP 成功运行 ✔
* Gradle/JDK 加速优化 ✔
* 掌握核心 Flutter 命令 ✔
* 了解热重载使用方法 ✔

目前 Flutter Android 开发环境已经准备就绪！

---

