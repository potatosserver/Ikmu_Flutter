// API 端點介面定義
// 使用 KmuClient 封裝加密/解密、認證管理

import 'package:ikmu_flutter/core/api/kmu_client.dart';
import 'package:ikmu_flutter/core/constants/api_constants.dart';
import 'package:ikmu_flutter/core/api/models.dart';
import 'package:ikmu_flutter/core/utils/crypto_utils.dart';
import 'package:ikmu_flutter/core/utils/date_utils.dart';

/// 認證端點
class AuthEndpoint {
  AuthEndpoint(this._client);

  final KmuClient _client;

  /// 登入
  Future<LoginResponse> login({
    required String userId,
    required String password,
    String? fcmToken,
  }) async {
    final response = await _client.login(
      userId: userId,
      password: password,
      fcmToken: fcmToken,
    );

    if (response['success'] == true && response['data'] != null) {
      final items = response['data'] as Map<String, dynamic>;
      return LoginResponse(
        success: true,
        message: response['message']?.toString() ?? '登入成功',
        token: items['token'] as String?,
        userInfo: UserProfile(
          userId: items['userId'] as String? ?? userId,
          userName: items['userName'] as String? ?? '',
          userType: items['userType'] as String? ?? '',
        ),
      );
    }

    return LoginResponse(
      success: false,
      message: response['message']?.toString() ?? '登入失敗',
    );
  }

  /// 登出
  Future<ApiResponse> logout(String token) async {
    _client.clearCredentials();
    return const ApiResponse(
      success: true,
      message: '已登出',
    );
  }
}

/// 行事曆端點
class CalendarEndpoint {
  CalendarEndpoint(this._client);

  final KmuClient _client;

  /// 取得日事件 (單日)
  Future<List<CalendarEvent>> getDayEvents({
    required String date, // YYYY-MM-DD
  }) async {
    final response = await _client.get(
      ApiEndpoints.calendar,
      queryParameters: {'d': date},
    );

    if (response['success'] == true && response['data'] != null) {
      final data = response['data'];
      List<dynamic> list = [];
      if (data is List) {
        list = data;
      } else if (data is Map) {
        final mapData = Map<String, dynamic>.from(data);
        final events = mapData['events'] ?? mapData['items'] ?? mapData['days'];
        if (events is List) {
          list = events;
        } else {
          // 處理 {"0": {...}, "1": {...}} 格式
          list = mapData.values.toList();
        }
      }

      return list
          .whereType<Map>()
          .map((e) {
            final map = Map<String, dynamic>.from(e);
            // 若 API 回傳缺少 date 或 dateFrom，自動補上查詢當日的日期
            if (map['date'] == null && map['dateFrom'] == null) {
              map['date'] = date;
            }
            return CalendarEvent.fromApi(map);
          })
          .toList();
    }
    // API 回傳 success != true 或無資料
    throw Exception('API 回傳失敗: ${response['message'] ?? '未知錯誤'}');
  }

  /// 取得月份所有事件 (自動平行併發下載 7x6 格子共 42 天，含上下月重疊天數)
  Future<List<CalendarEvent>> getMonthEvents({
    required String yearMonth, // YYYY-MM
  }) async {
    final parts = yearMonth.split('-');
    if (parts.length < 2) return [];

    final year = int.tryParse(parts[0]) ?? DateTime.now().year;
    final month = int.tryParse(parts[1]) ?? DateTime.now().month;

    // 計算該月第一天和最後一天
    final firstDayOfMonth = DateTime(year, month, 1);
    final lastDayOfMonth = DateTime(year, month + 1, 0);

    // 7x6 固定網格：週日為起始，共 42 格 (6 週)
    // 找出第一格的日期 (該月 1 號所在週的週日)
    final firstWeekday = firstDayOfMonth.weekday % 7; // 0=Sun, 1=Mon...
    final gridStartDate = firstDayOfMonth.subtract(Duration(days: firstWeekday));
    
    // 最後一格的日期 (該月最後一天所在週的週六)
    final lastWeekday = lastDayOfMonth.weekday % 7;
    final daysToAdd = (6 - lastWeekday) % 7; // 到週六需要加的天數
    final gridEndDate = lastDayOfMonth.add(Duration(days: daysToAdd));

    // 計算總天數
    final totalDays = gridEndDate.difference(gridStartDate).inDays + 1;

    // 產生所有 42 天的非同步請求列表
    final futures = List.generate(totalDays, (index) {
      final d = gridStartDate.add(Duration(days: index));
      final dateStr =
          '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      return getDayEvents(date: dateStr);
    });

    // 平行同時抓取所有天數
    final results = await Future.wait(futures);

    // 攤平 (flatten) 為單一事件清單
    final allEvents = <CalendarEvent>[];
    for (final dayEvents in results) {
      allEvents.addAll(dayEvents);
    }
    return allEvents;
  }

