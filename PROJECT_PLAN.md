# iKmuFlutter 專案企劃書

> **專案目標**：將現有 KMU 行動查詢系統 (Python Flask + MWC Web) 重構為 Flutter 跨平台應用
> **專案位置**：`/home/user/StudioProjects/iKmuFlutter`
> **目標平台**：Web (PWA) / Android / iOS / macOS / Windows / Linux
> **排除功能**：室內導航、問卷投票

---

## 1. 專案概覽

### 1.1 現有系統分析
| 模組 | 現狀 | Flutter 重構策略 |
|------|------|-----------------|
| **認證系統** | 學號/密碼 + 記住帳號 + SHA-256 uevw2 | 移植加密邏輯，Token 本地儲存 (Hive) |
| **行事曆** | 月/週/日三檢視、事件快取 1hr、日期同步 | 獨立 Feature，Riverpod 狀態管理 |
| **場地查詢** | 分類晶片、列表、詳情時間軸 | 獨立 Feature，支援離線快取 |
| **課程查詢** | 我的課表、成績查詢 | 合併為「學務」Feature |
| **校車/公車** | 即時動態、路線圖 | 整合 MapLibre (Web) / Google Maps (Mobile) |
| **Ubike/YouBike** | 站點查詢、租借狀態 | 獨立 Feature |
| **校園資訊** | 最新消息、行事曆、交通資訊 | 統一資訊流 |
| **個人設定** | 主題、通知、登出 | 共用設定模組 |

### 1.2 技術棧選型

| 層級 | 選型 | 版本 | 說明 |
|------|------|------|------|
| **Framework** | Flutter | 3.24+ | 穩定版，Web 支援成熟 |
| **狀態管理** | Riverpod | 2.5+ | 編譯期安全、ProviderScope |
| **路由** | GoRouter | 14+ | Web 深層連結、重導向守衛 |
| **網路層** | Dio | 5.7+ | Interceptor、重試、取消 |
| **本地儲存** | Hive | 2.2+ | Web 相容 (IndexedDB)、型別安全 |
| **序列化** | Freezed + json_serializable | 2.5+ / 6.8+ | Immutable、程式碼生成 |
| **加密** | pointycastle + crypto | 3.8+ / 3.0+ | 3DES/ECB/PKCS7、SHA-1/256 |
| **日期時間** | intl + time_zone | 0.19+ / 0.9+ | 時區、本地化格式 |
| **UI 元件** | Material 3 + flutter_animate | 1.3+ / 4.5+ | 動態色彩、流暢動畫 |
| **地圖** | maplibre_gl (Web) / google_maps_flutter (Mobile) | 0.17+ / 2.9+ | 向量瓦片、深色模式 |
| **圖表** | fl_chart | 0.69+ | 成績趨勢、統計圖 |
| **推播** | firebase_messaging | 14.7+ | FCM 整合 |

---

## 2. 目錄結構

