// 路由路徑常數
// 集中管理所有路由路徑

/// 路由路徑常數類
class RoutePaths {
  RoutePaths._();

  // ===========================================
  // 基礎路徑
  // ===========================================

  /// 啟動頁
  static const String splash = '/';

  /// 登入頁
  static const String login = '/login';

  /// 主畫面
  static const String home = '/home';

  // ===========================================
  // 主要功能頁面
  // ===========================================

  /// 行事曆
  static const String calendar = '/calendar';

  /// 場地查詢列表
  static const String classroom = '/classroom';

  /// 場地詳情
  static const String classroomDetail = '/classroom/:roomId';

  /// 我的課表
  static const String schedule = '/schedule';

  /// 我的成績
  static const String scores = '/scores';

  /// 成績詳情
  static const String scoreDetail = '/scores/:subjectId';

  // ===========================================
  // 校園資訊
  // ===========================================

  /// 新聞列表
  static const String news = '/news';

  /// 新聞詳情
  static const String newsDetail = '/news/:newsId';

  /// 交通資訊
  static const String traffic = '/traffic';

  // ===========================================
  // IRS 答題系統
  // ===========================================

  /// IRS 答題頁面
  static const String irs = '/irs';

  // ===========================================
  // 設定
  // ===========================================

  /// 設定頁
  static const String settings = '/settings';
}