// 場地查詢相關模型

import 'package:freezed_annotation/freezed_annotation.dart';

part 'classroom_models.freezed.dart';
part 'classroom_models.g.dart';

/// 場地分類
@freezed
abstract class ClassroomCategory with _$ClassroomCategory {
  const factory ClassroomCategory({
    required String id,
    required String name,
    String? icon,
    @Default(0) int sortOrder,
    @Default(0) int roomCount,
  }) = _ClassroomCategory;

  factory ClassroomCategory.fromJson(Map<String, dynamic> json) {
    return ClassroomCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String?,
      sortOrder: json['sort_order'] as int? ?? 0,
      roomCount: json['room_count'] as int? ?? 0,
    );
  }
}

/// 場地基本資訊 (列表用)
@freezed
abstract class ClassroomRoom with _$ClassroomRoom {
  const factory ClassroomRoom({
    required String id,
    required String name,
    String? building,
    String? floor,
    int? capacity,
    String? categoryId,
    String? categoryName,
    String? location,
    @Default([]) List<String> equipment,
    @Default(false) bool hasProjector,
    @Default(false) bool hasAc,
    @Default(false) bool hasComputer,
    String? imageUrl,
    String? description,
  }) = _ClassroomRoom;

  factory ClassroomRoom.fromJson(Map<String, dynamic> json) {
    return ClassroomRoom(
      id: json['id'] as String,
      name: json['name'] as String,
      building: json['building'] as String?,
      floor: json['floor'] as String?,
      capacity: json['capacity'] as int?,
      categoryId: json['category_id'] as String?,
      categoryName: json['category_name'] as String?,
      location: json['location'] as String?,
      equipment: (json['equipment'] as List?)?.map((e) => e as String).toList() ?? [],
      hasProjector: json['has_projector'] as bool? ?? false,
      hasAc: json['has_ac'] as bool? ?? false,
      hasComputer: json['has_computer'] as bool? ?? false,
      imageUrl: json['image_url'] as String?,
      description: json['description'] as String?,
    );
  }
}

/// 場地詳情
@freezed
abstract class ClassroomDetail with _$ClassroomDetail {
  const factory ClassroomDetail({
    required String id,
    required String name,
    String? building,
    String? floor,
    int? capacity,
    String? description,
    String? imageUrl,
    @Default([]) List<String> equipments,
    String? openTime,
    String? closeTime,
    String? contactPhone,
    String? manager,
    String? notes,
    String? location,
    String? categoryName,
  }) = _ClassroomDetail;

  factory ClassroomDetail.fromJson(Map<String, dynamic> json) {
    return ClassroomDetail(
      id: json['id'] as String,
      name: json['name'] as String,
      building: json['building'] as String?,
      floor: json['floor'] as String?,
      capacity: json['capacity'] as int?,
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String?,
      equipments: (json['equipments'] as List?)?.map((e) => e as String).toList() ?? [],
      openTime: json['open_time'] as String?,
      closeTime: json['close_time'] as String?,
      contactPhone: json['contact_phone'] as String?,
      manager: json['manager'] as String?,
      notes: json['notes'] as String?,
      location: json['location'] as String?,
      categoryName: json['category_name'] as String?,
    );
  }
}

/// 時間段 (場地使用狀況)
@freezed
abstract class TimeSlot with _$TimeSlot {
  const factory TimeSlot({
    required String id,
    required String startTime,
    required String endTime,
    required String status, // available, occupied, maintenance
    String? courseName,
    String? teacherName,
    String? department,
    String? className,
    int? weekday, // 1-7
    String? weeks, // e.g., "1-18"
    @Default(false) bool isRecurring,
  }) = _TimeSlot;

  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot(
      id: json['id'] as String,
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
      status: json['status'] as String,
      courseName: json['course_name'] as String?,
      teacherName: json['teacher_name'] as String?,
      department: json['department'] as String?,
      className: json['class_name'] as String?,
      weekday: json['weekday'] as int?,
      weeks: json['weeks'] as String?,
      isRecurring: json['is_recurring'] as bool? ?? false,
    );
  }
}

/// TimeSlot 擴展方法
extension TimeSlotExtension on TimeSlot {
  /// 解析時間
  DateTime? get parsedStartTime {
    try {
      final parts = startTime.split(':');
      return DateTime.now().copyWith(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
        second: 0,
      );
    } catch (_) {
      return null;
    }
  }

  DateTime? get parsedEndTime {
    try {
      final parts = endTime.split(':');
      return DateTime.now().copyWith(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
        second: 0,
      );
    } catch (_) {
      return null;
    }
  }

  /// 狀態顏色
  String get statusColor {
    switch (status) {
      case 'available':
        return '#00C853'; // Green
      case 'occupied':
        return '#FF1744'; // Red
      case 'maintenance':
        return '#FFD600'; // Amber
      default:
        return '#757575'; // Grey
    }
  }

  /// 狀態標籤
  String get statusLabel {
    switch (status) {
      case 'available':
        return '可借用';
      case 'occupied':
        return '使用中';
      case 'maintenance':
        return '維修中';
      default:
        return '未知';
    }
  }
}

/// 場地使用狀況
@freezed
abstract class ClassroomUsage with _$ClassroomUsage {
  const factory ClassroomUsage({
    required ClassroomDetail room,
    required String date,
    @Default([]) List<TimeSlot> timeSlots,
    int? weekday,
  }) = _ClassroomUsage;

  const ClassroomUsage._();

  // 便利 getter
  String get firstStartTime => timeSlots.isNotEmpty ? timeSlots.first.startTime : '';
  String get lastEndTime => timeSlots.isNotEmpty ? timeSlots.last.endTime : '';
}

/// 場地使用狀況回應
@freezed
abstract class ClassroomUsageResponse with _$ClassroomUsageResponse {
  const factory ClassroomUsageResponse({
    required bool success,
    required String message,
    dynamic data,
  }) = _ClassroomUsageResponse;

  factory ClassroomUsageResponse.fromJson(Map<String, dynamic> json) =>
      _$ClassroomUsageResponseFromJson(json);
}

/// 場地使用狀況資料
@freezed
abstract class ClassroomUsageData with _$ClassroomUsageData {
  const factory ClassroomUsageData({
    required ClassroomDetail room,
    required String date,
    @Default([]) List<TimeSlot> timeSlots,
    int? weekday,
  }) = _ClassroomUsageData;

  factory ClassroomUsageData.fromJson(Map<String, dynamic> json) {
    return ClassroomUsageData(
      room: ClassroomDetail.fromJson(json['room'] as Map<String, dynamic>),
      date: json['date'] as String,
      timeSlots: (json['time_slots'] as List?)
              ?.map((e) => TimeSlot.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      weekday: json['weekday'] as int?,
    );
  }
}

/// 場地狀態 (Riverpod 管理)
@freezed
abstract class ClassroomState with _$ClassroomState {
  const factory ClassroomState({
    @Default([]) List<ClassroomCategory> categories,
    String? selectedCategoryId,
    @Default([]) List<ClassroomRoom> rooms,
    ClassroomDetail? selectedRoom,
    ClassroomUsageData? usageData,
    String? usageDate,
    @Default(false) bool isLoadingCategories,
    @Default(false) bool isLoadingRooms,
    @Default(false) bool isLoadingDetail,
    @Default(false) bool isLoadingUsage,
    String? error,
  }) = _ClassroomState;

  factory ClassroomState.initial() => const ClassroomState();
}