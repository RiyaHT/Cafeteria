import 'dart:convert';
import 'dart:typed_data';
import 'dart:math';
import 'package:encrypt/encrypt.dart' as encrypt;

String generateRandomKey() {
  final random = Random.secure();
  final keyBytes = Uint8List(32);
  for (int i = 0; i < keyBytes.length; i++) {
    keyBytes[i] = random.nextInt(256);
  }
  return base64.encode(keyBytes);
}

String generateRandomIV() {
  final random = Random.secure();
  final ivBytes = Uint8List(16);
  for (int i = 0; i < ivBytes.length; i++) {
    ivBytes[i] = random.nextInt(256);
  }
  return base64.encode(ivBytes);
}

String aesGcmEncryptJson(String jsonData, String keyBase64, String ivBase64) {
  final keyBytes = encrypt.Key(Uint8List.fromList(base64.decode(keyBase64)));
  final iv = encrypt.IV(Uint8List.fromList(base64.decode(ivBase64)));

  final encrypter =
      encrypt.Encrypter(encrypt.AES(keyBytes, mode: encrypt.AESMode.gcm));

  final encrypted = encrypter.encrypt(jsonData, iv: iv);

  final encryptedString = base64.encode(encrypted.bytes);
  return encryptedString;
}

String aesGcmDecryptJson(
    String encryptedData, String keyBase64, String ivBase64) {
  final keyBytes = encrypt.Key(Uint8List.fromList(base64.decode(keyBase64)));
  final iv = encrypt.IV(Uint8List.fromList(base64.decode(ivBase64)));

  final encrypter =
      encrypt.Encrypter(encrypt.AES(keyBytes, mode: encrypt.AESMode.gcm));

  final decrypted = encrypter.decrypt64(encryptedData, iv: iv);

  return decrypted;
}
