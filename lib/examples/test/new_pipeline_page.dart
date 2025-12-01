import 'package:flutter/material.dart';
import 'position_picker_page.dart';

/// 流水线步骤数据结构
class PipelineStep {
  Offset? position;      // 通过“选择位置”页面获得
  int count;             // 点击次数
  int intervalMillis;    // 每次点击间隔（毫秒）

  PipelineStep({
    this.position,
    this.count = 1,
    this.intervalMillis = 100,
  });
}

class NewPipelinePage extends StatefulWidget {
  const NewPipelinePage({super.key});

  @override
  State<NewPipelinePage> createState() => _NewPipelinePageState();
}

class _NewPipelinePageState extends State<NewPipelinePage> {
  final TextEditingController _nameController = TextEditingController();
  final List<PipelineStep> _steps = [];

  @override
  void initState() {
    super.initState();
    // 默认先加一个步骤，免得一片空白
    _steps.add(PipelineStep());
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _addStep() {
    setState(() {
      _steps.add(PipelineStep());
    });
  }

  void _removeStep(int index) {
    setState(() {
      _steps.removeAt(index);
    });
  }

  Future<void> _pickPositionForStep(int index) async {
    final offset = await Navigator.push<Offset>(
      context,
      MaterialPageRoute(
        builder: (_) => const PositionPickerPage(),
      ),
    );

    if (offset != null) {
      setState(() {
        _steps[index].position = offset;
      });
    }
  }

  void _savePipeline() {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先输入流水线名称')),
      );
      return;
    }

    if (_steps.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请至少添加一个步骤')),
      );
      return;
    }

    if (_steps.any((s) => s.position == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('有步骤尚未选择点击位置')),
      );
      return;
    }

    // TODO: 在这里保存到本地 / 发送到服务端等
    // 现在先打印一下模拟
    debugPrint('Pipeline name: $name');
    for (var i = 0; i < _steps.length; i++) {
      final step = _steps[i];
      debugPrint(
          'Step $i: pos=${step.position}, count=${step.count}, interval=${step.intervalMillis}ms');
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('流水线已保存（当前是示例打印）')),
    );

    // 也可以直接返回上一页
    // Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('新建流水线'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '流水线名称',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            // 步骤列表
            Expanded(
              child: ListView.builder(
                itemCount: _steps.length,
                itemBuilder: (context, index) {
                  return _buildStepCard(index);
                },
              ),
            ),

            const SizedBox(height: 8),

            // 添加步骤
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: _addStep,
                icon: const Icon(Icons.add),
                label: const Text('添加步骤'),
              ),
            ),

            const SizedBox(height: 8),

            // 保存按钮
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _savePipeline,
                child: const Text('保存流水线'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepCard(int index) {
    final step = _steps[index];

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题 + 删除
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '步骤 ${index + 1}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_steps.length > 1)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => _removeStep(index),
                  ),
              ],
            ),

            const SizedBox(height: 8),

            // 位置 + 选择按钮
            Row(
              children: [
                Expanded(
                  child: Text(
                    step.position == null
                        ? '点击位置：未选择'
                        : '点击位置：(${step.position!.dx.toStringAsFixed(0)}, ${step.position!.dy.toStringAsFixed(0)})',
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _pickPositionForStep(index),
                  icon: const Icon(Icons.my_location),
                  label: const Text('选择位置'),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // 点击次数 + 间隔
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: '点击次数',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      step.count = int.tryParse(value) ?? 1;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: '间隔 (ms)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      step.intervalMillis = int.tryParse(value) ?? 100;
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
