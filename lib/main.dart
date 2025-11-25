import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() {//程序入口
  runApp(const LeopardApp());//启动一个叫LeopardApp的应用
}

//整个APP的根widget 你写的所有页面、控件、按钮、文字 等都必须挂在这个根widget上
// 整个app的大框架、地基
class LeopardApp extends StatelessWidget {
  const LeopardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: true,
      title: 'Leopard Demo', //Android 上：在“最近任务列表”（多任务切换界面）里显示，web浏览器tab上的标题
      theme: ThemeData(
        colorSchemeSeed: Colors.deepPurple,
        useMaterial3: true,//使用material design3风格
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),//为所有的输入框，配置统一样式：都会有外边框
      ),
      home: const HomePage(), // 现在首页就是一个空白模板
    );
  }
}

// main()
// │
// └── runApp(LeopardApp)
//   │
//   └── LeopardApp.build()
//     │
//     └── return MaterialApp
//       │
//       └── home: HomePage

/// 从这里开始你可以一点点练习搭界面
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
          onPressed: () {},
        child: const CounterFab(),
      ),
    );
  }
}

class CounterFab extends StatefulWidget {
  const CounterFab({super.key});

  @override
  State<CounterFab> createState() => _CounterFabState();
}

class _CounterFabState extends State<CounterFab> {
  int _count = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print('Counterfab initstate');
  }

  @override
  Widget build(BuildContext context) {
    // 每次 setState 触发重建时，都会打印这里
    if (kDebugMode) {
      print('CounterFab build, _count = $_count');
    }

    return FloatingActionButton(
      heroTag: null,
      onPressed: () {
        setState(() {
          _count ++;
        });
      },
      child: Text('$_count'),
    );
  }

  @override
  void dispose() {
    if (kDebugMode) {
      print('CounterFab dispose');
    }
    // TODO: implement dispose
    super.dispose();
  }
}
