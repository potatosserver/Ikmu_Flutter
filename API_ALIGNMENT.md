# IRS API 參數對齊對照表

> 本文件記錄 iKmuFlutter IRS 模組與 KMU 原生 Android App (反編譯 Java) 的 API 參數、回應格式、欄位映射對照。
> 所有對齊工作基於反編譯 Java 原始碼 (`IRSActivity.java`, `IRSRecordActivity.java`) 及 Python 實測腳本驗證。

---

## 1. IRS 即時答題 API (IRSActivity.java)

### 1.1 學生登入 `irs/stu/applogin` (SendIRSLoginData)

| 項目 | Flutter (重構前) | Flutter (重構後) | Java 原生 | 備註 |
|------|------------------|------------------|-----------|------|
| 端點 | `ApiEndpoints.irsStuApplogin` | 同上 | `/irs/stu/applogin` | POST |
| 參數: classid | `classid` | `classid` | `classid` | ✅ 一致 |
| 參數: stuno | `stuno` | `stuno` | `stuno` | ✅ 一致 |
| 參數: teacherno | `teacherno` | `teacherno` | `teacherno` | ✅ 一致 |
| 參數: bt | `bt` | `bt` | `bt` | 藍牙裝置識別碼，可空 |
| 回應 | `Map<String, dynamic>` | 同上 | `token`, `userId` 等 | 成功時回傳 token |

### 1.2 取得當前狀態 `irs/stu/current` (GetIRSCurrentData)

| 項目 | Flutter (重構前) | Flutter (重構後) | Java 原生 | 備註 |
|------|------------------|------------------|-----------|------|
| 端點 | `ApiEndpoints.irsCurrent` | 同上 | `/irs/stu/current` | POST |
| 參數: classid | `classid` | `classid` | `classid` | ✅ 一致 |
| 參數: stuno | `stuno` | `stuno` | `stuno` | ✅ 一致 |
| 參數: teacherno | `teacherno` | `teacherno` | `teacherno` | ✅ 一致 |
| 回應: success | `bool` | `bool` | `true/false` | ✅ 一致 |
| 回應: status | - | `String` | `status` | **新增**: `1`=進行中, `0`=未開始/結束 |
| 回應: message/reason | `message` | `message` | `reason` | **新增**: 失敗原因 (如「非上課時間」) |
| 回應: secno | - | `String` | `secno` | **新增**: 節次編號 |
| 回應: endTime | - | `String` | `endTime` | **新增**: 結束時間 (yyyyMMddHHmmss) |
| 回應: currentServerTime | - | `String` | `currentServerTime` | **新增**: 伺服器時間 (yyyyMMddHHmmss) |

### 1.3 取得當前題目 `irs/stu/current_qu` (GetIRSCurrentQu)

| 項目 | Flutter (重構前) | Flutter (重構後) | Java 原生 | 備註 |
|------|------------------|------------------|-----------|------|
| 端點 | `ApiEndpoints.irsStuCurrentQu` | 同上 | `/irs/stu/current_qu` | POST |
| 參數: classid | `cono` | `cono` | `cono` | **修正**: 原為 `classid` |
| 參數: stuno | `stuno` | `stuno` | `stuno` | ✅ 一致 |
| 參數: teacherno | - | `teafno` | `teafno` | **新增**: 教師編號 |
| 回應: quType | - | `String` | `quType` | `1`=快問快答, `2`=單選, `3`=多選, `4`=填空, `99`=試卷 |
| 回應: quData | - | `Map` | `quData` | 單題資料 |
| 回應: examData | - | `Map` | `examData` | 試卷資料 (quType=99) |
| 回應: question | - | `Map` | `question` | 通用題目欄位 |

### 1.4 取得老師列表 `irs/stu/teacher_class` (GetTeacherClass)

| 項目 | Flutter (重構前) | Flutter (重構後) | Java 原生 | 備註 |
|------|------------------|------------------|-----------|------|
| 端點 | `ApiEndpoints.irsCurrentTeacherClass` | 同上 | `/irs/stu/teacher_class` | POST |
| 參數: classid | `classid` | `classid` | `classid` | ✅ 一致 |
| 回應格式 | `List` 或 `{items: [...]}` | 同上 | 同上 | 兩種格式皆支援解析 |

### 1.5 多題連答 `irs/stu/paperFill` (UploadIRSPaperFillData)