  /// 取得週所有事件 (自動平行併發下載該週 7 天，週日到週六)
  Future<List<CalendarEvent>> getWeekEvents({
    required String weekStart, // YYYY-MM-DD
  }) async {
    final startDate = DateTime.tryParse(weekStart);
    if (startDate == null) return [];

    // 確保起始是週日
    final weekStartDate = DateUtils.getWeekStart(startDate);

    final futures = List.generate(7, (i) {
      final d = weekStartDate.add(Duration(days: i));
      final dateStr =
          '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      return getDayEvents(date: dateStr);
    });

    final results = await Future.wait(futures);
    return results.expand((dayList) => dayList).toList();
  }

  Future<EventDetailData?> getEventDetail({
    required String eventId,
  }) async => null;
}

/// 場地查詢端點
class ClassroomEndpoint {
  ClassroomEndpoint(this._client);

  final KmuClient _client;

  // 快取清單以供詳情查詢
  List<ClassroomRoom>? _cachedRooms;

  /// 取得場地列表
  Future<List<ClassroomRoom>> getRooms({
    String? categoryId,
    String? buildingId,
  }) async {
    final response = await _client.get(ApiEndpoints.classroomList);

    if (response['success'] == true && response['data'] != null) {
      final data = response['data'];
      if (data is List) {
        var rooms = data
            .whereType<Map>()
            .map((e) => ClassroomRoom.fromJson(Map<String, dynamic>.from(e)))
            .toList();

        _cachedRooms = rooms;

        if (categoryId != null && categoryId.isNotEmpty) {
          rooms = rooms.where((r) => r.categoryName == categoryId || r.categoryId == categoryId).toList();
        }

        return rooms;
      }
    }
    return [];
  }

  /// 取得場地分類（從場地清單中動態分組）
  Future<List<ClassroomCategory>> getCategories() async {
    final rooms = _cachedRooms ?? await getRooms();
    final Map<String, int> categoryCounts = {};

    for (final room in rooms) {
      final catName = room.categoryName;
      final cat = (catName != null && catName.isNotEmpty) ? catName : '其他';
      categoryCounts[cat] = (categoryCounts[cat] ?? 0) + 1;
    }

    return categoryCounts.entries.map((entry) {
      return ClassroomCategory(
        id: entry.key,
        name: entry.key,
        roomCount: entry.value,
      );
    }).toList();
  }

  /// 取得場地詳情
  Future<ClassroomDetail?> getRoomDetail({
    required String roomId,
  }) async {
    final rooms = _cachedRooms ?? await getRooms();
    try {
      final room = rooms.firstWhere(
        (r) => r.id == roomId || r.name == roomId,
      );
      return ClassroomDetail(
        id: room.id,
        name: room.name,
        capacity: room.capacity,
      );
    } catch (_) {
      return ClassroomDetail(
        id: roomId,
        name: roomId,
      );
    }
  }

