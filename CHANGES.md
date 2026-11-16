# IRS 模組重構變更記錄

> 本文件記錄 iKmuFlutter IRS (即時答題系統) 模組的重構變更，對齊 KMU 原生 Android App (IRSActivity.java, IRSRecordActivity.java) 的行為與 API 協定。

---

## 版本歷史

### v2.0.0 (2025-01-14) - 完整重構對齊原生行為

#### 🎯 核心目標
- 完整對齊 KMU 原生 IRSActivity.java 與 IRSRecordActivity.java 的 API 流程、參數、回應格式
- 修正所有已知的參數不一致、欄位映射錯誤、MQTT 協定差異
- 移除硬編碼測試帳號，強化安全性

#### 📦 模型層 (`lib/features/irs/models/irs_models.dart`)
| 變更項目 | 說明 |
|----------|------|
| `IrsAnswerRecord` | 新增 14 欄位完整對齊 Java `parseList`：`qseq, ques, ans, correct, hideAns, ansUsrId, ansTime, isMulti, score, scoreType, qType, subquList, optionList, imgPath, description, askDesc, teafNam, teafEnam, myScore, totalScore, scoreDesc, stdAnswer` |
| `ansUserId` 計算 | 修正為 `stuno + classId 末 4 碼` (對齊 Java `getAnsUserId`) |
| `IrsExamDetail` | 新增模型對齊 `irs/stu/examDetail` 回應結構：`items` 為物件，含 `subquList` 陣列 |
| `IrsSubQuestion` | 新增子題模型：`subQuOrder, questionType, description, scoreDesc, myAnswer, stdAnswer, optionList, imgPath` |
| `IrsRealtimeQuestion` | 新增 `seqList, assignStuList, period, subQuestions` 欄位 |
| Freezed 遷移 | 全模型改用 `@freezed` + `fromJson`/`toJson`，移除手寫序列化 |

#### 🔌 API 端點層 (`lib/core/api/endpoints/endpoints.dart`)
| API | 原參數 | 新參數 (對齊 Java) | 備註 |
|-----|--------|-------------------|------|
| `irs/stu/current_qu` | `cono`, `stuno` | `cono`, `stuno`, `teafno` | 新增 `teafno` |
| `irs/stu/applogin` | `classid`, `stuno`, `teacherno`, `bt` | 同上 | 參數名確認一致 |
| `irs/stu/current` | `classid`, `stuno`, `teacherno` | 同上 | 回傳 `secno, endTime, currentServerTime, status, reason` |
| `irs/stu/teacher_class` | `classid` | 同上 | 回傳 List 或 `{items: [...]}` 皆支援 |
| `irs/stu/paperFill` | `classid`, `stuno`, `teacherno`, `secno`, `username`, `answers` | 同上 | `answers` 必須為 JSON 字串 |
| `irs/stu/qaList` | `stuno`, `cono` | 同上 | 學生端作答記錄 |
| `irs/stu/askList` | `stuno`, `cono` | 同上 | 學生端提問記錄 |
| `irs/stu/examDetail` | `stuno`, `quid` | 同上 | 回傳 `items` 物件含 `subquList` |
| `irs/stu/mqttSend` | - | **新增** | HTTP POST 轉發 MQTT：`topic`, `msg`, `quid` |
| `irs/stu/abnormal` | - | **新增** | 異常/逾時/離開回報：`quid`, `status`, `stuno` |

#### 📡 MQTT 服務層 (`lib/core/api/services/irs_mqtt_service.dart`)
| 項目 | 原實作 | 新實作 (對齊 Java) |
|------|--------|-------------------|
| Client ID | UUID | `android_<stuno>_<timestamp>` |
| 訂閱主題 | 單一主題 | **雙主題**：`xnow_quick`, `xnow_normal` |
| 發送方式 | MQTT 直接發布 | **HTTP POST** 到 `URL_IRS_MQTTSEND` (`/irs/stu/mqttSend`) |
| 訊息類型 | 簡易分類 | 完整對齊：`1`=快問快答, `2`=單選, `3`=多選, `4`=填空, `98`=心跳/已讀, `99`=試卷 |
| 多選答案格式 | 逗號分隔 | **底線 `_` 連接** (對齊 Java) |
| 試卷答案 | 不支援 | **支援** `sendExamPaperAnswers` |
| 已讀回報 | 不支援 | **支援** `sendQuestionReceipt` (msgType 98) |
| 學生提問 | 不支援 | **支援** `sendStudentAsk` (topic: `stuask`) |
| 異常回報 | 不支援 | **支援** `sendAbnormal` (status: `1`=逾時, `2`=離開) |

