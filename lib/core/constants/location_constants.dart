// 位置常數
// 統一管理學校中心點座標，供 YouBike、天氣、地圖等功能使用

import 'package:latlong2/latlong.dart';

/// 高雄醫學大學 (KMU) 中心點座標
/// 位置：高雄市三民區五權一路100號
class KmuLocation {
  KmuLocation._();

  /// 高醫主校區中心點
  static const double latitude = 22.6320;
  static const double longitude = 120.3080;

  /// 經緯度物件 (供 flutter_map 等使用)
  static const LatLng latLng = LatLng(latitude, longitude);

  /// 校區名稱
  static const String campusName = '高雄醫學大學';

  /// 校區地址
  static const String campusAddress = '高雄市三民區五權一路100號';

  /// 經緯度字串 (供 Google Maps 等使用)
  static const String latLngString = '$latitude,$longitude';

  /// 供 YouBike API 使用的參數
  static const Map<String, double> youbikeParams = {
    'lat': latitude,
    'lng': longitude,
    'maxDistance': 2000, // 2公里範圍內的站點
  };

  /// 供 Open-Meteo 天氣 API 使用的參數
  static const Map<String, dynamic> weatherParams = {
    'latitude': latitude,
    'longitude': longitude,
    'timezone': 'Asia/Taipei',
  };
}