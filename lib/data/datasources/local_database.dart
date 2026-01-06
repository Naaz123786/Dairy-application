import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/diary_entry_model.dart';
import '../models/reminder_model.dart';

class LocalDatabase {
  static const String _diaryBoxName = 'diary';
  static const String _remindersBoxName = 'reminders';
  static const String _settingsBoxName = 'settings';
  static const String _onboardingCompleteKey = 'onboarding_complete';
  static const String _keyStorageKey = 'hive_encryption_key';

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Box<DiaryEntryModel>? _diaryBox;
  Box<ReminderModel>? _remindersBox;
  Box? _settingsBox;

  Box<DiaryEntryModel> get diaryBox => _diaryBox!;
  Box<ReminderModel> get remindersBox => _remindersBox!;
  Box get settingsBox => _settingsBox!;

  Future<void> init() async {
    // Register Adapters
    Hive.registerAdapter(DiaryEntryModelAdapter());
    Hive.registerAdapter(ReminderModelAdapter());

    // Encryption Key Logic
    String? keyString = await _secureStorage.read(key: _keyStorageKey);
    List<int> encryptionKey;
    if (keyString == null) {
      encryptionKey = Hive.generateSecureKey();
      await _secureStorage.write(
        key: _keyStorageKey,
        value: base64Url.encode(encryptionKey),
      );
    } else {
      encryptionKey = base64Url.decode(keyString);
    }

    // Open Boxes
    _diaryBox = await Hive.openBox<DiaryEntryModel>(
      _diaryBoxName,
      encryptionCipher: HiveAesCipher(encryptionKey),
    );

    _remindersBox = await Hive.openBox<ReminderModel>(_remindersBoxName);
    _settingsBox = await Hive.openBox(_settingsBoxName);
  }

  bool isOnboardingComplete() {
    return _settingsBox?.get(_onboardingCompleteKey, defaultValue: false) ??
        false;
  }

  Future<void> setOnboardingComplete() async {
    await _settingsBox?.put(_onboardingCompleteKey, true);
  }
}