```
iKmuFlutter/
├── .github/
│   └── workflows/           # CI/CD (analyze, test, build)
├── android/                 # Android 專案設定
├── ios/                     # iOS 專案設定
├── web/
│   ├── index.html           # PWA 入口、manifest、SW 註冊
│   ├── manifest.json        # PWA 資訊清單
│   ├── sw.js                # Service Worker (快取策略)
│   └── icons/               # PWA 圖示集
├── linux/                   # Linux 桌面設定
├── macos/                   # macOS 桌面設定
├── windows/                 # Windows 桌面設定
├── lib/
│   ├── main.dart            # App 入口、ProviderScope、GoRouter
│   ├── bootstrap.dart       # 環境初始化 (Hive、Dio、Theme)
│   │
│   ├── core/
│   │   ├── api/
│   │   │   ├── kmu_client.dart           # 核心 API 客戶端
│   │   │   ├── interceptors/
│   │   │   │   ├── auth_interceptor.dart     # Token 自動附加、刷新
│   │   │   │   ├── encryption_interceptor.dart # 3DES/SHA 加密
│   │   │   │   └── logging_interceptor.dart  # 開發模式日誌
│   │   │   ├── endpoints/
│   │   │   │   ├── auth_endpoint.dart        # login, logout
│   │   │   │   ├── calendar_endpoint.dart    # calendar, events
│   │   │   │   ├── classroom_endpoint.dart   # category, list, detail, usage
│   │   │   │   ├── course_endpoint.dart      # myclass, myscore
│   │   │   │   ├── bus_endpoint.dart         # bus routes, realtime
│   │   │   │   ├── bike_endpoint.dart        # youbike stations
│   │   │   │   ├── news_endpoint.dart        # campus news
│   │   │   │   └── traffic_endpoint.dart     # traffic info
│   │   │   ├── models/
│   │   │   │   ├── auth_models.dart          # LoginReq, LoginRes, Token
│   │   │   │   ├── calendar_models.dart      # CalendarEvent, EventType
│   │   │   │   ├── classroom_models.dart     # Category, Room, Usage, TimeSlot
│   │   │   │   ├── course_models.dart        # Course, Score, Semester
│   │   │   │   ├── bus_models.dart           # BusRoute, BusStop, Realtime
│   │   │   │   ├── bike_models.dart          # BikeStation, Availability
│   │   │   │   └── common_models.dart        # ApiResponse, Pagination
│   │   │   └── exceptions/
│   │   │       ├── api_exception.dart
│   │   │       └── network_exception.dart
│   │   │
│   │   ├── cache/
│   │   │   ├── cache_service.dart          # Hive 封裝、TTL 管理
│   │   │   ├── calendar_cache.dart         # 行事曆專用快取 (1hr)
│   │   │   ├── classroom_cache.dart        # 場地快取
│   │   │   └── auth_cache.dart             # Token、使用者資料
│   │   │
│   │   ├── auth/
│   │   │   ├── auth_controller.dart        # Riverpod Notifier
│   │   │   ├── token_manager.dart          # Access/Refresh Token 生命週期
│   │   │   └── biometric_auth.dart         # 指紋/FaceID (Mobile)
│   │   │
│   │   ├── theme/
│   │   │   ├── app_theme.dart              # Material 3 ThemeData
│   │   │   ├── color_schemes.dart          # Light/Dark 色系
│   │   │   └── typography.dart             # 字體、大小規範
│   │   │
│   │   ├── constants/
│   │   │   ├── api_constants.dart          # Base URL, akfw, 3DES Key
│   │   │   ├── cache_constants.dart        # Hive Box 名稱、TTL
│   │   │   └── route_constants.dart        # 路由路徑定義
│   │   │
│   │   ├── utils/
│   │   │   ├── crypto_utils.dart           # 3DES、SHA-1、SHA-256
│   │   │   ├── date_utils.dart             # 週起始、格式化
│   │   │   └── validation_utils.dart       # 學號、Email 驗證
│   │   │
│   │   └── errors/
│   │       ├── error_handler.dart          # 統一錯誤處理、Toast
│   │       └── retry_policy.dart           # 指數退避重試
│   │
│   ├── features/
│   │   ├── auth/
│   │   │   ├── pages/
│   │   │   │   ├── login_page.dart
│   │   │   │   └── change_password_page.dart
│   │   │   ├── widgets/
│   │   │   │   ├── login_form.dart
│   │   │   │   └── remember_me_checkbox.dart
│   │   │   └── providers/
│   │   │       └── auth_providers.dart
│   │   │
│   │   ├── calendar/
│   │   │   ├── pages/
│   │   │   │   └── calendar_page.dart          # TabBar + 共用導航
│   │   │   ├── controllers/
│   │   │   │   └── calendar_controller.dart    # Riverpod AsyncNotifier
│   │   │   ├── views/
│   │   │   │   ├── month_view.dart             # Grid、事件標記
│   │   │   │   ├── week_view.dart              # 7欄垂直列表
│   │   │   │   └── day_view.dart               # 垂直時間軸
│   │   │   ├── widgets/
│   │   │   │   ├── calendar_tab_bar.dart       # 共用月/週/日切換
│   │   │   │   ├── calendar_header.dart        # 共用標題+導航
│   │   │   │   ├── event_chip.dart             # 事件顯示晶片
│   │   │   │   └── day_detail_modal.dart       # 點擊事件詳情
│   │   │   └── providers/
│   │   │       └── calendar_providers.dart
│   │   │
│   │   ├── classroom/
│   │   │   ├── pages/
│   │   │   │   ├── classroom_list_page.dart    # 分類 + 列表
│   │   │   │   └── classroom_detail_page.dart  # 時間軸 + 日期選擇
│   │   │   ├── controllers/
│   │   │   │   └── classroom_controller.dart
│   │   │   ├── widgets/
│   │   │   │   ├── category_chips.dart         # 可捲動分類
│   │   │   │   ├── room_card.dart
│   │   │   │   ├── usage_timeline.dart         # 垂直單欄時間軸
│   │   │   │   └── date_picker_field.dart
│   │   │   └── providers/
│   │   │       └── classroom_providers.dart
│   │   │
│   │   ├── courses/
│   │   │   ├── pages/
│   │   │   │   ├── my_schedule_page.dart       # 週課表視圖
│   │   │   │   ├── my_scores_page.dart         # 學期成績、趨勢圖
│   │   │   │   └── score_detail_page.dart      # 單科詳情
│   │   │   ├── widgets/
│   │   │   │   ├── schedule_grid.dart
│   │   │   │   ├── course_card.dart
│   │   │   │   ├── score_card.dart
│   │   │   │   └── score_trend_chart.dart
│   │   │   └── providers/
│   │   │       └── course_providers.dart
│   │   │
│   │   ├── transport/
│   │   │   ├── pages/
│   │   │   │   ├── bus_page.dart               # 路線 + 即時到站
│   │   │   │   └── bike_page.dart              # YouBike 站點地圖
│   │   │   ├── widgets/
│   │   │   │   ├── bus_route_card.dart
│   │   │   │   ├── bus_stop_list.dart
│   │   │   │   ├── realtime_arrival.dart
│   │   │   │   └── bike_station_marker.dart
│   │   │   └── providers/
│   │   │       └── transport_providers.dart
│   │   │
│   │   ├── campus_info/
│   │   │   ├── pages/
│   │   │   │   ├── news_page.dart              # 最新消息列表
│   │   │   │   ├── news_detail_page.dart
│   │   │   │   └── traffic_page.dart           # 交通資訊
│   │   │   └── providers/
│   │   │       └── campus_info_providers.dart
│   │   │
│   │   └── settings/
│   │       ├── pages/
│   │       │   └── settings_page.dart          # 主題、通知、關於
│   │       └── providers/
│   │           └── settings_providers.dart
│   │
│   ├── routing/
│   │   ├── app_router.dart               # GoRouter 設定
│   │   ├── route_guards.dart             # 需登入守衛、重導向
│   │   └── routes.dart                   # 路由常數
│   │
│   └── shared/
│       ├── widgets/
│       │   ├── feature_card.dart         # 首頁功能卡片
│       │   ├── loading_indicator.dart
│       │   ├── error_display.dart
│       │   ├── empty_state.dart
│       │   ├── app_scaffold.dart         # 共用 Scaffold (AppBar + Body)
│       │   ├── pull_to_refresh.dart
│       │   └── animated_list.dart
│       ├── extensions/
│       │   ├── context_extensions.dart   # theme、colorScheme 便捷存取
│       │   └── datetime_extensions.dart
│       └── mixins/
│           └── lifecycle_mixin.dart
│
├── test/
│   ├── unit/
│   │   ├── core/
│   │   │   ├── crypto_utils_test.dart
│   │   │   ├── date_utils_test.dart
│   │   │   └── cache_service_test.dart
│   │   ├── api/
│   │   │   ├── kmu_client_test.dart
│   │   │   └── endpoints_test.dart
│   │   └── features/
│   │       ├── calendar_controller_test.dart
│   │       └── classroom_controller_test.dart
│   ├── widget/
│   │   ├── calendar_views_test.dart
│   │   └── classroom_widgets_test.dart
│   └── integration/
│       └── auth_flow_test.dart
│
├── pubspec.yaml
├── analysis_options.yaml              # lint 規則 (flutter analyze 0-0-0)
├── melos.yaml                         # (可選) Monorepo 管理
├── README.md
├── CHANGELOG.md
└── PROJECT_PLAN.md                    # 本文件
```

