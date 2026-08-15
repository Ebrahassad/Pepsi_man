# Audio Manifest

Handled by `AudioManager` via the `audioplayers` package. **A generated silent placeholder MP3 already exists at every path below**, so the project builds without missing-asset errors even before you add real music/SFX (see `ASSETS_GUIDE.md`). Missing files never crash the app either way — every call is wrapped in try/catch with a silent fallback.

## Music

| Name | Path | Used By | Purpose |
|---|---|---|---|
| menu_music.mp3 | assets/audio/music/menu_music.mp3 | audio_manager.dart | Main menu loop |
| world_01_music.mp3 | assets/audio/music/world_01_music.mp3 | audio_manager.dart | City Streets loop |
| world_02_music.mp3 | assets/audio/music/world_02_music.mp3 | audio_manager.dart | Highway loop |
| world_03_music.mp3 | assets/audio/music/world_03_music.mp3 | audio_manager.dart | Downtown loop |
| world_04_music.mp3 | assets/audio/music/world_04_music.mp3 | audio_manager.dart | Industrial Zone loop |
| world_05_music.mp3 | assets/audio/music/world_05_music.mp3 | audio_manager.dart | Extreme City loop |
| victory_music.mp3 | assets/audio/music/victory_music.mp3 | audio_manager.dart | Victory screen |
| game_over_music.mp3 | assets/audio/music/game_over_music.mp3 | audio_manager.dart | Game over screen |

## SFX

| Name | Path | Used By | Purpose |
|---|---|---|---|
| button_click.mp3 | assets/audio/sfx/button_click.mp3 | audio_manager.dart | UI button tap |
| can_collect.mp3 | assets/audio/sfx/can_collect.mp3 | item_engine.dart | Energy can collected |
| coin_collect.mp3 | assets/audio/sfx/coin_collect.mp3 | item_engine.dart | Coin collected |
| jump.mp3 | assets/audio/sfx/jump.mp3 | runner_physics.dart | Jump triggered |
| slide.mp3 | assets/audio/sfx/slide.mp3 | runner_physics.dart | Slide triggered |
| player_hit.mp3 | assets/audio/sfx/player_hit.mp3 | collision_engine.dart | Player hit by obstacle |
| shield_break.mp3 | assets/audio/sfx/shield_break.mp3 | collision_engine.dart | Shield absorbs a hit |
| magnet_activate.mp3 | assets/audio/sfx/magnet_activate.mp3 | item_engine.dart | Magnet power-up activated |
| speed_boost.mp3 | assets/audio/sfx/speed_boost.mp3 | item_engine.dart | Speed boost activated |
| invincibility.mp3 | assets/audio/sfx/invincibility.mp3 | item_engine.dart | Invincibility activated |
| checkpoint.mp3 | assets/audio/sfx/checkpoint.mp3 | level_engine.dart | Checkpoint reached |
| level_start.mp3 | assets/audio/sfx/level_start.mp3 | runner_game_screen.dart | Level begins |
| level_complete.mp3 | assets/audio/sfx/level_complete.mp3 | victory_screen.dart | Level completed |
| game_over.mp3 | assets/audio/sfx/game_over.mp3 | game_over_screen.dart | All lives lost |

All original filenames — no assets copied from the original Pepsi Man game.
