// 場地查詢 - 列表頁
// 分類篩選、搜尋、列表/卡片切換、Riverpod 狀態管理

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core.dart';

/// 場地列表狀態
@immutable
class ClassroomListState {
  const ClassroomListState({
    this.categories = const [],
    this.rooms = const [],
    this.filteredRooms = const [],
    this.selectedCategory,
    this.searchQuery = '',
    this.isGridView = false,
    this.isLoading = false,
    this.error,
  });

  final List<ClassroomCategory> categories;
  final List<ClassroomRoom> rooms;
  final List<ClassroomRoom> filteredRooms;
  final ClassroomCategory? selectedCategory;
  final String searchQuery;
  final bool isGridView;
  final bool isLoading;
  final String? error;

  ClassroomListState copyWith({
    List<ClassroomCategory>? categories,
    List<ClassroomRoom>? rooms,
    List<ClassroomRoom>? filteredRooms,
    ClassroomCategory? selectedCategory,
    String? searchQuery,
    bool? isGridView,
    bool? isLoading,
    String? error,
  }) {
    return ClassroomListState(
      categories: categories ?? this.categories,
      rooms: rooms ?? this.rooms,
      filteredRooms: filteredRooms ?? this.filteredRooms,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      isGridView: isGridView ?? this.isGridView,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// 場地列表 Notifier
class ClassroomListNotifier extends AutoDisposeNotifier<ClassroomListState> {
  late final Endpoints _endpoints;
  late final CacheService _cache;

  @override
  ClassroomListState build() {
    _endpoints = ref.read(endpointsProvider);
    _cache = ref.read(cacheServiceProvider);

    // 延遲載入，避免在 build 階段修改 state
    Future.microtask(() => _loadCategories());
    return const ClassroomListState();
  }

  /// 載入分類與場地
  Future<void> _loadCategories() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      const cacheKey = 'classroom_categories';
      final cached = await _cache.getSimple<List<dynamic>>(CacheBoxes.classroom, cacheKey);

      List<ClassroomCategory> categories = [];
      if (cached != null && cached.isNotEmpty) {
        try {
          categories = cached
              .map((e) => ClassroomCategory.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList();
        } catch (_) {
          await _cache.delete(CacheBoxes.classroom, cacheKey);
        }
      }

      if (categories.isEmpty) {
        categories = await _endpoints.classroom.getCategories();
        if (categories.isNotEmpty) {
          try {
            await _cache.setSimple(
              CacheBoxes.classroom,
              cacheKey,
              categories.map((c) => c.toJson()).toList(),
              ttl: CacheTTL.classroom,
            );
          } catch (_) {}
        }
      }

      state = state.copyWith(categories: categories);
      await _loadRooms();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '載入分類失敗: $e',
      );
    }
  }

  /// 載入場地
  Future<void> _loadRooms() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final selectedCategory = state.selectedCategory;
      final cacheKey = 'classroom_rooms_${selectedCategory?.id ?? "all"}';
      final cached = await _cache.getSimple<List<dynamic>>(CacheBoxes.classroom, cacheKey);

      List<ClassroomRoom> rooms = [];
      if (cached != null && cached.isNotEmpty) {
        try {
          rooms = cached
              .map((e) => ClassroomRoom.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList();
        } catch (_) {
          await _cache.delete(CacheBoxes.classroom, cacheKey);
        }
      }

      if (rooms.isEmpty) {
        rooms = await _endpoints.classroom.getRooms(categoryId: selectedCategory?.id ?? '');
        if (rooms.isNotEmpty) {
          try {
            await _cache.setSimple(
              CacheBoxes.classroom,
              cacheKey,
              rooms.map((r) => r.toJson()).toList(),
              ttl: CacheTTL.classroom,
            );
          } catch (_) {}
        }
      }

      _applyFilters(rooms);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '載入場地失敗: $e',
      );
    }
  }

  /// 套用篩選
  void _applyFilters(List<ClassroomRoom> rooms) {
    var filtered = rooms;

    // 分類篩選
    if (state.selectedCategory != null) {
      filtered = filtered.where((r) => r.categoryId == state.selectedCategory!.id || r.categoryName == state.selectedCategory!.name).toList();
    }

    // 搜尋關鍵字
    if (state.searchQuery.isNotEmpty) {
      final query = state.searchQuery.toLowerCase();
      filtered = filtered.where((r) =>
          r.name.toLowerCase().contains(query) ||
          r.building?.toLowerCase().contains(query) == true ||
          r.location?.toLowerCase().contains(query) == true ||
          r.id.toLowerCase().contains(query)).toList();
    }

    state = state.copyWith(
      rooms: rooms,
      filteredRooms: filtered,
      isLoading: false,
    );
  }

  /// 選擇分類
  void selectCategory(ClassroomCategory? category) {
    state = state.copyWith(selectedCategory: category);
    _loadRooms();
  }

  /// 更新搜尋
  void updateSearch(String query) {
    state = state.copyWith(searchQuery: query);
    _applyFilters(state.rooms);
  }

  /// 切換檢視模式
  void toggleView() {
    state = state.copyWith(isGridView: !state.isGridView);
  }

  /// 刷新
  Future<void> refresh() async {
    await _cache.delete(CacheBoxes.classroom, 'classroom_categories');
    await _cache.delete(CacheBoxes.classroom, 'classroom_rooms_all');
    if (state.selectedCategory != null) {
      await _cache.delete(CacheBoxes.classroom, 'classroom_rooms_${state.selectedCategory!.id}');
    }
    await _loadCategories();
  }

  /// 導航到詳情頁
  void goToDetail(BuildContext context, ClassroomRoom room) {
    context.push(RoutePaths.classroomDetail.replaceFirst(':roomId', room.id));
  }
}