---

## 3. 開發階段規劃

### Phase 1：基礎建設 (Week 1-2)
- [ ] `flutter create` 專案初始化
- [ ] `pubspec.yaml` 依賴配置、代碼生成設定
- [ ] `analysis_options.yaml` 嚴格規則 (0-0-0)
- [ ] Hive 初始化、Box 註冊、TypeAdapter 生成
- [ ] Dio + Interceptor 鏈 (Auth、Encryption、Logging)
- [ ] 加密工具類 (`crypto_utils.dart`) - 3DES/ECB/PKCS7、SHA-1、SHA-256
- [ ] KMU API 基礎客戶端 (`kmu_client.dart`)
- [ ] Material 3 主題系統 (Light/Dark、動態色彩)
- [ ] GoRouter 設定、路由守衛 (需登入頁面)
- [ ] CI/CD GitHub Actions (analyze, test, build web/android)

### Phase 2：認證系統 (Week 2-3)
- [ ] 登入頁面 (學號/密碼、記住帳號、生物辨識)
- [ ] `AuthController` (Riverpod) - 狀態：載入、成功、失敗、已登出
- [ ] Token 管理 - 自動刷新、過期處理、安全儲存
- [ ] 自動登入流程 (App 啟動檢查 Token 有效性)
- [ ] 登出、修改密碼
- [ ] 單元測試：加密、Token 解析、快取讀寫

