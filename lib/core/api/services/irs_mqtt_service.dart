import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:intl/intl.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

/// 透過後端 HTTP API (URL_IRS_MQTTSEND) 轉發 MQTT 訊息的函式介面
typedef IrsHttpMqttSender = Future<bool> Function({
  required String topic,
  required String msg,
  required String quid,
});

/// IRS MQTT 訊息類型
enum IrsMqttMsgType {
  quickQuiz, // 0 - 接收題目 (快問快答/一般題/試卷)
  answerConfirm, // 1 - 作答送出
  studentAsk, // 2 - 學生發問推播
  teacherReply, // 3 - 學生提問 / 教師回覆
  answerCompleted, // 4 - 作答完成確認 (ansSuccess)
  heartbeat, // 98 - 收到題目回報/心跳
  examPaper, // 99 - 試卷
  unknown,
}

/// IRS MQTT 訊息結構
class IrsMqttMessage {
  const IrsMqttMessage({
    required this.msgType,
    required this.rawPayload,
    this.topic,
    this.question,
    this.userId,
    this.rawJson,
  });

  factory IrsMqttMessage.fromRaw(String payload, {String? topic}) {
    try {
      final decoded = jsonDecode(payload);
      if (decoded is! Map) {
        return IrsMqttMessage(
          msgType: IrsMqttMsgType.unknown,
          rawPayload: payload,
          topic: topic,
        );
      }
      final json = Map<String, dynamic>.from(decoded);
      final msgTypeStr = json['msgType']?.toString() ?? '';
      final type = _parseMsgType(msgTypeStr);
      return IrsMqttMessage(
        msgType: type,
        rawPayload: payload,
        topic: topic,
        question: json['question'] is Map
            ? Map<String, dynamic>.from(json['question'] as Map)
            : null,
        userId: json['userId']?.toString(),
        rawJson: json,
      );
    } catch (_) {
      return IrsMqttMessage(
        msgType: IrsMqttMsgType.unknown,
        rawPayload: payload,
        topic: topic,
      );
    }
  }

  final IrsMqttMsgType msgType;
  final String rawPayload;
  final String? topic;
  final Map<String, dynamic>? question;
  final String? userId;
  final Map<String, dynamic>? rawJson;

  static IrsMqttMsgType _parseMsgType(String s) {
    switch (s) {
      case '0':
        return IrsMqttMsgType.quickQuiz;
      case '1':
        return IrsMqttMsgType.answerConfirm;
      case '2':
        return IrsMqttMsgType.studentAsk;
      case '3':
        return IrsMqttMsgType.teacherReply;
      case '4':
        return IrsMqttMsgType.answerCompleted;
      case '98':
        return IrsMqttMsgType.heartbeat;
      case '99':
        return IrsMqttMsgType.examPaper;
      default:
        return IrsMqttMsgType.unknown;
    }
  }
}

class IrsMqttService {
  IrsMqttService({
    required this.onMessageReceived,
    required this.onConnectionChanged,
    required this.onError,
    this.httpSender,
  });

  static const String _host = 'mbms.kmu.edu.tw';
  static const int _port = 1883;

  final void Function(IrsMqttMessage message)? onMessageReceived;
  final void Function(bool connected)? onConnectionChanged;
  final void Function(String)? onError;
  final IrsHttpMqttSender? httpSender;

  MqttServerClient? _client;
  StreamSubscription<List<MqttReceivedMessage<MqttMessage?>>>? _subscription;

  /// 依原生 IRSActivity.java 規則轉換 ansUserId：
  /// 學生 = userId，非學生 (教師/測試) = "t$userId"
  static String resolveAnsUserId(String userId, String? userType) {
    if (userType == null || userType.isEmpty || userType == '學生') {
      return userId;
    }
    return userId.startsWith('t') ? userId : 't$userId';
  }

  /// 依原生 IRSActivity.java 規則轉換 ansUserName：
  /// 學生 = userName，非學生 (教師/測試) = "測試帳號($userName)"
  static String resolveAnsUserName(String userName, String? userType) {
    if (userType == null || userType.isEmpty || userType == '學生') {
      return userName;
    }
    return '測試帳號($userName)';
  }

