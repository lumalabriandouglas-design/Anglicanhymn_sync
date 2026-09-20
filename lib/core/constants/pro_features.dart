enum ListeningFeature {
  playAudio,
  shuffleRepeat,
  playbackSpeed,
  sleepTimer,
  autoScroll,
}

class ProFeatures {
  /// The public hymn book stays fully open. Flip this only when billing goes live.
  static const bool unlockedForEveryone = true;

  /// Never mention plans, Plus, or payment in the public UI while this is true.
  static const bool hideSubscriptionUi = true;

  static const String defaultPin = '1977';

  static const String codeSecret = 'ahs-plus-1977';

  static bool canUse(ListeningFeature feature, {required bool plusActive}) {
    if (unlockedForEveryone || plusActive) return true;
    switch (feature) {
      case ListeningFeature.playAudio:
      case ListeningFeature.shuffleRepeat:
        return true;
      case ListeningFeature.playbackSpeed:
      case ListeningFeature.sleepTimer:
      case ListeningFeature.autoScroll:
        return false;
    }
  }
}
