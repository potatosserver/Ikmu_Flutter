# IRS 模組待驗證與後續優化項目 (TBD)

> 本文件記錄重構完成後仍需驗證、測試或優化的項目。優先順序：P0 (阻礙上線) > P1 (功能完整性) > P2 (體驗優化) > P3 (技術債)。

---

## P0 - 校內實測驗證 (阻礙上線)

### 1. API 端點實際路徑確認
| 端點 | 程式碼路徑 | 需確認實際路徑 | 狀態 |
|------|------------|----------------|------|
| MQTT 發送 | `/irs/stu/mqttSend` | 需校內實測 | ⏳ 待驗證 |
| 異常回報 | `/irs/stu/abnormal` | 需校內實測 | ⏳ 待驗證 |
| 學生登入 | `/irs/stu/applogin` | 已在 Python 腳本驗證 | ✅ |
| 當前狀態 | `/irs/stu/current` | 已在 Python 腳本驗證 | ✅ |
| 當前題目 | `/irs/stu/current_qu` | 已在 Python 腳本驗證 | ✅ |
| 老師列表 | `/irs/stu/teacher_class` | 已在 Python 腳本驗證 | ✅ |
| 多題連答 | `/irs/stu/paperFill` | 已在 Python 腳本驗證 | ✅ |
| 作答記錄 | `/irs/stu/qaList` | 已在 Python 腳本驗證 | ✅ |
| 提問記錄 | `/irs/stu/askList` | 已在 Python 腳本驗證 | ✅ |
| 考試詳情 | `/irs/stu/examDetail` | 已在 Python 腳本驗證 | ✅ |
| 課程列表 | `/irs/stu/current_class/{userId}` | 已在 Python 腳本驗證 | ✅ |

**驗證方式**：在 KMU 校園網路環境下，使用測試帳號實際呼叫 `/irs/stu/mqttSend` 和 `/irs/stu/abnormal`，確認回應格式與 HTTP 狀態碼。

### 2. 即時答題完整流程 E2E 測試
- [ ] 選課程 → 選老師 → 登入 (applogin) → 取得狀態 (current) → MQTT 連線 → 訂閱主題
- [ ] 接收快問快答 (msgType=1) → 作答 → 收到確認 (msgType=98/answerConfirm)
- [ ] 接收單選/多選/填空 (msgType=2/3/4) → 作答 → 送出
- [ ] 接收試卷 (msgType=99) → 多題作答 → 送出 (paperFill)
- [ ] 多題連答倒數計時 → 自動送出
- [ ] 學生提問 → 教師回覆接收
- [ ] 頁面離開/切換 → 發送異常回報 (status=2)
- [ ] 作答逾時 → 發送異常回報 (status=1)

### 3. MQTT 連線穩定性測試
- [ ] 網路切換 (WiFi ↔ 行動網路) 重連機制
- [ ] App 進入背景/前景切換
- [ ] 長時間連線 (上課 50 分鐘) 無斷線
- [ ] 心跳機制 (msgType=98) 間隔與伺服器期望一致

---

## P1 - 功能完整性

### 4. 試卷題 (questionType=99) 完整驗證
- [ ] `irs/stu/current_qu` 回傳 `examData` 結構確認
- [ ] `examData.subQuList` 陣列結構：`subQuOrder`, `questionType`, `description`, `optKey`, `optVal`, `imgPath`
- [ ] `irs/stu/examDetail` 回傳 `items.subquList` 結構確認
- [ ] 子題類型混合：單選(2) + 多選(3) + 填空(4) 同時存在
- [ ] 子題圖片 `imgPath` 顯示
- [ ] 試卷作答送出格式：`[{"order":1,"ans":"A"},{"order":2,"ans":"B_C"},...]`
- [ ] 歷史記錄詳情顯示試卷子題 (已在 `irs_history_page.dart` 實作)

### 5. 圖片題完整支援
- [ ] `imgPath` 完整 URL 組裝：`https://mbms.kmu.edu.tw:443/KmuIrs/file.serv?fileID={imgPath}`
- [ ] 即時答題主題圖片顯示
- [ ] 試卷子題圖片顯示
- [ ] 歷史記錄詳情圖片顯示
- [ ] Dio 下載圖片並用 `Image.memory` 顯示 (已實作)

### 6. 指定學生作答 (assignStuList) 驗證
- [ ] MQTT 訊息包含 `assignStuList` 時，僅名單內學生收到題目
- [ ] `assignStuList` 結構：`[{"stuNo": "115029028"}, ...]`
- [ ] 學生端正確過濾 (已在 `_processIncomingQuestion` 實作)

