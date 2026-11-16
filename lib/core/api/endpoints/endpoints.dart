// API 端點介面定義
// 使用 KmuClient 封裝加密/解密、認證管理

import 'dart:convert';

import 'package:ikmu_flutter/core/api/kmu_client.dart';
import 'package:ikmu_flutter/core/constants/api_constants.dart';
import 'package:ikmu_flutter/core/api/models.dart';
import 'package:ikmu_flutter/core/utils/crypto_utils.dart';
import 'package:ikmu_flutter/core/utils/date_utils.dart';
import 'package:ikmu_flutter/features/irs/utils/irs_debug_log.dart';

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
      final items = Map<String, dynamic>.from(response['data'] as Map);
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

  /// 修改密碼
  Future<ApiResponse> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    final response = await _client.post(
      'changePassword',
      data: <String, dynamic>{
        'old_password': oldPassword,
        'new_password': newPassword,
      },
    );

    if (response['success'] == true) {
      return ApiResponse(
        success: true,
        message: response['message']?.toString() ?? '密碼修改成功',
      );
    }

    return ApiResponse(
      success: false,
      message: response['message']?.toString() ?? '密碼修改失敗',
    );
  }
}

/// 行事曆端點
class CalendarEndpoint {
  CalendarEndpoint(this._client);

  final KmuClient _client;

  /// 取得日事件 (單日)
  Future<List<CalendarEvent>> getDayEvents({
    required String date,
  }) async {
    final response = await _client.get(
      ApiEndpoints.calendar,
      queryParameters: <String, dynamic>{'d': date},
    );

    if (response['success'] == true && response['data'] != null) {
      final data = response['data'];
      List<dynamic> list = <dynamic>[];
      if (data is List) {
        list = data;
      } else if (data is Map) {
        final mapData = Map<String, dynamic>.from(data);
        final events = mapData['events'] ?? mapData['items'] ?? mapData['days'];
        if (events is List) {
          list = events;
        } else {
          list = mapData.values.toList();
        }
      }

      return list.whereType<Map>().map((e) {
        final map = Map<String, dynamic>.from(e);
        if (map['date'] == null && map['dateFrom'] == null) {
          map['date'] = date;
        }
        return CalendarEvent.fromApi(map);
      }).toList();
    }
    throw Exception('API 回傳失敗: ${response['message'] ?? '未知錯誤'}');
  }

  /// 取得月份所有事件 (自動平行併發下載 7x6 格子共 42 天，含上下月重疊天數)
  Future<List<CalendarEvent>> getMonthEvents({
    required String yearMonth,
  }) async {
    final parts = yearMonth.split('-');
    if (parts.length < 2) return <CalendarEvent>[];

    final year = int.tryParse(parts[0]) ?? DateTime.now().year;
    final month = int.tryParse(parts[1]) ?? DateTime.now().month;

    final firstDayOfMonth = DateTime(year, month, 1);
    final lastDayOfMonth = DateTime(year, month + 1, 0);

    final firstWeekday = firstDayOfMonth.weekday % 7;
    final gridStartDate = firstDayOfMonth.subtract(Duration(days: firstWeekday));

    final lastWeekday = lastDayOfMonth.weekday % 7;
    final daysToAdd = (6 - lastWeekday) % 7;
    final gridEndDate = lastDayOfMonth.add(Duration(days: daysToAdd));

    final totalDays = gridEndDate.difference(gridStartDate).inDays + 1;

    final futures = List<Future<List<CalendarEvent>>>.generate(totalDays, (index) {
      final d = gridStartDate.add(Duration(days: index));
      final dateStr =
          '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      return getDayEvents(date: dateStr);
    });

    final results = await Future.wait(futures);

    final allEvents = <CalendarEvent>[];
    for (final dayEvents in results) {
      allEvents.addAll(dayEvents);
    }
    return allEvents;
  }