| 項目 | Flutter (重構前) | Flutter (重構後) | Java 原生 | 備註 |
|------|------------------|------------------|-----------|------|
| 端點 | `ApiEndpoints.irsPaperFill` | 同上 | `/irs/stu/paperFill` | POST |
| 參數: classid | `classid` | `classid` | `classid` | ✅ 一致 |
| 參數: stuno | `stuno` | `stuno` | `stuno` | ✅ 一致 |
| 參數: teacherno | `teacherno` | `teacherno` | `teacherno` | ✅ 一致 |
| 參數: secno | `secno` | `secno` | `secno` | 節次編號 (來自 current API) |
| 參數: username | `username` | `username` | `username` | 學生姓名 |
| 參數: answers | `List<Map>` | `String (JSON)` | `answers` (JSON 字串) | **修正**: 必須為 JSON 字串 |
| 回應 | `Map` | `Map` | `success`, `message` | ✅ 一致 |

---

## 2. IRS 歷史記錄 API (IRSRecordActivity.java)

### 2.1 學生課程列表 `irs/stu/current_class` (GetStudentClass)

| 項目 | Flutter (重構前) | Flutter (重構後) | Java 原生 | 備註 |
|------|------------------|------------------|-----------|------|
| 端點 | `ApiEndpoints.irsCurrentClass/$userId` | 同上 | `/irs/stu/current_class/{userId}` | POST |
| 參數: userId | `userId` (body) | `userId` (body) | `userId` | ✅ 一致 |
| 回應: teacherList | `List<IrsRealtimeTeacher>` | 同上 | `teacherList` | 包含老師清單供即時答題使用 |
| 回應欄位 | `id`, `name`, `startTime`, `endTime`, `seqno` | 同上 | 同上 | ✅ 一致 |

### 2.2 作答記錄 `irs/stu/qaList` (GetQAData)

| 項目 | Flutter (重構前) | Flutter (重構後) | Java 原生 | 備註 |
|------|------------------|------------------|-----------|------|
| 端點 | `ApiEndpoints.irsStudentQaList` | 同上 | `/irs/stu/qaList` | POST |
| 參數: stuno | `_currentUserId` | `_currentUserId` | `stuno` | 學號 |
| 參數: cono | `courseId` | `cono` | `cono` | **修正**: 原參數名為 `cono` |
| 回應格式 | `List` 或 `{items: [...]}` | 同上 | 同上 | 兩種格式皆支援 |
| 記錄欄位 (14 欄) | 不完整 | **完整 14 欄** | `parseList` 解析 | 詳見下方欄位對照表 |

### 2.3 提問記錄 `irs/stu/askList` (GetAskData)

| 項目 | Flutter (重構前) | Flutter (重構後) | Java 原生 | 備註 |
|------|------------------|------------------|-----------|------|
| 端點 | `ApiEndpoints.irsStudentAskList` | 同上 | `/irs/stu/askList` | POST |
| 參數: stuno | `_currentUserId` | `_currentUserId` | `stuno` | 學號 |
| 參數: cono | `courseId` | `cono` | `cono` | **修正**: 原參數名為 `cono` |
| 回應格式 | `List` 或 `{items: [...]}` | 同上 | 同上 | 兩種格式皆支援 |

### 2.4 考試詳情 `irs/stu/examDetail` (GetExamData)

| 項目 | Flutter (重構前) | Flutter (重構後) | Java 原生 | 備註 |
|------|------------------|------------------|-----------|------|
| 端點 | `ApiEndpoints.irsStudentExamDetail` | 同上 | `/irs/stu/examDetail` | POST |
| 參數: stuno | `userId` | `stuno` | `stuno` | 學號 |
| 參數: quid | `quid` | `quid` | `quid` | 題目/試卷 ID |
| 回應結構 | 錯誤 (當作陣列) | **正確 (物件)** | `items` 為物件 | **關鍵修正**: `items` 是物件非陣列 |
| 回應: items.subquList | - | `List<IrsSubQuestion>` | `subquList` | **新增**: 試卷子題列表 |
| 回應: items.ansTime | - | `String` | `ansTime` | 作答時間 |
| 回應: items.teafNam | - | `String` | `teafNam` | 教師中文名 |
| 回應: items.teafEnam | - | `String` | `teafEnam` | 教師英文名 |
| 回應: items.description | - | `String` | `description` | 試卷說明 |
| 回應: items.myScore | - | `int` | `myScore` | 我的得分 |
| 回應: items.totalScore | - | `int` | `totalScore` | 總分 |

---

## 3. 作答記錄欄位完整對照 (14 欄位)

> 對齊 `IRSRecordActivity.java` 中 `parseList` 方法解析的 14 個欄位

