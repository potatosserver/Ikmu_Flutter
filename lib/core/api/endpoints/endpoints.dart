// API 端點介面定義
// 使用 KmuClient 封裝加密/解密、認證管理

import 'package:ikmu_flutter/core/api/kmu_client.dart';
import 'package:ikmu_flutter/core/constants/api_constants.dart';
import 'package:ikmu_flutter/core/api/models.dart';
import 'package:ikmu_flutter/core/utils/crypto_utils.dart';

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

    // 對齊 Python ikmu.py: 回應是 {result: "true", items: {token, userId, userName, userType, ...}}
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
    return ApiResponse(
      success: true,
      message: '已登出',
    );
  }

  /// 安全提取 message，支援 String 或 int
  String _extractMessage(dynamic message) {
    if (message == null) return '';
    if (message is String) return message;
    if (message is int) return message.toString();
    return message.toString();
  }
}

/// 行事曆端點
/// Python API: /getCalendarEvent?d=yyyy-MM-dd (單日查詢，回傳整月事件)
class CalendarEndpoint {
  CalendarEndpoint(this._client);

  final KmuClient _client;

  /// 取得月份事件 - Python API: 傳入當月任一天 (例 2026-09-01)
  /// API 會回傳整個月份的事件
  Future<List<CalendarEvent>> getMonthEvents({
    required String yearMonth, // YYYY-MM
  }) async {
    // Python API 用 d=yyyy-MM-dd，取當月第一天
    final date = '$yearMonth-01';
    final response = await _client.get(
      ApiEndpoints.calendar,
      queryParameters: {'d': date},
    );

    if (response['success'] == true && response['data'] != null) {
      // data 可能是 List 或 Map (Python items 結構)
      final data = response['data'];
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map((e) => CalendarEvent.fromApi(e))
            .toList();
      } else if (data is Map<String, dynamic>) {
        // 若是 Map，嘗試取 events/days 欄位或整個 map 當單一事件
        final events = data['events'] ?? data['items'] ?? data['days'];
        if (events is List) {
          return events
              .whereType<Map<String, dynamic>>()
              .map((e) => CalendarEvent.fromApi(e))
              .toList();
        }
      }
    }
    return [];
  }

  /// 取得週事件 - 用週一日期查詢
  Future<List<CalendarEvent>> getWeekEvents({
    required String weekStart, // YYYY-MM-DD
  }) async {
    final response = await _client.get(
      ApiEndpoints.calendar,
      queryParameters: {'d': weekStart},
    );

    if (response['success'] == true && response['data'] != null) {
      final data = response['data'];
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map((e) => CalendarEvent.fromApi(e))
            .toList();
      }
    }
    return [];
  }

  /// 取得日事件 - 用當日日期查詢
  Future<List<CalendarEvent>> getDayEvents({
    required String date, // YYYY-MM-DD
  }) async {
    final response = await _client.get(
      ApiEndpoints.calendar,
      queryParameters: {'d': date},
    );

    if (response['success'] == true && response['data'] != null) {
      final data = response['data'];
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map((e) => CalendarEvent.fromApi(e))
            .toList();
      }
    }
    return [];
  }

  /// 取得事件詳情 - Python 沒有 detail API，回傳 null
  Future<EventDetailData?> getEventDetail({
    required String eventId,
  }) async {
    return null;
  }
}

/// 場地查詢端點
class ClassroomEndpoint {
  ClassroomEndpoint(this._client);

  final KmuClient _client;

  /// 取得場地分類
  Future<List<ClassroomCategory>> getCategories() async {
    final response = await _client.get(ApiEndpoints.classroomCategory);

    if (response['success'] == true && response['data'] is List) {
      final dataList = (response['data'] as List)
          .map((e) => ClassroomCategory.fromJson(e as Map<String, dynamic>))
          .toList();
      return dataList;
    }
    return [];
  }

  /// 取得場地列表
  Future<List<ClassroomRoom>> getRooms({
    required String categoryId,
    String? buildingId,
  }) async {
    final response = await _client.get(
      ApiEndpoints.classroomList,
      queryParameters: {
        'category_id': categoryId,
        if (buildingId != null) 'building_id': buildingId,
      },
    );

    if (response['success'] == true && response['data'] is List) {
      final dataList = (response['data'] as List)
          .map((e) => ClassroomRoom.fromJson(e as Map<String, dynamic>))
          .toList();
      return dataList;
    }
    return [];
  }

  /// 取得場地使用狀況
  Future<ClassroomUsageResponse?> getUsage({
    required String roomId,
    required String date, // YYYY-MM-DD
  }) async {
    final response = await _client.get(
      ApiEndpoints.classroomUsage,
      queryParameters: {
        'room_id': roomId,
        'date': date,
      },
    );

    if (response['success'] == true && response['data'] != null) {
      return ClassroomUsageResponse.fromJson(response['data'] as Map<String, dynamic>);
    }
    return null;
  }

  /// 取得場地詳情
  Future<ClassroomDetail?> getRoomDetail({
    required String roomId,
  }) async {
    final response = await _client.get(
      ApiEndpoints.classroomDetail,
      queryParameters: {'room_id': roomId},
    );

    if (response['success'] == true && response['data'] != null) {
      return ClassroomDetail.fromJson(response['data'] as Map<String, dynamic>);
    }
    return null;
  }
}

/// 課務端點
class CourseEndpoint {
  CourseEndpoint(this._client);

  final KmuClient _client;

  /// 取得課表 - Python: myclass_list 只要 id, pw
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
      // Python API: data 是 List<課堂>
      return MyScheduleResponse.fromJson({
        'success': true,
        'message': response['message']?.toString() ?? '成功',
        'data': response['data'],
      });
    }
    return null;
  }

  /// 取得成績學期清單 - Python: myscore_sem 端點
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

  /// 取得成績 - Python: myscore_his 端點 (需要 year, sem)
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

  /// 取得課程詳細資料 - Python: myclass_detail (需要 seq)
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