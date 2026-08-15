import 'package:flutter/foundation.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';

import 'ads_config.dart';

enum AdLoadState { notLoaded, loading, ready, failed }

/// Central Unity Ads wrapper. Every call is defensively wrapped — a
/// missing/failed ad SDK, no network, or an unsupported platform never
/// crashes the app or blocks gameplay; ads simply don't show.
class AdsManager {
  AdsManager._internal();
  static final AdsManager instance = AdsManager._internal();
  factory AdsManager() => instance;

  bool _initialized = false;
  AdLoadState _interstitialState = AdLoadState.notLoaded;
  AdLoadState _rewardedState = AdLoadState.notLoaded;

  bool get isReady => _initialized;
  bool get isInterstitialReady => _interstitialState == AdLoadState.ready;
  bool get isRewardedReady => _rewardedState == AdLoadState.ready;

  Future<void> init() async {
    if (_initialized) return;
    try {
      await UnityAds.init(
        gameId: AdsConfig.gameId,
        testMode: AdsConfig.testMode,
        onComplete: () {
          _initialized = true;
          loadInterstitial();
          loadRewarded();
        },
        onFailed: (error, message) {
          _initialized = false;
        },
      );
    } catch (_) {
      // Unity Ads SDK unavailable on this platform/build — the game stays
      // fully playable, just without ads.
    }
  }

  Future<void> loadInterstitial() async {
    if (!_initialized) return;
    _interstitialState = AdLoadState.loading;
    try {
      await UnityAds.load(
        placementId: AdsConfig.interstitialPlacementId,
        onComplete: (placementId) => _interstitialState = AdLoadState.ready,
        onFailed: (placementId, error, message) => _interstitialState = AdLoadState.failed,
      );
    } catch (_) {
      _interstitialState = AdLoadState.failed;
    }
  }

  Future<void> loadRewarded() async {
    if (!_initialized) return;
    _rewardedState = AdLoadState.loading;
    try {
      await UnityAds.load(
        placementId: AdsConfig.rewardedPlacementId,
        onComplete: (placementId) => _rewardedState = AdLoadState.ready,
        onFailed: (placementId, error, message) => _rewardedState = AdLoadState.failed,
      );
    } catch (_) {
      _rewardedState = AdLoadState.failed;
    }
  }

  /// Shows an interstitial if one is currently loaded. Silently does
  /// nothing if not ready — never delays or blocks navigation.
  Future<void> showInterstitial() async {
    if (!isInterstitialReady) return;
    try {
      await UnityAds.showVideoAd(
        placementId: AdsConfig.interstitialPlacementId,
        onComplete: (placementId) {
          _interstitialState = AdLoadState.notLoaded;
          loadInterstitial();
        },
        onFailed: (placementId, error, message) {
          _interstitialState = AdLoadState.notLoaded;
          loadInterstitial();
        },
        onSkipped: (placementId) {
          _interstitialState = AdLoadState.notLoaded;
          loadInterstitial();
        },
      );
    } catch (_) {
      // Fail silently.
    }
  }

  /// Shows a rewarded ad. [onReward] fires only if the user watches to
  /// completion. [onUnavailable] fires immediately (synchronously, on the
  /// same frame) if no rewarded ad is currently ready — callers use this
  /// to show a "try again later" message instead of a dead button.
  Future<void> showRewarded({
    required VoidCallback onReward,
    VoidCallback? onUnavailable,
  }) async {
    if (!isRewardedReady) {
      onUnavailable?.call();
      return;
    }
    try {
      await UnityAds.showVideoAd(
        placementId: AdsConfig.rewardedPlacementId,
        onComplete: (placementId) {
          _rewardedState = AdLoadState.notLoaded;
          onReward();
          loadRewarded();
        },
        onFailed: (placementId, error, message) {
          _rewardedState = AdLoadState.notLoaded;
          loadRewarded();
        },
        onSkipped: (placementId) {
          // Skipped before completion — no reward granted.
          _rewardedState = AdLoadState.notLoaded;
          loadRewarded();
        },
      );
    } catch (_) {
      // Fail silently.
    }
  }
}