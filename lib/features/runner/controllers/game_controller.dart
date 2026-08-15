import 'package:flutter/foundation.dart';

import '../models/game_progress_model.dart';

/// Tracks high-level app/game state (which screen "mode" we're logically
/// in) plus the currently selected world/level. Actual screen navigation
/// is handled by Flutter's Navigator in the screens themselves — this
/// controller is the single source of truth for *what* is selected.
class GameController extends ChangeNotifier {
  GameState _state = GameState.loading;
  int selectedWorldId = 1;
  int selectedLevelId = 1;

  GameState get state => _state;

  void setState(GameState newState) {
    _state = newState;
    notifyListeners();
  }

  void selectWorld(int worldId) {
    selectedWorldId = worldId;
    notifyListeners();
  }

  void selectLevel(int worldId, int levelId) {
    selectedWorldId = worldId;
    selectedLevelId = levelId;
    notifyListeners();
  }

  void goToMenu() => setState(GameState.menu);
  void goToWorldMap() => setState(GameState.worldMap);
  void goToLevelSelect() => setState(GameState.levelSelect);
  void goToPlaying() => setState(GameState.playing);
  void goToPaused() => setState(GameState.paused);
  void goToVictory() => setState(GameState.victory);
  void goToGameOver() => setState(GameState.gameOver);
  void goToFinalVictory() => setState(GameState.finalVictory);
}