| 索引 | Java 欄位名 | Flutter 模型欄位 | 型別 | 說明 |
|------|-------------|------------------|------|------|
| 0 | `qseq` | `questionId` | `String` | 題目序號/ID |
| 1 | `ques` | `title` | `String` | 題目內容 |
| 2 | `ans` | `myAnswer` | `String` | 我的答案 |
| 3 | `correct` | `correct` | `bool?` | 是否答對 |
| 4 | `hideAns` | `hideAns` | `String?` | 是否隱藏答案 |
| 5 | `ansUsrId` | `ansUserId` | `String?` | 作答者 ID |
| 6 | `ansTime` | `answerTime` / `askTime` | `String?` | 作答/提問時間 |
| 7 | `isMulti` | `isMulti` | `String?` | 是否多選 |
| 8 | `score` | `myScore` | `int?` | 獲得分數 |
| 9 | `scoreType` | `scoreType` | `String?` | 分數類型 |
| 10 | `qType` | `questionType` | `String?` | 題型: 1/2/3/4/99 |
| 11 | `subquList` | `subquList` | `List?` | 子題列表 (試卷用) |
| 12 | `optionList` | `options` | `List?` | 選項列表 |
| 13 | `imgPath` | `imgPath` | `String?` | 圖片路徑 |
| - | `description` | `description` | `String?` | 題目描述 (試卷用) |
| - | `askDesc` | `askDesc` | `String?` | 提問描述 |
| - | `teafNam` | `teacherName` | `String?` | 教師中文名 |
| - | `teafEnam` | `teacherEnglishName` | `String?` | 教師英文名 |
| - | `totalScore` | `totalScore` | `int?` | 總分 |
| - | `scoreDesc` | `scoreDesc` | `String?` | 分數說明 |
| - | `stdAnswer` | `stdAnswer` | `String?` | 標準答案 |

**關鍵修正**:
- `ansUserId` 計算邏輯：`stuno + classId 末 4 碼` (對齊 Java `getAnsUserId()`)
- `questionType == "99"` 表示試卷，需呼叫 `examDetail` API 取得 `subquList`

---

## 4. MQTT 協定對齊

### 4.1 連線參數

| 項目 | Flutter (重構前) | Flutter (重構後) | Java 原生 | 備註 |
|------|------------------|------------------|-----------|------|
| Broker | `mbms.kmu.edu.tw:8883` | 同上 | 同上 | SSL/TLS |
| Client ID | UUID | `android_<stuno>_<timestamp>` | 同上 | **關鍵修正**: 格式必須一致 |
| Username | 無 | 無 | 無 | |
| Password | 無 | 無 | 無 | |

### 4.2 訂閱主題

| 項目 | Flutter (重構前) | Flutter (重構後) | Java 原生 | 備註 |
|------|------------------|------------------|-----------|------|
| 快問快答 | `xnow_quick_${classId}_${teacherNo}` | `xnow_quick` | `xnow_quick` | **修正**: 固定主題，不帶參數 |
| 一般題目 | `xnow_normal_${classId}_${teacherNo}` | `xnow_normal` | `xnow_normal` | **修正**: 固定主題，不帶參數 |

### 4.3 發送方式 (關鍵差異)

| 項目 | Flutter (重構前) | Flutter (重構後) | Java 原生 | 備註 |
|------|------------------|------------------|-----------|------|
| 發送方式 | MQTT `publish` 直接發送 | **HTTP POST** → `/irs/stu/mqttSend` | `URL_IRS_MQTTSEND` | **架構差異**: 原生不直接發 MQTT，由後端轉發 |
| HTTP 端點 | - | `ApiEndpoints.irsMqttSend` | `/irs/stu/mqttSend` | POST |
| HTTP 參數: topic | - | `xnow_quick` / `xnow_normal` | 同上 | |
| HTTP 參數: msg | - | JSON 字串 | 同上 | 完整訊息內容 |
| HTTP 參數: quid | - | 題目 ID | 同上 | |

### 4.4 訊息類型對照

| msgType | 名稱 | 用途 | 發送方 |
|---------|------|------|--------|
| `1` | 快問快答 | 即時單題 | 教師端 → 學生端 |
| `2` | 單選題 | 一般單選 | 教師端 → 學生端 |
| `3` | 多選題 | 一般多選 | 教師端 → 學生端 |
| `4` | 填空題 | 文字填空 | 教師端 → 學生端 |
| `98` | 心跳/已讀 | 學生端回報已讀 | 學生端 → 後端 |
| `99` | 試卷 | 多題連答/考卷 | 教師端 → 學生端 |

### 4.5 學生端送出訊息格式 (HTTP POST 到 mqttSend)

#### 作答訊息 (單選/多選/填空/快問快答)
```json
{
  "msgType": "2",
  "quid": "question_id",
  "classId": "class_id",
  "teacherNo": "teacher_no",
  "ansUserId": "student_id",
  "ansUserName": "student_name",
  "answer": "A",           // 單選: "A", 多選: "A_B_C", 填空/快問: 文字
  "questionType": "2",     // 1/2/3/4
  "os": "android",
  "version": "1.0.0",
  "token": "",
  "device": "device_model"
}
```

