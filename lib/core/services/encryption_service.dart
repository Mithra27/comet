import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class EncryptionService {
  static final EncryptionService _instance = EncryptionService._internal();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  // Key for AES encryption
  encrypt.Key? _key;
  encrypt.IV? _iv;
  
  factory EncryptionService() {
    return _instance;
  }
  
  EncryptionService._internal();
  
  // Initialize encryption keys
  Future<void> _initializeKeys() async {
    if (_key != null && _iv != null) return;
    
    // We'll use the user's UID as part of the key generation for uniqueness
    final String uid = _auth.currentUser?.uid ?? 'default';
    
    // Try to get stored keys first
    String? storedKey = await _secureStorage.read(key: 'encryption_key_$uid');
    String? storedIv = await _secureStorage.read(key: 'encryption_iv_$uid');
    
    if (storedKey != null && storedIv != null) {
      // If keys exist, use them
      _key = encrypt.Key.fromBase64(storedKey);
      _iv = encrypt.IV.fromBase64(storedIv);
    } else {
      // Generate a key based on user ID and a device-specific salt
      final keyString = uid + DateTime.now().millisecondsSinceEpoch.toString();
      final keyBytes = sha256.convert(utf8.encode(keyString)).bytes;
      
      // Create the encryption key and IV
      _key = encrypt.Key(Uint8List.fromList(keyBytes));
      _iv = encrypt.IV.fromLength(16); // AES uses 16 bytes for IV
      
      // Store the keys securely
      await _secureStorage.write(key: 'encryption_key_$uid', value: _key!.base64);
      await _secureStorage.write(key: 'encryption_iv_$uid', value: _iv!.base64);
    }
  }
  
  // Encrypt a string
  Future<String> encrypt(String plainText) async {
    await _initializeKeys();
    
    final encrypter = encrypt.Encrypter(encrypt.AES(_key!));
    final encrypted = encrypter.encrypt(plainText, iv: _iv!);
    
    return encrypted.base64;
  }
  
  // Decrypt a string
  Future<String> decrypt(String encryptedText) async {
    await _initializeKeys();
    
    try {
      final encrypter = encrypt.Encrypter(encrypt.AES(_key!));
      final decrypted = encrypter.decrypt(
        encrypt.Encrypted.fromBase64(encryptedText),
        iv: _iv!,
      );
      
      return decrypted;
    } catch (e) {
      // If decryption fails, return a fallback message
      return "[Encrypted message - unable to decrypt]";
    }
  }
  
  // Reset keys (useful for logout)
  Future<void> resetKeys() async {
    final String uid = _auth.currentUser?.uid ?? 'default';
    await _secureStorage.delete(key: 'encryption_key_$uid');
    await _secureStorage.delete(key: 'encryption_iv_$uid');
    _key = null;
    _iv = null;
  }
}