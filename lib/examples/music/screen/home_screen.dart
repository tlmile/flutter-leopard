import 'package:flutter/material.dart';
import 'package:flutter_leopard_demo/examples/music/screen/common/todo_screen.dart';

import '../service/mpd_remote_service.dart';
import '../service/settings.dart';
import 'FavouriteTracksScreen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // 页面跳转方法
  void _openFavouriteTracks(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        //页面路由
        builder: (_) => const FavouriteTracksScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //页面相当于房子 scaffold相当于页面的框架
      backgroundColor: Colors.black,
      body: Padding(
        //body 为页面内容区域。padding 包裹其他组件并添加内边距的Widget
        padding: const EdgeInsets.symmetric(horizontal: 16),
        //左右各加 16 像素的内边距（padding） symmetric表示对称
        child: Column(
          //竖直方向排列子组件 (一列)
          crossAxisAlignment: CrossAxisAlignment.start, //列 内容左对齐
          children: [
            const SizedBox(height: 80), //SizedBox 占位组件，表示80的空白间距
            const Text(
              'Home',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'FAVORITES',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              //网络布局 按固定列数排列的网络布局
              crossAxisCount: 2,
              //每行 2列
              shrinkWrap: true,
              //高度自适应，因为gridview会尝试占满整个页面的高度，这里表示：你只占用你真正需要的高度
              physics: const NeverScrollableScrollPhysics(),
              //禁止GridView自己滚动，gridview黑夜是可滚动的
              mainAxisSpacing: 16,
              //行与行之间的垂直间距
              crossAxisSpacing: 16,
              //列与列之间的水平间距
              children: [
                FavouriteTracksCard(onTap: () => _openFavouriteTracks(context)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

///卡片组件
///一个看起来像卡片（小矩形块）的 UI 区域，里面放一个功能、内容或入口
///例如：
///[扫一扫] [收付款]
// [卡包]   [更多]
class FavouriteTracksCard extends StatelessWidget {
  //final 字段必须在构造函数初始化。不要用 late，应该加 required 构造参数。
  // VoidCallback 的常见使用场景
  // 场景	示例
  // 按钮点击	onPressed: () {}
  // InkWell 点击	onTap: () {}
  // 自定义卡片点击	你现在用的
  // 列表项点击	onTap: () {}
  // 事件触发	子组件通知父组件执行某事
  // 基本所有“点击、触发、回调”的地方都会用 VoidCallback。
  final VoidCallback onTap; //一个无参数，也不返回任何东西的回调函数
  const FavouriteTracksCard({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      //带点击水波纹效果的“可点击组件”
      onTap: onTap, //就是前面提供的页面跳转方法
      borderRadius: BorderRadius.circular(12), //把你的卡片的四个角变圆
      child: Ink(
        decoration: BoxDecoration(
          color: const Color(Settings.primaryColor),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
            padding: const EdgeInsets.all(16), //上下左右内边都是16
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,//垂直方向水平居中
              children: [
                ValueListenableBuilder(
                    valueListenable: MpdRemoteService.instance.favoriteSongList,
                    builder: (context,value,child) {
                      return Text(
                        value.length.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                ),
                const Text(
                  'Tracks',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
        ),
      ),
    );
  }
}
