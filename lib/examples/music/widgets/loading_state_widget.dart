import 'package:flutter/material.dart';

class LoadingStateWidget extends StatelessWidget {
  final AnimationController animation;

  const LoadingStateWidget({super.key, required this.animation});

  @override
  Widget build(BuildContext context) {
    return Center(//Center 组件用于让它的 child 水平 + 垂直居中
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,//垂直剧中
        children: [
          AnimatedBuilder(//监听动画，每帧重建 child，让你可以自定义 UI 动画变化。
            animation: animation,
            builder: (context, child) {
              return Transform.rotate(//旋转效果
                angle: animation.value * 2 * 3.14159,//一整圈
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 2,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.music_note,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          const Text(
            'Initializing...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