  /// 依原生 IRSActivity.java 格式產生 clientId：{ansUserId}_{yyMMddHHmmss}
  static String buildClientId({
    required String userId,
    String? userType,
  }) {
    final ansUserId = resolveAnsUserId(userId, userType);
    final formattedTime = DateFormat('yyMMddHHmmss').format(DateTime.now());
    return '${ansUserId}_$formattedTime';
  }

  /// 連線到 MQTT Broker (tcp://mbms.kmu.edu.tw:1883)
  Future<bool> connect({
    String? userId,
    String? userType,
  }) async {
    try {
      await _subscription?.cancel();
      _subscription = null;
      _client?.disconnect();

      final clientId = (userId != null && userId.isNotEmpty)
          ? buildClientId(userId: userId, userType: userType)
          : 'ikmu_flutter_${DateFormat('yyMMddHHmmss').format(DateTime.now())}';

      final client = MqttServerClient.withPort(_host, clientId, _port);
      client.secure = false;
      client.keepAlivePeriod = 20;
      client.connectTimeoutPeriod = 10000;
      client.connectionMessage = MqttConnectMessage()
          .withClientIdentifier(clientId)
          .startClean()
          .withWillQos(MqttQos.atLeastOnce);
      client.onConnected = _onConnected;
      client.onDisconnected = _onDisconnected;
      client.onSubscribed = _onSubscribed;
      client.onSubscribeFail = _onSubscribeFail;
      _client = client;

      await client.connect();

      final state = client.connectionStatus;
      if (state != null && state.state == MqttConnectionState.connected) {
        onConnectionChanged?.call(true);
        return true;
      } else {
        onError?.call('MQTT 連線失敗: ${state?.state}');
        return false;
      }
    } catch (e) {
      onError?.call('MQTT 連線異常: $e');
      return false;
    }
  }

  void _onConnected() {
    developer.log('[IrsMqttService] MQTT 已連線', name: 'IRS_MQTT');
    onConnectionChanged?.call(true);
  }

  void _onDisconnected() {
    developer.log('[IrsMqttService] MQTT 已斷線', name: 'IRS_MQTT');
    onConnectionChanged?.call(false);
  }

  void _onSubscribed(String topic) {
    developer.log('[IrsMqttService] 已訂閱: $topic', name: 'IRS_MQTT');
  }

  void _onSubscribeFail(String topic) {
    developer.log('[IrsMqttService] 訂閱失敗: $topic', name: 'IRS_MQTT');
    onError?.call('訂閱失敗: $topic');
  }

  /// 訂閱 IRS 學生端三大主題 (對應 IRSActivity.java 第 271-273 行):
  /// 1. xnow_quick_{classId}_{teacherNo}
  /// 2. xnow_normal_{classId}_{teacherNo}
  /// 3. ansSuccess
  Future<void> subscribeToQuestion({
    required String classId,
    required String teacherNo,
  }) async {
    final client = _client;
    if (client == null ||
        client.connectionStatus?.state != MqttConnectionState.connected) {
      onError?.call('MQTT 未連線');
      return;
    }

    final quickTopic = 'xnow_quick_${classId}_$teacherNo';
    final normalTopic = 'xnow_normal_${classId}_$teacherNo';
    const ansSuccessTopic = 'ansSuccess';

    try {
      await _subscription?.cancel();
      _subscription = null;

      client.subscribe(quickTopic, MqttQos.atLeastOnce);
      client.subscribe(normalTopic, MqttQos.atLeastOnce);
      client.subscribe(ansSuccessTopic, MqttQos.atLeastOnce);

      _subscription =
          client.updates?.listen((List<MqttReceivedMessage<MqttMessage?>> event) {
        for (final message in event) {
          final payloadMessage = message.payload;
          if (payloadMessage is MqttPublishMessage) {
            final payload = MqttPublishPayload.bytesToStringAsString(
              payloadMessage.payload.message,
            );
            developer.log(
              '[IrsMqttService] 收到訊息: ${message.topic} -> $payload',
              name: 'IRS_MQTT',
            );
            final parsed = IrsMqttMessage.fromRaw(
              payload,
              topic: message.topic,
            );
            onMessageReceived?.call(parsed);
          }
        }
      });
    } catch (e) {
      onError?.call('訂閱題目失敗: $e');
    }
  }