  /// 取得場地使用狀況（對齊 Python: /getClassroomUsageByDate）
  Future<ClassroomUsageResponse?> getUsage({
    required String roomId,
    required String date, // YYYY-MM-DD
  }) async {
    final response = await _client.get(
      '/getClassroomUsageByDate',
      queryParameters: {
        'plano': roomId,
        'date': date,
      },
    );

    if (response['success'] == true && response['data'] != null) {
      final data = response['data'];
      final List<TimeSlot> timeSlots = [];

      if (data is List && data.isNotEmpty) {
        final first = Map<String, dynamic>.from(data.first as Map);

        const startTimes = [
          '08:10', '09:10', '10:10', '11:10',
          '12:10', '13:10', '14:10', '15:10',
          '16:10', '17:10', '18:10', '19:10',
          '20:10', '21:10',
        ];
        const endTimes = [
          '09:00', '10:00', '11:00', '12:00',
          '13:00', '14:00', '15:00', '16:00',
          '17:00', '18:00', '19:00', '20:00',
          '21:00', '22:00',
        ];

        for (int i = 1; i <= 14; i++) {
          final slotKey = 't$i';
          final val = first[slotKey]?.toString().trim() ?? '';
          final status = (val.isEmpty || val == '空閒' || val == '可借')
              ? 'free'
              : (val.contains('借出') ? 'pending' : 'busy');

          timeSlots.add(
            TimeSlot(
              id: 't$i',
              startTime: startTimes[i - 1],
              endTime: endTimes[i - 1],
              status: status,
            ),
          );
        }
      }

      final usage = ClassroomUsage(
        room: ClassroomDetail(id: roomId, name: ''),
        date: date,
        timeSlots: timeSlots,
      );

      return ClassroomUsageResponse(
        success: true,
        message: '成功',
        data: [usage],
      );
    }

    return ClassroomUsageResponse(
      success: true,
      message: '成功',
      data: [
        ClassroomUsage(
          room: ClassroomDetail(id: roomId, name: ''),
          date: date,
          timeSlots: const [],
        ),
      ],
    );
  }
}

/// 課務端點
class CourseEndpoint {
  CourseEndpoint(this._client);

  final KmuClient _client;

  /// 取得課表
  Future<MyScheduleResponse?> getSchedule({
    required String userId,
    required String password,
  }) async {
    final encryptedId = CryptoUtils.encrypt3DesHex(userId);
    final encryptedPw = CryptoUtils.encrypt3DesHex(password);
    final response = await _client.get(
      ApiEndpoints.myClass,
      queryParameters: {
        'id': encryptedId,
        'pw': encryptedPw,
      },
    );

    if (response['success'] == true && response['data'] != null) {
      return MyScheduleResponse.fromJson({
        'success': true,
        'message': response['message']?.toString() ?? '成功',
        'data': response['data'],
      });
    }
    return null;
  }

  /// 取得成績學期清單
  Future<List<SemesterInfo>> getSemesters({
    required String userId,
    required String password,
  }) async {
    final encryptedId = CryptoUtils.encrypt3DesHex(userId);
    final encryptedPw = CryptoUtils.encrypt3DesHex(password);
    final response = await _client.get(
      ApiEndpoints.myScoreSem,
      queryParameters: {
        'id': encryptedId,
        'pw': encryptedPw,
      },
    );

    if (response['success'] == true && response['data'] is List) {
      final dataList = (response['data'] as List)
          .map((e) => SemesterInfo.fromJson(e as Map<String, dynamic>))
          .toList();
      return dataList;
    }
    return [];
  }

  /// 取得成績
  Future<MyScoresResponse?> getScores({
    required String year,
    required String sem,
    required String userId,
    required String password,
  }) async {
    final encryptedId = CryptoUtils.encrypt3DesHex(userId);
    final encryptedPw = CryptoUtils.encrypt3DesHex(password);
    final response = await _client.get(
      ApiEndpoints.myScoreHis,
      queryParameters: {
        'id': encryptedId,
        'pw': encryptedPw,
        'year': year,
        'sem': sem,
      },
    );

    if (response['success'] == true && response['data'] != null) {
      return MyScoresResponse.fromJson({
        'success': true,
        'message': response['message']?.toString() ?? '成功',
        'data': response['data'],
      });
    }
    return null;
  }

  /// 取得課程詳細資料
  Future<Map<String, dynamic>?> getClassDetail({
    required String seq,
    required String userId,
    required String password,
  }) async {
    final encryptedId = CryptoUtils.encrypt3DesHex(userId);
    final encryptedPw = CryptoUtils.encrypt3DesHex(password);
    final response = await _client.get(
      ApiEndpoints.myClassDetail,
      queryParameters: {
        'id': encryptedId,
        'pw': encryptedPw,
        'seq': seq,
      },
    );

    if (response['success'] == true && response['data'] != null) {
      if (response['data'] is Map<String, dynamic>) {
        return response['data'] as Map<String, dynamic>;
      }
      if (response['data'] is List && (response['data'] as List).isNotEmpty) {
        return (response['data'] as List).first as Map<String, dynamic>;
      }
    }
    return null;
  }
}

/// 交通端點
class TransportEndpoint {
  TransportEndpoint(this._client);

  final KmuClient _client;

