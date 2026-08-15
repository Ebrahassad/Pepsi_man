import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/game_constants.dart';
import '../data/game_config.dart';
import '../models/game_progress_model.dart';

/// Persists and mutates the player's save data (unlocked worlds/levels,
/// stars, best scores, currency). Single source of truth — screens read
/// through this instead of touching SharedPreferences directly.
class GameProgressManager extends ChangeNotifier {
  static const _prefsKey = '${GameConstants.prefsPrefix}progress';

  GameProgressModel _progress = GameProgressModel();
  final Set<String> _unlockedAchievements = {};

  GameProgressModel get progress => _progress;
  Set<String> get unlockedAchievements => _unlockedAchievements;

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw != null) {
        _progress = GameProgressModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      }
      final achievementsRaw = prefs.getStringList('${GameConstants.prefsPrefix}achievements');
      if (achievementsRaw != null) {
        _unlockedAchievements.addAll(achievementsRaw);
      }
      notifyListeners();
    } catch (_) {
      // Keep default (fresh) progress if prefs are unavailable/corrupt.
    }
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, jsonEncode(_progress.toJson()));
      await prefs.setStringList(
        '${GameConstants.prefsPrefix}achievements',
        _unlockedAchievements.toList(),
      );
    } catch (_) {
      // Non-fatal — progress still holds in memory for this session.
    }
  }

  /// Call after a level run ends (win or lose) to record results, unlock
  /// the next level/world if appropriate, and evaluate achievements.
  /// [perfect] means the run finished without taking a single hit.
  /// [reachedMaxSpeed] means the runner hit its level's max speed at some
  /// point during the run (used for the "Speed Runner" achievement).
  Future<void> recordLevelResult({
    required int levelId,
    required int worldId,
    required int indexInWorld,
    required int score,
    required int stars,
    required bool completed,
    required int coinsEarned,
    required int cansEarned,
    bool perfect = false,
    bool reachedMaxSpeed = false,
  }) async {
    final newlyUnlocked = <String>{};

    if (completed) {
      final bestScore = _progress.bestScoreByLevel[levelId] ?? 0;
      if (score > bestScore) {
        _progress.bestScoreByLevel[levelId] = score;
      }
      final bestStars = _progress.starsByLevel[levelId] ?? 0;
      if (stars > bestStars) {
        _progress.starsByLevel[levelId] = stars;
      }

      _progress.unlockedLevels.add(levelId);

      if (GameConfig.isLastLevelOfWorld(indexInWorld)) {
        newlyUnlocked.add('world_complete');
        if (!GameConfig.isFinalWorld(worldId)) {
          _progress.unlockedWorlds.add(worldId + 1);
          final nextLevelId = GameConfig.globalLevelId(worldId + 1, 1);
          _progress.unlockedLevels.add(nextLevelId);
        } else {
          newlyUnlocked.add('all_worlds_complete');
        }
      } else {
        final nextLevelId = levelId + 1;
        _progress.unlockedLevels.add(nextLevelId);
      }

      newlyUnlocked.add('first_run');
      if (perfect) {
        newlyUnlocked.add('perfect_level');
        newlyUnlocked.add('no_hit');
      }
      if (reachedMaxSpeed) {
        newlyUnlocked.add('speed_runner');
      }
    }

    _progress.totalCoins += coinsEarned;
    _progress.totalCans += cansEarned;

    if (_progress.totalCans >= 100) newlyUnlocked.add('cans_100');
    if (_progress.totalCans >= 500) newlyUnlocked.add('cans_500');
    if (_progress.totalCans >= 1000) newlyUnlocked.add('cans_1000');

    _unlockedAchievements.addAll(newlyUnlocked);

    notifyListeners();
    await _persist();
  }

  bool isWorldUnlocked(int worldId) => _progress.unlockedWorlds.contains(worldId);
  bool isLevelUnlocked(int levelId) => _progress.unlockedLevels.contains(levelId);
  int starsFor(int levelId) => _progress.starsByLevel[levelId] ?? 0;
  int bestScoreFor(int levelId) => _progress.bestScoreByLevel[levelId] ?? 0;

  Future<bool> spendCoins(int amount) async {
    if (_progress.totalCoins < amount) return false;
    _progress.totalCoins -= amount;
    notifyListeners();
    await _persist();
    return true;
  }

  Future<void> addCoins(int amount) async {
    _progress.totalCoins += amount;
    notifyListeners();
    await _persist();
  }

  Future<void> unlockAchievement(String id) async {
    if (_unlockedAchievements.contains(id)) return;
    _unlockedAchievements.add(id);
    notifyListeners();
    await _persist();
  }

  Future<void> resetProgress() async {
    _progress = GameProgressModel();
    _unlockedAchievements.clear();
    notifyListeners();
    await _persist();
  }
}
