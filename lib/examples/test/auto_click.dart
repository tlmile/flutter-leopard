import 'package:flutter/material.dart';

import 'new_pipeline_page.dart';

void main() {
  runApp(const AutoClickApp());
}

class AutoClickApp extends StatelessWidget {
  const AutoClickApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AuthClick',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5B86E5),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF050816),
        fontFamily: 'SF Pro',
      ),
      home: const AuthClickHomePage(),
    );
  }
}

class AuthClickHomePage extends StatefulWidget {
  const AuthClickHomePage({super.key});

  @override
  State<AuthClickHomePage> createState() => _AuthClickHomePageState();
}

class _AuthClickHomePageState extends State<AuthClickHomePage> {
  final List<ClickPipeline> _pipelines = [
    ClickPipeline(
      name: '抖音自动点赞流水线',
      description: '随机 1–2 秒点击红心，间隔上滑下一条，循环 3 轮。',
      modeLabel: '循环 3 轮',
      pointCount: 2,
      isRunning: false,
    ),
    ClickPipeline(
      name: '日常签到脚本',
      description: '进入 app → 点击签到 → 返回首页。',
      modeLabel: '每日一次',
      pointCount: 3,
      isRunning: true,
    ),
    ClickPipeline(
      name: '压测点按脚本',
      description: '固定频率 500ms 点击同一位置，用于压力测试。',
      modeLabel: '无限循环',
      pointCount: 1,
      isRunning: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Stack(
        children: [
          // 顶部渐变背景
          Container(
            height: 260,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF5B86E5),
                  Color(0xFF36D1DC),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // 顶部栏
                Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    children: [
                      // App 标题
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AuthClick',
                            style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '自动点击 · 流水线 · 后台运行',
                            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      // 小状态标签
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.greenAccent,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '服务就绪',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium!
                                  .copyWith(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // 顶部统计卡片
                Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  child: _buildSummaryCard(colorScheme),
                ),

                const SizedBox(height: 8),

                // 列表标题
                Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  child: Row(
                    children: [
                      Text(
                        '我的流水线',
                        style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${_pipelines.length} 个脚本',
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 4),

                // 流水线列表
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ListView.separated(
                      padding: const EdgeInsets.only(bottom: 90, top: 4),
                      itemCount: _pipelines.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final pipeline = _pipelines[index];
                        return _buildPipelineCard(pipeline, index);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFab(),
    );
  }

  Widget _buildSummaryCard(ColorScheme colorScheme) {
    final runningCount = _pipelines.where((p) => p.isRunning).length;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1020).withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 18,
            offset: Offset(0, 10),
          )
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
        ),
      ),
      child: Row(
        children: [
          // 左侧图标圆圈
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF5B86E5),
                  Color(0xFF36D1DC),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.blueAccent.withOpacity(0.5),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.touch_app_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(width: 16),
          // 中间统计信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '今日自动点击中心',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.92),
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '正在运行 $runningCount 个流水线 · 长按脚本可更多操作',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // 小统计块
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$runningCount',
                style: const TextStyle(
                  color: Colors.greenAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              Text(
                '运行中',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPipelineCard(ClickPipeline pipeline, int index) {
    final isRunning = pipeline.isRunning;

    return GestureDetector(
      onTap: () {
        // TODO: 这里将来可以跳转到流水线详情页
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('将来这里进入「${pipeline.name}」详情页'),
          ),
        );
      },
      onLongPress: () {
        // TODO: 长按操作（编辑 / 删除 / 复制）
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF15192A),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.white.withOpacity(0.06),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.55),
              blurRadius: 14,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding:
          const EdgeInsets.only(left: 14, right: 14, top: 12, bottom: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 标题 + 状态
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      color: Colors.white.withOpacity(0.04),
                    ),
                    child: Text(
                      '#${index + 1}',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      pipeline.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildStatusChip(isRunning),
                ],
              ),

              const SizedBox(height: 6),

              // 描述
              Text(
                pipeline.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 10),

              // 底部行：点位信息 + 模式 + 按钮
              Row(
                children: [
                  // 左侧小信息
                  Row(
                    children: [
                      Icon(
                        Icons.graphic_eq_rounded,
                        size: 16,
                        color: Colors.blueAccent.withOpacity(0.9),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${pipeline.pointCount} 个点击点',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    Icons.repeat_rounded,
                    size: 15,
                    color: Colors.purpleAccent.withOpacity(0.9),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    pipeline.modeLabel,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                    ),
                  ),
                  const Spacer(),
                  // 右侧按钮
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      backgroundColor: isRunning
                          ? Colors.white.withOpacity(0.06)
                          : Colors.blueAccent.withOpacity(0.18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        _pipelines[index] =
                            pipeline.copyWith(isRunning: !pipeline.isRunning);
                      });
                    },
                    icon: Icon(
                      isRunning
                          ? Icons.stop_rounded
                          : Icons.play_arrow_rounded,
                      size: 18,
                      color: isRunning ? Colors.redAccent : Colors.blueAccent,
                    ),
                    label: Text(
                      isRunning ? '停止' : '启动',
                      style: TextStyle(
                        color: isRunning
                            ? Colors.redAccent
                            : Colors.blueAccent.shade100,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(bool isRunning) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: isRunning
            ? Colors.greenAccent.withOpacity(0.16)
            : Colors.white.withOpacity(0.04),
      ),
      child: Row(
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isRunning ? Colors.greenAccent : Colors.white24,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            isRunning ? '运行中' : '已停止',
            style: TextStyle(
              color: isRunning ? Colors.greenAccent : Colors.white60,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFab() {
    return FloatingActionButton.extended(
      onPressed: () {
        // 跳转到新建流水线页面
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NewPipelinePage()),
        );
      },
      icon: const Icon(Icons.add_rounded),
      label: const Text('新建流水线'),
    );
  }

}

class ClickPipeline {
  final String name;
  final String description;
  final String modeLabel;
  final int pointCount;
  final bool isRunning;

  ClickPipeline({
    required this.name,
    required this.description,
    required this.modeLabel,
    required this.pointCount,
    required this.isRunning,
  });

  ClickPipeline copyWith({
    String? name,
    String? description,
    String? modeLabel,
    int? pointCount,
    bool? isRunning,
  }) {
    return ClickPipeline(
      name: name ?? this.name,
      description: description ?? this.description,
      modeLabel: modeLabel ?? this.modeLabel,
      pointCount: pointCount ?? this.pointCount,
      isRunning: isRunning ?? this.isRunning,
    );
  }
}
