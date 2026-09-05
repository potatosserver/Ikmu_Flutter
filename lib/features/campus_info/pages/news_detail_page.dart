// 新聞詳情頁面

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class NewsDetailPage extends ConsumerWidget {
  const NewsDetailPage({required this.newsId, super.key});

  final String newsId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('新聞詳情'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // TODO: 分享
            },
            tooltip: '分享',
          ),
          IconButton(
            icon: const Icon(Icons.bookmark_border),
            onPressed: () {
              // TODO: 收藏
            },
            tooltip: '收藏',
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
              color: Theme.of(context).colorScheme.primary.withOpacity( 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              '新聞詳情功能開發中',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '完整內容、圖片、附件、相關新聞',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            Text('News ID: $newsId'),
          ],
        ),
      ),
    );
  }
}