// IRS 問卷列表頁面（IRS 首頁）
// 包含問卷列表 + 即時答題的課程/老師選擇與 MQTT 連線
// 完整對齊 KMU 原生 IRSActivity.java：
// - MQTT 發送使用 HTTP POST (URL_IRS_MQTTSEND) 由後端轉發
// - Client ID: android_<stuno>_<timestamp>
// - 訂閱主題: xnow_quick, xnow_normal
// - 即時題目流程: 選課程/老師 -> SendIRSLoginData -> GetIRSCurrentData -> MQTT Connect & Subscribe

import 'dart:async';
import 'dart:io' show Platform;
import 'dart:typed_data';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;

import '../../../core.dart';
import '../providers/irs_providers.dart';
import '../utils/irs_debug_log.dart';
import '../../../core/api/services/irs_mqtt_service.dart';

class IrsListPage extends ConsumerStatefulWidget {
  const IrsListPage({super.key});

  @override
  ConsumerState<IrsListPage> createState() => _IrsListPageState();
}

class _IrsListPageState extends ConsumerState<IrsListPage> {
  static const String _irsImageBaseUrl =
      'https://mbms.kmu.edu.tw:443/KmuIrs/file.serv?fileID=';

  IrsMqttService? _mqttService;
  Timer? _reconnectTimer;
  Timer? _autoSelectTimer;

  String? _selectedClassId;
  String? _selectedTeacherNo;
  List<IrsStudentClass> _classes = <IrsStudentClass>[];
  List<IrsRealtimeTeacher> _teachers = <IrsRealtimeTeacher>[];

  bool _isConnecting = false;
  bool _isConnected = false;
  bool _isSubscribed = false;
  bool _isAutoConnecting = false;

  // 伺服器時間差 (秒) 與當前 secno
  int _phoneTimeDiffSeconds = 0;
  String _secno = '';

  // 當前課程 seqno (用於 seqList 過濾)
  String? _currentSeqno;

  // 當前即時題目狀態 (type: 1=快問快答, 2=單選, 3=多選, 4=填空, 99=試卷)
  IrsRealtimeQuestion? _currentQuestion;
  String? _activeQuid;
  final Map<String, bool> _selectedOptions = <String, bool>{};
  String _textAnswer = '';

  bool _isSubmitting = false;
  int _periodCount = 0;
  int _totalPeriod = 0;
  Timer? _countdownTimer;
  bool _hasAnswered = false;

  // 多題連答 (paperFill) 狀態
  int _ctPeriodCount = 0;
  Timer? _ctCountdownTimer;
  bool _canSubmitPaperFill = false;
  bool _canAskTeacher = false;
  final List<TextEditingController> _paperFillControllers =
      List<TextEditingController>.generate(5, (_) => TextEditingController());

  // 學生提問狀態
  final TextEditingController _askController = TextEditingController();
  bool _isAnonymousAsk = false;
  bool _isSendingAsk = false;

  String _cachedAppVersion = '1.0.0';
  String _cachedDeviceModel = 'Flutter';

  @override
  void initState() {
    super.initState();
    unawaited(_initDeviceMetadata());
    unawaited(_loadClasses());
    _startAutoSelectCheck();
  }

