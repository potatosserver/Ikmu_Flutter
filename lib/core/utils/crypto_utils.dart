// KMU API 加密工具類
// 移植自 Python ikmu.py 的加密邏輯
// 3DES/ECB/PKCS7 + SHA-1 (uevw) + SHA-256 (uevw2)

import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:pointycastle/api.dart';
import 'package:pointycastle/export.dart';

import '../constants/api_constants.dart';

/// 加密工具類
class CryptoUtils {
  CryptoUtils._();

  // ===========================================
  // 常數
  // ===========================================

  /// uevw2 字元集 (A-Z 0-9 .-_ a-z)
  static const String _uevw2Charset = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.-_abcdefghijklmnopqrstuvwxyz';

  // ===========================================
  // 時間戳與簽名
  // ===========================================

  /// 取得當前時間戳 (毫秒)
  static int currentTimestampMs() {
    return DateTime.now().millisecondsSinceEpoch;
  }

  /// 取得當前時間戳 (秒)
  static int currentTimestampSec() {
    return (DateTime.now().millisecondsSinceEpoch / 1000).floor();
  }

  /// 產生 uevw (SHA-1)
  /// 格式: userId (Python 版: sha1_hex(user_id))
  static String generateUevw(String userId) {
    final bytes = utf8.encode(userId);
    final digest = sha1.convert(bytes);
    return digest.toString();
  }

  /// 產生 uevw2 (SHA-256 大寫)
  /// 格式: userId@timestamp[@token]
  static String generateUevw2(String userId, int timestamp, [String? token]) {
    final data = token != null && token.isNotEmpty
        ? '$userId@$timestamp@$token'
        : '$userId@$timestamp';
    final bytes = utf8.encode(data);
    final digest = sha256.convert(bytes);
    return digest.toString().toUpperCase();
  }

  /// 產生 uevw2 供登入使用 (動態隨機 key 加密 userId)
  /// 對應 Python compute_uevw2: 3DES/ECB/PKCS5Padding 加密 userId，回傳 hex_encrypted@random_key
  static String generateUevw2ForLogin(String userId) {
    // 產生 24-char 隨機 key
    final random = Random.secure();
    final randomKey = String.fromCharCodes(
      List.generate(24, (_) => _uevw2Charset.codeUnitAt(random.nextInt(_uevw2Charset.length))),
    );

    // 用隨機 key 3DES/ECB/PKCS7 加密 userId
    final keyBytes = utf8.encode(randomKey);
    final dataBytes = utf8.encode(userId);
    
    final cipher = PaddedBlockCipher('DESede/PKCS7');
    cipher.init(
      true,
      PaddedBlockCipherParameters(KeyParameter(keyBytes), null),
    );
    final encrypted = cipher.process(Uint8List.fromList(dataBytes));
    final hexEncrypted = encrypted.map((b) => b.toRadixString(16).padLeft(2, '0')).join();

    return '$hexEncrypted@$randomKey';
  }

  // ===========================================
  // 3DES/ECB/PKCS7 加密
  // ===========================================

  /// 3DES 加密 (ECB + PKCS7) - 回傳 Base64
  /// 使用 pointycastle 高階 API: PaddedBlockCipher('DESede/PKCS7')
  static String encrypt3Des(String plainText) {
    try {
      final key = Uint8List.fromList(utf8.encode(kDesKey));
      final data = Uint8List.fromList(utf8.encode(plainText));

      // 使用高階 API: PaddedBlockCipher('演算法/填充')
      final cipher = PaddedBlockCipher('DESede/PKCS7');

      // 初始化加密模式
      cipher.init(
        true,
        PaddedBlockCipherParameters(KeyParameter(key), null),
      );

      // 加密 - process() 直接回傳完整加密後的 Uint8List
      final output = cipher.process(data);
      return base64Encode(output);
    } catch (e) {
      throw Exception('3DES 加密失敗: $e');
    }
  }

  /// 3DES 加密 (ECB + PKCS7) - 回傳小寫十六進位字串
  /// 對應 Python encrypt_3des_ecb
  static String encrypt3DesHex(String plainText) {
    try {
      final key = Uint8List.fromList(utf8.encode(kDesKey));
      final data = Uint8List.fromList(utf8.encode(plainText));

      final cipher = PaddedBlockCipher('DESede/PKCS7');
      cipher.init(
        true,
        PaddedBlockCipherParameters(KeyParameter(key), null),
      );

      final output = cipher.process(data);
      return output.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    } catch (e) {
      throw Exception('3DES Hex 加密失敗: $e');
    }
  }

  /// 3DES 解密 (ECB + PKCS7) - Base64 輸入
  static String decrypt3Des(String encryptedBase64) {
    try {
      final key = Uint8List.fromList(utf8.encode(kDesKey));
      final data = base64Decode(encryptedBase64);

      // 使用高階 API
      final cipher = PaddedBlockCipher('DESede/PKCS7');

      // 初始化解密模式
      cipher.init(
        false,
        PaddedBlockCipherParameters(KeyParameter(key), null),
      );

      // 解密
      final output = cipher.process(data);
      return utf8.decode(output);
    } catch (e) {
      throw Exception('3DES 解密失敗: $e');
    }
  }

  // ===========================================
  // 請求資料加密 (保留給其他 API 使用)
  // ===========================================

  /// 加密請求資料
  /// Python 端: encrypt_request(data) -> base64(3des(json_string))
  static String encryptRequest(Map<String, dynamic> data) {
    final jsonStr = jsonEncode(data);
    return encrypt3Des(jsonStr);
  }

  /// 解密回應資料
  static Map<String, dynamic> decryptResponse(String encryptedBase64) {
    final jsonStr = decrypt3Des(encryptedBase64);
    return jsonDecode(jsonStr) as Map<String, dynamic>;
  }
}