  /// 收到題目後發送已讀回報 (msgType: "98")
  /// 對應 IRSActivity.java SendData4Type99，透過 HTTP POST URL_IRS_MQTTSEND 轉發
  Future<bool> sendQuestionReceipt({
    required String classId,
    required String teacherNo,
    required String questionId,
    required String questionType,
    required String ansUserId,
    required String os,
    required String version,
    required String token,
    required String device,
  }) async {
    final topic =
        questionType == '1' ? 'quick_${classId}_$teacherNo' : questionId;
    final payload = jsonEncode(<String, dynamic>{
      'msgType': '98',
      'userId': ansUserId,
      'questionId': questionId,
      'os': os,
      'version': version,
      'token': token,
      'device': device,
    });
    return _sendViaHttp(topic: topic, msg: payload, quid: questionId);
  }

  /// 送出單題作答 (msgType: "1"，questionType "1"/"2"/"3"/"4")
  /// 對應 IRSActivity.java: 透過 HTTP POST URL_IRS_MQTTSEND 轉發
  /// - questionType == "1" (快問快答): topic = quick_{classId}_{teacherNo}
  /// - questionType == "2"/"3"/"4": topic = {questionId}
  Future<bool> sendAnswer({
    required String classId,
    required String teacherNo,
    required String questionId,
    required String questionType,
    required String ansUserId,
    required String ansUserName,
    required String answer,
  }) async {
    final isQuick = questionType == '1';
    final topic = isQuick ? 'quick_${classId}_$teacherNo' : questionId;
    final payload = jsonEncode(<String, dynamic>{
      'msgType': '1',
      'questionType': questionType,
      'userId': ansUserId,
      'userName': ansUserName,
      'answer': answer,
    });
    return _sendViaHttp(topic: topic, msg: payload, quid: questionId);
  }

  /// 送出試卷多題作答 (msgType: "1", questionType: "99")
  /// 對應 IRSActivity.java SendData4Type99:
  /// ansList 格式為 [{"order": 1, "ans": "..."}]，多選以 "_" 連接
  Future<bool> sendExamPaperAnswers({
    required String questionId,
    required String ansUserId,
    required String ansUserName,
    required List<Map<String, dynamic>> ansList,
  }) async {
    final payload = jsonEncode(<String, dynamic>{
      'msgType': '1',
      'questionType': '99',
      'userId': ansUserId,
      'userName': ansUserName,
      'ansList': ansList,
    });
    return _sendViaHttp(topic: questionId, msg: payload, quid: questionId);
  }

  /// 學生提問 (msgType: "3", topic: "stuask")
  /// 對應 IRSActivity.java btn23
  Future<bool> sendStudentAsk({
    required String classId,
    required String teacherNo,
    required String secno,
    required String ansUserId,
    required String ansUserName,
    required String content,
    bool anonymous = false,
  }) async {
    final payload = jsonEncode(<String, dynamic>{
      'msgType': '3',
      'userId': anonymous ? '000000000' : ansUserId,
      'userName': anonymous ? '匿名' : ansUserName,
      'content': content,
      'class_id': classId,
      'teacherno': teacherNo,
      'sec_no': secno,
    });
    return _sendViaHttp(topic: 'stuask', msg: payload, quid: '');
  }

  Future<bool> _sendViaHttp({
    required String topic,
    required String msg,
    required String quid,
  }) async {
    final sender = httpSender;
    if (sender == null) {
      onError?.call('尚未設定 HTTP MQTT 轉發端點 (httpSender)');
      return false;
    }
    try {
      developer.log(
        '[IrsMqttService] HTTP MQTTSEND: topic=$topic, quid=$quid, msg=$msg',
        name: 'IRS_MQTT',
      );
      final ok = await sender(topic: topic, msg: msg, quid: quid);
      if (!ok) {
        onError?.call('送出失敗：伺服器未回傳成功');
      }
      return ok;
    } catch (e) {
      onError?.call('HTTP 送出異常: $e');
      return false;
    }
  }

  /// 取消訂閱
  Future<void> unsubscribe() async {
    await _subscription?.cancel();
    _subscription = null;
  }

  /// 斷線
  void disconnect() {
    unawaited(_subscription?.cancel());
    _subscription = null;
    _client?.disconnect();
    onConnectionChanged?.call(false);
  }

  /// 檢查是否已連線
  bool get isConnected {
    final status = _client?.connectionStatus;
    return status != null && status.state == MqttConnectionState.connected;
  }
}