  Future<void> _initDeviceMetadata() async {
    try {
      final info = await PackageInfo.fromPlatform();
      _cachedAppVersion = info.version;
    } catch (_) {}
    try {
      final deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final android = await deviceInfo.androidInfo;
        _cachedDeviceModel = android.model;
      } else if (Platform.isIOS) {
        final ios = await deviceInfo.iosInfo;
        _cachedDeviceModel = ios.utsname.machine;
      }
    } catch (_) {}
  }

  String _getAnsUserId() {
    final auth = ref.read(authControllerProvider);
    final userId = auth.userId ?? '';
    final userType = auth.userProfile?.userType;
    return IrsMqttService.resolveAnsUserId(userId, userType);
  }

  String _getAnsUserName() {
    final auth = ref.read(authControllerProvider);
    final userName = auth.userProfile?.userName ?? auth.userId ?? '';
    final userType = auth.userProfile?.userType;
    return IrsMqttService.resolveAnsUserName(userName, userType);
  }

  bool _isStudentRole() {
    final userType = ref.read(authControllerProvider).userProfile?.userType;
    return userType == null || userType.isEmpty || userType == '學生';
  }

  IrsMqttService _getMqttService() {
    _mqttService ??= IrsMqttService(
      onMessageReceived: _onMqttMessage,
      onConnectionChanged: _onMqttConnectionChanged,
      onError: _onMqttError,
      httpSender: ({
        required String topic,
        required String msg,
        required String quid,
        String? msgType,
      }) =>
          ref.read(irsProvider.notifier).sendMqttMessage(
                topic: topic,
                msg: msg,
                quid: quid,
                msgType: msgType,
              ),
    );
    return _mqttService!;
  }

  void _onMqttConnectionChanged(bool connected) {
    if (!mounted) return;
    setState(() => _isConnected = connected);
    if (!connected) {
      _startReconnect();
    } else {
      _reconnectTimer?.cancel();
    }
  }

  void _startReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer.periodic(const Duration(seconds: 10), (_) async {
      if (_isConnected || _isConnecting || _isAutoConnecting) return;
      if (_selectedClassId == null || _selectedTeacherNo == null) return;
      final authState = ref.read(authControllerProvider);
      final userId = authState.userId;
      if (userId == null || userId.isEmpty) return;

      final mqttService = _getMqttService();
      final success = await mqttService.connect(
        userId: userId,
        userType: authState.userProfile?.userType,
      );
      if (success && mounted) {
        setState(() => _isConnected = true);
        await mqttService.subscribeToQuestion(
          classId: _selectedClassId!,
          teacherNo: _selectedTeacherNo!,
        );
        if (mounted) setState(() => _isSubscribed = true);
      }
    });
  }

  void _onMqttError(String error) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('MQTT 錯誤：$error')),
    );
  }

  void _startAutoSelectCheck() {
    _autoSelectTimer?.cancel();
    _autoSelectTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      _checkAndAutoConnect();
    });
    // 立即檢查一次
    _checkAndAutoConnect();
  }

  Future<void> _checkAndAutoConnect() async {
    final now = DateTime.now();
    final authState = ref.read(authControllerProvider);
    final userId = authState.userId;
    if (userId == null || userId.isEmpty) return;

    final notifier = ref.read(irsProvider.notifier);
    await notifier.loadStudentClasses();
    if (!mounted) return;

    final classes = ref.read(irsProvider).studentClasses;
    if (classes.isEmpty) return;

    // 找出當前時間範圍內的課程
    IrsStudentClass? currentClass;
    for (final c in classes) {
      try {
        final start = DateTime.parse(c.startTime ?? '');
        final end = DateTime.parse(c.endTime ?? '');
        if (now.isAfter(start) && now.isBefore(end)) {
          currentClass = c;
          break;
        }
      } catch (_) {}
    }

    if (currentClass == null) return;

    // 若已選擇不同課程，不自動切換（尊重使用者手動選擇）
    if (_selectedClassId != null && _selectedClassId != currentClass.id) return;

    // 更新課程列表狀態
    setState(() => _classes = classes);

    // 自動選擇課程
    if (_selectedClassId != currentClass.id) {
      await _onClassChanged(currentClass.id!);
    }

    // 自動連線 MQTT
    if (_selectedClassId != null && _selectedTeacherNo != null && !_isSubscribed) {
      await _autoConnectAndSubscribe();
    }
  }

  Future<void> _loadClasses() async {
    final notifier = ref.read(irsProvider.notifier);
    await notifier.loadStudentClasses();
    if (!mounted) return;
    setState(() {
      _classes = ref.read(irsProvider).studentClasses;
    });
  }

  Future<void> _onClassChanged(String? classId) async {
    IrsDebugLog.log('[IRS] _onClassChanged: classId=$classId');
    if (_selectedClassId != null && _selectedClassId != classId) {
      await _unsubscribe();
    }

    String? seqno;
    for (final c in _classes) {
      if (c.id == classId) {
        seqno = c.seqno;
        break;
      }
    }

    setState(() {
      _selectedClassId = classId;
      _currentSeqno = seqno;
      _selectedTeacherNo = null;
      _teachers = <IrsRealtimeTeacher>[];
      _clearQuestion();
    });

    if (classId != null && classId.isNotEmpty) {
      final notifier = ref.read(irsProvider.notifier);
      IrsDebugLog.log('[IRS] 正在載入老師列表...');
      await notifier.loadTeacherClasses(classId);
      if (!mounted) return;
      final teachers = ref.read(irsProvider).availableTeachers;
      IrsDebugLog.log('[IRS] 載入老師完成: ${teachers.length} 位');
      for (final t in teachers) {
        IrsDebugLog.log('[IRS]   老師: id=${t.id}, name=${t.name}');
      }
      setState(() {
        _teachers = teachers;
      });

      // 自動選擇第一個老師並連線（如果只有一個老師）
      if (_teachers.length == 1) {
        IrsDebugLog.log('[IRS] 單一老師自動選擇: ${_teachers.first.id}');
        await _onTeacherChanged(_teachers.first.id);
      }
    }
  }

  Future<void> _onTeacherChanged(String? teacherNo) async {
    if (_selectedTeacherNo != null && _selectedTeacherNo != teacherNo) {
      await _unsubscribe();
    }
    setState(() {
      _selectedTeacherNo = teacherNo;
      _clearQuestion();
    });

    // 選擇老師後自動連線 MQTT
    if (teacherNo != null && teacherNo.isNotEmpty && _selectedClassId != null) {
      await _autoConnectAndSubscribe();
    }
  }

  void _clearQuestion() {
    _currentQuestion = null;
    _activeQuid = null;
    _selectedOptions.clear();
    _textAnswer = '';
    _hasAnswered = false;
    _periodCount = 0;
    _totalPeriod = 0;
    _countdownTimer?.cancel();
  }

  Future<void> _autoConnectAndSubscribe() async {
    if (_isAutoConnecting) return;
    if (_selectedClassId == null || _selectedTeacherNo == null) return;

    setState(() => _isAutoConnecting = true);

    try {
      // 執行 IRS 登入與取得當前狀態 (對齊 IRSActivity.java SendIRSLoginData + GetIRSCurrentData)
      await _irsLoginAndGetCurrent();

      final mqttService = _getMqttService();
      final authState = ref.read(authControllerProvider);
      final userId = authState.userId;
      if (userId == null || userId.isEmpty) {
        throw Exception('使用者 ID 為空');
      }
      await mqttService.connect(
        userId: userId,
        userType: authState.userProfile?.userType,
      );

      await mqttService.subscribeToQuestion(
        classId: _selectedClassId!,
        teacherNo: _selectedTeacherNo!,
      );
      if (!mounted) return;
      setState(() {
        _isConnected = true;
        _isSubscribed = true;
        _isAutoConnecting = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isAutoConnecting = false);
      debugPrint('[IRS] 自動連線失敗: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('自動連線失敗：$e')),
      );
    }
  }

  /// 步驟 1+2：SendIRSLoginData + GetIRSCurrentData (對齊 IRSActivity.java)
  Future<void> _irsLoginAndGetCurrent() async {
    final notifier = ref.read(irsProvider.notifier);
    final ansUserId = _getAnsUserId();

    if (_isStudentRole()) {
      final loginResult = await notifier.irsStuApplogin(
        classId: _selectedClassId!,
        studentId: ansUserId,
        teacherNo: _selectedTeacherNo!,
        bt: '',
      );
      if (!mounted) return;
      IrsDebugLog.log('[IRS] applogin 結果: $loginResult');
    }

    final currentData = await notifier.getIRSCurrentData(
      classId: _selectedClassId!,
      studentId: ansUserId,
      teacherNo: _selectedTeacherNo!,
    );
    if (!mounted) return;
    IrsDebugLog.log('[IRS] current 狀態: $currentData');

    if (currentData == null) return;

    final isSuccess = currentData['success'] == true;
    final status = currentData['status']?.toString() ?? '';
    final reason = currentData['message']?.toString() ?? '';
    final serverTimeStr = currentData['currentServerTime']?.toString() ?? '';
    final endTimeStr = currentData['endTime']?.toString() ?? '';
    final secno = currentData['secno']?.toString() ?? '';

    final serverTime = _parseServerDateTime(serverTimeStr);
    if (serverTime != null) {
      _phoneTimeDiffSeconds = serverTime.difference(DateTime.now()).inSeconds;
    }

    if (isSuccess) {
      final endTime = _parseServerDateTime(endTimeStr);
      int ctSeconds = 0;
      if (serverTime != null && endTime != null) {
        ctSeconds = endTime.difference(serverTime).inSeconds;
      }
      setState(() {
        _secno = secno;
        _canSubmitPaperFill = ctSeconds > 0;
        _canAskTeacher = true;
      });
      if (ctSeconds > 0) {
        _startPaperFillCountdown(ctSeconds);
      }
    } else {
      setState(() {
        _secno = secno;
        _canSubmitPaperFill = false;
        _canAskTeacher = status != '1';
      });
      if (status == '1' && reason.isNotEmpty) {
        await showDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(reason),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('確定'),
              ),
            ],
          ),
        );
      }
    }
  }

  void _startPaperFillCountdown(int seconds) {
    _ctCountdownTimer?.cancel();
    setState(() => _ctPeriodCount = seconds);
    _ctCountdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_ctPeriodCount > 0) {
        setState(() => _ctPeriodCount--);
      } else {
        _ctCountdownTimer?.cancel();
        if (_canSubmitPaperFill) {
          unawaited(_submitPaperFillData(autoSubmit: true));
        }
      }
    });
  }

  /// 解析日期時間字串，支援：
  /// - yyyyMMddHHmmss (14 碼)
  /// - yyyy/MM/dd HH:mm:ss
  /// - ISO-8601
  /// - 民國年 yyyMMdd / yyy/MM/dd
  DateTime? _parseServerDateTime(String raw) {
    final s = raw.trim();
    if (s.isEmpty) return null;

    if (RegExp(r'^\d{14}$').hasMatch(s)) {
      final y = int.parse(s.substring(0, 4));
      final m = int.parse(s.substring(4, 6));
      final d = int.parse(s.substring(6, 8));
      final hh = int.parse(s.substring(8, 10));
      final mm = int.parse(s.substring(10, 12));
      final ss = int.parse(s.substring(12, 14));
      return DateTime(y, m, d, hh, mm, ss);
    }

    final slashMatch = RegExp(
      r'^(\d{3,4})/(\d{1,2})/(\d{1,2})\s+(\d{1,2}):(\d{1,2}):(\d{1,2})$',
    ).firstMatch(s);
    if (slashMatch != null) {
      var year = int.parse(slashMatch.group(1)!);
      if (year < 1911) year += 1911;
      return DateTime(
        year,
        int.parse(slashMatch.group(2)!),
        int.parse(slashMatch.group(3)!),
        int.parse(slashMatch.group(4)!),
        int.parse(slashMatch.group(5)!),
        int.parse(slashMatch.group(6)!),
      );
    }

    if (RegExp(r'^\d{7}$').hasMatch(s)) {
      final y = int.parse(s.substring(0, 3)) + 1911;
      final m = int.parse(s.substring(3, 5));
      final d = int.parse(s.substring(5, 7));
      return DateTime(y, m, d);
    }

    return DateTime.tryParse(s.replaceAll('/', '-'));
  }

  Future<void> _unsubscribe() async {
    await _mqttService?.unsubscribe();
    _countdownTimer?.cancel();
    _ctCountdownTimer?.cancel();
    if (mounted) setState(() => _isSubscribed = false);
  }

  void _onMqttMessage(IrsMqttMessage message) {
    if (!mounted) return;

    switch (message.msgType) {
      case IrsMqttMsgType.quickQuiz:
      case IrsMqttMsgType.examPaper:
        if (message.question != null) {
          unawaited(_processIncomingQuestion(message.question!));
        }
        break;
      case IrsMqttMsgType.answerCompleted:
        final ansUserId = _getAnsUserId();
        if (message.userId == null || message.userId == ansUserId) {
          _showAnswerConfirm();
        }
        break;
      case IrsMqttMsgType.answerConfirm:
        IrsDebugLog.log('[IRS] 收到作答訊息確認');
        break;
      case IrsMqttMsgType.studentAsk:
        _showInfoDialog('學生發問', message.rawPayload);
        break;
      case IrsMqttMsgType.teacherReply:
        _showInfoDialog('教師回覆', message.rawPayload);
        break;
      case IrsMqttMsgType.heartbeat:
        IrsDebugLog.log('[IRS] 收到心跳訊息 (98)');
        break;
      case IrsMqttMsgType.unknown:
        IrsDebugLog.log('[IRS] 未知訊息類型: ${message.rawPayload}');
        break;
    }
  }

  Future<void> _processIncomingQuestion(Map<String, dynamic> q) async {
    final ansUserId = _getAnsUserId();
    final question = IrsRealtimeQuestion.fromJson(q);
    final questionId = question.id;
    final questionType = question.type.toString();

    // 1. seqList 過濾 (僅學生檢查)
    final seqList = question.seqList ?? '';
    if (_isStudentRole() &&
        _currentSeqno != null &&
        _currentSeqno!.isNotEmpty &&
        seqList.isNotEmpty &&
        !seqList.contains(_currentSeqno!)) {
      IrsDebugLog.log('[IRS] seqList 不包含 $_currentSeqno，忽略題目');
      return;
    }

    // 2. assignStuList 權限檢查
    final assignStuList = q['assignStuList'];
    if (assignStuList is List && assignStuList.isNotEmpty) {
      final isAssigned = assignStuList.any((item) {
        if (item is Map) {
          final stuNo = item['stuNo']?.toString() ?? '';
          return stuNo.contains(ansUserId);
        }
        return false;
      });
      if (!isAssigned) {
        IrsDebugLog.log('[IRS] 學生 $ansUserId 不在 assignStuList 內，忽略題目');
        return;
      }
    }

    // 3. 檢查題目結束時間 (endTime - now - phoneTimeDiff)
    int periodSeconds = question.period;
    final endTime = _parseServerDateTime(question.answerTime);
    if (endTime != null) {
      final diffSeconds =
          endTime.difference(DateTime.now()).inSeconds - _phoneTimeDiffSeconds;
      if (diffSeconds < 0) {
        IrsDebugLog.log('[IRS] 題目已逾時 (diff=$diffSeconds)，忽略');
        return;
      }
      if (periodSeconds <= 0 || diffSeconds < periodSeconds) {
        periodSeconds = diffSeconds;
      }
    }

    // 4. 檢查 SharedPreferences 是否已作答過該 questionId
    try {
      final prefs = await SharedPreferences.getInstance();
      final answeredKey = '${ansUserId}_$questionId';
      final alreadyAnswered = prefs.getString(answeredKey) ?? '';
      if (alreadyAnswered.isNotEmpty) {
        IrsDebugLog.log('[IRS] 題目 $questionId 已經作答過，忽略');
        return;
      }
    } catch (_) {}

    if (!mounted) return;

    // 5. 送出已讀回報 (msgType: "98") via HTTP POST URL_IRS_MQTTSEND
    if (_selectedClassId != null && _selectedTeacherNo != null) {
      unawaited(
        _getMqttService().sendQuestionReceipt(
          classId: _selectedClassId!,
          teacherNo: _selectedTeacherNo!,
          questionId: questionId,
          questionType: questionType,
          ansUserId: ansUserId,
          os: Platform.isIOS ? 'ios' : 'android',
          version: _cachedAppVersion,
          token: '',
          device: _cachedDeviceModel,
        ),
      );
    }

    setState(() {
      _currentQuestion = question;
      _activeQuid = questionId;
      _selectedOptions.clear();
      _textAnswer = '';
      _hasAnswered = false;
    });

    _startCountdown(periodSeconds);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          questionType == '1'
              ? '快問快答已開始，請作答！'
              : '收到新題目：${question.content}',
        ),
      ),
    );
  }

  void _startCountdown(int seconds) {
    _countdownTimer?.cancel();
    if (seconds <= 0) {
      setState(() {
        _periodCount = 0;
        _totalPeriod = 0;
      });
      return;
    }
    setState(() {
      _periodCount = seconds;
      _totalPeriod = seconds;
    });
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_periodCount > 0) {
        setState(() => _periodCount--);
      } else {
        _countdownTimer?.cancel();
        unawaited(_handleQuestionTimeout());
      }
    });
  }

  Future<void> _handleQuestionTimeout() async {
    final quid = _activeQuid;
    if (quid != null && quid.isNotEmpty && !_hasAnswered) {
      unawaited(
        ref.read(irsProvider.notifier).sendAbnormal(
              quid: quid,
              status: '1',
              studentId: _getAnsUserId(),
            ),
      );
    }
    if (!mounted) return;
    final isQuick = _currentQuestion?.type == 1;
    setState(() {
      _activeQuid = null;
      _currentQuestion = null;
    });
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isQuick ? '快問快答時間到了' : '作答時間到了'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('確定'),
          ),
        ],
      ),
    );
  }

  void _showAnswerConfirm() {
    unawaited(
      showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('作答完成'),
          content: const Text('教師已收到您的答案！'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('確定'),
            ),
          ],
        ),
      ),
    );
  }

  void _showInfoDialog(String title, String content) {
    unawaited(
      showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('確定'),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleOption(String optionKey, {required bool isSingle}) {
    setState(() {
      if (isSingle) {
        _selectedOptions
          ..clear()
          ..[optionKey] = true;
      } else {
        _selectedOptions[optionKey] = !(_selectedOptions[optionKey] ?? false);
      }
    });
  }

  Future<void> _markQuestionAnswered(String questionId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('${_getAnsUserId()}_$questionId', questionId);
    } catch (_) {}
  }

  Future<void> _submitQuickAnswer(String answer) async {
    final q = _currentQuestion;
    if (q == null ||
        answer.trim().isEmpty ||
        _selectedClassId == null ||
        _selectedTeacherNo == null) {
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final ok = await _getMqttService().sendAnswer(
        classId: _selectedClassId!,
        teacherNo: _selectedTeacherNo!,
        questionId: q.id,
        questionType: '1',
        ansUserId: _getAnsUserId(),
        ansUserName: _getAnsUserName(),
        answer: answer.trim(),
      );

      if (!mounted) return;
      if (ok) {
        await _markQuestionAnswered(q.id);
        _countdownTimer?.cancel();
        setState(() {
          _hasAnswered = true;
          _activeQuid = null;
          _currentQuestion = null;
        });
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('快問快答答案已送出')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _submitAnswer() async {
    final q = _currentQuestion;
    if (q == null ||
        _selectedClassId == null ||
        _selectedTeacherNo == null) {
      return;
    }

    final ansUserId = _getAnsUserId();
    final ansUserName = _getAnsUserName();
    final mqttService = _getMqttService();

    // 試卷題 (questionType == 99)
    if (q.type == 99) {
      final List<Map<String, dynamic>> ansList = <Map<String, dynamic>>[];
      for (int i = 0; i < q.subQuestions.length; i++) {
        final sub = q.subQuestions[i];
        String ans = '';
        if (sub.questionType == '2') {
          ans = _examSingleAnswers[sub.subQuOrder] ?? '';
        } else if (sub.questionType == '3') {
          final keys = (_examMultiAnswers[sub.subQuOrder] ?? <String>{}).toList();
          ans = keys.join('_');
        } else if (sub.questionType == '4') {
          ans = (_examTextAnswers[sub.subQuOrder] ?? '').trim();
        }
        if (ans.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('第 ${i + 1} 題尚未作答')),
          );
          return;
        }
        ansList.add(<String, dynamic>{
          'order': sub.subQuOrder,
          'ans': ans,
        });
      }

      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('試卷確定送出?'),
          content: Text('共 ${ansList.length} 小題，送出後無法修改。'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('確定'),
            ),
          ],
        ),
      );
      if (confirmed != true || !mounted) return;

      setState(() => _isSubmitting = true);
      try {
        final ok = await mqttService.sendExamPaperAnswers(
          questionId: q.id,
          ansUserId: ansUserId,
          ansUserName: ansUserName,
          ansList: ansList,
        );
        if (!mounted) return;
        if (ok) {
          await _markQuestionAnswered(q.id);
          _countdownTimer?.cancel();
          setState(() {
            _hasAnswered = true;
            _activeQuid = null;
            _currentQuestion = null;
          });
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('試卷答案已發送')),
          );
        }
      } finally {
        if (mounted) setState(() => _isSubmitting = false);
      }
      return;
    }

    // 單選 (2) / 多選 (3) / 文字 (4)
    final selectedKeys = _selectedOptions.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();

    final String answerText;
    if (q.type == 3) {
      // Java 多選以 "_" 連接
      answerText = selectedKeys.join('_');
    } else if (q.type == 4) {
      answerText = _textAnswer.trim();
    } else {
      answerText =
          selectedKeys.isNotEmpty ? selectedKeys.first : _textAnswer.trim();
    }

    if (answerText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('請先作答')),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('確定送出答案？'),
        content: Text(
          '${q.content}\n\n答案：$answerText',
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('確定'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isSubmitting = true);
    try {
      final ok = await mqttService.sendAnswer(
        classId: _selectedClassId!,
        teacherNo: _selectedTeacherNo!,
        questionId: q.id,
        questionType: q.type.toString(),
        ansUserId: ansUserId,
        ansUserName: ansUserName,
        answer: answerText,
      );

      if (!mounted) return;
      if (ok) {
        await _markQuestionAnswered(q.id);
        _countdownTimer?.cancel();
        setState(() {
          _selectedOptions.clear();
          _textAnswer = '';
          _hasAnswered = true;
          _activeQuid = null;
          _currentQuestion = null;
        });
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('答案已發送')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  /// 送出多題連答 (irs/stu/paperFill)
  Future<void> _submitPaperFillData({bool autoSubmit = false}) async {
    if (_selectedClassId == null || _selectedTeacherNo == null) return;

    if (!autoSubmit) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('確定送出連答答案？'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('確定'),
            ),
          ],
        ),
      );
      if (confirmed != true || !mounted) return;
    }

    final answers =
        _paperFillControllers.map((c) => c.text.trim()).toList();
    final ok = await ref.read(irsProvider.notifier).submitPaperFill(
          classId: _selectedClassId!,
          studentId: _getAnsUserId(),
          teacherNo: _selectedTeacherNo!,
          secno: _secno,
          username: _getAnsUserName(),
          answers: answers,
        );

    if (!mounted) return;
    if (ok) {
      _ctCountdownTimer?.cancel();
      setState(() => _canSubmitPaperFill = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('連答答案已送出')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ref.read(irsProvider).historyError ?? '連答送出失敗',
          ),
        ),
      );
    }
  }

  /// 送出學生提問 (msgType: "3", topic: "stuask")
  Future<void> _sendStudentAsk() async {
    final text = _askController.text.trim();
    if (text.isEmpty ||
        _selectedClassId == null ||
        _selectedTeacherNo == null) {
      return;
    }

    setState(() => _isSendingAsk = true);
    try {
      final ok = await _getMqttService().sendStudentAsk(
        classId: _selectedClassId!,
        teacherNo: _selectedTeacherNo!,
        secno: _secno,
        ansUserId: _getAnsUserId(),
        ansUserName: _getAnsUserName(),
        content: text,
        anonymous: _isAnonymousAsk,
      );
      if (!mounted) return;
      if (ok) {
        _askController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('提問已送出')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSendingAsk = false);
    }
  }

  @override
  void dispose() {
    final quid = _activeQuid;
    if (quid != null && quid.isNotEmpty && !_hasAnswered) {
      unawaited(
        ref.read(irsProvider.notifier).sendAbnormal(
              quid: quid,
              status: '2',
              studentId: _getAnsUserId(),
            ),
      );
    }
    _mqttService?.disconnect();
    _countdownTimer?.cancel();
    _ctCountdownTimer?.cancel();
    _reconnectTimer?.cancel();
    _autoSelectTimer?.cancel();
    for (final c in _paperFillControllers) {
      c.dispose();
    }
    _askController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(irsProvider);
    final notifier = ref.read(irsProvider.notifier);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('IRS 答題系統'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: notifier.refresh,
            tooltip: '重新整理',
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => context.push(RoutePaths.irsHistory),
            tooltip: '歷史記錄',
          ),
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: () => context.push(RoutePaths.irsDebugLog),
            tooltip: '除錯日誌',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: notifier.refresh,
        child: CustomScrollView(
          slivers: [
            // 課程/老師選擇區塊 + 連線狀態
            SliverToBoxAdapter(
              child: _buildClassTeacherSelector(theme),
            ),
            // 即時答題區塊（置頂）
            SliverToBoxAdapter(
              child: _buildRealtimeSection(theme),
            ),
            // 問卷列表
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Text(
                  '問卷列表',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            state.isLoading && state.questionnaires.isEmpty
                ? const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()))
                : state.error != null
                    ? SliverFillRemaining(
                        child: _buildError(context, state.error!, notifier))
                    : state.questionnaires.isEmpty
                        ? SliverFillRemaining(child: _buildEmptyState(context))
                        : _buildListView(context, state, notifier),
          ],
        ),
      ),
    );
  }

  Widget _buildClassTeacherSelector(ThemeData theme) {
    final currentClass = _classes.where((c) => c.id == _selectedClassId).firstOrNull;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outlineVariant,
            width: 0.5,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '即時答題設定',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              // 自動連線狀態指示
              if (_isAutoConnecting)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else if (_isSubscribed)
                _ConnectionBadge(
                  isConnected: _isConnected,
                  label: '已訂閱',
                  color: Colors.green,
                )
              else if (_selectedClassId != null && _selectedTeacherNo != null)
                _ConnectionBadge(
                  isConnected: _isConnected,
                  label: '未連線',
                  color: Colors.orange,
                ),
            ],
          ),
          const SizedBox(height: 12),
          // 課程選擇
          DropdownButtonFormField<String>(
            value: _selectedClassId?.isNotEmpty == true ? _selectedClassId : null,
            items: _classes.map((c) {
              return DropdownMenuItem<String>(
                value: c.id ?? '',
                child: Text(c.displayName),
              );
            }).toList(),
            onChanged: _onClassChanged,
            decoration: const InputDecoration(
              labelText: '選擇課程',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.school, size: 20),
            ),
          ),
          if (currentClass != null) ...[
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Text(
                '時間：${_formatTimeRange(currentClass.startTime ?? '', currentClass.endTime ?? '')}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],

          const SizedBox(height: 12),

          // 老師選擇
          DropdownButtonFormField<String>(
            value: _selectedTeacherNo,
            items: _teachers.map((t) {
              return DropdownMenuItem<String>(
                value: t.teacherNo,
                child: Text(t.teacherName),
              );
            }).toList(),
            onChanged: _teachers.isEmpty ? null : _onTeacherChanged,
            decoration: InputDecoration(
              labelText: '選擇老師',
              border: OutlineInputBorder(),
              prefixIcon: const Icon(Icons.person, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRealtimeSection(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outlineVariant,
            width: 0.5,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.live_tv,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                '即時答題',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (_selectedClassId == null || _selectedTeacherNo == null)
                Text(
                  '請先選擇課程與老師',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                )
              else if (!_isSubscribed && !_isAutoConnecting)
                OutlinedButton.icon(
                  onPressed: _autoConnectAndSubscribe,
                  icon: const Icon(Icons.cloud_upload, size: 18),
                  label: const Text('手動連線'),
                )
              else if (_isAutoConnecting)
                const SizedBox(
                  width: 80,
                  child: Center(
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                )
              else
                _ConnectionBadge(
                  isConnected: _isConnected,
                  label: _isSubscribed ? '已連線' : '連線中...',
                  color: _isConnected ? Colors.green : Colors.orange,
                ),
            ],
          ),

          // 當前題目顯示區
          if (_isSubscribed || _currentQuestion != null) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            if (_currentQuestion != null)
              _buildCurrentQuestionCard(theme)
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text('等待老師發題...'),
                ),
              ),
          ],
          if (_canSubmitPaperFill || _ctPeriodCount > 0) ...[
            const SizedBox(height: 16),
            _buildPaperFillSection(theme),
          ],
          if (_isSubscribed && _canAskTeacher) ...[
            const SizedBox(height: 16),
            _buildAskTeacherSection(theme),
          ],
        ],
      ),
    );
  }

  Widget _buildCurrentQuestionCard(ThemeData theme) {
    final q = _currentQuestion!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  q.content,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (_periodCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _periodCount <= 10
                        ? theme.colorScheme.error
                        : theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_periodCount}s',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          if (_periodCount > 0) ...[
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: _totalPeriod > 0
                  ? (_periodCount / _totalPeriod).clamp(0.0, 1.0)
                  : 0,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              color: _periodCount <= 10
                  ? theme.colorScheme.error
                  : theme.colorScheme.primary,
              minHeight: 4,
              borderRadius: BorderRadius.circular(2),
            ),
          ],
          const SizedBox(height: 12),
          if (q.imagePath != null && q.imagePath!.isNotEmpty) ...[
            GestureDetector(
              onTap: () => unawaited(_showImageDialog(q.imagePath!)),
              child: Container(
                height: 140,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.colorScheme.outlineVariant,
                    width: 0.5,
                  ),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.image, size: 32),
                    SizedBox(height: 4),
                    Text('點擊查看圖片題目'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          if (q.type == 1)
            _buildQuickQuizInputs(theme)
          else if (q.type == 99)
            _buildExamPaperInputs(theme, q)
          else
            _buildStandardQuestionInputs(theme, q),
        ],
      ),
    );
  }

  Widget _buildQuickQuizInputs(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List<Widget>.generate(5, (index) {
            final value = '${index + 1}';
            return FilledButton.tonal(
              onPressed:
                  _isSubmitting ? null : () => _submitQuickAnswer(value),
              child: Text(value),
            );
          }),
        ),
        const SizedBox(height: 12),
        Row(
          children: <Widget>[
            Expanded(
              child: TextField(
                decoration: const InputDecoration(
                  hintText: '或輸入自訂答案',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                onChanged: (v) => _textAnswer = v,
              ),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: _isSubmitting
                  ? null
                  : () => _submitQuickAnswer(_textAnswer),
              child: const Text('送出'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStandardQuestionInputs(
    ThemeData theme,
    IrsRealtimeQuestion q,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (q.options.isNotEmpty) ...<Widget>[
          Text(
            '選項',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          if (q.type == 3)
            ...q.options.map((option) {
              final isSelected = _selectedOptions[option.key] ?? false;
              return CheckboxListTile(
                value: isSelected,
                onChanged: (_) => _toggleOption(option.key, isSingle: false),
                title: Text(
                  '${option.key}. ${option.value}',
                  style: theme.textTheme.bodySmall,
                ),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                dense: true,
              );
            })
          else
            RadioGroup<String>(
              groupValue: _selectedOptions.entries
                  .firstWhere(
                    (e) => e.value,
                    orElse: () => const MapEntry<String, bool>('', false),
                  )
                  .key,
              onChanged: (value) {
                if (value != null) _toggleOption(value, isSingle: true);
              },
              child: Column(
                children: q.options.map((option) {
                  return RadioListTile<String>(
                    value: option.key,
                    title: Text(
                      '${option.key}. ${option.value}',
                      style: theme.textTheme.bodySmall,
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  );
                }).toList(),
              ),
            ),
          const SizedBox(height: 12),
        ],
        if (q.type == 4) ...<Widget>[
          TextField(
            decoration: InputDecoration(
              hintText: '請輸入答案',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            maxLines: 2,
            onChanged: (v) => _textAnswer = v,
          ),
          const SizedBox(height: 12),
        ],
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _isSubmitting ? null : _submitAnswer,
            icon: _isSubmitting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send, size: 18),
            label: Text(_isSubmitting ? '送出中...' : '送出答案'),
          ),
        ),
      ],
    );
  }

  Widget _buildExamPaperInputs(ThemeData theme, IrsRealtimeQuestion q) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ...q.subQuestions.asMap().entries.map((entry) {
          final index = entry.key;
          final sub = entry.value;
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    '${index + 1}. ${sub.description}',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (sub.imgPath != null && sub.imgPath!.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: () =>
                          unawaited(_showImageDialog(sub.imgPath!)),
                      icon: const Icon(Icons.image, size: 18),
                      label: const Text('查看子題圖片'),
                    ),
                  ],
                  const SizedBox(height: 8),
                  if (sub.questionType == '2')
                    RadioGroup<String>(
                      groupValue: _examSingleAnswers[sub.subQuOrder] ?? '',
                      onChanged: (val) {
                        if (val != null) {
                          setState(
                            () => _examSingleAnswers[sub.subQuOrder] = val,
                          );
                        }
                      },
                      child: Column(
                        children: sub.options.map((opt) {
                          return RadioListTile<String>(
                            value: opt.key,
                            title: Text('${opt.key}. ${opt.value}'),
                            controlAffinity: ListTileControlAffinity.leading,
                            dense: true,
                          );
                        }).toList(),
                      ),
                    )
                  else if (sub.questionType == '3')
                    Column(
                      children: sub.options.map((opt) {
                        final selected =
                            _examMultiAnswers[sub.subQuOrder] ?? <String>{};
                        return CheckboxListTile(
                          value: selected.contains(opt.key),
                          onChanged: (checked) {
                            setState(() {
                              final set = Set<String>.from(selected);
                              if (checked == true) {
                                set.add(opt.key);
                              } else {
                                set.remove(opt.key);
                              }
                              _examMultiAnswers[sub.subQuOrder] = set;
                            });
                          },
                          title: Text('${opt.key}. ${opt.value}'),
                          controlAffinity: ListTileControlAffinity.leading,
                          dense: true,
                        );
                      }).toList(),
                    )
                  else
                    TextField(
                      decoration: const InputDecoration(
                        hintText: '請輸入答案',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      maxLines: 2,
                      onChanged: (v) =>
                          _examTextAnswers[sub.subQuOrder] = v,
                    ),
                ],
              ),
            ),
          );
        }),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _isSubmitting ? null : _submitAnswer,
            icon: _isSubmitting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send),
            label: Text(_isSubmitting ? '送出中...' : '送出試卷'),
          ),
        ),
      ],
    );
  }

  // 試卷用的答案暫存
  final Map<int, String> _examSingleAnswers = <int, String>{};
  final Map<int, Set<String>> _examMultiAnswers = <int, Set<String>>{};
  final Map<int, String> _examTextAnswers = <int, String>{};

  Future<void> _showImageDialog(String imagePath) async {
    final imageUrl =
        imagePath.startsWith('http') ? imagePath : '$_irsImageBaseUrl$imagePath';
    try {
      final response = await Dio().get<List<int>>(
        imageUrl,
        options: Options(responseType: ResponseType.bytes),
      );
      final bytes = Uint8List.fromList(response.data ?? <int>[]);

      if (!mounted) return;
      unawaited(
        showDialog<void>(
          context: context,
          builder: (ctx) => Dialog(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const SizedBox(height: 16),
                const Text(
                  '圖片題目',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                InteractiveViewer(
                  maxScale: 3.0,
                  child: Image.memory(bytes),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('關閉'),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('圖片下載失敗：$e')),
      );
    }
  }

  Widget _buildPaperFillSection(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outlineVariant,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                '多題連答 (最多 5 題)',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (_ctPeriodCount > 0)
                Text(
                  '剩餘 $_ctPeriodCount 秒自動送出',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          ...List<Widget>.generate(5, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: TextField(
                controller: _paperFillControllers[index],
                decoration: InputDecoration(
                  labelText: '第 ${index + 1} 題答案',
                  border: const OutlineInputBorder(),
                  isDense: true,
                ),
                maxLines: 2,
              ),
            );
          }),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed:
                  (_canSubmitPaperFill || _ctPeriodCount > 0) && !_isSubmitting
                      ? _submitPaperFillData
                      : null,
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send),
              label: Text(
                _isSubmitting
                    ? '送出中...'
                    : (_ctPeriodCount > 0
                        ? '送出連答 (自動倒數中)'
                        : '送出連答'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAskTeacherSection(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '提問老師',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _askController,
            decoration: const InputDecoration(
              hintText: '輸入您想問的問題...',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              Checkbox(
                value: _isAnonymousAsk,
                onChanged: (v) =>
                    setState(() => _isAnonymousAsk = v ?? false),
              ),
              Text(
                '匿名提問',
                style: theme.textTheme.bodyMedium,
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed:
                    _isSendingAsk ? null : _sendStudentAsk,
                icon: _isSendingAsk
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.question_answer),
                label: Text(_isSendingAsk ? '送出中...' : '送出提問'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context, String error, IrsNotifier notifier) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              '載入失敗',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: notifier.refresh,
              icon: const Icon(Icons.refresh),
              label: const Text('重試'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.quiz_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            '目前無可用問卷',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            '請稍後再試或下拉重新整理',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildListView(BuildContext context, IrsState state, IrsNotifier notifier) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final questionnaire = state.questionnaires[index];
          return _QuestionnaireCard(
            questionnaire: questionnaire,
            onTap: () => notifier.loadQuestionnaireDetail(questionnaire.id).then((_) {
              if (context.mounted) {
                context.push('${RoutePaths.irs}/detail');
              }
            }),
          );
        },
        childCount: state.questionnaires.length,
      ),
    );
  }

  String _formatTimeRange(String start, String end) {
    try {
      final startDate = DateTime.parse(start);
      final endDate = DateTime.parse(end);
      return '${startDate.month}/${startDate.day} ${startDate.hour}:${startDate.minute.toString().padLeft(2, '0')} - ${endDate.hour}:${endDate.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '$start - $end';
    }
  }
}

/// IRS 除錯日誌頁面
class IrsDebugLogPage extends ConsumerWidget {
  const IrsDebugLogPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logs = IrsDebugLog.logs;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('IRS 除錯日誌'),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy_all),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: IrsDebugLog.allLogs));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('日誌已複製到剪貼簿')),
              );
            },
            tooltip: '複製全部日誌',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              IrsDebugLog.clear();
              (context as Element).markNeedsBuild();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('日誌已清除')),
              );
            },
            tooltip: '清除日誌',
          ),
        ],
      ),
      body: logs.isEmpty
          ? const Center(child: Text('暫無日誌'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: logs.length,
              itemBuilder: (context, index) {
                final log = logs[logs.length - 1 - index]; // 最新在上
                return SelectableText(
                  log,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontFamily: 'monospace',
                    fontSize: 11,
                  ),
                );
              },
            ),
    );
  }
}

