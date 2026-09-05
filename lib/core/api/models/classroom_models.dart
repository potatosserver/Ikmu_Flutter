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
      id: (json['id'] ?? json['plakno'] ?? json['no'] ?? '').toString(),
      name: (json['name'] ?? json['plaknam'] ?? '').toString(),
      icon: json['icon']?.toString(),
      sortOrder: (json['sort_order'] ?? json['sortOrder']) as int? ?? 0,
      roomCount: (json['room_count'] ?? json['roomCount']) as int? ?? 0,
    );
  }
}

extension ClassroomCategoryExtension on ClassroomCategory {
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'icon': icon,
        'sort_order': sortOrder,
        'room_count': roomCount,
      };
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
      id: (json['id'] ?? json['no'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      building: json['building']?.toString(),
      floor: json['floor']?.toString(),
      capacity: (json['capacity'] is int)
          ? json['capacity'] as int
          : int.tryParse(json['capacity']?.toString() ?? ''),
      categoryId: (json['category_id'] ?? json['plakno'])?.toString(),
      categoryName: (json['category_name'] ?? json['plaknam'])?.toString(),
      location: json['location']?.toString(),
      equipment: (json['equipment'] as List?)?.map((e) => e.toString()).toList() ?? [],
      hasProjector: json['has_projector'] as bool? ?? false,
      hasAc: json['has_ac'] as bool? ?? false,
      hasComputer: json['has_computer'] as bool? ?? false,
      imageUrl: json['image_url']?.toString(),
      description: json['description']?.toString(),
    );
  }
}

extension ClassroomRoomExtension on ClassroomRoom {
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'building': building,
        'floor': floor,
        'capacity': capacity,
        'category_id': categoryId,
        'category_name': categoryName,
        'location': location,
        'equipment': equipment,
        'has_projector': hasProjector,
        'has_ac': hasAc,
        'has_computer': hasComputer,
        'image_url': imageUrl,
        'description': description,
      };
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
      id: (json['id'] ?? json['no'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      building: json['building']?.toString(),
      floor: json['floor']?.toString(),
      capacity: (json['capacity'] is int)
          ? json['capacity'] as int
          : int.tryParse(json['capacity']?.toString() ?? ''),
      description: json['description']?.toString(),
      imageUrl: json['image_url']?.toString(),
      equipments: (json['equipments'] as List?)?.map((e) => e.toString()).toList() ?? [],
      openTime: json['open_time']?.toString(),
      closeTime: json['close_time']?.toString(),
      contactPhone: json['contact_phone']?.toString(),
      manager: json['manager']?.toString(),
      notes: json['notes']?.toString(),
      location: json['location']?.toString(),
      categoryName: (json['category_name'] ?? json['plaknam'])?.toString(),
    );
  }
}

extension ClassroomDetailExtension on ClassroomDetail {
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'building': building,
        'floor': floor,
        'capacity': capacity,
        'description': description,
        'image_url': imageUrl,
        'equipments': equipments,
        'open_time': openTime,
        'close_time': closeTime,
        'contact_phone': contactPhone,
        'manager': manager,
        'notes': notes,
        'location': location,
        'category_name': categoryName,
      };
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
      id: (json['id'] ?? '').toString(),
      startTime: (json['start_time'] ?? json['startTime'] ?? '').toString(),
      endTime: (json['end_time'] ?? json['endTime'] ?? '').toString(),
      status: (json['status'] ?? 'available').toString(),
      courseName: json['course_name']?.toString(),
      teacherName: json['teacher_name']?.toString(),
      department: json['department']?.toString(),
      className: json['class_name']?.toString(),
      weekday: (json['weekday'] is int)
          ? json['weekday'] as int
          : int.tryParse(json['weekday']?.toString() ?? ''),
      weeks: json['weeks']?.toString(),
      isRecurring: json['is_recurring'] as bool? ?? false,
    );
  }
}

/// TimeSlot 擴展方法
extension TimeSlotExtension on TimeSlot {
  Map<String, dynamic> toJson() => {
        'id': id,
        'start_time': startTime,
        'end_time': endTime,
        'status': status,
        'course_name': courseName,
        'teacher_name': teacherName,
        'department': department,
        'class_name': className,
        'weekday': weekday,
        'weeks': weeks,
        'is_recurring': isRecurring,
      };

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
      room: ClassroomDetail.fromJson(json['room'] as Map<String, dynamic>? ?? {}),
      date: (json['date'] ?? '').toString(),
      timeSlots: (json['time_slots'] as List?)
              ?.map((e) => TimeSlot.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      weekday: (json['weekday'] is int)
          ? json['weekday'] as int
          : int.tryParse(json['weekday']?.toString() ?? ''),
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