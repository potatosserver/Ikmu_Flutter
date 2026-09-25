// 新聞列表頁面

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class NewsPage extends ConsumerWidget {
  const NewsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('校園新聞'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // TODO: 重新整理
            },
            tooltip: '重新整理',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.category),
            onSelected: (value) {
              // TODO: 分類篩選
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'all', child: Text('全部')),
              const PopupMenuItem(value: 'announcement', child: Text('公告')),
              const PopupMenuItem(value: 'event', child: Text('活動')),
            ],
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.article,
              size: 80,
              color: Theme.of(context).colorScheme.primary.withValues( alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              '新聞功能開發中',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '分類篩選、詳情頁、收藏、分享',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}