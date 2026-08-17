enum RunnerState {
  idle,
  running,
  jumping,
  sliding,
  hit,
  falling,
  celebrating,
}

/// Represents RunnerHero — the player character.
class RunnerModel {
  RunnerState state;
  int lane;
  int lives;
  bool isInvincible;
  bool hasShield;
  bool isMagnetActive;
  bool isSpeedBoostActive;

  RunnerModel({
    this.state = RunnerState.idle,
    this.lane = 1,
    this.lives = 3,
    this.isInvincible = false,
    this.hasShield = false,
    this.isMagnetActive = false,
    this.isSpeedBoostActive = false,
  });

  static const Map<RunnerState, String> assetByState = {
    RunnerState.idle:
        'assets/images/characters/runner/runner_run_01.webp',
    RunnerState.running:
        'assets/images/characters/runner/runner_run_01.webp',
    RunnerState.jumping:
        'assets/images/characters/runner/runner_jump_01.webp',
    RunnerState.sliding:
        'assets/images/characters/runner/runner_slide_01.webp',
    RunnerState.hit:
        'assets/images/characters/runner/runner_hit_01.webp',
    RunnerState.falling:
        'assets/images/characters/runner/runner_hit_03.webp',
    RunnerState.celebrating:
        'assets/images/characters/runner/runner_celebrate_01.webp',
  };

  static const List<String> runCycleAssets = [
    'assets/images/characters/runner/runner_run_01.webp',
    'assets/images/characters/runner/runner_run_02.webp',
    'assets/images/characters/runner/runner_run_03.webp',
    'assets/images/characters/runner/runner_run_04.webp',
    'assets/images/characters/runner/runner_run_05.webp',
    'assets/images/characters/runner/runner_run_06.webp',
  ];

  static const List<String> jumpCycleAssets = [
    'assets/images/characters/runner/runner_jump_01.webp',
    'assets/images/characters/runner/runner_jump_02.webp',
    'assets/images/characters/runner/runner_jump_03.webp',
    'assets/images/characters/runner/runner_jump_04.webp',
  ];

  static const List<String> slideCycleAssets = [
    'assets/images/characters/runner/runner_slide_01.webp',
    'assets/images/characters/runner/runner_slide_02.webp',
    'assets/images/characters/runner/runner_slide_03.webp',
  ];

  static const List<String> hitCycleAssets = [
    'assets/images/characters/runner/runner_hit_01.webp',
    'assets/images/characters/runner/runner_hit_02.webp',
    'assets/images/characters/runner/runner_hit_03.webp',
  ];

  static const List<String> celebrateCycleAssets = [
    'assets/images/characters/runner/runner_celebrate_01.webp',
    'assets/images/characters/runner/runner_celebrate_02.webp',
    'assets/images/characters/runner/runner_celebrate_03.webp',
  ];

  RunnerModel copyWith({
    RunnerState? state,
    int? lane,
    int? lives,
    bool? isInvincible,
    bool? hasShield,
    bool? isMagnetActive,
    bool? isSpeedBoostActive,
  }) {
    return RunnerModel(
      state: state ?? this.state,
      lane: lane ?? this.lane,
      lives: lives ?? this.lives,
      isInvincible: isInvincible ?? this.isInvincible,
      hasShield: hasShield ?? this.hasShield,
      isMagnetActive: isMagnetActive ?? this.isMagnetActive,
      isSpeedBoostActive:
          isSpeedBoostActive ?? this.isSpeedBoostActive,
    );
  }
}