#### 試卷作答 (msgType: "99")
```json
{
  "msgType": "99",
  "quid": "exam_id",
  "classId": "class_id",
  "teacherNo": "teacher_no",
  "ansUserId": "student_id",
  "ansUserName": "student_name",
  "answer": "[{\"order\":1,\"ans\":\"A\"},{\"order\":2,\"ans\":\"B_C\"},...]",
  "questionType": "99",
  "os": "android",
  "version": "1.0.0",
  "token": "",
  "device": "device_model"
}
```

#### 學生提問 (msgType: "3", topic: "stuask")
```json
{
  "msgType": "3",
  "topic": "stuask",
  "classId": "class_id",
  "teacherNo": "teacher_no",
  "secno": "section_no",
  "ansUserId": "student_id",
  "ansUserName": "student_name",
  "content": "提問內容",
  "anonymous": false,
  "os": "android",
  "version": "1.0.0",
  "token": "",
  "device": "device_model"
}
```

#### 已讀回報 (msgType: "98")
```json
{
  "msgType": "98",
  "quid": "question_id",
  "classId": "class_id",
  "teacherNo": "teacher_no",
  "ansUserId": "student_id",
  "questionType": "2",
  "os": "android",
  "version": "1.0.0",
  "token": "",
  "device": "device_model"
}
```

#### 異常/逾時/離開回報 (HTTP POST 到 `/irs/stu/abnormal`)
| 參數 | 值 | 說明 |
|------|-----|------|
| `quid` | 題目 ID | |
| `status` | `1` / `2` | `1`=作答逾時, `2`=頁面暫停/離開 |
| `stuno` | 學號 | |

---

## 5. 日期時間格式處理

支援以下格式 (對齊 Java `parseDateTime`):
| 格式 | 範例 | 處理方式 |
|------|------|----------|
| `yyyyMMddHHmmss` | `20250114103045` | 直接解析 |
| `yyyy/MM/dd HH:mm:ss` | `2025/01/14 10:30:45` | 替換 `/` 為 `-` 解析 |
| 民國年 `yyy/MM/dd` | `114/01/14` | 年份 +1911 |
| 民國年 `yyyMMdd` | `1140114` | 年份 +1911 |
| ISO-8601 | `2025-01-14T10:30:45` | 直接解析 |

---

## 6. 多選答案格式

| 端 | 格式 | 範例 |
|----|------|------|
| Java 原生 / API 送出 | 底線 `_` 連接 | `"A_B_C"` |
| Flutter 舊版 | 逗號 `,` 連接 | `"A,B,C"` |
| **Flutter 新版** | **底線 `_` 連接** | **`"A_B_C"`** ✅ |

---

## 7. ansUserId 計算規則

```dart
// Java 原生邏輯 (IRSActivity.java getAnsUserId)
String getAnsUserId(String userId, String userType) {
  if (userType != "學生" && userType.isNotEmpty) {
    return userId; // 老師/助教用原 ID
  }
  // 學生: stuno + classId 末 4 碼
  return userId + (classId.length >= 4 ? classId.substring(classId.length - 4) : classId);
}
```

Flutter 實作：`IrsMqttService.resolveAnsUserId(userId, userType)`

---

## 8. 驗證腳本對照

Python 測試腳本位置：`/home/user/桌面/IRS_AI_Flat/api_responses_test_irs_*.py`

| 腳本 | 對應 API | 驗證項目 |
|------|----------|----------|
| `test_irs_current_qu.py` | `current_qu` | 參數 `cono`, `stuno`, `teafno`、回應結構 |
| `test_irs_applogin.py` | `applogin` | 登入流程、token 取得 |
| `test_irs_current.py` | `current` | 回傳 `secno`, `endTime`, `currentServerTime`, `status` |
| `test_irs_paperFill.py` | `paperFill` | 多題連答送出、answers JSON 格式 |
| `test_irs_qaList.py` | `qaList` | 14 欄位解析、questionType 99 處理 |
| `test_irs_examDetail.py` | `examDetail` | `items` 為物件、`subquList` 解析 |
| `test_irs_askList.py` | `askList` | 提問記錄欄位 |
| `test_irs_student_class.py` | `current_class` | 課程列表含 `teacherList` |

---

## 9. 待確認項目 (TBD.md 參考)

- [ ] `irs/stu/mqttSend` 實際端點路徑是否為 `/irs/stu/mqttSend` (需校內實測)
- [ ] `irs/stu/abnormal` 端點路徑確認
- [ ] 試卷題 `questionType=99` 的 `subQuList` 回應結構完整驗證
- [ ] 圖片題 `imgPath` 完整 URL 組裝規則
- [ ] MQTT 重連機制與心跳間隔原生行為確認