#### 🧠 Provider 層 (`lib/features/irs/providers/irs_providers.dart`)
| 變更 | 說明 |
|------|------|
| `loadExamDetail` | 完整重寫：`questionType == "99"` 呼叫 `examDetail` API 解析 `subquList`；單題則由記錄直接建構 |
| `submitPaperFill` | 新增多題連答送出方法 |
| `sendMqttMessage` / `sendAbnormal` | 新增代理方法供頁面呼叫 |
| 狀態新增 | `examDetail`, `historyTab`, `selectedCourseId` |

#### 📱 頁面層
| 檔案 | 關鍵變更 |
|------|----------|
| `irs_realtime_page.dart` | 完整重寫：對齊 IRSActivity.java 完整流程 (選課程/老師 → 登入 → 取得狀態 → MQTT 連線訂閱 → 收發題目/作答/提問/多題連答) |
| `irs_history_page.dart` | 詳情對話框支援試卷 `subquList` 顯示 (對齊 show99View) |
| `irs_list_page.dart` | 首頁整合即時答題，自動偵測當前課程並連線 |
| `irs_detail_page.dart` | 靜態問卷答題頁 (無變動，已符合規格) |

#### 🛡️ 安全性與品質
- 移除所有硬編碼測試帳號 (`115029028`, `AndrewCho970531`)
- 所有 API 參數名稱、欄位映射經 Java 反編譯碼與 Python 實測腳本驗證
- `flutter analyze` 零錯誤、零警告、零提示 (0-0-0)

---

## 檔案異動清單

### 核心檔案 (5 檔)
1. `lib/features/irs/models/irs_models.dart` - 模型完整重寫 (685 行)
2. `lib/core/api/services/irs_mqtt_service.dart` - MQTT 服務重寫 (401 行)
3. `lib/core/api/endpoints/endpoints.dart` - API 端點參數對齊
4. `lib/features/irs/providers/irs_providers.dart` - Provider 邏輯完善
5. `lib/features/irs/pages/irs_realtime_page.dart` - 即時答題頁完整重寫

### 頁面檔案 (3 檔)
6. `lib/features/irs/pages/irs_history_page.dart` - 歷史記錄詳情支援試卷子題
7. `lib/features/irs/pages/irs_detail_page.dart` - 靜態問卷答題 (微調)
8. `lib/features/irs/pages/irs_list_page.dart` - 首頁整合即時答題

### 文件檔案 (3 檔)
9. `CHANGES.md` - 本檔案
10. `API_ALIGNMENT.md` - API 參數對齊對照表
11. `TBD.md` - 待驗證/後續優化項目

---

## 驗證清單

- [x] `flutter analyze` → 0 errors, 0 warnings, 0 hints
- [x] `flutter build apk --release` → 編譯通過
- [x] 模型序列化/反序列化測試
- [x] API 參數名稱對照 Java 反編譯碼
- [x] MQTT Client ID 格式驗證
- [x] 訂閱主題雙通道驗證
- [x] 多選答案底線連接格式驗證
- [x] 試卷 `examDetail` 回應結構驗證
- [ ] 校園網路實機測試 (需 KMU 校內環境)
- [ ] 即時答題完整流程 E2E 測試
- [ ] 多題連答倒數自動送出測試
- [ ] 學生提問/教師回覆測試

---

## 相關參考
- 反編譯 Java 原始碼：`/home/user/下載/ikmu_source/sources/`
  - `com/kmu/irs/IRSActivity.java` (2214 行) - 即時答題主流程
  - `com/kmu/irs/IRSRecordActivity.java` (791 行) - 歷史記錄/考試詳情
- Python 實測腳本：`/home/user/桌面/IRS_AI_Flat/api_responses_test_irs_*.py`
- 重構提示詞：`/home/user/桌面/IRS_AI_Flat/AI.md` (4215 行)