  /// 取得週所有事件 (自動平行併發下載該週 7 天，週日到週六)
  Future<List<CalendarEvent>> getWeekEvents({
    required String weekStart,
  }) async {
    final startDate = DateTime.tryParse(weekStart);
    if (startDate == null) return <CalendarEvent>[];

    final weekStartDate = DateUtils.getWeekStart(startDate);

    final futures = List<Future<List<CalendarEvent>>>.generate(7, (i) {
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
          rooms = rooms
              .where((r) =>
                  r.categoryName == categoryId || r.categoryId == categoryId)
              .toList();
        }

        return rooms;
      }
    }
    return <ClassroomRoom>[];
  }

  /// 取得場地分類（從場地清單中動態分組）
  Future<List<ClassroomCategory>> getCategories() async {
    final rooms = _cachedRooms ?? await getRooms();
    final Map<String, int> categoryCounts = <String, int>{};

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
    required String date,
  }) async {
    final response = await _client.get(
      '/getClassroomUsageByDate',
      queryParameters: <String, dynamic>{
        'plano': roomId,
        'date': date,
      },
    );

    if (response['success'] == true && response['data'] != null) {
      final data = response['data'];
      final List<TimeSlot> timeSlots = <TimeSlot>[];

      if (data is List && data.isNotEmpty) {
        final first = Map<String, dynamic>.from(data.first as Map);

        const startTimes = <String>[
          '08:10',
          '09:10',
          '10:10',
          '11:10',
          '12:10',
          '13:10',
          '14:10',
          '15:10',
          '16:10',
          '17:10',
          '18:10',
          '19:10',
          '20:10',
          '21:10',
        ];
        const endTimes = <String>[
          '09:00',
          '10:00',
          '11:00',
          '12:00',
          '13:00',
          '14:00',
          '15:00',
          '16:00',
          '17:00',
          '18:00',
          '19:00',
          '20:00',
          '21:00',
          '22:00',
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
        data: <ClassroomUsage>[usage],
      );
    }

    return ClassroomUsageResponse(
      success: true,
      message: '成功',
      data: <ClassroomUsage>[
        ClassroomUsage(
          room: ClassroomDetail(id: roomId, name: ''),
          date: date,
          timeSlots: const <TimeSlot>[],
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
      queryParameters: <String, dynamic>{
        'id': encryptedId,
        'pw': encryptedPw,
      },
    );

    if (response['success'] == true && response['data'] != null) {
      return MyScheduleResponse.fromJson(<String, dynamic>{
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
      queryParameters: <String, dynamic>{
        'id': encryptedId,
        'pw': encryptedPw,
      },
    );

    if (response['success'] == true && response['data'] is List) {
      final dataList = (response['data'] as List)
          .whereType<Map>()
          .map((e) => SemesterInfo.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      return dataList;
    }
    return <SemesterInfo>[];
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
      queryParameters: <String, dynamic>{
        'id': encryptedId,
        'pw': encryptedPw,
        'year': year,
        'sem': sem,
      },
    );

    if (response['success'] == true && response['data'] != null) {
      return MyScoresResponse.fromJson(<String, dynamic>{
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
      queryParameters: <String, dynamic>{
        'id': encryptedId,
        'pw': encryptedPw,
        'seq': seq,
      },
    );

    if (response['success'] == true && response['data'] != null) {
      if (response['data'] is Map) {
        return Map<String, dynamic>.from(response['data'] as Map);
      }
      if (response['data'] is List && (response['data'] as List).isNotEmpty) {
        final first = (response['data'] as List).first;
        if (first is Map) {
          return Map<String, dynamic>.from(first);
        }
      }
    }
    return null;
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
      queryParameters: <String, dynamic>{
        if (category != null) 'category': category,
        'page': page,
        'page_size': pageSize,
      },
    );

    if (response['success'] == true && response['data'] != null) {
      return NewsListResponse.fromJson(
        Map<String, dynamic>.from(response['data'] as Map),
      );
    }
    return null;
  }

  /// 取得新聞詳情
  Future<NewsDetailResponse?> getNewsDetail({
    required String newsId,
  }) async {
    final response = await _client.get(
      ApiEndpoints.newsDetail,
      queryParameters: <String, dynamic>{'news_id': newsId},
    );

    if (response['success'] == true && response['data'] != null) {
      return NewsDetailResponse.fromJson(
        Map<String, dynamic>.from(response['data'] as Map),
      );
    }
    return null;
  }

  /// 取得 POI
  Future<List<POI>> getPOI() async {
    final response = await _client.get(ApiEndpoints.poiList);

    if (response['success'] == true && response['data'] is List) {
      return (response['data'] as List)
          .whereType<Map>()
          .map((e) => POI.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    return <POI>[];
  }

  /// 取得圖庫
  Future<List<GalleryItem>> getGallery() async {
    final response = await _client.get(ApiEndpoints.gallery);

    if (response['success'] == true && response['data'] is List) {
      return (response['data'] as List)
          .whereType<Map>()
          .map((e) => GalleryItem.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    return <GalleryItem>[];
  }
}

/// IRS 端點
class IrsEndpoint {
  IrsEndpoint(this._client);

  // 原生 URL_IRS_MQTTSEND 與 URL_IRS_STU_ABNORMAL 對應路徑
  // 若與校內伺服器實際路徑不同，請於 TBD.md 實測項目確認並同步 ApiEndpoints
  static const String _irsMqttSendPath = 'mqttSend'; // 對應 strings.xml URL_IRS_MQTTSEND = /appwsv3/mqttSend
  static const String _irsStuAbnormalPath = '/irs/stu/abnormal';

  final KmuClient _client;
  String _currentUserId = '';

  /// 設定當前使用者 ID (供學生端 API 使用)
  set userId(String value) {
    _currentUserId = value;
  }

  /// 取得 IRS 問卷列表
  Future<List<IrsQuestionnaire>> getQuestionnaires() async {
    final response = await _client.get(ApiEndpoints.questionnaire);

    if (response['success'] == true && response['data'] is List) {
      return (response['data'] as List)
          .whereType<Map>()
          .map((e) => IrsQuestionnaire.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    return <IrsQuestionnaire>[];
  }

  /// 取得 IRS 問卷詳情 (包含題目)
  Future<IrsQuestionnaireDetail?> getQuestionnaireDetail(
    String questionnaireId,
  ) async {
    final response = await _client.get(
      ApiEndpoints.questionnaire,
      queryParameters: <String, dynamic>{
        'id': questionnaireId,
        'detail': 'true',
      },
    );

    if (response['success'] == true && response['data'] is Map) {
      return IrsQuestionnaireDetail.fromJson(
        Map<String, dynamic>.from(response['data'] as Map),
      );
    }
    return null;
  }

  /// 提交 IRS 問卷答題
  Future<IrsSubmissionResponse> submitAnswers(
    IrsSubmissionRequest request,
  ) async {
    final response = await _client.post(
      ApiEndpoints.questionnaire,
      data: request.toJson(),
    );

    if (response['success'] == true) {
      final dataMap = response['data'] is Map
          ? Map<String, dynamic>.from(response['data'] as Map)
          : null;
      return IrsSubmissionResponse(
        success: true,
        message: response['message']?.toString() ?? '提交成功',
        submissionId: dataMap?['submissionId']?.toString(),
        score: (dataMap?['score'] as num?)?.toInt() ?? 0,
      );
    }

    return IrsSubmissionResponse(
      success: false,
      message: response['message']?.toString() ?? '提交失敗',
    );
  }

  /// IRS 即時答題：取得當前題目 (irs/stu/current_qu)
  /// 對齊 IRSActivity.java GetIRSCurrentQu：參數為 cono, stuno, teafno
  Future<Map<String, dynamic>?> getCurrentQuestion({
    required String classId,
    required String studentId,
    required String teacherNo,
  }) async {
    final response = await _client.post(
      ApiEndpoints.irsStuCurrentQu,
      data: <String, dynamic>{
        'cono': classId,
        'stuno': studentId,
        'teafno': teacherNo,
      },
    );

    if (response['success'] == true && response['data'] is Map) {
      return Map<String, dynamic>.from(response['data'] as Map);
    }
    return null;
  }

  /// IRS 學生登入 (irs/stu/applogin)
  /// 對齊 IRSActivity.java SendIRSLoginData：參數為 classid, stuno, teacherno, bt
  Future<Map<String, dynamic>?> irsStuApplogin({
    required String classId,
    required String studentId,
    required String teacherNo,
    required String bt,
  }) async {
    final response = await _client.post(
      ApiEndpoints.irsStuApplogin,
      data: <String, dynamic>{
        'classid': classId,
        'stuno': studentId,
        'teacherno': teacherNo,
        'bt': bt,
      },
    );

    if (response['success'] == true) {
      final data = response['data'];
      if (data is Map) {
        return Map<String, dynamic>.from(data);
      }
      return <String, dynamic>{'success': true};
    }
    return null;
  }

  /// IRS 取得當前狀態 (irs/stu/current)
  /// 回傳 status, secno, endTime, currentServerTime (及失敗時之 reason)
  Future<Map<String, dynamic>?> getIRSCurrentData({
    required String classId,
    required String studentId,
    required String teacherNo,
  }) async {
    final response = await _client.post(
      ApiEndpoints.irsCurrent,
      data: <String, dynamic>{
        'classid': classId,
        'stuno': studentId,
        'teacherno': teacherNo,
      },
    );

    final dataMap = response['data'] is Map
        ? Map<String, dynamic>.from(response['data'] as Map)
        : <String, dynamic>{};

    return <String, dynamic>{
      'success': response['success'] == true,
      'message': response['message']?.toString() ?? '',
      ...dataMap,
    };
  }

  /// IRS 即時答題：透過後端 HTTP POST 轉發 MQTT 訊息 (對應 URL_IRS_MQTTSEND)
  /// 參數為 topic, msg, quid, [msgType]
  Future<bool> sendMqttMessage({
    required String topic,
    required String msg,
    required String quid,
    String? msgType,
  }) async {
    final response = await _client.post(
      _irsMqttSendPath,
      data: <String, dynamic>{
        'topic': topic,
        'msg': msg,
        'quid': quid,
        if (msgType != null) 'msgType': msgType,
      },
    );
    return response['success'] == true;
  }

  /// IRS 學生端異常/逾時/離開回報 (對應 URL_IRS_STU_ABNORMAL)
  /// status: "1"=作答逾時, "2"=頁面暫停/離開
  Future<bool> sendAbnormal({
    required String quid,
    required String status,
    required String studentId,
  }) async {
    final response = await _client.post(
      _irsStuAbnormalPath,
      data: <String, dynamic>{
        'quid': quid,
        'status': status,
        'stuno': studentId,
      },
    );
    return response['success'] == true;
  }

  /// IRS 即時答題：取得課程下的老師列表 (irs/stu/teacher_class)
  /// 參數為 classid
  Future<List<IrsRealtimeTeacher>> getTeacherClasses({
    required String classId,
  }) async {
    IrsDebugLog.log('[IRS_ENDPOINT] getTeacherClasses: classId=$classId');
    final response = await _client.post(
      ApiEndpoints.irsCurrentTeacherClass,
      data: <String, dynamic>{'classid': classId},
    );
    IrsDebugLog.log(
      '[IRS_ENDPOINT] 回傳: success=${response['success']}, data type=${response['data']?.runtimeType}',
    );

    if (response['success'] == true && response['data'] is List) {
      final list = (response['data'] as List)
          .whereType<Map>()
          .map((e) => IrsRealtimeTeacher.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      IrsDebugLog.log('[IRS_ENDPOINT] 解析 List 完成: ${list.length} 筆');
      return list;
    }
    if (response['success'] == true && response['data'] is Map) {
      final data = Map<String, dynamic>.from(response['data'] as Map);
      if (data['items'] is List) {
        final list = (data['items'] as List)
            .whereType<Map>()
            .map(
              (e) => IrsRealtimeTeacher.fromJson(Map<String, dynamic>.from(e)),
            )
            .toList();
        IrsDebugLog.log('[IRS_ENDPOINT] 解析 items 完成: ${list.length} 筆');
        return list;
      }
      if (data.values.isNotEmpty) {
        final list = data.values
            .whereType<Map>()
            .map(
              (e) => IrsRealtimeTeacher.fromJson(Map<String, dynamic>.from(e)),
            )
            .toList();
        IrsDebugLog.log('[IRS_ENDPOINT] 解析 Map values 完成: ${list.length} 筆');
        return list;
      }
    }
    IrsDebugLog.log('[IRS_ENDPOINT] 回傳空陣列');
    return <IrsRealtimeTeacher>[];
  }

  /// IRS 即時答題：提交多題連答/填空答案 (irs/stu/paperFill)
  /// 對齊 IRSActivity.java UploadIRSPaperFillData：answers 為 JSON 字串
  Future<Map<String, dynamic>?> submitPaperFill({
    required String classId,
    required String studentId,
    required String teacherNo,
    required String secno,
    required String username,
    required Object answers,
  }) async {
    final encodedAnswers =
        answers is String ? answers : jsonEncode(answers);
    final response = await _client.post(
      ApiEndpoints.irsPaperFill,
      data: <String, dynamic>{
        'classid': classId,
        'stuno': studentId,
        'teacherno': teacherNo,
        'secno': secno,
        'username': username,
        'answers': encodedAnswers,
      },
    );

    if (response['success'] == true) {
      return <String, dynamic>{
        'success': true,
        'message': response['message']?.toString() ?? '送出成功',
        'data': response['data'],
      };
    }
    return <String, dynamic>{
      'success': false,
      'message': response['message']?.toString() ?? '送出失敗',
    };
  }

  /// 學生端：取得課程列表 (含 teacherList)
  Future<List<IrsStudentClass>> getStudentClasses({
    required String userId,
  }) async {
    final response = await _client.post(
      '${ApiEndpoints.irsCurrentClass}/$userId',
      data: <String, dynamic>{'userId': userId},
    );

    if (response['success'] == true) {
      final data = response['data'];
      List<dynamic>? list;
      if (data is List) {
        list = data;
      } else if (data is Map && data['items'] is List) {
        list = data['items'] as List<dynamic>;
      }
      if (list != null) {
        return list
            .whereType<Map>()
            .map((e) => IrsStudentClass.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    }
    return <IrsStudentClass>[];
  }

  /// 學生端：取得作答記錄 (irs/stu/qaList)
  Future<List<IrsAnswerRecord>> getAnswerRecords(String courseId) async {
    final response = await _client.post(
      ApiEndpoints.irsStudentQaList,
      data: <String, dynamic>{
        'stuno': _currentUserId,
        'cono': courseId,
      },
    );

    if (response['success'] == true && response['data'] != null) {
      final data = response['data'];
      if (data is List) {
        return data
            .whereType<Map>()
            .map((e) => IrsAnswerRecord.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
      if (data is Map && data['items'] is List) {
        return (data['items'] as List)
            .whereType<Map>()
            .map((e) => IrsAnswerRecord.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    }
    return <IrsAnswerRecord>[];
  }

  /// 學生端：取得提問記錄 (irs/stu/askList)
  Future<List<IrsAnswerRecord>> getAskRecords(String courseId) async {
    final response = await _client.post(
      ApiEndpoints.irsStudentAskList,
      data: <String, dynamic>{
        'stuno': _currentUserId,
        'cono': courseId,
      },
    );

    if (response['success'] == true && response['data'] != null) {
      final data = response['data'];
      if (data is List) {
        return data
            .whereType<Map>()
            .map((e) => IrsAnswerRecord.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
      if (data is Map && data['items'] is List) {
        return (data['items'] as List)
            .whereType<Map>()
            .map((e) => IrsAnswerRecord.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    }
    return <IrsAnswerRecord>[];
  }

  /// 學生端：取得考試詳情 (irs/stu/examDetail)
  /// 回應 items 為單一物件，內含 subquList
  Future<IrsExamDetail?> getExamDetail({
    required String userId,
    required String quid,
  }) async {
    final response = await _client.post(
      ApiEndpoints.irsStudentExamDetail,
      data: <String, dynamic>{
        'stuno': userId,
        'quid': quid,
      },
    );

    if (response['success'] == true && response['data'] is Map) {
      final dataMap = Map<String, dynamic>.from(response['data'] as Map);
      final items = dataMap['items'] is Map
          ? Map<String, dynamic>.from(dataMap['items'] as Map)
          : dataMap;
      return IrsExamDetail.fromJson(items);
    }
    return null;
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
  late final CampusInfoEndpoint campusInfo = CampusInfoEndpoint(_client);
  late final IrsEndpoint irs = IrsEndpoint(_client);
}