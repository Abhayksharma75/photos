import 'package:encrypt/encrypt.dart';

class EncryptionUtil {
  static String encrypt(String data, String key) {
    final keyBytes = Key.fromUtf8(key.padRight(32, '0'));
    final iv = IV.fromLength(16);
    final encrypter = Encrypter(AES(keyBytes));

    return encrypter.encrypt(data, iv: iv).base64;
  }
}

