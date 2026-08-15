# Asset Manifest — Images

All paths are relative to the project root. **A generated placeholder PNG already exists at every path below** (labeled, colored rectangles) so the project builds and runs immediately — replace any of them with your own original artwork using the exact same filename/path (see `ASSETS_GUIDE.md` for a friendlier walkthrough, in Arabic). If a file is ever missing, the game additionally falls back to a drawn placeholder at runtime (see `runner_widget.dart` / `obstacle_widget.dart` fallback painters) — it will not crash either way.

## Character — RunnerHero

| Name | Path | Type | Used By | Purpose |
|---|---|---|---|---|
| runner_idle.png | assets/images/characters/runner/runner_idle.png | Image | runner_widget.dart | Idle pose before run starts |
| runner_run_01.png | assets/images/characters/runner/runner_run_01.png | Image | runner_widget.dart | Running animation frame 1 |
| runner_run_02.png | assets/images/characters/runner/runner_run_02.png | Image | runner_widget.dart | Running animation frame 2 |
| runner_run_03.png | assets/images/characters/runner/runner_run_03.png | Image | runner_widget.dart | Running animation frame 3 |
| runner_jump.png | assets/images/characters/runner/runner_jump.png | Image | runner_widget.dart | Jump pose |
| runner_slide.png | assets/images/characters/runner/runner_slide.png | Image | runner_widget.dart | Slide pose |
| runner_hit.png | assets/images/characters/runner/runner_hit.png | Image | runner_widget.dart | Hit/collision pose |
| runner_celebrate.png | assets/images/characters/runner/runner_celebrate.png | Image | victory_screen.dart | Level-complete celebration pose |

## Obstacles

| Name | Path | Type | Used By | Purpose |
|---|---|---|---|---|
| car.png | assets/images/obstacles/car.png | Image | obstacle_widget.dart | Static/moving car obstacle |
| truck.png | assets/images/obstacles/truck.png | Image | obstacle_widget.dart | Truck obstacle |
| bus.png | assets/images/obstacles/bus.png | Image | obstacle_widget.dart | Bus obstacle |
| barrier.png | assets/images/obstacles/barrier.png | Image | obstacle_widget.dart | Generic barrier |
| cone.png | assets/images/obstacles/cone.png | Image | obstacle_widget.dart | Traffic cone (jump) |
| trash_bin.png | assets/images/obstacles/trash_bin.png | Image | obstacle_widget.dart | Trash bin obstacle |
| construction_barrier.png | assets/images/obstacles/construction_barrier.png | Image | obstacle_widget.dart | Construction barrier (jump) |
| container.png | assets/images/obstacles/container.png | Image | obstacle_widget.dart | Industrial container |
| gate.png | assets/images/obstacles/gate.png | Image | obstacle_widget.dart | High gate (slide) |
| road_block.png | assets/images/obstacles/road_block.png | Image | obstacle_widget.dart | Road block (jump) |

## Items & Power-Ups

| Name | Path | Type | Used By | Purpose |
|---|---|---|---|---|
| energy_can.png | assets/images/items/energy_can.png | Image | item_widget.dart | Main collectible |
| bonus_can.png | assets/images/items/bonus_can.png | Image | item_widget.dart | High-value collectible |
| coin.png | assets/images/items/coin.png | Image | item_widget.dart | Coin collectible |
| magnet.png | assets/images/items/magnet.png | Image | item_widget.dart | Magnet power-up |
| shield.png | assets/images/items/shield.png | Image | item_widget.dart | Shield power-up |
| speed_boost.png | assets/images/items/speed_boost.png | Image | item_widget.dart | Speed boost power-up |
| invincibility.png | assets/images/items/invincibility.png | Image | item_widget.dart | Invincibility power-up |

## UI

| Name | Path | Type | Used By | Purpose |
|---|---|---|---|---|
| game_logo.png | assets/images/ui/game_logo.png | Image | splash_screen.dart, main_menu_screen.dart | App logo |
| play_button.png | assets/images/ui/play_button.png | Image | main_menu_screen.dart | Play button |
| pause_button.png | assets/images/ui/pause_button.png | Image | hud_widget.dart | Pause button |
| replay_button.png | assets/images/ui/replay_button.png | Image | victory_screen.dart, game_over_screen.dart | Replay button |
| home_button.png | assets/images/ui/home_button.png | Image | multiple screens | Return to main menu |
| next_button.png | assets/images/ui/next_button.png | Image | victory_screen.dart | Next level button |
| lock.png | assets/images/ui/lock.png | Image | level_select_screen.dart | Locked level indicator |
| star.png | assets/images/ui/star.png | Image | multiple screens | Filled star |
| star_empty.png | assets/images/ui/star_empty.png | Image | multiple screens | Empty star |
| coin_icon.png | assets/images/ui/coin_icon.png | Image | hud_widget.dart | Coin HUD icon |
| can_icon.png | assets/images/ui/can_icon.png | Image | hud_widget.dart | Can HUD icon |
| life_icon.png | assets/images/ui/life_icon.png | Image | hud_widget.dart | Life HUD icon |
| checkpoint.png | assets/images/ui/checkpoint.png | Image | track_painter.dart | Checkpoint marker |

## Backgrounds & Worlds

| Name | Path | Type | Used By | Purpose |
|---|---|---|---|---|
| splash_background.png | assets/images/backgrounds/splash_background.png | Image | splash_screen.dart | Splash background |
| main_menu_background.png | assets/images/backgrounds/main_menu_background.png | Image | main_menu_screen.dart | Menu background |
| world_map_background.png | assets/images/backgrounds/world_map_background.png | Image | world_map_screen.dart | World map background |
| city_background.png | assets/images/backgrounds/city_background.png | Image | runner_game_screen.dart | World 1 backdrop |
| highway_background.png | assets/images/backgrounds/highway_background.png | Image | runner_game_screen.dart | World 2 backdrop |
| downtown_background.png | assets/images/backgrounds/downtown_background.png | Image | runner_game_screen.dart | World 3 backdrop |
| industrial_background.png | assets/images/backgrounds/industrial_background.png | Image | runner_game_screen.dart | World 4 backdrop |
| extreme_city_background.png | assets/images/backgrounds/extreme_city_background.png | Image | runner_game_screen.dart | World 5 backdrop |
| victory_background.png | assets/images/backgrounds/victory_background.png | Image | victory_screen.dart | Victory backdrop |
| game_over_background.png | assets/images/backgrounds/game_over_background.png | Image | game_over_screen.dart | Game over backdrop |
| world_01.png ... world_05.png | assets/images/worlds/world_0X.png | Image | world_map_screen.dart | World thumbnail icons |

All original, generic names — nothing copied or referenced from the original Pepsi Man game.