/// 連線狀態徽章
class _ConnectionBadge extends StatelessWidget {
  const _ConnectionBadge({
    required this.isConnected,
    required this.label,
    required this.color,
  });

  final bool isConnected;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isConnected ? Icons.check_circle : Icons.sync,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// 問卷卡片
class _QuestionnaireCard extends StatelessWidget {
  const _QuestionnaireCard({
    required this.questionnaire,
    required this.onTap,
  });

  final IrsQuestionnaire questionnaire;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSubmitted = questionnaire.isSubmitted;

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: InkWell(
        onTap: isSubmitted ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      questionnaire.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (isSubmitted)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '已完成',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                questionnaire.description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _InfoChip(
                    icon: Icons.help_outline,
                    label: '${questionnaire.questionCount} 題',
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  _InfoChip(
                    icon: Icons.access_time,
                    label: _formatTimeRange(questionnaire.startTime, questionnaire.endTime),
                    color: theme.colorScheme.secondary,
                  ),
                  if (questionnaire.category != null) ...[
                    const SizedBox(width: 8),
                    _InfoChip(
                      icon: Icons.category_outlined,
                      label: questionnaire.category!,
                      color: theme.colorScheme.tertiary,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimeRange(String start, String end) {
    try {
      final startDate = DateTime.parse(start);
      final endDate = DateTime.parse(end);
      return '${startDate.month}/${startDate.day} - ${endDate.month}/${endDate.day}';
    } catch (_) {
      return '$start - $end';
    }
  }
}

/// 資訊晶片
class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}