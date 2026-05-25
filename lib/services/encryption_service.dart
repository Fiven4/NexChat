import 'package:encrypt/encrypt.dart' as encrypt;

class EncryptionService {
  static final _key = encrypt.Key.fromUtf8('my32lengthsupersecretnooneknows1');
  static final _iv = encrypt.IV.fromUtf8('16charslongiv123');

  static encrypt.Encrypter get _encrypter => encrypt.Encrypter(encrypt.AES(_key, mode: encrypt.AESMode.cbc));

  static String encryptMessage(String plainText) {
    try {
      final encrypted = _encrypter.encrypt(plainText, iv: _iv);
      return encrypted.base64;
    } catch (e) {
      return plainText;
    }
  }

  static String decryptMessage(String encryptedText) {
    try {
      return _encrypter.decrypt64(encryptedText, iv: _iv);
    } catch (e) {
      return "🔒 [Ошибка расшифровки]";
    }
  }
}