/// 場地列表 Provider
final classroomListProvider = AutoDisposeNotifierProvider<ClassroomListNotifier, ClassroomListState>(() {
  return ClassroomListNotifier();
});

/// 場地列表頁面
class ClassroomListPage extends ConsumerWidget {
  const ClassroomListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(classroomListProvider);
    final notifier = ref.read(classroomListProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('場地查詢'),
        actions: [
          IconButton(
            icon: Icon(state.isGridView ? Icons.view_list : Icons.grid_view),
            onPressed: notifier.toggleView,
            tooltip: state.isGridView ? '列表檢視' : '網格檢視',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: notifier.refresh,
            tooltip: '重新整理',
          ),
        ],
      ),
      body: Column(
        children: [
          // 搜尋列
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: '搜尋場地名稱、代號、建築...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: state.searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => notifier.updateSearch(''),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: notifier.updateSearch,
            ),
          ),

          // 分類篩選
          if (state.categories.isNotEmpty)
            SizedBox(
              height: 48,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: state.categories.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _CategoryChip(
                      label: '全部',
                      isSelected: state.selectedCategory == null,
                      onTap: () => notifier.selectCategory(null),
                    );
                  }
                  final category = state.categories[index - 1];
                  return _CategoryChip(
                    label: category.name,
                    isSelected: state.selectedCategory?.id == category.id,
                    onTap: () => notifier.selectCategory(category),
                  );
                },
              ),
            ),

          // 結果統計
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  '共 ${state.filteredRooms.length} 個場地',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const Spacer(),
                if (state.selectedCategory != null)
                  TextButton.icon(
                    icon: const Icon(Icons.clear, size: 16),
                    label: const Text('清除篩選'),
                    onPressed: () => notifier.selectCategory(null),
                  ),
              ],
            ),
          ),

          // 列表/網格
          Expanded(
            child: state.isLoading && state.rooms.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : state.error != null
                    ? _buildError(context, state.error!, notifier)
                    : state.filteredRooms.isEmpty
                        ? _buildEmptyState(context)
                        : state.isGridView
                            ? _buildGridView(context, state, notifier)
                            : _buildListView(context, state, notifier),
          ),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context, String error, ClassroomListNotifier notifier) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              '載入失敗',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: notifier.refresh,
              icon: const Icon(Icons.refresh),
              label: const Text('重試'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.meeting_room_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            '找不到符合條件的場地',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            '請嘗試調整搜尋條件或篩選分類',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildListView(BuildContext context, ClassroomListState state, ClassroomListNotifier notifier) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: state.filteredRooms.length,
      itemBuilder: (context, index) {
        final room = state.filteredRooms[index];
        return _RoomListTile(
          room: room,
          onTap: () => notifier.goToDetail(context, room),
        );
      },
    );
  }

  Widget _buildGridView(BuildContext context, ClassroomListState state, ClassroomListNotifier notifier) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.1,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: state.filteredRooms.length,
      itemBuilder: (context, index) {
        final room = state.filteredRooms[index];
        return _RoomGridCard(
          room: room,
          onTap: () => notifier.goToDetail(context, room),
        );
      },
    );
  }
}

