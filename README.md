# Pepsi Runner

An original fast-paced 3-lane arcade runner for Android, built with Flutter. The player (**RunnerHero**) runs forward continuously through 5 original worlds, switching lanes, jumping, and sliding to dodge traffic and obstacles while collecting cans, coins, and power-ups.

This is an **original** game: original character, original art/audio asset slots, original names. No files, models, sounds, or code are copied from the commercial "Pepsi Man" game — it is only a style reference for the runner genre.

## Gameplay

- Auto-running character across 3 lanes (Left / Center / Right)
- Swipe Left/Right to change lane, Swipe Up to jump, Swipe Down to slide
- Optional on-screen buttons (toggle in Settings)
- 5 Worlds × 10 Levels = 50 data-driven levels (no hardcoded per-level screens)
- Obstacles: cars, trucks, buses, barriers, cones, containers, gates, road blocks
- Collectibles: energy cans, bonus cans, coins
- Power-ups: Magnet, Shield, Speed Boost, Invincibility
- Checkpoints, combos, lives, stars, achievements, daily rewards, shop

## Requirements

- Flutter SDK >= 3.3.0
- Dart >= 3.3.0
- Android SDK / emulator or device

## Dependencies

- `audioplayers` — music & SFX
- `shared_preferences` — save progress/settings
- `provider` — state management for controllers/managers

## Running the project

```bash
flutter clean
flutter pub get
flutter analyze
flutter test
flutter run
```

## Building a release APK

```bash
flutter build apk --release
```

## Architecture

See `PROJECT_STRUCTURE.md` for the full folder tree. Summary:

- `core/` — audio, constants, language, theme, utility helpers shared app-wide
- `features/runner/models/` — plain data classes & enums
- `features/runner/data/` — static/data-driven config (worlds, levels, obstacles, items) — no gameplay data lives inside screens
- `features/runner/engine/` — gameplay logic: physics, collision, scoring, camera, procedural track generation, object pooling
- `features/runner/controllers/` — glue between input/UI and engine
- `features/runner/managers/` — persistence, settings, rewards, language
- `features/runner/screens/` — all UI screens
- `features/runner/widgets/` — reusable game widgets (runner sprite, obstacles, items, HUD, track painter)

## Adding a World

1. Add a `WorldModel` entry in `lib/features/runner/data/world_data.dart`.
2. Add a background asset path and register it in `ASSET_MANIFEST.md`.
3. Add 10 `LevelModel` entries referencing the new `worldId` in `level_data.dart`.

## Adding a Level

Add a `LevelModel` in `level_data.dart` with `id`, `worldId`, `difficulty`, `distance`, `baseSpeed`, `maxSpeed`, `acceleration`, `obstacles`, `items`, `powerUps`, `checkpoints`, and `starRequirements`. Levels are consumed by `LevelEngine` + `TrackGenerator` — no new screen code is needed.

## Adding an Obstacle

1. Add a value to the `ObstacleType` enum in `obstacle_model.dart`.
2. Add its config (jump/slide requirement, lane behavior) in `obstacle_data.dart`.
3. Drop the art asset at `assets/images/obstacles/<name>.png` and list it in `ASSET_MANIFEST.md`.

## Adding an Item / Power-Up

Same pattern as obstacles: extend `ItemType` or `PowerUpType`, add config in `item_data.dart`, add the asset.

## Changing the Character

Replace the `runner_*.png` files under `assets/images/characters/runner/` (same filenames) or point `RunnerModel`'s asset paths at a new folder. No engine code needs to change since physics/animation states are name-independent.

## Changing Audio

Replace files under `assets/audio/music/` and `assets/audio/sfx/` using the same filenames listed in `AUDIO_MANIFEST.md`, or update the paths in `audio_manager.dart`.

## Building an APK

```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

## Delivery Status

The project is complete: all Dart source, the Android platform folder, test
suite, and placeholder art/audio assets are included. **Read
`START_HERE.md` first** — one command (`flutter create . --platforms=android`)
is required before your first build, because the Gradle wrapper's binary
jar could not be generated in the sandbox this project was built in. See
`ASSETS_GUIDE.md` for how to swap in your own art/audio.
