import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter_leopard_demo/examples/login/themes/theme.dart';

/// ●—————○—————○
/// ↑ 这个泡泡会跟着滑动
/// 跟随pageview滑动的气泡指示器

class BubbleIndicatorPainter extends CustomPainter {
  BubbleIndicatorPainter({
    required this.pageController,
    this.dxTarget = 125.0,
    this.dxEntry = 25.0,
    this.radius = 21.0,
    this.dy = 25.0,
  }) : super(repaint: pageController) {
    //构造执行前，先调用父类CustomPainter的构造函数，只要pageController 变化，重绘我
    painter =
        Paint() //级联操作符 表示创建对象后修改属性后，再执行painter=***操作
          ..color = CustomTheme.White
          ..style = PaintingStyle.fill;
  }

  late final Paint painter;

  //分别表示：气泡最终移动到的位置，气泡的开始位置，气泡左右两端两个半圆的半径，气泡整体的纵向位置y坐标
  //   entry          target
  //   ↓               ↓
  // ( ●———————○ )
  //     \_______/
  final double dxTarget, dxEntry, radius, dy;
  final PageController
  pageController; //pageview的监听器+控制器，pageview是flutter中用来做左右滑动翻页的组件

  @override
  void paint(Canvas canvas, Size size) {
    final ScrollPosition pos = pageController.position;
    //最大可滑动距离 - 最左侧位置(一般是0) + 屏幕宽度
    final double fullExtent =
        pos.maxScrollExtent - pos.minScrollExtent + pos.viewportDimension;
    //已经滑动的距离/全部内容的总长度 得到百分比
    final double pageOffset = pos.extentBefore / fullExtent;
    //起点在左，目标在右 =》 从左往右移动
    final bool left2right = dxEntry < dxTarget;
    // 如果left2right = true（从左往右）
    //
    // entry  = 起点 dxEntry
    // target = 终点 dxTarget
    final Offset entry = Offset(left2right ? dxEntry : dxTarget, dy);
    final Offset target = Offset(left2right ? dxTarget : dxEntry, dy);

    final Path path = Path();
    //entry点为中心，从正下方开始画，顺时针180度，画的是半圆
    path.addArc(
      Rect.fromCircle(center: entry, radius: radius),
      0.5 * pi,
      1 * pi,
    );
    //画矩形
    // top = dy - radius
    // ↓
    // +--------------+
    // |              |
    // |   矩形部分   |
    // |              |
    // +--------------+
    // ↑
    // bottom = dy + radius
    //
    // left = entry.dx
    // right = target.dx

    path.addRect(Rect.fromLTRB(entry.dx, dy - radius, target.dx, dy + radius));
    path.addArc(
      Rect.fromCircle(center: target, radius: radius),
      1.5 * pi,
      1 * pi,
    );

    canvas.translate(size.width * pageOffset, 0.0);
    // canvas.drawShadow(
    //     path,                         // 要产生阴影的形状
    //     CustomTheme.loginGradientStart, // 阴影颜色
    //     3.0,                          // 阴影模糊半径（越大越模糊）
    //     true                          // 是否透明（true=更真实的阴影）
    // );

    canvas.drawShadow(path, CustomTheme.loginGradientStart, 3.0, true);
    canvas.drawPath(path, painter);
  }

  @override
  //告诉flutter 每次都要重绘这个bubble指示器
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
