// 交通整合頁面 - 地圖為中心
// 整合公車、YouBike、捷運、輕軌圖層
// 使用 flutter_map + vector_map_tiles 向量瓦片
// 響應式設計支援窄/寬螢幕

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
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core.dart';
import '../../../../core/constants/location_constants.dart';
import '../../../core/ui/responsive.dart';

/// Transport 頁面狀態
@immutable
class TransportState {
  const TransportState({
    this.bikeStations = const [],
    this.metroStations = const [],
    this.lrtStations = const [],
    this.metroRealtime = const [],
    this.selectedStation,
    this.selectedMetroStation,
    this.userLocation,
    this.isLoading = false,
    this.isLoadingLRT = false,
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
  final List<MetroRealtime> metroRealtime;
  final BikeStation? selectedStation;
  final MetroStation? selectedMetroStation;
  final latlong.LatLng? userLocation;
  final bool isLoading;
  final bool isLoadingLRT;
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
    List<MetroRealtime>? metroRealtime,
    BikeStation? selectedStation,
    MetroStation? selectedMetroStation,
    latlong.LatLng? userLocation,
    bool? isLoading,
    bool? isLoadingLRT,
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
    bool clearSelectedMetroStation = false,
  }) {
    return TransportState(
      bikeStations: bikeStations ?? this.bikeStations,
      metroStations: metroStations ?? this.metroStations,
      lrtStations: lrtStations ?? this.lrtStations,
      metroRealtime: metroRealtime ?? this.metroRealtime,
      selectedStation: clearSelectedStation ? null : (selectedStation ?? this.selectedStation),
      selectedMetroStation: clearSelectedMetroStation ? null : (selectedMetroStation ?? this.selectedMetroStation),
      userLocation: userLocation ?? this.userLocation,
      isLoading: isLoading ?? this.isLoading,
      isLoadingLRT: isLoadingLRT ?? this.isLoadingLRT,
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

    // 載入儲存的圖層偏好設定
    _loadLayerPreferences();

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

  Future<void> _loadLayerPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final showBikeLayer = prefs.getBool('transport_show_bike_layer') ?? true;
      final showBusLayer = prefs.getBool('transport_show_bus_layer') ?? false;
      final showMetroLayer = prefs.getBool('transport_show_metro_layer') ?? false;
      final showLrtLayer = prefs.getBool('transport_show_lrt_layer') ?? false;
      final autoRefreshEnabled = prefs.getBool('transport_auto_refresh') ?? true;
      
      state = state.copyWith(
        showBikeLayer: showBikeLayer,
        showBusLayer: showBusLayer,
        showMetroLayer: showMetroLayer,
        showLrtLayer: showLrtLayer,
        autoRefreshEnabled: autoRefreshEnabled,
      );
    } catch (e) {
      debugPrint('載入圖層偏好失敗: $e');
    }
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
      loadMetroRealtime(),
      loadLRTRealtime(),
    ]);
  }

  Future<void> _loadBikeStations() async {
    final location = state.userLocation;
    if (location == null) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      const cacheKey = 'bike_stations_realtime';
      final cachedJson = await _cache.getSimple<List<dynamic>>(CacheBoxes.transport, cacheKey);

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
        // 序列化為 JSON 供 sqflite 儲存
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
    final newValue = !state.showBikeLayer;
    state = state.copyWith(showBikeLayer: newValue);
    _saveLayerPreference('transport_show_bike_layer', newValue);
  }

  void toggleBusLayer() {
    final newValue = !state.showBusLayer;
    state = state.copyWith(showBusLayer: newValue);
    _saveLayerPreference('transport_show_bus_layer', newValue);
  }

  void toggleMetroLayer() {
    final newValue = !state.showMetroLayer;
    state = state.copyWith(showMetroLayer: newValue);
    _saveLayerPreference('transport_show_metro_layer', newValue);
  }

  void toggleLrtLayer() {
    final newValue = !state.showLrtLayer;
    state = state.copyWith(showLrtLayer: newValue);
    _saveLayerPreference('transport_show_lrt_layer', newValue);
  }

  Future<void> _saveLayerPreference(String key, bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(key, value);
    } catch (e) {
      debugPrint('儲存圖層偏好失敗: $e');
    }
  }

  void selectStation(BikeStation station) {
    state = state.copyWith(selectedStation: station, clearSelectedMetroStation: true);
  }

  void selectMetroStation(MetroStation station) {
    state = state.copyWith(selectedMetroStation: station, clearSelectedStation: true);
  }

  void selectLRTStation(LRTStation station) {
    state = state.copyWith(selectedMetroStation: MetroStation(
      id: station.id,
      name: station.name,
      nameEn: station.nameEn,
      latitude: station.latitude,
      longitude: station.longitude,
      line: 'C',
      sequence: station.sequence,
      address: station.address,
      transfer: null,
    ), clearSelectedStation: true);
  }

  void clearSelection() {
    state = state.copyWith(clearSelectedStation: true, clearSelectedMetroStation: true);
  }

  void toggleAutoRefresh() {
    final newValue = !state.autoRefreshEnabled;
    state = state.copyWith(autoRefreshEnabled: newValue);
    _saveLayerPreference('transport_auto_refresh', newValue);
    if (newValue) {
      _startAutoRefresh();
    } else {
      _refreshTimer?.cancel();
    }
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

  Future<void> navigateToStationWithRoute(BikeStation station) async {
    // 使用 Google Maps 導航模式 (包含路線規劃)
    final url = 'https://www.google.com/maps/dir/?api=1&destination=${station.latitude},${station.longitude}&travelmode=bicycling';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  // 捷運站點載入
  Future<void> loadMetroStations() async {
    state = state.copyWith(isLoading: true);
    try {
      const cacheKey = 'metro_stations';
      final cachedJson = await _cache.getSimple<List<dynamic>>(CacheBoxes.transport, cacheKey);
      
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
    state = state.copyWith(isLoadingLRT: true);
    try {
      const cacheKey = 'lrt_stations';
      final cachedJson = await _cache.getSimple<List<dynamic>>(CacheBoxes.transport, cacheKey);
      
      if (cachedJson != null && cachedJson.isNotEmpty) {
        final cached = cachedJson
            .whereType<Map>()
            .map((e) => LRTStation.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        state = state.copyWith(lrtStations: cached, isLoadingLRT: false);
      }

      final stations = await _endpoints.transport.getLRTStations();
      
      if (stations.isNotEmpty) {
        final jsonList = stations.map((s) => s.toJson()).toList();
        await _cache.setSimple(CacheBoxes.transport, cacheKey, jsonList, ttl: CacheTTL.transport);
        state = state.copyWith(lrtStations: stations, isLoadingLRT: false);
      } else if (state.lrtStations.isEmpty) {
        state = state.copyWith(isLoadingLRT: false);
      }
    } catch (e) {
      debugPrint('載入輕軌站點失敗: $e');
      if (state.lrtStations.isEmpty) {
        state = state.copyWith(isLoadingLRT: false);
      }
    }
  }

  // 捷運即時到站載入
  Future<void> loadMetroRealtime() async {
    try {
      final realtime = await _endpoints.transport.getMetroRealtime();
      if (realtime.isNotEmpty) {
        state = state.copyWith(metroRealtime: realtime);
      }
    } catch (e) {
      debugPrint('載入捷運即時到站失敗: $e');
    }
  }

  // 輕軌即時到站載入
  Future<void> loadLRTRealtime() async {
    try {
      final realtime = await _endpoints.transport.getLRTRealtime();
      if (realtime.isNotEmpty) {
        // 合併捷運與輕軌即時到站資料
        final combined = [...state.metroRealtime, ...realtime];
        state = state.copyWith(metroRealtime: combined);
      }
    } catch (e) {
      debugPrint('載入輕軌即時到站失敗: $e');
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
  static const double _defaultZoom = 14.0; // OpenFreeMap maxZoom = 14

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
      final styleMap = styleJson as Map<String, dynamic>;
      
      final center = styleMap['center'];
      latlong.LatLng? centerPoint;
      if (center is List<dynamic> && center.length == 2) {
        centerPoint = latlong.LatLng((center[1] as num).toDouble(), (center[0] as num).toDouble());
      }
      double? zoom = (styleMap['zoom'] as num?)?.toDouble();
      if (zoom != null && zoom < 2) {
        zoom = null;
        centerPoint = null;
      }
      
      final styleObj = Style(
        name: styleMap['name'] as String?,
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
        final source = entry.value as Map<String, dynamic>;
        final sourceType = source['type'] as String?;
        if (sourceType != 'vector') continue;

        // 支援兩種格式：
        // 1. tiles 陣列: "tiles": ["https://.../{z}/{x}/{y}.pbf"]
        // 2. url 單一模板: "url": "https://.../{z}/{x}/{y}.pbf"
        final entryTiles = source['tiles'];
        final entryUrl = source['url'];
        final maxzoom = source['maxzoom'] as int? ?? 14;
        final minzoom = source['minzoom'] as int? ?? 1;

        String? tileUrl;
        if (entryTiles is List<dynamic> && entryTiles.isNotEmpty) {
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
    // 監聽捷運即時到站資料
    ref.listen<List<MetroRealtime>>(
      transportProvider.select((s) => s.metroRealtime),
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
        AnimatedOpacity(
          opacity: state.showMetroLayer ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: IgnorePointer(
            ignoring: !state.showMetroLayer,
            child: _buildMetroLayer(state),
          ),
        ),
        // 輕軌路線圖層 (環狀輕軌)
        AnimatedOpacity(
          opacity: state.showLrtLayer ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: IgnorePointer(
            ignoring: !state.showLrtLayer,
            child: _buildLRTLayer(state),
          ),
        ),
        // YouBike 站點圖層
        AnimatedOpacity(
          opacity: state.showBikeLayer ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: IgnorePointer(
            ignoring: !state.showBikeLayer,
            child: _buildBikeLayer(state),
          ),
        ),
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

    // 依路線前綴分組
    final redLine = stations.where((s) => s.id.startsWith('R')).toList();
    final orangeLine = stations.where((s) => s.id.startsWith('O')).toList();

    // 依 ID 的數字部分排序
    int extractNumber(String id) {
      final match = RegExp(r'(\d+)').firstMatch(id);
      return match != null ? int.parse(match.group(1)!) : 0;
    }

    redLine.sort((a, b) => extractNumber(a.id).compareTo(extractNumber(b.id)));
    orangeLine.sort((a, b) => extractNumber(a.id).compareTo(extractNumber(b.id)));

    // 過濾支線站點，只保留主線
    // 紅線主線: R3-R24 (數字 3-24) + RK1 (岡山車站)
    // 橘線主線: O1-O14 (數字 1-14)，排除 OT1 (大寮支線)
    final redMainLine = redLine.where((s) {
      final num = extractNumber(s.id);
      return (s.id.startsWith('R') && num >= 3 && num <= 24) || s.id == 'RK1';
    }).toList();
    final orangeMainLine = orangeLine.where((s) {
      final num = extractNumber(s.id);
      return s.id.startsWith('O') && !s.id.startsWith('OT') && num >= 1 && num <= 14;
    }).toList();

    final polylines = <Polyline>[];
    final markers = <Marker>[];

    // 紅線 Polyline (僅主線)
    if (redMainLine.length >= 2) {
      polylines.add(Polyline(
        points: redMainLine.map((s) => latlong.LatLng(s.latitude, s.longitude)).toList(),
        color: Colors.red,
        strokeWidth: 4,
        borderColor: Colors.white,
        borderStrokeWidth: 1,
      ));
    }
    // 橘線 Polyline (僅主線)
    if (orangeMainLine.length >= 2) {
      polylines.add(Polyline(
        points: orangeMainLine.map((s) => latlong.LatLng(s.latitude, s.longitude)).toList(),
        color: Colors.orange,
        strokeWidth: 4,
        borderColor: Colors.white,
        borderStrokeWidth: 1,
      ));
    }

    // 站點標記 (顯示所有站點含支線，支線用較小/空心圖示區分)
    for (final station in stations) {
      final isRed = station.id.startsWith('R');
      final isOrange = station.id.startsWith('O');
      final num = extractNumber(station.id);
      final isBranch = (isRed && ((num < 3 || num > 24) && station.id != 'RK1')) ||
                       (isOrange && (station.id.startsWith('OT') || num < 1 || num > 14));

      markers.add(Marker(
        point: latlong.LatLng(station.latitude, station.longitude),
        width: isBranch ? 22 : 28,
        height: isBranch ? 22 : 28,
        child: GestureDetector(
          onTap: () => ref.read(transportProvider.notifier).selectMetroStation(station),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isRed ? Colors.red : Colors.orange,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 4, offset: const Offset(0, 2)),
              ],
            ),
            child: Center(
              child: Icon(
                isBranch ? Icons.train_outlined : Icons.train,
                size: isBranch ? 10 : 14,
                color: Colors.white,
              ),
            ),
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

    // 依 ID 的數字部分排序 (C1, C2, C3... 而非 C1, C10, C11...)
    int extractNumber(String id) {
      final match = RegExp(r'(\d+)').firstMatch(id);
      return match != null ? int.parse(match.group(1)!) : 0;
    }

    final sortedStations = List<LRTStation>.from(stations)
      ..sort((a, b) => extractNumber(a.id).compareTo(extractNumber(b.id)));

    // 過濾掉支線站點 (如 C21A)，環狀線主線只保留 C1-C37
    final mainLineStations = sortedStations.where((s) => !RegExp(r'[A-Z]$').hasMatch(s.id)).toList();

    final polylines = <Polyline>[];
    final markers = <Marker>[];

    // 環狀輕軌 Polyline (僅主線，首尾相連形成環)
    if (mainLineStations.length >= 2) {
      final points = mainLineStations.map((s) => latlong.LatLng(s.latitude, s.longitude)).toList();
      // 環狀線：加入第一個點以閉合
      points.add(points.first);
      polylines.add(Polyline(
        points: points,
        color: Colors.green,
        strokeWidth: 4,
        borderColor: Colors.white,
        borderStrokeWidth: 1,
      ));
    }

    // 站點標記 (顯示所有站點含支線)
    for (final station in stations) {
      final isBranch = RegExp(r'[A-Z]$').hasMatch(station.id);
      markers.add(Marker(
        point: latlong.LatLng(station.latitude, station.longitude),
        width: isBranch ? 20 : 26,
        height: isBranch ? 20 : 26,
        child: GestureDetector(
          onTap: () => ref.read(transportProvider.notifier).selectLRTStation(station),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.green,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 4, offset: const Offset(0, 2)),
              ],
            ),
            child: Center(
              child: Icon(
                isBranch ? Icons.tram_outlined : Icons.tram,
                size: isBranch ? 10 : 12,
                color: Colors.white,
              ),
            ),
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
    // 統一使用 YouBike 黃色
    return '#FFD600';
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
    final rb = ResponsiveBreakpoints.of(context);
    final buttonSize = const ResponsiveValue<double>(
      mobile: 48,
      tablet: 52,
      desktop: 56,
    ).resolve(context);
    final spacing = ResponsiveSpacing.responsive(context, mobile: 8, desktop: 12);

    return Positioned(
      right: rb.isMobile ? 12 : 16,
      bottom: rb.isMobile ? 120 : 100,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ActionButton(
            icon: Icons.layers_outlined,
            onPressed: () => _showLayerBottomSheet(context),
            tooltip: '圖層設定',
            size: buttonSize,
          ),
          SizedBox(height: spacing),
          _ActionButton(
            icon: Icons.my_location_outlined,
            onPressed: _flyToUserLocation,
            tooltip: '定位到高醫中心',
            size: buttonSize,
          ),
          SizedBox(height: spacing),
          _RefreshFab(notifier: notifier, size: buttonSize + 8),
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

  void _showLayerBottomSheet(BuildContext context) {
    final notifier = ref.read(transportProvider.notifier);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Consumer(
        builder: (context, ref, _) {
          final state = ref.watch(transportProvider);
          return Padding(
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
                                onPressed: () => notifier.toggleAutoRefresh(),
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
          );
        },
      ),
    );
  }

  Widget _buildBottomSheet(BuildContext context, TransportState state, TransportNotifier notifier) {
    if (state.selectedStation == null && state.selectedMetroStation == null) {
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
                children: state.selectedMetroStation != null
                    ? _buildMetroStationDetail(context, state.selectedMetroStation!, state, notifier)
                    : _buildStationDetail(context, state.selectedStation!, notifier),
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
              onPressed: () => notifier.navigateToStationWithRoute(station),
            ),
          ),
        ],
      ),
    ];
  }

  List<Widget> _buildMetroStationDetail(BuildContext context, MetroStation station, TransportState state, TransportNotifier notifier) {
    final theme = Theme.of(context);
    final isRed = station.line == 'red';
    final lineColor = isRed ? Colors.red : Colors.orange;
    
    // 找該站的即時到站資訊
    final realtimeList = state.metroRealtime.where((r) => r.stationId == station.id).toList();
    
    return [
      // 標題列
      Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: lineColor.withValues(alpha: 0.15),
            child: Icon(Icons.train, size: 28, color: lineColor),
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
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: lineColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        isRed ? '紅線' : '橘線',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: lineColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (station.transfer != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '轉乘: ${station.transfer}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
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

      // 即時到站資訊
      if (realtimeList.isNotEmpty) ...[
        Text('即時到站', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        ...realtimeList.map((rt) => _MetroRealtimeCard(realtime: rt, lineColor: lineColor)),
        const SizedBox(height: 16),
      ] else ...[
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.schedule, size: 20, color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(width: 12),
              Text('無即時到站資料', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            ],
          ),
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
              onPressed: () {
                final url = 'https://www.google.com/maps/search/?api=1&query=${station.latitude},${station.longitude}';
                launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
              },
            ),
          ),
        ],
      ),
    ];
  }
}

/// 捷運即時到站卡片
class _MetroRealtimeCard extends StatelessWidget {
  const _MetroRealtimeCard({required this.realtime, required this.lineColor});

  final MetroRealtime realtime;
  final Color lineColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isArriving = realtime.estimateTime < 60;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isArriving 
            ? lineColor.withValues(alpha: 0.15)
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isArriving ? lineColor : theme.colorScheme.outlineVariant,
        ),
      ),
      child: Row(
        children: [
          // 方向
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: lineColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              realtime.tripHeadSign,
              style: theme.textTheme.labelMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // 終點站
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '往 ${realtime.destinationStationName}',
                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  realtime.lineName,
                  style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          // 到站時間
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                realtime.displayTime,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isArriving ? lineColor : theme.colorScheme.onSurface,
                ),
              ),
              if (isArriving)
                Text(
                  '即將進站',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: lineColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
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
  const _RefreshFab({required this.notifier, required this.size});

  final TransportNotifier notifier;
  final double size;

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
            width: size,
            height: size,
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
              borderRadius: BorderRadius.circular(size / 2),
              child: Container(
                width: size - 8,
                height: size - 8,
                alignment: Alignment.center,
                child: Icon(
                  Icons.refresh_rounded,
                  size: size * 0.5,
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
              fontSize: size * 0.35,
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
    this.size = 52,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;
  final double size;

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
          borderRadius: BorderRadius.circular(size / 2),
          child: Container(
            width: size,
            height: size,
            alignment: Alignment.center,
            child: Icon(icon, size: size * 0.46, color: theme.colorScheme.onSurface),
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