### 7. seqList 過濾機制驗證
- [ ] 課程 `seqno` 與題目 `seqList` 比對邏輯
- [ ] `seqList` 格式：逗號分隔字串 `"1,2,3"` 或單一值
- [ ] 學生端正確過濾 (已在 `_processIncomingQuestion` 實作)

### 8. 已作答記錄本地快取 (SharedPreferences)
- [ ] Key 格式：`${ansUserId}_${questionId}`
- [ ] 重複題目不重複顯示
- [ ] 清除快取功能 (除錯用)

---

## P2 - 體驗優化

### 9. UI/UX 改善
- [ ] 載入狀態骨架屏
- [ ] 空狀態插圖優化
- [ ] 錯誤訊息更友善 (含重試按鈕)
- [ ] 即時答題倒數計時視覺化 (進度條 + 顏色變化)
- [ ] 試卷作答進度顯示 (已答/總題數)
- [ ] 多題連答輸入框字數提示

### 10. 除錯與診斷
- [ ] `IrsDebugLogPage` 匯出日誌檔案功能
- [ ] MQTT 連線狀態詳細資訊顯示 (Client ID, 訂閱主題, 最後收到訊息時間)
- [ ] API 請求/回應原始 JSON 檢視 (開發模式)
- [ ] 記憶體/CPU 使用量監控 (長時間上課)

### 11. 多語言支援 (i18n)
- [ ] 繁體中文 (預設)
- [ ] 簡體中文
- [ ] 英文
- [ ] ARB 檔案管理

---

## P3 - 技術債與架構優化

### 12. 程式碼品質
- [ ] 移除 `irs_list_page.dart` 中重複的即時答題邏輯 (與 `irs_realtime_page.dart` 共用)
- [ ] 提取共用 Widget：`_buildQuestionCard`, `_buildOptions`, `_buildCountdown`
- [ ] `IrsMqttService` 拆分：連線管理、訊息解析、發送介面
- [ ] Provider 狀態拆分：`irsRealtimeProvider`, `irsHistoryProvider`, `irsQuestionnaireProvider`

### 13. 測試覆蓋率
- [ ] 模型序列化/反序列化單元測試
- [ ] API 端點參數組裝單元測試
- [ ] MQTT 訊息解析單元測試
- [ ] Provider 狀態轉換單元測試
- [ ] Widget 測試：關鍵頁面渲染

### 14. 效能優化
- [ ] 圖片快取策略 (memory + disk)
- [ ] 列表虛擬化 (長清單)
- [ ] 延遲載入非關鍵資源
- [ ] 程式碼分割 (deferred loading)

### 15. 安全性強化
- [ ] Certificate Pinning (MQTT TLS)
- [ ] API 請求簽名/驗證
- [ ] 敏感資料記憶體保護
- [ ] 除錯日誌生產環境自動停用

---

## 已知限制與妥協

| 項目 | 說明 | 影響程度 | 後續計畫 |
|------|------|----------|----------|
| 無 Android 模擬器/真機 | 僅能靜態分析與 Web 版驗證 | 高 | GitHub Actions 建置 APK 後實機測試 |
| 校內網路限制 | API 僅能在 KMU 校園網路呼叫 | 高 | 申請 VPN 或測試環境 |
| MQTT 直接連線 | 原生 App 走 HTTP POST 轉發，非直接 MQTT | 中 | 已對齊 HTTP POST 方式 |
| 試卷題完整流程 | 缺乏實際試卷題目測試資料 | 中 | 等待教師端配合測試 |
| 推播通知 | FCM 整合未驗證 | 低 | 後續整合 |

---

## 相關資源連結

- 專案根目錄：`/home/user/StudioProjects/iKmuFlutter/`
- 反編譯 Java 原始碼：`/home/user/下載/ikmu_source/sources/`
  - `com/kmu/irs/IRSActivity.java` (2214 行)
  - `com/kmu/irs/IRSRecordActivity.java` (791 行)
- Python 測試腳本：`/home/user/桌面/IRS_AI_Flat/api_responses_test_irs_*.py`
- 重構提示詞：`/home/user/桌面/IRS_AI_Flat/AI.md` (4215 行)
- 變更記錄：`CHANGES.md`
- API 對照表：`API_ALIGNMENT.md`

---

## 更新記錄

| 日期 | 更新者 | 內容 |
|------|--------|------|
| 2025-01-14 | AI Assistant | 初版建立，整理重構後待驗證項目 |