  /// 取得公車路線
  Future<List<BusRoute>> getBusRoutes() async {
    final response = await _client.get(ApiEndpoints.busRoute);

    if (response['success'] == true && response['data'] is List) {
      final dataList = (response['data'] as List)
          .map((e) => BusRoute.fromJson(e as Map<String, dynamic>))
          .toList();
      return dataList;
    }
    return [];
  }

  /// 取得公車即時資訊
  Future<List<BusRealtime>> getBusRealtime({
    required String routeId,
  }) async {
    final response = await _client.get(
      ApiEndpoints.busRealtime,
      queryParameters: {'route_id': routeId},
    );

    if (response['success'] == true && response['data'] is List) {
      final dataList = (response['data'] as List)
          .map((e) => BusRealtime.fromJson(e as Map<String, dynamic>))
          .toList();
      return dataList;
    }
    return [];
  }

  /// 取得 YouBike 站點
  Future<List<BikeStation>> getBikeStations() async {
    final response = await _client.get(ApiEndpoints.bikeStation);

    if (response['success'] == true && response['data'] is List) {
      final dataList = (response['data'] as List)
          .map((e) => BikeStation.fromJson(e as Map<String, dynamic>))
          .toList();
      return dataList;
    }
    return [];
  }

  /// 取得公車站牌
  Future<BusStopResponse> getBusStops(String routeId) async {
    final response = await _client.get(
      '${ApiEndpoints.busRoute}/$routeId/stops',
    );

    if (response['success'] == true && response['data'] != null) {
      return BusStopResponse.fromJson(response['data'] as Map<String, dynamic>);
    }
    return const BusStopResponse(success: false, message: '載入站牌失敗', stops: []);
  }
}

/// 校園資訊端點
class CampusInfoEndpoint {
  CampusInfoEndpoint(this._client);

  final KmuClient _client;

  /// 取得新聞列表
  Future<NewsListResponse?> getNewsList({
    String? category,
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _client.get(
      ApiEndpoints.newsList,
      queryParameters: {
        if (category != null) 'category': category,
        'page': page,
        'page_size': pageSize,
      },
    );

    if (response['success'] == true && response['data'] != null) {
      return NewsListResponse.fromJson(response['data'] as Map<String, dynamic>);
    }
    return null;
  }

  /// 取得新聞詳情
  Future<NewsDetailResponse?> getNewsDetail({
    required String newsId,
  }) async {
    final response = await _client.get(
      ApiEndpoints.newsDetail,
      queryParameters: {'news_id': newsId},
    );

    if (response['success'] == true && response['data'] != null) {
      return NewsDetailResponse.fromJson(response['data'] as Map<String, dynamic>);
    }
    return null;
  }

  /// 取得交通資訊
  Future<List<TrafficInfo>> getTrafficInfo() async {
    final response = await _client.get(ApiEndpoints.trafficInfo);

    if (response['success'] == true && response['data'] is List) {
      final dataList = (response['data'] as List)
          .map((e) => TrafficInfo.fromJson(e as Map<String, dynamic>))
          .toList();
      return dataList;
    }
    return [];
  }

  /// 取得 POI
  Future<List<POI>> getPOI() async {
    final response = await _client.get(ApiEndpoints.poiList);

    if (response['success'] == true && response['data'] is List) {
      final dataList = (response['data'] as List)
          .map((e) => POI.fromJson(e as Map<String, dynamic>))
          .toList();
      return dataList;
    }
    return [];
  }

  /// 取得圖庫
  Future<List<GalleryItem>> getGallery() async {
    final response = await _client.get(ApiEndpoints.gallery);

    if (response['success'] == true && response['data'] is List) {
      final dataList = (response['data'] as List)
          .map((e) => GalleryItem.fromJson(e as Map<String, dynamic>))
          .toList();
      return dataList;
    }
    return [];
  }
}

/// 端點整合類
class Endpoints {
  Endpoints(this._client);

  final KmuClient _client;

  late final AuthEndpoint auth = AuthEndpoint(_client);
  late final CalendarEndpoint calendar = CalendarEndpoint(_client);
  late final ClassroomEndpoint classroom = ClassroomEndpoint(_client);
  late final CourseEndpoint courses = CourseEndpoint(_client);
  late final TransportEndpoint transport = TransportEndpoint(_client);
  late final CampusInfoEndpoint campusInfo = CampusInfoEndpoint(_client);
}