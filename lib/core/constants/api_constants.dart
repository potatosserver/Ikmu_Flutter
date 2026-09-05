// API 常數定義
// 注意：敏感資訊請從環境變數讀取，不得硬編碼於程式碼中

/// KMU API 基礎 URL
const String kKmuApiBaseUrl = 'https://mbms.kmu.edu.tw/appwsv3/';

/// 座位預約 API (僅校內網路可存取)
const String kKmuSeatApiBaseUrl = 'https://sbms.lib.kmu.edu.tw/booking/APPAPI/';

/// API 端點
class ApiEndpoints {
  ApiEndpoints._();
  
  // Auth - 對應 Python ikmu.py
  static const String verify = 'verify';
  static const String login = verify; // 別名
  static const String logout = 'logout';
  
  // 我的課表/成績 - 對應 Python
  static const String myClass = 'getMyClassList';
  static const String myClassDetail = 'getClassDetail';
  static const String myScoreSem = 'getMyAllSem';
  static const String myScoreHis = 'getMyScoreHistory';
  
  // 行事曆
  static const String calendar = 'getCalendarEvent';
  static const String calendarSearch = 'searchCalendarEvent';
  
  // 場地查詢
  static const String classroomCategory = 'getClassroomList';
  static const String classroomList = 'getClassroomList';
  static const String classroomDetail = 'getClassroomDetail';
  static const String classroomUsage = 'getClassroomUsage';
  static const String classroomUsageByDate = 'getClassroomUsageByDate';
  
  // 交通
  static const String busRoute = 'getActiveBus';
  static const String busRealtime = 'getStopOfBus';
  static const String bikeStation = 'getKHCBikeInfo';
  static const String trafficInfo = 'getTrafficData';
  
  // 校園資訊
  static const String newsList = 'getNewsList';
  static const String newsDetail = 'getNewsDetail';
  static const String poiList = 'getMapPoi';
  static const String gallery = 'getGallery';
  
  // 新增 API
  static const String appLayout = 'getAppLayout';
  static const String layoutUrl = 'getLayoutUrl';
  static const String securityData = 'getSecurityData';
  static const String beaconInfo = 'getBeaconList';
  static const String checkToken = 'checkToken';
  static const String questionnaire = 'getValidQuestionnaire';
  static const String enews = 'getEnews';
  static const String enewsList = 'getEnewsList';
  static const String goodSoftware = 'getGoodSoftware';
  static const String sysVersion = 'getSysVersion';
}

/// 3DES 加密金鑰
const String kDesKey = 'KMU2readPerlJava20110705';

/// akfw 常數
const String kAkfw = 'wCNDaoyYPRFU0Vg5EMNqcEvXKtRc4s33';

/// 應用常數
class AppConstants {
  AppConstants._();
  
  static const String appName = 'i高醫';
  static const String appNameEn = 'iKmu';
  static const String packageName = 'com.kmu.ikmu_flutter';
  static const String version = '1.0.0';
  static const int buildNumber = 1;
  
  // 快取 TTL (毫秒)
  static const int cacheTtlShort = 5 * 60 * 1000;      // 5 分鐘
  static const int cacheTtlMedium = 30 * 60 * 1000;    // 30 分鐘
  static const int cacheTtlLong = 60 * 60 * 1000;      // 1 小時
  static const int cacheTtlDay = 24 * 60 * 60 * 1000;  // 1 天
  static const int cacheTtlWeek = 7 * 24 * 60 * 60 * 1000; // 1 週
  static const int cacheTtlMonth = 30 * 24 * 60 * 60 * 1000; // 1 個月 (30 天)
}

/// 快取 Box 名稱
enum CacheBoxes {
  auth,
  calendar,
  classroom,
  courses,
  transport,
  campusInfo,
  settings,
  generic,
}

/// 快取 TTL 分類
enum CacheTTL {
  auth(AppConstants.cacheTtlLong),           // 1 小時
  calendar(AppConstants.cacheTtlDay),        // 1 天
  classroom(AppConstants.cacheTtlMedium),    // 30 分鐘
  courses(AppConstants.cacheTtlMonth),       // 1 個月 (30 天)
  transport(AppConstants.cacheTtlShort),     // 5 分鐘
  campusInfo(AppConstants.cacheTtlMedium),   // 30 分鐘
  settings(AppConstants.cacheTtlDay),        // 1 天
  generic(AppConstants.cacheTtlMedium);      // 30 分鐘

  const CacheTTL(this.milliseconds);

  final int milliseconds;
}