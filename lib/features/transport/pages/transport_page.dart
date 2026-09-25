// 交通整合頁面 - 地圖為中心
// 整合公車、YouBike、捷運、輕軌圖層
// 使用 flutter_map + vector_map_tiles 向量瓦片

import 'package:flutter/services.dart' show rootBundle;
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart' show compute;

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:vector_map_tiles/vector_map_tiles.dart';
import 'package:vector_tile_renderer/vector_tile_renderer.dart' as vtr_logger;
import 'package:vector_tile_renderer/vector_tile_renderer.dart' hide TileLayer, Theme;
import 'package:latlong2/latlong.dart' as latlong;
import 'package:url_launcher/url_launcher.dart';

import '../../../core.dart';
import '../../../../core/constants/location_constants.dart';

/// Transport 頁面狀態
@immutable
class TransportState {
  const TransportState({
    this.bikeStations = const [],
    this.metroStations = const [],
    this.lrtStations = const [],
    this.selectedStation,
    this.userLocation,
    this.isLoading = false,
    this.error,
    this.showBikeLayer = true,
    this.showBusLayer = false,
    this.showMetroLayer = false,
    this.showLrtLayer = false,
    this.searchQuery = '',
    this.filteredStations = const [],
    this.lastRefreshTime,
    this.autoRefreshEnabled = true,
  });

  final List<BikeStation> bikeStations;
  final List<MetroStation> metroStations;
  final List<LRTStation> lrtStations;
  final BikeStation? selectedStation;
  final latlong.LatLng? userLocation;
  final bool isLoading;
  final String? error;
  final bool showBikeLayer;
  final bool showBusLayer;
  final bool showMetroLayer;
  final bool showLrtLayer;
  final String searchQuery;
  final List<BikeStation> filteredStations;
  final DateTime? lastRefreshTime;
  final bool autoRefreshEnabled;

  TransportState copyWith({
    List<BikeStation>? bikeStations,
    List<MetroStation>? metroStations,
    List<LRTStation>? lrtStations,
    BikeStation? selectedStation,
    latlong.LatLng? userLocation,
    bool? isLoading,
    String? error,
    bool? showBikeLayer,
    bool? showBusLayer,
    bool? showMetroLayer,
    bool? showLrtLayer,
    String? searchQuery,
    List<BikeStation>? filteredStations,
    DateTime? lastRefreshTime,
    bool? autoRefreshEnabled,
    bool clearSelectedStation = false,
  }) {
    return TransportState(
      bikeStations: bikeStations ?? this.bikeStations,
      metroStations: metroStations ?? this.metroStations,
      lrtStations: lrtStations ?? this.lrtStations,
      selectedStation: clearSelectedStation ? null : (selectedStation ?? this.selectedStation),
      userLocation: userLocation ?? this.userLocation,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      showBikeLayer: showBikeLayer ?? this.showBikeLayer,
      showBusLayer: showBusLayer ?? this.showBusLayer,
      showMetroLayer: showMetroLayer ?? this.showMetroLayer,
      showLrtLayer: showLrtLayer ?? this.showLrtLayer,
      searchQuery: searchQuery ?? this.searchQuery,
      filteredStations: filteredStations ?? this.filteredStations,
      lastRefreshTime: lastRefreshTime ?? this.lastRefreshTime,
      autoRefreshEnabled: autoRefreshEnabled ?? this.autoRefreshEnabled,
    );
  }
}

/// Transport Notifier
class TransportNotifier extends AutoDisposeNotifier<TransportState> {
  late final Endpoints _endpoints;
  late final CacheService _cache;
  Timer? _refreshTimer;
  int _countdownSeconds = 30;

  @override
  TransportState build() {
    _endpoints = ref.read(endpointsProvider);
    _cache = ref.read(cacheServiceProvider);

    // 啟動自動刷新計時器
    _startAutoRefresh();

    // 延遲載入
    Future.microtask(() {
      _getUserLocation();
    });

    ref.onDispose(() {
      _refreshTimer?.cancel();
    });

    return const TransportState();
  }

