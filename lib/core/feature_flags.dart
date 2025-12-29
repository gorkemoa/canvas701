/// Feature flags - MVP'de statik değerler
/// İleride remote config ile dinamik hale getirilebilir.
class FeatureFlags {
  FeatureFlags._();

  static final FeatureFlags instance = FeatureFlags._();

  /// Creators modülü açık mı?
  /// MVP'de kapalı
  bool get isCreatorsEnabled => false;

  /// Favoriler özelliği açık mı?
  /// MVP'de opsiyonel
  bool get isFavoritesEnabled => true;

  /// Kullanıcı girişi zorunlu mu?
  /// MVP'de hayır
  bool get isLoginRequired => false;

  /// Gerçek ödeme aktif mi?
  /// MVP'de sadece UI
  bool get isPaymentEnabled => false;

  /// Push notification aktif mi?
  bool get isPushEnabled => false;

  /// Arama özelliği aktif mi?
  bool get isSearchEnabled => true;
}
