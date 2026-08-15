enum RunnerState { idle, running, jumping, sliding, hit, falling, celebrating }

/// Represents RunnerHero — the player character. Holds only presentation
/// + high-level status; live physics values live in `RunnerPhysics`.
class RunnerModel {
  RunnerState state;
  int lane; // 0 = left, 1 = center, 2 = right
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
    RunnerState.idle: 'assets/images/characters/runner/runner_idle.png',
    RunnerState.running: 'assets/images/characters/runner/runner_run_01.png',
    RunnerState.jumping: 'assets/images/characters/runner/runner_jump.png',
    RunnerState.sliding: 'assets/images/characters/runner/runner_slide.png',
    RunnerState.hit: 'assets/images/characters/runner/runner_hit.png',
    RunnerState.falling: 'assets/images/characters/runner/runner_hit.png',
    RunnerState.celebrating: 'assets/images/characters/runner/runner_celebrate.png',
  };

  static const List<String> runCycleAssets = [
    'assets/images/characters/runner/runner_run_01.png',
    'assets/images/characters/runner/runner_run_02.png',
    'assets/images/characters/runner/runner_run_03.png',
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
      isSpeedBoostActive: isSpeedBoostActive ?? this.isSpeedBoostActive,
    );
  }
}
