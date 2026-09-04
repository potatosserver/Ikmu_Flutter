// 公車即時到站頁面
// 路線選擇、站牌查詢、即時到站倒數、收藏站牌

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core.dart';

/// 公車狀態
@immutable
class BusState {
  const BusState({
    this.routes = const [],
    this.selectedRoute,
    this.stops = const [],
    this.realtime = const [],
    this.favoriteStops = const [],
    this.isLoading = false,
    this.error,
  });

  final List<BusRoute> routes;
  final BusRoute? selectedRoute;
  final List<BusStop> stops;
  final List<BusRealtime> realtime;
  final List<String> favoriteStops; // stop IDs
  final bool isLoading;
  final String? error;

  BusState copyWith({
    List<BusRoute>? routes,
    BusRoute? selectedRoute,
    List<BusStop>? stops,
    List<BusRealtime>? realtime,
    List<String>? favoriteStops,
    bool? isLoading,
    String? error,
  }) {
    return BusState(
      routes: routes ?? this.routes,
      selectedRoute: selectedRoute ?? this.selectedRoute,
      stops: stops ?? this.stops,
      realtime: realtime ?? this.realtime,
      favoriteStops: favoriteStops ?? this.favoriteStops,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// 公車 Notifier
class BusNotifier extends AutoDisposeNotifier<BusState> {
  late final Endpoints _endpoints;
  late final CacheService _cache;

  @override
  BusState build() {
    _endpoints = ref.read(endpointsProvider);
    _cache = ref.read(cacheServiceProvider);

    // 延遲載入，避免在 build 階段修改 state
    Future.microtask(() {
      _loadRoutes();
      _loadFavorites();
    });
    return const BusState();
  }

  Future<void> _loadRoutes() async {
    try {
      final cacheKey = 'bus_routes';
      final cached = _cache.get<List<dynamic>>(
        CacheBoxes.transport,
        cacheKey,
        fromJson: (json) => json as List<dynamic>,
      );
      if (cached != null) {
        state = state.copyWith(routes: cached.map((e) => BusRoute.fromJson(e as Map<String, dynamic>)).toList());
        return;
      }

      final response = await _endpoints.transport.getBusRoutes();
      if (response.isNotEmpty) {
        await _cache.set(CacheBoxes.transport, cacheKey, response,
            fromJson: (json) => json as List<dynamic>,
            ttl: CacheTTL.transport);
        state = state.copyWith(routes: response);
      }
    } catch (e) {
      debugPrint('載入公車路線失敗: $e');
    }
  }

  Future<void> _loadFavorites() async {
    // TODO: 從本地儲存載入收藏站牌
  }

  void selectRoute(BusRoute route) {
    state = state.copyWith(selectedRoute: route);
    _loadStopsAndRealtime(route.id);
  }

  Future<void> _loadStopsAndRealtime(String routeId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final stopsCacheKey = 'bus_stops_$routeId';
      final cachedStops = _cache.get<List<dynamic>>(
        CacheBoxes.transport,
        stopsCacheKey,
        fromJson: (json) => json as List<dynamic>,
      );
      if (cachedStops != null) {
        state = state.copyWith(stops: cachedStops.map((e) => BusStop.fromJson(e as Map<String, dynamic>)).toList());
      }

      final response = await _endpoints.transport.getBusStops(routeId);
      if (response.success && response.stops.isNotEmpty) {
        await _cache.set(CacheBoxes.transport, stopsCacheKey, response.stops,
            fromJson: (json) => BusStop.fromJson(json as Map<String, dynamic>),
            ttl: CacheTTL.classroom);
        state = state.copyWith(stops: response.stops);
      }

      // 載入即時資訊
      _loadRealtime(routeId);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: '載入站牌失敗: $e');
    }
  }

  Future<void> _loadRealtime(String routeId) async {
    try {
      final realtime = await _endpoints.transport.getBusRealtime(routeId: routeId);
      state = state.copyWith(realtime: realtime);
    } catch (e) {
      debugPrint('載入即時資訊失敗: $e');
    }
  }

  void toggleFavorite(String stopId) {
    final favorites = List<String>.from(state.favoriteStops);
    if (favorites.contains(stopId)) {
      favorites.remove(stopId);
    } else {
      favorites.add(stopId);
    }
    state = state.copyWith(favoriteStops: favorites);
    // TODO: 持久化
  }

  bool isFavorite(String stopId) => state.favoriteStops.contains(stopId);

  Future<void> refresh() async {
    if (state.selectedRoute != null) {
      _cache.delete(CacheBoxes.transport, 'bus_stops_${state.selectedRoute!.id}');
      await _loadStopsAndRealtime(state.selectedRoute!.id);
    }
  }
}

/// 公車 Provider
final busProvider = AutoDisposeNotifierProvider<BusNotifier, BusState>(() {
  return BusNotifier();
});

/// 公車頁面
class BusPage extends ConsumerWidget {
  const BusPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(busProvider);
    final notifier = ref.read(busProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('公車即時到站'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: notifier.refresh,
            tooltip: '重新整理',
          ),
        ],
      ),
      body: state.isLoading && state.routes.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
              ? _buildError(context, state.error!, notifier)
              : Column(
                  children: [
                    // 路線選擇
                    _buildRouteSelector(context, state, notifier),

                    // 收藏站牌快速存取
                    if (state.favoriteStops.isNotEmpty)
                      _buildFavorites(context, state, notifier),

                    // 站牌列表/即時資訊
                    Expanded(
                      child: state.selectedRoute == null
                          ? _buildRouteList(context, state, notifier)
                          : _buildStopList(context, state, notifier),
                    ),
                  ],
                ),
    );
  }

  Widget _buildRouteSelector(BuildContext context, BusState state, BusNotifier notifier) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: state.routes.length,
        itemBuilder: (context, index) {
          final route = state.routes[index];
          final isSelected = state.selectedRoute?.id == route.id;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(route.name),
              selected: isSelected,
              onSelected: (_) => notifier.selectRoute(route),
              selectedColor: Theme.of(context).colorScheme.primaryContainer,
              labelStyle: TextStyle(
                color: isSelected ? Theme.of(context).colorScheme.onPrimaryContainer : null,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFavorites(BuildContext context, BusState state, BusNotifier notifier) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.star, color: Theme.of(context).colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Text('收藏站牌', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: state.favoriteStops.take(5).map((stopId) {
              // 找到站牌資訊
              final stop = state.stops.firstWhere((s) => s.id == stopId, orElse: () => BusStop(id: stopId, name: stopId, sequence: 0, latitude: 0, longitude: 0));
              return FilterChip(
                label: Text(stop.name),
                onSelected: (_) {
                  if (state.selectedRoute != null) {
                    notifier.selectRoute(state.selectedRoute!);
                  }
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteList(BuildContext context, BusState state, BusNotifier notifier) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.routes.length,
      itemBuilder: (context, index) {
        final route = state.routes[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Text(route.name.substring(0, 1), style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer, fontWeight: FontWeight.w700)),
            ),
            title: Text(route.name, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            subtitle: Text('${route.firstBus ?? "--"} → ${route.lastBus ?? "--"}'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => notifier.selectRoute(route),
          ),
        );
      },
    );
  }

  Widget _buildStopList(BuildContext context, BusState state, BusNotifier notifier) {
    if (state.stops.isEmpty) {
      return const Center(child: Text('此路線無站牌資料'));
    }

    return RefreshIndicator(
      onRefresh: notifier.refresh,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.stops.length,
        itemBuilder: (context, index) {
          final stop = state.stops[index];
          final realtime = state.realtime.firstWhere((r) => r.stopId == stop.id, orElse: () => BusRealtime(routeId: '', stopId: '', stopName: '', estimateTime: null));
          final isFav = notifier.isFavorite(stop.id);

          return _StopCard(
            stop: stop,
            realtime: realtime,
            isFavorite: isFav,
            onFavoriteToggle: () => notifier.toggleFavorite(stop.id),
          );
        },
      ),
    );
  }

  Widget _buildError(BuildContext context, String error, BusNotifier notifier) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 16),
            Text('載入失敗', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(error, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant), textAlign: TextAlign.center),
            const SizedBox(height: 24),
            FilledButton.icon(onPressed: notifier.refresh, icon: const Icon(Icons.refresh), label: const Text('重試')),
          ],
        ),
      ),
    );
  }
}

