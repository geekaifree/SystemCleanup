import 'package:flutter/material.dart';
import 'dart:math';

void main() => runApp(const SystemCleanupApp());
class SystemCleanupApp extends StatelessWidget {
  const SystemCleanupApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(title: '系统清理工具', debugShowCheckedModeBanner: false,
    theme: ThemeData(colorSchemeSeed: Colors.green, useMaterial3: true, brightness: Brightness.light),
    darkTheme: ThemeData(colorSchemeSeed: Colors.green, useMaterial3: true, brightness: Brightness.dark),
    home: const CleanupHomePage());
}

class CleanupCategory {
  String name, icon, desc, size;
  bool selected;
  CleanupCategory({required this.name, required this.icon, required this.desc, required this.size, this.selected = true});
}

class CleanupHomePage extends StatefulWidget {
  const CleanupHomePage({super.key});
  @override
  State<CleanupHomePage> setState() => _CleanupHomePageState();
}

class _CleanupHomePageState extends State<CleanupHomePage> {
  final _categories = [
    CleanupCategory(name: '系统缓存', icon: '🗑️', desc: '系统临时文件和缓存', size: '2.3 GB'),
    CleanupCategory(name: '浏览器缓存', icon: '🌐', desc: '浏览器缓存和Cookie', size: '1.8 GB'),
    CleanupCategory(name: '应用缓存', icon: '📱', desc: '应用程序缓存文件', size: '3.1 GB'),
    CleanupCategory(name: '日志文件', icon: '📋', desc: '系统和应用日志', size: '560 MB'),
    CleanupCategory(name: '回收站', icon: '♻️', desc: '已删除的文件', size: '1.2 GB'),
    CleanupCategory(name: '下载文件', icon: '⬇️', desc: '下载目录中的文件', size: '4.5 GB'),
    CleanupCategory(name: 'Windows更新', icon: '🔄', desc: '旧的Windows更新文件', size: '890 MB'),
    CleanupCategory(name: '缩略图缓存', icon: '🖼️', desc: '图片和视频缩略图', size: '320 MB'),
  ];

  bool _scanning = false;
  bool _cleaning = false;
  double _progress = 0;
  String _status = '就绪';

  double get _totalSize {
    double total = 0;
    for (final c in _categories.where((c) => c.selected)) {
      final num = double.parse(c.size.split(' ')[0]);
      total += c.size.contains('GB') ? num : num / 1024;
    }
    return total;
  }

  void _scan() {
    setState(() { _scanning = true; _status = '扫描中...'; });
    Future.delayed(const Duration(seconds: 2), () => setState(() { _scanning = false; _status = '扫描完成'; }));
  }

  void _clean() {
    setState(() { _cleaning = true; _progress = 0; _status = '清理中...'; });
    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 100));
      setState(() { _progress += 0.02; });
      if (_progress >= 1) { setState(() { _cleaning = false; _status = '清理完成'; }); return false; }
      return true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🧹 系统清理'), centerTitle: true, actions: [
        IconButton(icon: const Icon(Icons.refresh), onPressed: _scanning ? null : _scan, tooltip: '重新扫描'),
      ]),
      body: Column(children: [
        // 状态卡片
        Card(margin: const EdgeInsets.all(12), child: Padding(padding: const EdgeInsets.all(20), child: Column(children: [
          Icon(_cleaning ? Icons.cleaning_services : Icons.storage, size: 48, color: _cleaning ? Colors.green : Colors.blue),
          const SizedBox(height: 8),
          Text(_status, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _cleaning ? Colors.green : null)),
          const SizedBox(height: 8),
          Text('可释放空间: ${_totalSize.toStringAsFixed(1)} GB', style: const TextStyle(color: Colors.grey)),
          if (_cleaning) ...[const SizedBox(height: 12), LinearProgressIndicator(value: _progress, backgroundColor: Colors.grey.shade200, color: Colors.green), const SizedBox(height: 4), Text('${(_progress * 100).toInt()}%', style: const TextStyle(fontWeight: FontWeight.bold))],
        ]))),
        // 清理类别
        Expanded(child: ListView.builder(padding: const EdgeInsets.symmetric(horizontal: 12), itemCount: _categories.length, itemBuilder: (ctx, i) {
          final c = _categories[i];
          return Card(margin: const EdgeInsets.only(bottom: 8), child: CheckboxListTile(
            value: c.selected, onChanged: _cleaning ? null : (v) => setState(() => c.selected = v!),
            secondary: Text(c.icon, style: const TextStyle(fontSize: 28)),
            title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(c.desc, style: const TextStyle(fontSize: 12)),
            secondary: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Text(c.size, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green))),
          );
        })),
        // 清理按钮
        Container(padding: const EdgeInsets.all(16), child: SizedBox(width: double.infinity, height: 52, child: FilledButton.icon(
          onPressed: _cleaning || _categories.where((c) => c.selected).isEmpty ? null : _clean,
          icon: Icon(_cleaning ? Icons.hourglass_top : Icons.cleaning_services),
          label: Text(_cleaning ? '清理中...' : '立即清理 ${_totalSize.toStringAsFixed(1)} GB'),
          style: FilledButton.styleFrom(backgroundColor: Colors.green),
        ))),
      ]),
    );
  }
}
