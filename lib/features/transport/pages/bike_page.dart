// YouBike 站點頁面
// 站點列表、地圖顯示、即時車輛數、收藏站點、導航

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core.dart';
import '../../../../core/constants/location_constants.dart';

/// YouBike 狀態
@immutable
class BikeState {
  const BikeState({
    this.stations = const [],
    this.filteredStations = const [],
    this.searchQuery = '',
    this.showOnlyAvailable = false,
    this.favoriteStations = const [],
    this.isLoading = false,
    this.error,
  });

  final List<BikeStation> stations;
  final List<BikeStation> filteredStations;
  final String searchQuery;
  final bool showOnlyAvailable;
  final List<String> favoriteStations; // station IDs
  final bool isLoading;
  final String? error;

  BikeState copyWith({
    List<BikeStation>? stations,
    List<BikeStation>? filteredStations,
    String? searchQuery,
    bool? showOnlyAvailable,
    List<String>? favoriteStations,
    bool? isLoading,
    String? error,
  }) {
    return BikeState(
      stations: stations ?? this.stations,
      filteredStations: filteredStations ?? this.filteredStations,
      searchQuery: searchQuery ?? this.searchQuery,
      showOnlyAvailable: showOnlyAvailable ?? this.showOnlyAvailable,
      favoriteStations: favoriteStations ?? this.favoriteStations,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// YouBike Notifier
class BikeNotifier extends AutoDisposeNotifier<BikeState> {
  late final Endpoints _endpoints;
  late final CacheService _cache;

  @override
  BikeState build() {
    _endpoints = ref.read(endpointsProvider);
    _cache = ref.read(cacheServiceProvider);

    // 延遲載入，避免在 build 階段修改 state
    Future.microtask(() {
      _loadStations();
      _loadFavorites();
    });
    return const BikeState();
  }

  Future<void> _loadStations() async {
      state = state.copyWith(isLoading: true, error: null);

      try {
        const cacheKey = 'bike_stations';
        final cached = _cache.getSimple<List<BikeStation>>(CacheBoxes.transport, cacheKey);
        if (cached != null) {
          _applyFilters(cached);
          return;
        }

        // 使用統一的學校中心點座標 (高醫主校區) 查詢 YouBike 即時資料
        final stations = await _endpoints.transport.getBikeRealtime(
          lat: KmuLocation.latitude,
          lng: KmuLocation.longitude,
          maxDistance: 2000, // 2公里範圍
        );

        if (stations.isNotEmpty) {
          await _cache.setSimple(CacheBoxes.transport, cacheKey, stations, ttl: CacheTTL.transport);
          _applyFilters(stations);
        } else {
          throw Exception('載入站點失敗');
        }
      } catch (e) {
        state = state.copyWith(isLoading: false, error: '載入站點失敗: $e');
      }
    }

  Future<void> _loadFavorites() async {
    // TODO: 從本地儲存載入
  }

  void _applyFilters(List<BikeStation> stations) {
    var filtered = stations;

    if (state.showOnlyAvailable) {
      filtered = filtered.where((s) => s.availableBikes > 0 && s.availableDocks > 0).toList();
    }

    if (state.searchQuery.isNotEmpty) {
      final query = state.searchQuery.toLowerCase();
      filtered = filtered.where((s) =>
          s.name.toLowerCase().contains(query) ||
          s.address?.toLowerCase().contains(query) == true ||
          s.id.toLowerCase().contains(query)).toList();
    }

    state = state.copyWith(
      stations: stations,
      filteredStations: filtered,
      isLoading: false,
    );
  }

  void updateSearch(String query) {
    state = state.copyWith(searchQuery: query);
    _applyFilters(state.stations);
  }

  void toggleAvailableFilter() {
    state = state.copyWith(showOnlyAvailable: !state.showOnlyAvailable);
    _applyFilters(state.stations);
  }

  void toggleFavorite(String stationId) {
    final favorites = List<String>.from(state.favoriteStations);
    if (favorites.contains(stationId)) {
      favorites.remove(stationId);
    } else {
      favorites.add(stationId);
    }
    state = state.copyWith(favoriteStations: favorites);
    // TODO: 持久化
  }

  bool isFavorite(String stationId) => state.favoriteStations.contains(stationId);

  Future<void> refresh() async {
    await _cache.remove(CacheBoxes.transport, 'bike_stations');
    await _loadStations();
  }

  Future<void> navigateToStation(BikeStation station) async {
    final url = 'https://www.google.com/maps/search/?api=1&query=${station.latitude},${station.longitude}';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }
}

/// YouBike Provider
final bikeProvider = AutoDisposeNotifierProvider<BikeNotifier, BikeState>(() {
  return BikeNotifier();
});

/// YouBike 頁面
class BikePage extends ConsumerWidget {
  const BikePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(bikeProvider);
    final notifier = ref.read(bikeProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('YouBike 站點'),
        actions: [
          IconButton(
            icon: Icon(state.showOnlyAvailable ? Icons.filter_list : Icons.filter_list_off),
            onPressed: notifier.toggleAvailableFilter,
            tooltip: state.showOnlyAvailable ? '顯示全部' : '僅顯示有車位',
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
                hintText: '搜尋站點名稱、地址...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: state.searchQuery.isNotEmpty
                    ? IconButton(icon: const Icon(Icons.clear), onPressed: () => notifier.updateSearch(''))
                    : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: notifier.updateSearch,
            ),
          ),

          // 篩選狀態
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                FilterChip(
                  label: Text('僅顯示有車/有位 (${state.filteredStations.where((s) => s.availableBikes > 0 && s.availableDocks > 0).length})'),
                  selected: state.showOnlyAvailable,
                  onSelected: (_) => notifier.toggleAvailableFilter(),
                  selectedColor: Theme.of(context).colorScheme.primaryContainer,
                ),
                const Spacer(),
                Text('共 ${state.filteredStations.length} / ${state.stations.length} 站',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
              ],
            ),
          ),

          // 收藏站點
          if (state.favoriteStations.isNotEmpty)
            _buildFavorites(context, state, notifier),

          // 站點列表
          Expanded(
            child: state.isLoading && state.stations.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : state.error != null
                    ? _buildError(context, state.error!, notifier)
                    : state.filteredStations.isEmpty
                        ? _buildEmptyState(context)
                        : _buildStationList(context, state, notifier),
          ),
        ],
      ),
    );
  }

  Widget _buildFavorites(BuildContext context, BikeState state, BikeNotifier notifier) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.star, color: Theme.of(context).colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Text('收藏站點', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: state.favoriteStations.length,
              itemBuilder: (context, index) {
                final stationId = state.favoriteStations[index];
                final station = state.stations.firstWhere((s) => s.id == stationId, orElse: () => BikeStation(id: stationId, name: stationId, latitude: 0, longitude: 0, address: '', totalDocks: 0, availableBikes: 0, availableDocks: 0));
                return _FavoriteStationCard(station: station, onTap: () => notifier.navigateToStation(station));
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStationList(BuildContext context, BikeState state, BikeNotifier notifier) {
    return RefreshIndicator(
      onRefresh: notifier.refresh,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.filteredStations.length,
        itemBuilder: (context, index) {
          final station = state.filteredStations[index];
          final isFav = notifier.isFavorite(station.id);

          return _StationCard(
            station: station,
            isFavorite: isFav,
            onFavoriteToggle: () => notifier.toggleFavorite(station.id),
            onNavigate: () => notifier.navigateToStation(station),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.directions_bike_outlined, size: 80, color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Text('找不到符合條件的站點', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text('請嘗試調整搜尋條件', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context, String error, BikeNotifier notifier) {
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

/// 收藏站點卡片
class _FavoriteStationCard extends StatelessWidget {
  const _FavoriteStationCard({required this.station, required this.onTap});

  final BikeStation station;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final availablePercent = station.totalDocks > 0 ? station.availableBikes / station.totalDocks : 0.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(station.name, style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis)),
                Icon(Icons.directions_bike, size: 16, color: theme.colorScheme.primary),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: availablePercent, backgroundColor: theme.colorScheme.surfaceContainer, color: availablePercent > 0.3 ? Colors.green : (availablePercent > 0 ? Colors.orange : Colors.red)),
            const SizedBox(height: 4),
            Text('${station.availableBikes} 車 / ${station.availableDocks} 位', style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}

/// 站點卡片
class _StationCard extends StatelessWidget {
  const _StationCard({
    required this.station,
    required this.isFavorite,
    required this.onFavoriteToggle,
    required this.onNavigate,
  });

  final BikeStation station;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onNavigate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final availablePercent = station.totalDocks > 0 ? station.availableBikes / station.totalDocks : 0.0;
    final isAvailable = station.availableBikes > 0 && station.availableDocks > 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onNavigate,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(station.name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                  ),
                  IconButton(
                    icon: Icon(isFavorite ? Icons.star : Icons.star_border, color: isFavorite ? Colors.amber : theme.colorScheme.onSurfaceVariant),
                    onPressed: onFavoriteToggle,
                  ),
                  IconButton(icon: const Icon(Icons.navigation), onPressed: onNavigate, tooltip: '導航'),
                ],
              ),
              const SizedBox(height: 8),
              Text(station.address ?? '', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              const SizedBox(height: 12),
              Row(
                children: [
                  _StatItem(label: '可借車', value: '${station.availableBikes}', color: station.availableBikes > 0 ? Colors.green : Colors.red, icon: Icons.directions_bike),
                  const SizedBox(width: 16),
                  _StatItem(label: '可還車', value: '${station.availableDocks}', color: station.availableDocks > 0 ? Colors.green : Colors.red, icon: Icons.park),
                  const SizedBox(width: 16),
                  _StatItem(label: '總車位', value: '${station.totalDocks}', color: theme.colorScheme.onSurfaceVariant, icon: Icons.ev_station),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: availablePercent,
                backgroundColor: theme.colorScheme.surfaceContainer,
                color: availablePercent > 0.3 ? Colors.green : (availablePercent > 0 ? Colors.orange : Colors.red),
                minHeight: 6,
                borderRadius: BorderRadius.circular(3),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text('可用率 ${(availablePercent * 100).toStringAsFixed(0)}%', style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: isAvailable ? Colors.green.withValues(alpha: 0.2) : Colors.red.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(isAvailable ? '可使用' : '滿車/無位', style: theme.textTheme.labelSmall?.copyWith(color: isAvailable ? Colors.green : Colors.red, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.label, required this.value, required this.color, required this.icon});
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(value, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: color)),
          Text(label, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}