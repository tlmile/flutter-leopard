import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// 短暂消息提示 组件
class CustomSnackBar {
  CustomSnackBar(
    BuildContext context,
    Widget content, {
    SnackBarAction? snackBarAction,
    Color backgroundColor = Colors.green,
  }) {
    final SnackBar snackBar = SnackBar(
      action: snackBarAction,
      backgroundColor: backgroundColor,
      content: content,
      behavior: SnackBarBehavior.floating,
    );
    ScaffoldMessenger.of(context).hideCurrentSnackBar();//如果当前已经有一个Snackbar正在显示，则把它关闭
    ScaffoldMessenger.of(context).showSnackBar(snackBar);//显示新创建的提示框
  }
}
