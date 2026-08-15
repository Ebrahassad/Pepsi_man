import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/game_constants.dart';

class DailyRewardTier {
  final int day; // 1..7
  final int coins;
  final int cans;

  const DailyRewardTier({required this.day, required this.coins, required this.cans});
}

/// Tracks the daily-login reward streak and whether today's reward is
/// still claimable. Coins/cans are handed to `GameProgressManager` by the
/// caller (DailyRewardScreen) after [claim] returns the tier reward.
class RewardManager extends ChangeNotifier {
  static const _lastClaimKey = '${GameConstants.prefsPrefix}last_reward_day';
  static const _streakKey = '${GameConstants.prefsPrefix}reward_streak';

  static const List<DailyRewardTier> tiers = [
    DailyRewardTier(day: 1, coins: 50, cans: 5),
    DailyRewardTier(day: 2, coins: 75, cans: 5),
    DailyRewardTier(day: 3, coins: 100, cans: 10),
    DailyRewardTier(day: 4, coins: 125, cans: 10),
    DailyRewardTier(day: 5, coins: 150, cans: 15),
    DailyRewardTier(day: 6, coins: 200, cans: 15),
    DailyRewardTier(day: 7, coins: 300, cans: 25),
  ];

  DateTime? _lastClaimDate;
  int _streak = 0;

  int get streak => _streak;

  bool get canClaimToday {
    if (_lastClaimDate == null) return true;
    final now = DateTime.now();
    return !_isSameDay(_lastClaimDate!, now);
  }

  DailyRewardTier get nextTier => tiers[_streak % tiers.length];

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastClaimMillis = prefs.getInt(_lastClaimKey);
      if (lastClaimMillis != null) {
        _lastClaimDate = DateTime.fromMillisecondsSinceEpoch(lastClaimMillis);
      }
      _streak = prefs.getInt(_streakKey) ?? 0;
      notifyListeners();
    } catch (_) {}
  }

  /// Returns the tier reward claimed, or null if already claimed today.
  Future<DailyRewardTier?> claim() async {
    if (!canClaimToday) return null;

    final now = DateTime.now();
    final wasConsecutive = _lastClaimDate != null &&
        _isSameDay(_lastClaimDate!.add(const Duration(days: 1)), now);

    _streak = wasConsecutive ? _streak + 1 : 0;
    final tier = tiers[_streak % tiers.length];
    _lastClaimDate = now;

    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_lastClaimKey, now.millisecondsSinceEpoch);
      await prefs.setInt(_streakKey, _streak);
    } catch (_) {}

    return tier;
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
