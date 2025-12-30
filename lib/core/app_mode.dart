import 'package:flutter/material.dart';

/// Uygulamanın hangi modda çalıştığını belirler.
/// MVP'de sadece canvas modu aktif olacak.
enum AppMode {
  /// Canvas701 - Tek satıcı, kürasyonlu tablo satış
  canvas,

  /// Creators - Çoklu satıcı pazar yeri (ileride)
  creators,

  /// Hybrid - Her iki mod birlikte (ileride)
  hybrid,
}

/// Aktif uygulama modu
class AppModeManager {
  AppModeManager._();

  static final AppModeManager instance = AppModeManager._();

  /// MVP'de sadece Canvas701 aktif
  AppMode _currentMode = AppMode.canvas;

  /// ValueNotifier - UI'da mod değişimini dinlemek için
  final modeNotifier = ValueNotifier<AppMode>(AppMode.canvas);

  AppMode get currentMode => _currentMode;

  bool get isCanvas => _currentMode == AppMode.canvas;
  bool get isCreators => _currentMode == AppMode.creators;
  bool get isHybrid => _currentMode == AppMode.hybrid;

  /// Mod değiştirme - UI'yı günceller
  void setMode(AppMode mode) {
    _currentMode = mode;
    modeNotifier.value = mode;
  }
}

