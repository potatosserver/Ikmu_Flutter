// 校園資訊、新聞、POI 相關模型

import 'package:freezed_annotation/freezed_annotation.dart';
import 'common_models.dart';

part 'campus_info_models.freezed.dart';
part 'campus_info_models.g.dart';

/// 新聞/公告
@freezed
abstract class NewsItem with _$NewsItem {
  const factory NewsItem({
    required String id,
    required String title,
    required String publishDate, String? summary,
    String? content,
    String? category,
    String? categoryName,
    String? author,
    String? source,
    String? imageUrl,
    String? linkUrl,
    @Default(false) bool isImportant,
    @Default(0) int views,
    @Default([]) List<NewsAttachment> attachments,
  }) = _NewsItem;

  factory NewsItem.fromJson(Map<String, dynamic> json) {
    return NewsItem(
      id: json['id'] as String,
      title: json['title'] as String,
      summary: json['summary'] as String?,
      content: json['content'] as String?,
      category: json['category'] as String?,
      categoryName: json['category_name'] as String?,
      publishDate: json['publish_date'] as String,
      author: json['author'] as String?,
      source: json['source'] as String?,
      imageUrl: json['image_url'] as String?,
      linkUrl: json['link_url'] as String?,
      isImportant: json['is_important'] as bool? ?? false,
      views: json['views'] as int? ?? 0,
      attachments: (json['attachments'] as List?)
              ?.map((e) => NewsAttachment.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

/// NewsItem 擴展方法
extension NewsItemExtension on NewsItem {
  /// 發布日期解析
  DateTime? get parsedPublishDate {
    try {
      return DateTime.parse(publishDate);
    } catch (_) {
      return null;
    }
  }

  /// 相對時間顯示
  String get relativeTime {
    final parsed = parsedPublishDate;
    if (parsed == null) return publishDate;
    final now = DateTime.now();
    final diff = now.difference(parsed);
    if (diff.inDays > 30) return '${diff.inDays ~/ 30} 個月前';
    if (diff.inDays > 0) return '${diff.inDays} 天前';
    if (diff.inHours > 0) return '${diff.inHours} 小時前';
    if (diff.inMinutes > 0) return '${diff.inMinutes} 分鐘前';
    return '剛剛';
  }
}

/// 新聞附件
@freezed
abstract class NewsAttachment with _$NewsAttachment {
  const factory NewsAttachment({
    required String name,
    required String url,
    int? size,
    String? type,
  }) = _NewsAttachment;

  factory NewsAttachment.fromJson(Map<String, dynamic> json) {
    return NewsAttachment(
      name: json['name'] as String,
      url: json['url'] as String,
      size: json['size'] as int?,
      type: json['type'] as String?,
    );
  }
}

/// 新聞列表回應
@freezed
abstract class NewsListResponse with _$NewsListResponse {
  const factory NewsListResponse({
    required bool success,
    required String message,
    data,
  }) = _NewsListResponse;

  factory NewsListResponse.fromJson(Map<String, dynamic> json) =>
      _$NewsListResponseFromJson(json);
}

/// 新聞列表資料
@freezed
abstract class NewsListData with _$NewsListData {
  const factory NewsListData({
    @Default([]) List<dynamic> items,
    Pagination? pagination,
    @Default([]) List<NewsCategory> categories,
  }) = _NewsListData;

  factory NewsListData.fromJson(Map<String, dynamic> json) {
    return NewsListData(
      items: (json['items'] as List?) ??
          [],
      pagination: json['pagination'] != null
          ? Pagination.fromJson(json['pagination'] as Map<String, dynamic>)
          : null,
      categories: (json['categories'] as List?)
              ?.map((e) => NewsCategory.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

/// 新聞分類
@freezed
abstract class NewsCategory with _$NewsCategory {
  const factory NewsCategory({
    required String id,
    required String name,
    @Default(0) int count,
  }) = _NewsCategory;

  factory NewsCategory.fromJson(Map<String, dynamic> json) {
    return NewsCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      count: json['count'] as int? ?? 0,
    );
  }
}

/// 新聞詳情回應
@freezed
abstract class NewsDetailResponse with _$NewsDetailResponse {
  const factory NewsDetailResponse({
    required bool success,
    required String message,
    data,
  }) = _NewsDetailResponse;

  factory NewsDetailResponse.fromJson(Map<String, dynamic> json) =>
      _$NewsDetailResponseFromJson(json);
}

/// POI 點位
@freezed
abstract class POI with _$POI {
  const factory POI({
    required String id,
    required String name,
    required String category,
    required double latitude, required double longitude, String? categoryName,
    String? description,
    String? address,
    String? phone,
    String? imageUrl,
    String? openTime,
    String? closeTime,
    @Default([]) List<String> tags,
  }) = _POI;

  factory POI.fromJson(Map<String, dynamic> json) {
    return POI(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      categoryName: json['category_name'] as String?,
      description: json['description'] as String?,
      address: json['address'] as String?,
      phone: json['phone'] as String?,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      imageUrl: json['image_url'] as String?,
      openTime: json['open_time'] as String?,
      closeTime: json['close_time'] as String?,
      tags: (json['tags'] as List?)?.map((e) => e as String).toList() ?? [],
    );
  }
}

/// POI 回應
@freezed
abstract class POIResponse with _$POIResponse {
  const factory POIResponse({
    required bool success,
    required String message,
    @Default([]) List<dynamic> data,
  }) = _POIResponse;

  factory POIResponse.fromJson(Map<String, dynamic> json) =>
      _$POIResponseFromJson(json);
}

/// 圖庫項目
@freezed
abstract class GalleryItem with _$GalleryItem {
  const factory GalleryItem({
    required String id,
    required String title,
    required String imageUrl,
    String? thumbnailUrl,
    String? description,
    String? category,
    String? photographer,
    String? date,
  }) = _GalleryItem;

  factory GalleryItem.fromJson(Map<String, dynamic> json) {
    return GalleryItem(
      id: json['id'] as String,
      title: json['title'] as String,
      imageUrl: json['image_url'] as String,
      thumbnailUrl: json['thumbnail_url'] as String?,
      description: json['description'] as String?,
      category: json['category'] as String?,
      photographer: json['photographer'] as String?,
      date: json['date'] as String?,
    );
  }
}

/// 圖庫回應
@freezed
abstract class GalleryResponse with _$GalleryResponse {
  const factory GalleryResponse({
    required bool success,
    required String message,
    @Default([]) List<dynamic> data,
  }) = _GalleryResponse;

  factory GalleryResponse.fromJson(Map<String, dynamic> json) =>
      _$GalleryResponseFromJson(json);
}

/// 校園資訊狀態
@freezed
abstract class CampusInfoState with _$CampusInfoState {
  const factory CampusInfoState({
    @Default([]) List<NewsItem> newsList,
    @Default([]) List<NewsCategory> newsCategories,
    String? selectedCategoryId,
    NewsItem? selectedNews,
    @Default([]) List<POI> pois,
    @Default([]) List<GalleryItem> gallery,
    @Default(false) bool isLoadingNews,
    @Default(false) bool isLoadingPois,
    @Default(false) bool isLoadingGallery,
    String? error,
  }) = _CampusInfoState;

  factory CampusInfoState.initial() => const CampusInfoState();
}