### Phase 3：行事曆 (Week 3-4) ⭐ 核心優先
- [ ] `CalendarController` - 月/週/日狀態、快取管理
- [ ] 月檢視：Grid、事件標記 (最多3個+更多)、今天高亮
- [ ] 週檢視：7欄垂直列表、事件無限堆疊、週導航
- [ ] 日檢視：垂直時間軸、全天事件
- [ ] 共用導航列：月/週/日同步日期、上一個/下一個
- [ ] TabBar 切換 (月/週/日) - 日期狀態同步
- [ ] 事件點擊 → 底部 Modal 詳情
- [ ] 快取策略：月份一次性下載、1hr TTL、過期自動刷新
- [ ] 離線模式：快取優先、網路補充

### Phase 4：場地查詢 (Week 4-5)
- [ ] 分類晶片 (可水平捲動、單選)
- [ ] 場地列表：卡片式、搜尋過濾
- [ ] 場地詳情：垂直時間軸 (單欄)、日期選擇器、今天按鈕
- [ ] 快取：分類/列表 24hr、詳情 1hr

### Phase 5：課務系統 (Week 5-6)
- [ ] 我的課表：週視圖 Grid、課程卡片、顏色標記
- [ ] 我的成績：學期選擇、科目列表、學分/加權平均
- [ ] 成績趨勢圖 (fl_chart) - 學期 GPA 走勢
- [ ] 單科詳情：平時/期中/期末、排名

### Phase 6：交通與校園資訊 (Week 6-7)
- [ ] 校車：路線列表、站點順序、即時到站倒數
- [ ] YouBike：地圖標記、租借/歸還數量、導航連結
- [ ] 最新消息：列表、詳情、分類篩選
- [ ] 交通資訊：路況、停車場即時剩餘

### Phase 7：設定與優化 (Week 7-8)
- [ ] 設定頁：主題切換 (系統/淺/深)、字體大小、通知開關
- [ ] PWA 設定：Service Worker (Stale-While-Revalidate)、離線頁面
- [ ] 效能優化：圖片快取、列表虛擬化、程式碼分割
- [ ] 無障礙：語意標籤、對比度、鍵盤導航
- [ ] 國際化 (i18n)：繁中/英文 ARB 檔案