  void _startAutoRefresh() {
    _refreshTimer?.cancel();
    _countdownSeconds = 30;
    _refreshTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!state.autoRefreshEnabled) return;

      _countdownSeconds--;
      if (_countdownSeconds <= 0) {
        _countdownSeconds = 30;
        refreshBikeData();
      }
      // 觸發 UI 更新倒數
      state = state.copyWith(lastRefreshTime: DateTime.now());
    });
  }

  void resetCountdown() {
    _countdownSeconds = 30;
  }

  int get countdownSeconds => _countdownSeconds;

  Future<void> _getUserLocation() async {
    // 使用統一的學校中心點座標 (高醫主校區)
    state = state.copyWith(userLocation: KmuLocation.latLng);
    // 並行載入所有站點資料
    await Future.wait([
      _loadBikeStations(),
      loadMetroStations(),
      loadLRTStations(),
    ]);
  }

  Future<void> _loadBikeStations() async {
    final location = state.userLocation;
    if (location == null) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      const cacheKey = 'bike_stations_realtime';
      final cachedJson = _cache.getSimple<List<dynamic>>(CacheBoxes.transport, cacheKey);

      if (cachedJson != null && cachedJson.isNotEmpty) {
        final cached = cachedJson
            .whereType<Map>()
            .map((e) => BikeStation.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        _applyFilters(cached);
        state = state.copyWith(isLoading: false);
      }

      // 總是嘗試取得即時資料
      final stations = await _endpoints.transport.getBikeRealtime(
        lat: location.latitude,
        lng: location.longitude,
        maxDistance: 1500,
      );

      if (stations.isNotEmpty) {
        // 序列化為 JSON 供 Hive 儲存
        final jsonList = stations.map((s) => s.toJson()).toList();
        await _cache.setSimple(CacheBoxes.transport, cacheKey, jsonList, ttl: CacheTTL.transport);
        _applyFilters(stations);
      } else if (state.bikeStations.isEmpty) {
        throw Exception('無站點資料');
      }
    } catch (e) {
      debugPrint('載入 YouBike 失敗: $e');
      if (state.bikeStations.isEmpty) {
        state = state.copyWith(isLoading: false, error: '載入站點失敗: $e');
      }
    }
  }

  void _applyFilters(List<BikeStation> stations) {
    var filtered = stations;

    if (state.searchQuery.isNotEmpty) {
      final query = state.searchQuery.toLowerCase();
      filtered = filtered.where((s) =>
          s.name.toLowerCase().contains(query) ||
          s.address?.toLowerCase().contains(query) == true ||
          s.id.toLowerCase().contains(query) ||
          s.sarea?.toLowerCase().contains(query) == true).toList();
    }

    state = state.copyWith(
      bikeStations: stations,
      filteredStations: filtered,
      isLoading: false,
    );
  }

  void updateSearch(String query) {
    state = state.copyWith(searchQuery: query);
    _applyFilters(state.bikeStations);
  }

  void toggleBikeLayer() {
    state = state.copyWith(showBikeLayer: !state.showBikeLayer);
  }

  void toggleBusLayer() {
    state = state.copyWith(showBusLayer: !state.showBusLayer);
  }

  void toggleMetroLayer() {
    state = state.copyWith(showMetroLayer: !state.showMetroLayer);
  }

  void toggleLrtLayer() {
    state = state.copyWith(showLrtLayer: !state.showLrtLayer);
  }

  void selectStation(BikeStation station) {
    state = state.copyWith(selectedStation: station);
  }

  void clearSelection() {
    state = state.copyWith(clearSelectedStation: true);
  }

  Future<void> refreshBikeData() async {
    resetCountdown();
    await _loadBikeStations();
  }

  Future<void> navigateToStation(BikeStation station) async {
    final url = 'https://www.google.com/maps/search/?api=1&query=${station.latitude},${station.longitude}';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  // 捷運站點載入
  Future<void> loadMetroStations() async {
    state = state.copyWith(isLoading: true);
    try {
      const cacheKey = 'metro_stations';
      final cachedJson = _cache.getSimple<List<dynamic>>(CacheBoxes.transport, cacheKey);
      
      if (cachedJson != null && cachedJson.isNotEmpty) {
        final cached = cachedJson
            .whereType<Map>()
            .map((e) => MetroStation.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        state = state.copyWith(metroStations: cached, isLoading: false);
      }

      final stations = await _endpoints.transport.getMetroStations();
      
      if (stations.isNotEmpty) {
        final jsonList = stations.map((s) => s.toJson()).toList();
        await _cache.setSimple(CacheBoxes.transport, cacheKey, jsonList, ttl: CacheTTL.transport);
        state = state.copyWith(metroStations: stations, isLoading: false);
      } else if (state.metroStations.isEmpty) {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      debugPrint('載入捷運站點失敗: $e');
      if (state.metroStations.isEmpty) {
        state = state.copyWith(isLoading: false);
      }
    }
  }

  // 輕軌站點載入
  Future<void> loadLRTStations() async {
    state = state.copyWith(isLoading: true);
    try {
      const cacheKey = 'lrt_stations';
      final cachedJson = _cache.getSimple<List<dynamic>>(CacheBoxes.transport, cacheKey);
      
      if (cachedJson != null && cachedJson.isNotEmpty) {
        final cached = cachedJson
            .whereType<Map>()
            .map((e) => LRTStation.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        state = state.copyWith(lrtStations: cached, isLoading: false);
      }

      final stations = await _endpoints.transport.getLRTStations();
      
      if (stations.isNotEmpty) {
        final jsonList = stations.map((s) => s.toJson()).toList();
        await _cache.setSimple(CacheBoxes.transport, cacheKey, jsonList, ttl: CacheTTL.transport);
        state = state.copyWith(lrtStations: stations, isLoading: false);
      } else if (state.lrtStations.isEmpty) {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      debugPrint('載入輕軌站點失敗: $e');
      if (state.lrtStations.isEmpty) {
        state = state.copyWith(isLoading: false);
      }
    }
  }
}

/// Transport Provider
final transportProvider = AutoDisposeNotifierProvider<TransportNotifier, TransportState>(() {
  return TransportNotifier();
});

// 倒數計時 Provider
final countdownProvider = Provider<int>((ref) {
  final notifier = ref.watch(transportProvider.notifier);
  return notifier.countdownSeconds;
});

/// Transport 頁面
class TransportPage extends ConsumerStatefulWidget {
  const TransportPage({super.key});

  @override
  ConsumerState<TransportPage> createState() => _TransportPageState();
}

class _TransportPageState extends ConsumerState<TransportPage> {
  final MapController _mapController = MapController();
  Style? _style;
  bool _styleLoaded = false;

  // 高醫預設中心點 (使用統一座標常數)
  static const latlong.LatLng _kmuCenter = KmuLocation.latLng;
  static const double _defaultZoom = 15.0;

  @override
  void initState() {
    super.initState();
    _loadStyle();
  }

  Future<void> _loadStyle() async {
    try {
      // 從本地資產讀取 MapLibre 風格
      final styleText = await rootBundle.loadString('assets/maps/liberty_style.json');
      final styleJson = await compute(jsonDecode, styleText);
      
      // 手動構建 Style 對象，避開 StyleReader 的 HTTP 載入
      final providers = await _buildProvidersFromStyle(styleJson);
      final themeReader = ThemeReader(logger: const vtr_logger.Logger.noop());
      final theme = themeReader.read(styleJson);
      
      final center = styleJson['center'];
      latlong.LatLng? centerPoint;
      if (center is List && center.length == 2) {
        centerPoint = latlong.LatLng((center[1] as num).toDouble(), (center[0] as num).toDouble());
      }
      double? zoom = (styleJson['zoom'] as num?)?.toDouble();
      if (zoom != null && zoom < 2) {
        zoom = null;
        centerPoint = null;
      }
      
      final styleObj = Style(
        name: styleJson['name'] as String?,
        theme: theme,
        providers: providers,
        center: centerPoint,
        zoom: zoom,
      );
      
      if (mounted) {
        setState(() {
          _style = styleObj;
          _styleLoaded = true;
        });
      }
    } catch (e) {
      debugPrint('載入地圖風格失敗: $e');
      // Fallback 到線上風格（需要 API key）
      try {
        final style = await StyleReader(
          uri: 'https://tiles.stadiamaps.com/styles/osm_bright.json',
          logger: const vtr_logger.Logger.noop(),
        ).read();
        if (mounted) {
          setState(() {
            _style = style;
            _styleLoaded = true;
          });
        }
      } catch (e) {
        debugPrint('載入備用風格也失敗: $e');
      }
    }
  }

  Future<TileProviders> _buildProvidersFromStyle(Map<String, dynamic> styleJson) async {
      final sources = styleJson['sources'];
      if (sources is! Map) {
        throw 'Invalid style: sources not found';
      }

      final providers = <String, VectorTileProvider>{};

      for (final entry in sources.entries) {
        final source = entry.value;
        final sourceType = source['type'];
        if (sourceType != 'vector') continue;

        // 支援兩種格式：
        // 1. tiles 陣列: "tiles": ["https://.../{z}/{x}/{y}.pbf"]
        // 2. url 單一模板: "url": "https://.../{z}/{x}/{y}.pbf"
        final entryTiles = source['tiles'];
        final entryUrl = source['url'];
        final maxzoom = source['maxzoom'] as int? ?? 14;
        final minzoom = source['minzoom'] as int? ?? 1;

        String? tileUrl;
        if (entryTiles is List && entryTiles.isNotEmpty) {
          tileUrl = entryTiles[0] as String;
        } else if (entryUrl is String && entryUrl.isNotEmpty) {
          tileUrl = entryUrl;
        }

        if (tileUrl != null) {
          // 所有向量瓦片使用 vector 類型
          providers[entry.key] = NetworkVectorTileProvider(
            type: TileProviderType.vector,
            urlTemplate: tileUrl,
            maximumZoom: maxzoom,
            minimumZoom: minzoom,
          );
        }
      }

      if (providers.isEmpty) {
        throw 'No valid vector tile providers found in style';
      }

      return TileProviders(providers);
    }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(transportProvider);
    final notifier = ref.read(transportProvider.notifier);

    // 監聽倒數計時更新 UI
    ref.listen<int>(countdownProvider, (previous, next) {
      if (mounted) setState(() {});
    });

    // 監聽 YouBike 站點資料變更，重新繪製地圖圖層
    ref.listen<List<BikeStation>>(
      transportProvider.select((s) => s.bikeStations),
      (previous, next) {
        if (mounted) setState(() {});
      },
    );

    // 監聽圖層顯示開關
    ref.listen<bool>(
      transportProvider.select((s) => s.showBikeLayer),
      (previous, next) {
        if (mounted) setState(() {});
      },
    );
    ref.listen<bool>(
      transportProvider.select((s) => s.showMetroLayer),
      (previous, next) {
        if (mounted) setState(() {});
      },
    );
    ref.listen<bool>(
      transportProvider.select((s) => s.showLrtLayer),
      (previous, next) {
        if (mounted) setState(() {});
      },
    );
    // 監聽捷運站點資料
    ref.listen<List<MetroStation>>(
      transportProvider.select((s) => s.metroStations),
      (previous, next) {
        if (mounted) setState(() {});
      },
    );
    // 監聽輕軌站點資料
    ref.listen<List<LRTStation>>(
      transportProvider.select((s) => s.lrtStations),
      (previous, next) {
        if (mounted) setState(() {});
      },
    );

    // 監聽選中站點變更
    ref.listen<BikeStation?>(
      transportProvider.select((s) => s.selectedStation),
      (previous, next) {
        if (mounted) setState(() {});
      },
    );

    return Scaffold(
      body: Stack(
        children: [
          // 地圖
          _buildMap(),

          // 頂部搜尋列
          _buildSearchBar(context, state, notifier),

          // 右下角功能按鈕群
          _buildActionButtons(context, state, notifier),

          // 底部抽屜
          _buildBottomSheet(context, state, notifier),
        ],
      ),
    );
  }

  Widget _buildMap() {
    final state = ref.watch(transportProvider);
    if (!_styleLoaded || _style == null) {
      return Container(
        color: Theme.of(context).colorScheme.surface,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _kmuCenter,
        initialZoom: _defaultZoom,
        maxZoom: 14, // OpenFreeMap planet vector tiles max zoom
        minZoom: 1,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.drag | 
                 InteractiveFlag.flingAnimation | 
                 InteractiveFlag.pinchMove | 
                 InteractiveFlag.pinchZoom | 
                 InteractiveFlag.doubleTapZoom,
        ),
        onTap: (tapPosition, point) {
          // 點擊地圖空白處關閉抽屜
          ref.read(transportProvider.notifier).clearSelection();
        },
      ),
      children: [
        // 向量瓦片圖層
        VectorTileLayer(
          theme: _style!.theme,
          tileProviders: _style!.providers,
          tileOffset: TileOffset.DEFAULT,
        ),
        // 捷運路線圖層 (紅/橘線)
        if (state.showMetroLayer)
          _buildMetroLayer(state),
        // 輕軌路線圖層 (環狀輕軌)
        if (state.showLrtLayer)
          _buildLRTLayer(state),
        // YouBike 站點圖層
        if (state.showBikeLayer)
          _buildBikeLayer(state),
        // RichAttributionWidget (法律要求)
        RichAttributionWidget(
          alignment: AttributionAlignment.bottomRight,
          attributions: [
            TextSourceAttribution(
              '© OpenStreetMap contributors, © 國土測繪中心',
              onTap: () => launchUrl(Uri.parse('https://www.openstreetmap.org/copyright')),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBikeLayer(TransportState state) {
    final state = ref.read(transportProvider);
    final markers = state.bikeStations.map((station) {
      final isSelected = state.selectedStation?.id == station.id;
      final color = _getAvailabilityColor(station);
      
      return Marker(
        point: latlong.LatLng(station.latitude, station.longitude),
        width: isSelected ? 40 : 24,
        height: isSelected ? 40 : 24,
        child: GestureDetector(
          onTap: () => ref.read(transportProvider.notifier).selectStation(station),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? const Color(0xFF3B82F6) : Color(int.parse(color.replaceFirst('#', ''), radix: 16) | 0xFF000000),
              border: Border.all(
                color: Colors.white,
                width: isSelected ? 3 : 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                Icons.pedal_bike,
                size: isSelected ? 20 : 12,
                color: Colors.white,
              ),
            ),
          ),
        ),
      );
    }).toList();

    return MarkerLayer(markers: markers);
  }

  // 捷運路線圖層
  Widget _buildMetroLayer(TransportState state) {
    final stations = state.metroStations;
    if (stations.isEmpty) return const SizedBox.shrink();

    // 依路線分組
    final redLine = stations.where((s) => s.line == 'red').toList()
      ..sort((a, b) => a.sequence.compareTo(b.sequence));
    final orangeLine = stations.where((s) => s.line == 'orange').toList()
      ..sort((a, b) => a.sequence.compareTo(b.sequence));

    final polylines = <Polyline>[];
    final markers = <Marker>[];

    // 紅線 Polyline
    if (redLine.length >= 2) {
      polylines.add(Polyline(
        points: redLine.map((s) => latlong.LatLng(s.latitude, s.longitude)).toList(),
        color: Colors.red,
        strokeWidth: 4,
        borderColor: Colors.white,
        borderStrokeWidth: 1,
      ));
    }
    // 橘線 Polyline
    if (orangeLine.length >= 2) {
      polylines.add(Polyline(
        points: orangeLine.map((s) => latlong.LatLng(s.latitude, s.longitude)).toList(),
        color: Colors.orange,
        strokeWidth: 4,
        borderColor: Colors.white,
        borderStrokeWidth: 1,
      ));
    }

    // 站點標記
    for (final station in stations) {
      final isRed = station.line == 'red';
      markers.add(Marker(
        point: latlong.LatLng(station.latitude, station.longitude),
        width: 28,
        height: 28,
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isRed ? Colors.red : Colors.orange,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 4, offset: const Offset(0, 2)),
            ],
          ),
          child: const Center(
            child: Icon(Icons.train, size: 14, color: Colors.white),
          ),
        ),
      ));
    }

    return Stack(children: [
      PolylineLayer(polylines: polylines),
      MarkerLayer(markers: markers),
    ]);
  }

  // 輕軌路線圖層
  Widget _buildLRTLayer(TransportState state) {
    final stations = state.lrtStations;
    if (stations.isEmpty) return const SizedBox.shrink();

    // 依序號排序
    final sortedStations = List<LRTStation>.from(stations)
      ..sort((a, b) => a.sequence.compareTo(b.sequence));

    final polylines = <Polyline>[];
    final markers = <Marker>[];

    // 環狀輕軌 Polyline
    if (sortedStations.length >= 2) {
      polylines.add(Polyline(
        points: sortedStations.map((s) => latlong.LatLng(s.latitude, s.longitude)).toList(),
        color: Colors.green,
        strokeWidth: 4,
        borderColor: Colors.white,
        borderStrokeWidth: 1,
        // 環狀線：首尾相連
      ));
    }

    // 站點標記
    for (final station in stations) {
      markers.add(Marker(
        point: latlong.LatLng(station.latitude, station.longitude),
        width: 26,
        height: 26,
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.green,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 4, offset: const Offset(0, 2)),
            ],
          ),
          child: const Center(
            child: Icon(Icons.tram, size: 12, color: Colors.white),
          ),
        ),
      ));
    }

    return Stack(children: [
      PolylineLayer(polylines: polylines),
      MarkerLayer(markers: markers),
    ]);
  }

  String _getAvailabilityColor(BikeStation station) {
    if (station.status == 'maintenance' || station.status == 'closed') {
      return '#FF1744';
    }
    if (station.availableBikes == 0) {
      return '#FF1744';
    }
    if (station.availabilityRatio < 0.2) {
      return '#FFD600';
    }
    return '#00C853';
  }

  Color _parseColor(String hex) {
    hex = hex.replaceFirst('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }

  Widget _buildSearchBar(BuildContext context, TransportState state, TransportNotifier notifier) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: SearchAnchor(
          builder: (context, controller) {
            return Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: TextEditingController(text: state.searchQuery),
                decoration: InputDecoration(
                  hintText: '搜尋 YouBike 站點...',
                  prefixIcon: Icon(Icons.search, color: theme.colorScheme.onSurfaceVariant),
                  suffixIcon: state.searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, color: theme.colorScheme.onSurfaceVariant),
                          onPressed: () => notifier.updateSearch(''),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                ),
                onChanged: notifier.updateSearch,
                onTap: () => controller.openView(),
              ),
            );
          },
          suggestionsBuilder: (context, controller) {
            if (state.filteredStations.isEmpty && state.searchQuery.isNotEmpty) {
              return [
                ListTile(
                  leading: Icon(Icons.location_off, color: theme.colorScheme.onSurfaceVariant),
                  title: Text('找不到相關站點', style: theme.textTheme.bodyMedium),
                ),
              ];
            }
            return state.filteredStations.take(10).map((station) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: _parseColor(_getAvailabilityColor(station)).withValues(alpha: 0.2),
                  child: Icon(Icons.pedal_bike, size: 20, color: _parseColor(_getAvailabilityColor(station))),
                ),
                title: Text(station.name, style: theme.textTheme.bodyMedium),
                subtitle: Text(
                  '${station.availableBikes} 車 / ${station.availableDocks} 位 · ${station.sarea ?? ''}',
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
                onTap: () {
                  controller.closeView('');
                  notifier.selectStation(station);
                  _flyToStation(station);
                },
              );
            }).toList();
          },
        ),
      ),
    );
  }

  void _flyToStation(BikeStation station) {
    _mapController.move(
      latlong.LatLng(station.latitude, station.longitude),
      17.0,
    );
  }

  Widget _buildActionButtons(BuildContext context, TransportState state, TransportNotifier notifier) {
    return Positioned(
      right: 16,
      bottom: 100, // 避開底部抽屜
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 圖層切換
          _ActionButton(
            icon: Icons.layers_outlined,
            onPressed: _showLayerBottomSheet,
            tooltip: '圖層設定',
          ),
          const SizedBox(height: 10),
          // 定位
          _ActionButton(
            icon: Icons.my_location_outlined,
            onPressed: _flyToUserLocation,
            tooltip: '定位到高醫中心',
          ),
          const SizedBox(height: 10),
          // 重新整理 - 使用 FAB 風格帶倒數計時進度環
          _RefreshFab(notifier: notifier),
        ],
      ),
    );
  }

  void _flyToUserLocation() {
    final location = ref.read(transportProvider).userLocation;
    if (location != null) {
      _mapController.move(location, 16.0);
    }
  }

  void _showLayerBottomSheet() {
    final state = ref.read(transportProvider);
    final notifier = ref.read(transportProvider.notifier);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text('地圖圖層', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _LayerToggle(
                      label: 'YouBike 站點',
                      icon: Icons.pedal_bike,
                      color: Colors.amber,
                      value: state.showBikeLayer,
                      onChanged: (_) => notifier.toggleBikeLayer(),
                    ),
                    _LayerToggle(
                      label: '公車路線',
                      icon: Icons.directions_bus,
                      color: Colors.blue,
                      value: state.showBusLayer,
                      onChanged: (_) => notifier.toggleBusLayer(),
                    ),
                    _LayerToggle(
                      label: '捷運紅/橘線',
                      icon: Icons.tram,
                      color: Colors.red,
                      value: state.showMetroLayer,
                      onChanged: (_) => notifier.toggleMetroLayer(),
                    ),
                    _LayerToggle(
                      label: '環狀輕軌',
                      icon: Icons.train,
                      color: Colors.green,
                      value: state.showLrtLayer,
                      onChanged: (_) => notifier.toggleLrtLayer(),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.refresh),
                            label: const Text('重新整理'),
                            onPressed: notifier.refreshBikeData,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton.icon(
                            icon: Icon(state.autoRefreshEnabled ? Icons.pause : Icons.play_arrow),
                            label: Text(state.autoRefreshEnabled ? '暫停自動更新' : '啟用自動更新'),
                            onPressed: () {
                              // TODO: 切換自動更新
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSheet(BuildContext context, TransportState state, TransportNotifier notifier) {
    if (state.selectedStation == null) {
      return const SizedBox.shrink();
    }

    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.25,
      maxChildSize: 1.0,
      snap: true,
      snapSizes: const [0.25, 0.5, 1.0],
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          children: [
            // 拖曳手把
            Container(
              margin: const EdgeInsets.only(top: 10),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // 內容
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
                children: _buildStationDetail(context, state.selectedStation!, notifier),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildStationDetail(BuildContext context, BikeStation station, TransportNotifier notifier) {
    final theme = Theme.of(context);
    final color = _parseColor(_getAvailabilityColor(station));
    final availablePercent = station.totalDocks > 0 ? station.availableBikes / station.totalDocks : 0.0;

    return [
      // 標題列
      Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: color.withValues(alpha: 0.15),
            child: Icon(Icons.pedal_bike, size: 28, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  station.name,
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (station.sarea != null)
                  Text(
                    station.sarea!,
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
              ],
            ),
          ),
          // 關閉按鈕
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: notifier.clearSelection,
            tooltip: '關閉',
          ),
        ],
      ),
      const SizedBox(height: 16),

      // 地址
      if (station.address != null) ...[
        Row(
          children: [
            Icon(Icons.place, size: 18, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                station.address!,
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],

      // 即時車位卡片
      Row(
        children: [
          // 可借車
          Expanded(
            child: _StatCard(
              label: '可借車',
              value: '${station.availableBikes}',
              icon: Icons.directions_bike,
              color: station.availableBikes > 0 ? Colors.green : Colors.red,
              progressColor: station.availableBikes > 0 ? Colors.green : Colors.red,
            ),
          ),
          const SizedBox(width: 12),
          // 可還車
          Expanded(
            child: _StatCard(
              label: '可還車',
              value: '${station.availableDocks}',
              icon: Icons.park,
              color: station.availableDocks > 0 ? Colors.green : Colors.red,
              progressColor: station.availableDocks > 0 ? Colors.green : Colors.red,
            ),
          ),
          const SizedBox(width: 12),
          // 總車位
          Expanded(
            child: _StatCard(
              label: '總車位',
              value: '${station.totalDocks}',
              icon: Icons.ev_station,
              color: theme.colorScheme.onSurfaceVariant,
              progressColor: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),

      // 進度條
      LinearProgressIndicator(
        value: availablePercent,
        backgroundColor: theme.colorScheme.surfaceContainerHighest,
        color: availablePercent > 0.3 ? Colors.green : (availablePercent > 0 ? Colors.orange : Colors.red),
        minHeight: 8,
        borderRadius: BorderRadius.circular(4),
      ),
      const SizedBox(height: 8),
      Row(
        children: [
          Text(
            '可用率 ${(availablePercent * 100).toStringAsFixed(0)}%',
            style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: (station.availableBikes > 0 && station.availableDocks > 0)
                  ? Colors.green.withValues(alpha: 0.15)
                  : Colors.red.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              (station.availableBikes > 0 && station.availableDocks > 0) ? '可使用' : '滿車/無位',
              style: theme.textTheme.labelSmall?.copyWith(
                color: (station.availableBikes > 0 && station.availableDocks > 0) ? Colors.green : Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 20),

      // 更新時間
      if (station.updatedAt != null || station.mday != null) ...[
        Text(
          '更新時間: ${station.mday ?? station.updatedAt}',
          style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 16),
      ],

      // 操作按鈕
      Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              icon: const Icon(Icons.navigation),
              label: const Text('導航前往'),
              onPressed: () => notifier.navigateToStation(station),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton.icon(
              icon: const Icon(Icons.directions_bike),
              label: const Text('查看路線'),
              onPressed: () {
                // TODO: 規劃騎乘路線
              },
            ),
          ),
        ],
      ),
    ];
  }
}

/// 圖層切換項目
class _LayerToggle extends StatelessWidget {
  const _LayerToggle({
    required this.label,
    required this.icon,
    required this.color,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500)),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: color,
          ),
        ],
      ),
    );
  }
}

/// 重新整理 FAB (帶倒數計時進度環) - 參考 YouBike Flutter 設計
class _RefreshFab extends ConsumerWidget {
  const _RefreshFab({required this.notifier});

  final TransportNotifier notifier;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final countdown = ref.watch(countdownProvider);

    return Tooltip(
      message: '重新整理資料',
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 進度環
          SizedBox(
            width: 64,
            height: 64,
            child: CircularProgressIndicator(
              value: countdown / 30,
              strokeWidth: 4,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
            ),
          ),
          // 圓形按鈕
          Material(
            color: theme.colorScheme.primaryContainer,
            elevation: 4,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: notifier.refreshBikeData,
              borderRadius: BorderRadius.circular(32),
              child: Container(
                width: 56,
                height: 56,
                alignment: Alignment.center,
                child: Icon(
                  Icons.refresh_rounded,
                  size: 28,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ),
          // 中央倒數文字
          Text(
            '$countdown',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}

/// 動作按鈕
class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Tooltip(
      message: tooltip,
      child: Material(
        color: theme.colorScheme.surface,
        elevation: 4,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(28),
          child: Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            child: Icon(icon, size: 24, color: theme.colorScheme.onSurface),
          ),
        ),
      ),
    );
  }
}

/// 統計卡片
class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.progressColor,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color progressColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(value, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700, color: color)),
          const SizedBox(height: 4),
          Text(label, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}