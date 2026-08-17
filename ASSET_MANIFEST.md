# Asset Manifest — Images

All paths are relative to the project root. **A generated placeholder PNG already exists at every path below** (labeled, colored rectangles) so the project builds and runs immediately — replace any of them with your own original artwork using the exact same filename/path (see `ASSETS_GUIDE.md` for a friendlier walkthrough, in Arabic). If a file is ever missing, the game additionally falls back to a drawn placeholder at runtime (see `runner_widget.dart` / `obstacle_widget.dart` fallback painters) — it will not crash either way.

## Character — RunnerHero

| Name | Path | Type | Used By | Purpose |
|---|---|---|---|---|
| runner_idle.webp | assets/images/characters/runner/runner_idle.webp | Image | runner_widget.dart | Idle pose before run starts |
| runner_run_01.webp | assets/images/characters/runner/runner_run_01.webp | Image | runner_widget.dart | Running animation frame 1 |
| runner_run_02.webp | assets/images/characters/runner/runner_run_02.webp | Image | runner_widget.dart | Running animation frame 2 |
| runner_run_03.webp | assets/images/characters/runner/runner_run_03.webp | Image | runner_widget.dart | Running animation frame 3 |
| runner_jump.webp | assets/images/characters/runner/runner_jump.webp | Image | runner_widget.dart | Jump pose |
| runner_slide.webp | assets/images/characters/runner/runner_slide.webp | Image | runner_widget.dart | Slide pose |
| runner_hit.webp | assets/images/characters/runner/runner_hit.webp | Image | runner_widget.dart | Hit/collision pose |
| runner_celebrate.webp | assets/images/characters/runner/runner_celebrate.webp | Image | victory_screen.dart | Level-complete celebration pose |

## Obstacles

| Name | Path | Type | Used By | Purpose |
|---|---|---|---|---|
| car.webp | assets/images/obstacles/car.webp | Image | obstacle_widget.dart | Static/moving car obstacle |
| truck.webp | assets/images/obstacles/truck.webp | Image | obstacle_widget.dart | Truck obstacle |
| bus.webp | assets/images/obstacles/bus.webp | Image | obstacle_widget.dart | Bus obstacle |
| barrier.webp | assets/images/obstacles/barrier.webp | Image | obstacle_widget.dart | Generic barrier |
| cone.webp | assets/images/obstacles/cone.webp | Image | obstacle_widget.dart | Traffic cone (jump) |
| trash_bin.webp | assets/images/obstacles/trash_bin.webp | Image | obstacle_widget.dart | Trash bin obstacle |
| construction_barrier.webp | assets/images/obstacles/construction_barrier.webp | Image | obstacle_widget.dart | Construction barrier (jump) |
| container.webp | assets/images/obstacles/container.webp | Image | obstacle_widget.dart | Industrial container |
| gate.webp | assets/images/obstacles/gate.webp | Image | obstacle_widget.dart | High gate (slide) |
| road_block.webp | assets/images/obstacles/road_block.webp | Image | obstacle_widget.dart | Road block (jump) |

## Items & Power-Ups

| Name | Path | Type | Used By | Purpose |
|---|---|---|---|---|
| energy_can.webp | assets/images/items/energy_can.webp | Image | item_widget.dart | Main collectible |
| bonus_can.webp | assets/images/items/bonus_can.webp | Image | item_widget.dart | High-value collectible |
| coin.webp | assets/images/items/coin.webp | Image | item_widget.dart | Coin collectible |
| magnet.webp | assets/images/items/magnet.webp | Image | item_widget.dart | Magnet power-up |
| shield.webp | assets/images/items/shield.webp | Image | item_widget.dart | Shield power-up |
| speed_boost.webp | assets/images/items/speed_boost.webp | Image | item_widget.dart | Speed boost power-up |
| invincibility.webp | assets/images/items/invincibility.webp | Image | item_widget.dart | Invincibility power-up |

## UI

| Name | Path | Type | Used By | Purpose |
|---|---|---|---|---|
| game_logo.webp | assets/images/ui/game_logo.webp | Image | splash_screen.dart, main_menu_screen.dart | App logo |
| play_button.webp | assets/images/ui/play_button.webp | Image | main_menu_screen.dart | Play button |
| pause_button.webp | assets/images/ui/pause_button.webp | Image | hud_widget.dart | Pause button |
| replay_button.webp | assets/images/ui/replay_button.webp | Image | victory_screen.dart, game_over_screen.dart | Replay button |
| home_button.webp | assets/images/ui/home_button.webp | Image | multiple screens | Return to main menu |
| next_button.webp | assets/images/ui/next_button.webp | Image | victory_screen.dart | Next level button |
| lock.webp | assets/images/ui/lock.webp | Image | level_select_screen.dart | Locked level indicator |
| star.webp | assets/images/ui/star.webp | Image | multiple screens | Filled star |
| star_empty.webp | assets/images/ui/star_empty.webp | Image | multiple screens | Empty star |
| coin_icon.webp | assets/images/ui/coin_icon.webp | Image | hud_widget.dart | Coin HUD icon |
| can_icon.webp | assets/images/ui/can_icon.webp | Image | hud_widget.dart | Can HUD icon |
| life_icon.webp | assets/images/ui/life_icon.webp | Image | hud_widget.dart | Life HUD icon |
| checkpoint.webp | assets/images/ui/checkpoint.webp | Image | track_painter.dart | Checkpoint marker |

## Backgrounds & Worlds

| Name | Path | Type | Used By | Purpose |
|---|---|---|---|---|
| splash_background.webp | assets/images/backgrounds/splash_background.webp | Image | splash_screen.dart | Splash background |
| main_menu_background.webp | assets/images/backgrounds/main_menu_background.webp | Image | main_menu_screen.dart | Menu background |
| world_map_background.webp | assets/images/backgrounds/world_map_background.webp | Image | world_map_screen.dart | World map background |
| city_background.webp | assets/images/backgrounds/city_background.webp | Image | runner_game_screen.dart | World 1 backdrop |
| highway_background.webp | assets/images/backgrounds/highway_background.webp | Image | runner_game_screen.dart | World 2 backdrop |
| downtown_background.webp | assets/images/backgrounds/downtown_background.webp | Image | runner_game_screen.dart | World 3 backdrop |
| industrial_background.webp | assets/images/backgrounds/industrial_background.webp | Image | runner_game_screen.dart | World 4 backdrop |
| extreme_city_background.webp | assets/images/backgrounds/extreme_city_background.webp | Image | runner_game_screen.dart | World 5 backdrop |
| victory_background.webp | assets/images/backgrounds/victory_background.webp | Image | victory_screen.dart | Victory backdrop |
| game_over_background.webp | assets/images/backgrounds/game_over_background.webp | Image | game_over_screen.dart | Game over backdrop |
| world_01.webp ... world_05.webp | assets/images/worlds/world_0X.webp | Image | world_map_screen.dart | World thumbnail icons |

All original, generic names — nothing copied or referenced from the original Pepsi Man game.