### Phase 8：測試與發布 (Week 8-9)
- [ ] 單元測試覆蓋率 > 80%
- [ ] Widget 測試關鍵流程
- [ ] 整合測試：登入 → 行事曆 → 場地 → 登出
- [ ] Web 建置驗證：`flutter build web --wasm`
- [ ] Android 建置：`flutter build apk --release`
- [ ] iOS 建置：`flutter build ipa --release` (需 Mac)
- [ ] 發布準備：版本號、更新日誌、隱私權政策

---

## 4. 關鍵技術細節

### 4.1 KMU API 加密流程 (移植自 Python)

```dart
// 關鍵常數 (從環境變數讀取，不硬編碼)
const String DES_KEY = 'KMU2readPerlJava20110705';  // 24 bytes for 3DES
const String AKFW = 'wCNDaoyYPRFU0Vg5EMNqcEvXKtRc4s33';

// uevw = SHA-1(userId + timestamp) -> hex lowercase
// uevw2 = SHA-256(userId + timestamp + token) -> hex UPPERCASE
// 3DES/ECB/PKCS7 加密 request body
```

### 4.2 快取策略

| 資料類型 | TTL | 儲存位置 | 更新策略 |
|---------|-----|---------|---------|
| 行事曆事件 | 1小時 | Hive `calendar_cache` | 月份整包下載、增量更新 |
| 場地分類/列表 | 24小時 | Hive `classroom_cache` | 背景刷新 |
| 場地詳情/時段 | 1小時 | Hive `classroom_cache` | 按需載入 |
| 使用者 Token | 永久 (手動登出) | Hive `auth_cache` + FlutterSecureStorage | 自動刷新 |
| 課表/成績 | 6小時 | Hive `course_cache` | 學期切換觸發 |
| 消息/公告 | 2小時 | Hive `news_cache` | 下拉刷新 |

### 4.3 狀態管理模式 (Riverpod)

```dart
// 非同步載入器模式
@riverpod
class CalendarController extends _$CalendarController {
  @override
  Future<CalendarState> build() async {
    return CalendarState.initial();
  }
  
  Future<void> switchView(CalendarView view) async { ... }
  Future<void> navigate(int delta) async { ... }
  Future<void> refresh() async { ... }
}

// 快取優先的資料提供者
final calendarEventsProvider = FutureProvider.family
  .autoDispose<List<CalendarEvent>, String>((ref, dateStr) async {
    final cache = await ref.watch(cacheServiceProvider).getCalendarEvent(dateStr);
    if (cache != null && !cache.isExpired) return cache.events;
    return ref.watch(kmuClientProvider).fetchCalendarEvents(dateStr);
  });
```

### 4.4 Web 專用處理

| 項目 | 處理方式 |
|------|---------|
| **CORS** | KMU API 若無 CORS，需架設代理 (Cloudflare Workers / 自建) |
| **Service Worker** | `flutter build web` 產生 + 自訂 `sw.js` (快取策略) |
| **深層連結** | GoRouter + `url_strategy: path` |
| **IndexedDB** | Hive 自動使用 (Web) |
| **生物辨識** | Web 不支援，降級為 PIN/密碼 |
| **地圖** | Web 使用 `maplibre_gl` (向量瓦片)、Mobile 用 `google_maps_flutter` |
| **推播** | Web Push API (VAPID) + FCM |

---

## 5. 環境變數與安全

```yaml
# .env (不提交 Git)
KMU_API_BASE_URL=https://mbms.kmu.edu.tw/appwsv3/
KMU_SEAT_API_BASE=https://sbms.lib.kmu.edu.tw/booking/APPAPI/
DES_KEY=KMU2readPerlJava20110705
AKFW=wCNDaoyYPRFU0Vg5EMNqcEvXKtRc4s33
FCM_VAPID_KEY=xxx
SENTRY_DSN=xxx
```