/// 分類晶片
class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        selectedColor: theme.colorScheme.primaryContainer,
        labelStyle: TextStyle(
          color: isSelected
              ? theme.colorScheme.onPrimaryContainer
              : theme.colorScheme.onSurface,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}

/// 場地列表項目
class _RoomListTile extends StatelessWidget {
  const _RoomListTile({
    required this.room,
    required this.onTap,
  });

  final ClassroomRoom room;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 圖示/類型指示
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getRoomIcon(room),
                  color: theme.colorScheme.onPrimaryContainer,
                  size: 24,
                ),
              ),

              const SizedBox(width: 16),

              // 場地資訊 (加入 mainAxisSize: MainAxisSize.min 避免高度未約束問題)
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      room.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            room.building != null && room.building!.isNotEmpty
                                ? '${room.building}${room.location != null && room.location!.isNotEmpty ? " • ${room.location}" : ""}'
                                : room.location ?? room.categoryName ?? '一般教室',
                            style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (room.capacity != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 14,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '可容納 ${room.capacity} 人',
                            style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                          ),
                          if (room.equipment.isNotEmpty) ...[
                            const SizedBox(width: 16),
                            Flexible(
                              child: Text(
                                '設備: ${room.equipment.take(3).join(', ')}${room.equipment.length > 3 ? '...' : ''}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // 箭頭
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getRoomIcon(ClassroomRoom room) {
    final name = room.name.toLowerCase();
    if (name.contains('電腦') || name.contains('computer') || name.contains('程式')) {
      return Icons.computer;
    }
    if (name.contains('語言') || name.contains('language')) {
      return Icons.translate;
    }
    if (name.contains('會議') || name.contains('meeting') || name.contains('討論')) {
      return Icons.meeting_room;
    }
    if (name.contains('實驗') || name.contains('lab')) {
      return Icons.science;
    }
    if (name.contains('視聽') || name.contains('av') || name.contains('多媒體')) {
      return Icons.tv;
    }
    return Icons.class_;
  }
}

/// 場地網格卡片
class _RoomGridCard extends StatelessWidget {
  const _RoomGridCard({
    required this.room,
    required this.onTap,
  });

  final ClassroomRoom room;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _getRoomIcon(room),
                      color: theme.colorScheme.onPrimaryContainer,
                      size: 20,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    room.name,
                    style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    room.building ?? room.location ?? room.categoryName ?? '',
                    style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              if (room.capacity != null)
                Row(
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 12,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${room.capacity}人',
                      style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getRoomIcon(ClassroomRoom room) {
    final name = room.name.toLowerCase();
    if (name.contains('電腦') || name.contains('computer') || name.contains('程式')) {
      return Icons.computer;
    }
    if (name.contains('語言') || name.contains('language')) {
      return Icons.translate;
    }
    if (name.contains('會議') || name.contains('meeting') || name.contains('討論')) {
      return Icons.meeting_room;
    }
    if (name.contains('實驗') || name.contains('lab')) {
      return Icons.science;
    }
    if (name.contains('視聽') || name.contains('av') || name.contains('多媒體')) {
      return Icons.tv;
    }
    return Icons.class_;
  }
}