# Super Mario — x86 Assembly Edition 🍄

A fully playable, console-based clone of *Super Mario Bros.*, written entirely in **x86 Assembly (MASM)** using the **Irvine32** library. The game runs directly in the Windows console and implements real-time physics, enemy AI, power-ups, multiple levels, persistent save data, and a complete menu system — all without a single line of C or C++.

> Built as a low-level systems programming project to demonstrate real-time game logic, state machines, and I/O handling using nothing but raw x86 instructions.

---

## Table of Contents

- [Features](#features)
- [Gameplay Preview](#gameplay-preview)
- [Controls](#controls)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Building the Project](#building-the-project)
  - [Running the Game](#running-the-game)
- [Project Structure](#project-structure)
- [Technical Overview](#technical-overview)
  - [Game State Machine](#game-state-machine)
  - [Physics Engine](#physics-engine)
  - [Rendering](#rendering)
  - [Power-Up System](#power-up-system)
  - [Enemies & AI](#enemies--ai)
  - [Level 2 Mechanics](#level-2-mechanics)
  - [Persistence (File I/O)](#persistence-file-io)
- [Architecture Diagram](#architecture-diagram)
- [Known Limitations](#known-limitations)
- [Roadmap](#roadmap)
- [Contributing](#contributing)
- [License](#license)

---

## Features

- 🎮 **Full game loop** — title screen, main menu, instructions, pause menu, gameplay, and level-complete/game-over states
- 🧱 **Custom physics engine** — gravity, variable jump height, double jumps, boundary clamping, and collision resolution, all built from scratch in assembly
- 🍄 **Mario power progression** — Small → Super → Fire → Star, each with distinct behavior, timers, and visual feedback
- 🔥 **Fireball combat** — shoot and track up to 2 simultaneous fireballs with collision detection against enemies
- 👾 **Enemy variety** — walking Goombas and shell-mechanic Koopa Troopas, with squash/stomp detection and star-powered instant kills
- 🪙 **Coins, breakable bricks, and item blocks** that spawn mushrooms, fire flowers, stars, or springs
- 🌍 **Two distinct levels**, including moving platforms, vertical elevator platforms, animated Piranha Plants, pipes, and bottomless pits
- 🚩 **Flagpole finish** with position-based bonus scoring (top/middle/bottom) and a fireworks bonus
- 💾 **Persistent save system** — high scores, player name, and level progress are written to and read from disk between sessions
- ⏱️ **Timer-driven game clock** with life loss on timeout
- 🖥️ **Pure console rendering** — no graphics libraries; everything is drawn using direct console character/color writes via Irvine32

---

## Gameplay Preview

```
  ____  _   _ ____  _____ ____    __  __    _    ____ ___ ___
 / ___|| | | |  _ \| ____|  _ \  |  \/  |  / \  |  _ \_ _/ _ \
 \___ \| | | | |_) |  _| | |_) | | |\/| | / _ \ | |_) | | | |
  ___) | |_| |  __/| |___|  _ <  | |  | |/ ___ \|  _ <| | |_| |
 |____/ \___/|_|   |_____|_| \_\ |_|  |_/_/   \_\_| \_\___\___/

                    Press ENTER to continue...
```

*(Add real screenshots or a terminal recording GIF here — e.g. via [Terminalizer](https://terminalizer.com/) or [asciinema](https://asciinema.org/) — to make the repo pop.)*

---

## Controls

| Key                | Action                              |
|---------------------|--------------------------------------|
| `A` / `←`           | Move left                            |
| `D` / `→`           | Move right                           |
| `W` / `Space`       | Jump (double jump when enabled)      |
| `F`                 | Shoot fireball (Fire Mario only)     |
| `P`                 | Pause game                           |
| `Enter`             | Confirm / continue on menu screens   |
| `1` / `2` / `3`     | Menu selection                       |

---

## Getting Started

### Prerequisites

This project targets **32-bit x86 assembly on Windows** and depends on the **Irvine32** link library (from Kip Irvine's *Assembly Language for x86 Processors*).

You'll need:

- **Windows OS** (the console rendering and file I/O rely on Windows console APIs via Irvine32)
- **Microsoft Visual Studio** (Community edition is fine) with MASM (`ml.exe`) support enabled
- **Irvine32 library** — [download here](https://asmirvine.com/) and follow the linker/include setup instructions provided on that site

### Building the Project

1. Clone the repository:
   ```bash
   git clone https://github.com/MuhammadAhmad78/super-mario-asm.git
   cd super-mario-asm
   ```
2. Open Visual Studio and create a new **Empty Project** (or open an existing MASM-configured solution).
3. Add `src/SuperMario.asm` to the project.
4. Make sure the project properties point to the Irvine32 `Include` and `Lib` directories.
5. Build the solution (`Ctrl+Shift+B`).

### Running the Game

Run the compiled `.exe` from Visual Studio (`F5` / `Ctrl+F5`) or directly from a console window sized to at least **155x30** characters for correct rendering.

> 💡 Tip: Maximize your console window or use `mode con: cols=160 lines=32` before launching for the best experience.

---

## Project Structure

```
super-mario-asm/
├── src/
│   └── SuperMario.asm      # Full game source (single-file MASM program)
├── docs/                    # (optional) design notes, diagrams, screenshots
├── LICENSE
├── .gitignore
└── README.md
```

The game is intentionally kept in a single `.asm` file, organized into clearly delimited sections (data declarations, constants, and procedures), consistent with how the original coursework/project was structured.

---

## Technical Overview

### Game State Machine

The game is driven by a single `gameState` byte and a central dispatch loop in `main`:

```
STATE_TITLE → STATE_MENU → STATE_INSTRUCTIONS
                  ↓
           STATE_GAMEPLAY ⇄ STATE_PAUSED
                  ↓
       STATE_LEVEL_COMPLETE / STATE_GAME_OVER
```

Each state has a dedicated procedure (`ShowTitleScreen`, `ShowMainMenu`, `ShowInstructionsScreen`, `GameLoop`, `ShowPauseScreen`) that `main` calls in a loop, checking `gameState` after every iteration to decide the next transition.

### Physics Engine

Implemented in `UpdatePhysics`, the engine handles:

- **Gravity** — constant downward acceleration (`GRAVITY_STRENGTH`), capped by `MAX_FALL_SPEED`
- **Jumping** — `JUMP_POWER` applies an initial upward velocity; `DOUBLE_JUMP_ENABLED` allows a second mid-air jump
- **Horizontal movement** — velocity-based movement clamped to `MIN_X`/`MAX_X`
- **Ground & platform collision** — resolves Mario's position against `GROUND_LEVEL`, blocks, and (in Level 2) moving/elevator platforms
- **Pit detection** — `CheckIfInPit` determines whether Mario has fallen into a pit and should lose a life

### Rendering

There is no double-buffered graphics context — the game **erases and redraws** only the sprites/tiles that moved each frame (`EraseMario` → `DrawMario`, `EraseEnemies` → `DrawEnemy`, etc.), which keeps the console flicker-free without needing a full-screen redraw every tick. Static elements (ground, pipes, blocks, clouds) are drawn once per level load in `DrawLevel`.

### Power-Up System

Mario's power state is tracked via `marioPowerState` (`MARIO_SMALL`, `MARIO_SUPER`, `MARIO_FIRE`, `MARIO_STAR`):

- **Mushroom** → upgrades Small → Super
- **Fire Flower** → upgrades to Fire Mario (enables fireball shooting)
- **Star** → grants temporary invincibility (`marioStarTimer`) with a flashing visual effect, then reverts to `marioRetainState`
- **Spring** → temporary jump-power boost (`springBoostActive` / `springBoostTimer`)

Damage is resolved through `ApplyDamageToMario`, which downgrades Fire → Super → Small → life lost, matching classic Mario damage rules.

### Enemies & AI

Two enemy types are supported via `enemyType`:

- **Goombas** — simple left/right patrol with pit-avoidance and squash-on-stomp behavior
- **Koopa Troopas** — patrol like Goombas, but stomping converts them into a stationary **shell** (`enemyState = 1`) which can then be kicked at `SHELL_SPEED` to clear other enemies

Collision resolution (stomp vs. side-hit) lives in `CheckCollisions`.

### Level 2 Mechanics

Level 2 introduces additional systems layered on top of the base engine:

- **Piranha Plants** — a 4-state animation cycle (`Hidden → Rising → Visible → Lowering`) driven by per-plant timers in `UpdatePiranhaPlants`
- **Moving Platforms** — horizontal patrol between `movingPlatMinX`/`movingPlatMaxX`
- **Elevator Platforms** — vertical patrol between `elevatorPlatMinY`/`elevatorPlatMaxY`

These are conditionally updated and drawn only `IF currentLevel == 2`, keeping Level 1 lightweight.

### Persistence (File I/O)

The game reads/writes three flat files using Irvine32's file I/O routines:

| File               | Purpose                                   |
|--------------------|--------------------------------------------|
| `player.txt`       | Stores the current player's name           |
| `highscore.txt`    | Stores the all-time high score + name      |
| `progress.txt`     | Stores world/level/lives/score for resuming |

Numeric values are converted between binary and ASCII using hand-written `DWordToString` / `StringToDWord` routines (no CRT dependency).

---

## Architecture Diagram

```
                     ┌──────────────┐
                     │     main     │
                     └──────┬───────┘
                            │  dispatch on gameState
          ┌─────────────────┼─────────────────┐
          ▼                 ▼                 ▼
   ShowTitleScreen    ShowMainMenu      GameLoop
                            │                 │
                    ShowInstructionsScreen     ├─ HandleInput
                                                ├─ UpdatePhysics
                                                ├─ UpdateEnemies / UpdatePowerups
                                                ├─ UpdateFireballs
                                                ├─ (Level 2) Update*Platforms/Piranhas
                                                ├─ CheckCollisions
                                                ├─ CheckFlagpoleCollision
                                                └─ Draw* / Erase* (render pass)
```

---

## Known Limitations

- Windows-only (Irvine32 wraps Win32 console APIs directly)
- Fixed console dimensions (155×30) — no dynamic resizing
- Single-file source (by original design) rather than split into modules
- No audio backend wired up (`MakeSound` is currently a stub — see [Roadmap](#roadmap))

## Roadmap

- [ ] Wire up `MakeSound` to actual PC speaker / WAV playback
- [ ] Add a third level with new hazards
- [ ] Externalize level layouts into data files instead of hardcoded arrays
- [ ] Add unit-style test harness for physics edge cases

---

## Contributing

Issues and pull requests are welcome. If you're extending the game (new levels, enemies, or power-ups), please keep new procedures documented with a short header comment describing inputs/outputs and registers used, consistent with the rest of the codebase.

## License

Released under the [MIT License](LICENSE) — see the LICENSE file for details.