/// 站牌卡片
class _StopCard extends StatelessWidget {
  const _StopCard({
    required this.stop,
    this.realtime,
    required this.isFavorite,
    required this.onFavoriteToggle,
  });

  final BusStop stop;
  final BusRealtime? realtime;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // 站牌資訊
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(stop.name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                      ),
                      IconButton(
                        icon: Icon(isFavorite ? Icons.star : Icons.star_border, color: isFavorite ? Colors.amber : theme.colorScheme.onSurfaceVariant),
                        onPressed: onFavoriteToggle,
                        tooltip: isFavorite ? '取消收藏' : '加入收藏',
                      ),
                    ],
                  ),
                  if (realtime != null) ...[
                    const SizedBox(height: 8),
                    _RealtimeInfo(realtime: realtime!),
                  ] else ...[
                    const SizedBox(height: 8),
                    Text('無即時資料', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 即時資訊顯示
class _RealtimeInfo extends StatelessWidget {
  const _RealtimeInfo({required this.realtime});

  final BusRealtime realtime;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (realtime.estimateTime == null || realtime.estimateTime! <= 0) {
      return Text('尚無班車', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant));
    }

    final minutes = realtime.estimateTime!;
    final isArriving = minutes <= 3;

    return Row(
      children: [
        Icon(
          isArriving ? Icons.directions_bus : Icons.schedule,
          size: 18,
          color: isArriving ? Colors.green : theme.colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Text(
          '$minutes 分鐘',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: isArriving ? Colors.green : theme.colorScheme.primary,
          ),
        ),
        if (realtime.busPlate != null) ...[
          const SizedBox(width: 12),
          Text('車牌: ${realtime.busPlate}', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        ],
      ],
    );
  }
}