**建置時注入**：
```yaml
# pubspec.yaml
flutter:
  assets:
    - .env.prod
    - .env.dev
```

```dart
// main.dart
const String env = String.fromEnvironment('ENV', defaultValue: 'dev');
final config = await loadConfig('.env.$env');
```

---

## 6. 程式碼品質標準

```yaml
# analysis_options.yaml 關鍵規則
linter:
  rules:
    - always_declare_return_types
    - avoid_empty_else
    - avoid_relative_lib_imports
    - avoid_type_to_string
    - cancel_subscriptions
    - close_sinks
    - comment_references
    - control_flow_in_finally
    - empty_statements
    - hash_and_equals
    - no_duplicate_case_values
    - prefer_const_constructors
    - prefer_final_fields
    - prefer_single_quotes
    - type_init_formals
    - unawaited_futures
    - unnecessary_null_checks
    - use_build_context_synchronously
    - use_key_in_widget_constructors
```

- **flutter analyze** 必須 **0 errors, 0 warnings, 0 hints**
- **格式化**：`dart format .` (CI 強制檢查)
- **提交前**：`flutter analyze && flutter test && dart format --set-exit-if-changed .`

---

## 7. 部署架構

```
┌─────────────────────────────────────────────────────────────┐
│                      用戶端                                    │
│  Web (PWA)  │  Android  │  iOS  │  Desktop (Mac/Win/Linux)  │
└──────────────────────────┬────────────────────────────────────┘
                           │ HTTPS + 3DES 加密
                           ▼
┌─────────────────────────────────────────────────────────────┐
│                    KMU 官方 API                                │
│  mbms.kmu.edu.tw/appwsv3/  (教務、行事曆、場地、課表、成績)      │
│  sbms.lib.kmu.edu.tw/      (座位預約 - 僅校內網路)              │
└─────────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│                    Firebase (可選)                             │
│  FCM 推播  │  Crashlytics  │  Analytics  │  Remote Config   │
└─────────────────────────────────────────────────────────────┘
```

**Web 部署**：Firebase Hosting / Cloudflare Pages / GitHub Pages / 自有 Nginx
**Mobile 部署**：Play Store / App Store / TestFlight / Firebase App Distribution

---

## 8. 風險與對策

| 風險 | 影響 | 對策 |
|------|------|------|
| KMU API 無 CORS | Web 無法直連 | 架設 Cloudflare Workers 代理、或 Nginx 反向代理 |
| 座位預約 API 僅校內 | 校外無法使用 | 功能標示「校內專用」、錯誤提示友善化 |
| API 變更無通知 | 功能突然失效 | 版本化 API 端點、錯誤回報機制、快速熱修復 |
| 3DES 被視為不安全 | 合規風險 | 僅用於 KMU 相容、不儲存敏感資料、推動學校升級 |
| Flutter Web 效能 | 低階裝置卡頓 | WASM 建置、程式碼分割、虛擬化列表、圖片快取 |

---

## 9. 成功指標

- [ ] **flutter analyze**: 0-0-0
- [ ] **測試覆蓋率**: > 80% (核心邏輯 > 95%)
- [ ] **Web Lighthouse**: Performance > 90, PWA > 90, Accessibility > 95
- [ ] **啟動時間**: Web < 3s (首屏)、Mobile < 2s
- [ ] **記憶體**: 長時間運行無洩漏 (LeakCanary / DevTools 驗證)
- [ ] **離線可用**: 核心功能 (行事曆、場地、課表) 完全離線可用

---

## 10. 下一步行動

1. **確認企劃書內容** - 有無遺漏功能、優先順序調整
2. **建立 Flutter 專案** - `flutter create --platforms=web,android,ios,linux,macos,windows`
3. **配置 pubspec.yaml** - 所有依賴、代碼生成、環境變數
4. **建立基礎架構** - core/api、core/cache、core/auth、theme、routing
5. **開始 Phase 1 實作**

---

**文件版本**：v1.0  
**建立日期**：2026-09-03  
**負責人**：AndrewCho  
**審核狀態**：待確認