# Flappy Dog: Game Plan

A tap-to-fly arcade game for iPhone, written in Swift. You guide a small dog with wings through gaps between bone pillars. Each gap you clear scores a point. Touching a pillar, the ground or the top of the screen ends the run.

## Goals

- **Built in Swift.** Swift 6, SwiftUI for menus and buttons, SpriteKit for the game itself. No third-party engines or packages.
- **A dog with wings.** A round pup with feathered wings and a 3-frame flap animation. It tilts up when it flaps and noses down as it falls.
- **Easy buttons.** Large, clearly labelled buttons and one-tap controls. Nothing to learn beyond "tap to fly".
- **Score.** A live score during play, a saved best score, and a game-over card that shows both.

## Originality

The genre and the tap-to-fly mechanic are shared by many games. The art, sound and name of this game are our own.

- Obstacles are stacked **bone pillars** coming from the top and bottom. They are not pipes.
- The setting is a park in the sky: soft clouds, rolling hills and a grassy ground strip.
- We make or commission all sprites and sounds ourselves. No assets, names or visual style are taken from other games.

## Controls and screens

| Screen | What the player sees | Buttons and input |
|---|---|---|
| **Home** | Title, the dog hovering, best score | **Play** (big, centred, about 88 pt tall), **Settings** (gear) |
| **Get ready** | The dog hovers in place and a "Tap to fly" hint appears | Tap anywhere to start. Nothing moves until the first tap. |
| **Playing** | Large score at the top centre | Tap anywhere to flap, **Pause** button in the top corner (at least 60 pt) |
| **Paused** | Dimmed game | **Resume**, **Home** |
| **Game over** | Score, best score, a "New best!" badge when earned | **Play again** (big), **Home** |
| **Settings** | Toggles | Sound on/off, Haptics on/off, **Relaxed mode** (wider gaps, slower speed) |

Input rules:
- Tap anywhere on the play area to flap. A keyboard space bar also flaps (iPad keyboards, Mac).
- Every button is at least 60 pt with a text label. The main actions are 88 pt and use the full width of the screen's thumb zone.
- After a crash, **Play again** ignores taps for 0.5 s so a panicked tap doesn't restart the game straight away.

## Scoring

- +1 each time the dog's centre passes a pillar pair's gap.
- The best score is saved on the device (`UserDefaults` through `@AppStorage`) and shown on Home and Game over.
- Relaxed mode keeps its own best score so the two modes don't mix.
- Later (not v1): Game Center leaderboard.

## Technical design

### Stack

| Piece | Choice |
|---|---|
| Language | Swift 6 (strict concurrency) |
| Tooling | Xcode 27.2, Swift 6.4 |
| Minimum OS | iOS 18 |
| App shell and UI | SwiftUI: menus, HUD and buttons as overlays |
| Game rendering | SpriteKit through `SpriteView` |
| Tests | Swift Testing (unit), XCTest (UI) |
| Devices | iPhone in portrait. iPad runs the same layout. |

### Key idea: game logic separate from rendering

The rules of the game live in a plain Swift struct, `GameWorld`, with no SpriteKit in it. It holds the dog's height and speed, the pillars and the score, and it steps forward in time. `GameScene` (SpriteKit) only draws what `GameWorld` says and passes taps to it.

This keeps the physics, scoring and collisions fully unit-testable, and lets us tune how the game feels without touching any drawing code.

```
Tap ─▶ GameScene ─▶ GameWorld.flap()
                    GameWorld.step(dt) ─▶ events: .scored, .crashed
GameScene draws world state ◀─┘
GameModel (@Observable) ◀─ events ─▶ SwiftUI overlays (score, game over)
```

### Project layout

```
FlappyDog/
  FlappyDogApp.swift          @main, WindowGroup { RootView() }
  Model/
    GameModel.swift           @Observable @MainActor: phase, score, best; links SwiftUI and the scene
    GamePhase.swift           enum: home, ready, playing, paused, gameOver
    ScoreStore.swift          best-score persistence (normal and relaxed)
  Game/
    GameWorld.swift           pure logic: dog, pillars, gravity, collisions, scoring
    GameConfig.swift          tuning values with .normal and .relaxed presets
    GameScene.swift           SKScene: draws GameWorld, parallax background, input
    DogNode.swift             dog sprite, wing-flap animation, tilt
    PillarNode.swift          bone-pillar sprite pair
  Views/
    RootView.swift            SpriteView plus an overlay chosen by phase
    HomeView.swift
    HUDView.swift             score and pause button
    PauseView.swift
    GameOverView.swift
    SettingsView.swift
    BigButton.swift           shared large-button style
  Services/
    SoundPlayer.swift         short sound effects, honours the mute setting
    Haptics.swift             flap tap, crash thud, score tick
  Resources/
    Assets.xcassets           dog frames, bones, background layers, app icon
    Sounds/                   flap, score, crash (.caf)
FlappyDogTests/               GameWorld, scoring, config and store tests
FlappyDogUITests/             Play, score and restart flows
```

### Game loop and physics

- **Fixed time step.** `GameWorld` updates in fixed 1/120 s steps using an accumulator, so the game behaves the same on 60 Hz and 120 Hz (ProMotion) screens.
- **Flap.** A flap *sets* the upward speed. It doesn't add to it, so every tap feels the same.
- **Fixed logical size.** The scene uses a fixed 390 × 844 pt world scaled with `.aspectFit`. The background extends to fill any extra space. Difficulty is the same on every device.
- **Forgiving hitbox.** The dog collides as a circle about 70% the size of its sprite, and pillars are slightly smaller than their art. Near misses count as misses.

Starting tuning values (in `GameConfig`, to be tuned in M2):

| Value | Normal | Relaxed |
|---|---|---|
| Gravity | 1600 pt/s² | 1400 pt/s² |
| Flap speed (upward) | 480 pt/s | 450 pt/s |
| Max fall speed | 800 pt/s | 700 pt/s |
| Scroll speed | 160 pt/s | 120 pt/s |
| Gap height | 200 pt | 260 pt |
| Pillar spacing | 230 pt | 260 pt |
| Gap centre range | 25–75% of play height | 30–70% |
| Ramp | +5% speed and −5 pt gap every 10 points, capped at 1.4× speed and a 170 pt gap | none |

Pillar gaps come from an injectable random number generator. Tests use a seeded generator so the runs repeat exactly.

### Feel and feedback

- The dog's wings flap faster for a moment after each tap. It tilts up to +20° on a flap and down to −70° as it falls.
- Haptics: a light tap on each flap, a soft tick on each point, a heavy thud on a crash. All can be turned off in Settings.
- Sounds: a flap whoosh, a "boop" on each point and a cartoon bonk on a crash. A mute toggle turns them all off.
- On a crash: a short screen shake and white flash, then the dog falls to the ground before the game-over card slides in.

### Accessibility

- VoiceOver labels on every button, and the score is announced on game over.
- Dynamic Type on all menu text. Gameplay text stays at a fixed size.
- Reduce Motion turns off the screen shake and slows the parallax background.
- Pillars and background are high-contrast and don't rely on colour alone.
- Relaxed mode is an easier option for younger or newer players.

## Milestones

Each milestone ends with a playable build and passing tests.

| # | Milestone | Done when |
|---|---|---|
| M0 | **Project setup** | The Xcode project exists with the folder layout above, `.gitignore` is in place, and the app launches to an empty `SpriteView` |
| M1 | **Dog flies** | `GameWorld` gravity and flap work; the dog is a placeholder circle that falls, flaps, and crashes at the ground and ceiling; unit tests cover the physics |
| M2 | **Pillars and collisions** | Pillars spawn, scroll and despawn; crashes end the run; the tuning values feel right on a real device |
| M3 | **Score and game over** | The live score works, the best score saves and survives an app restart, and the game-over card shows score, best and "New best!" |
| M4 | **Screens and easy buttons** | Home, Get ready, Pause, Game over and Settings all work; Relaxed mode works; UI tests cover Play → score → crash → Play again |
| M5 | **Art and sound** | Dog sprite with wing frames, bone pillars, parallax park background, ground, app icon and sound effects are in |
| M6 | **Polish and accessibility** | Haptics, screen shake, Reduce Motion, VoiceOver and Dynamic Type are done, and it runs at a steady 120 fps on a ProMotion iPhone |
| M7 | **TestFlight** | Signing, store listing, privacy details (no data collected) and a TestFlight build are ready |

## Testing

- **Unit tests (Swift Testing)** on `GameWorld`: a flap sets the speed, falling speed is capped, a point is scored exactly once per pillar, the ground, ceiling and pillar edges cause a crash, and a near miss inside the forgiving hitbox does not. The ramp stops at its caps.
- **Unit tests** on `ScoreStore`: the best score only goes up, and normal and relaxed scores are stored separately.
- **UI tests (XCTest)** with a launch argument that seeds the generator and slows the game down: tap Play, score at least one point, crash, check the game-over card, then tap Play again.
- **Manual check** on a small iPhone (SE size) and a large one (Pro Max) for button reach and layout.

## Out of scope for v1

Ads, in-app purchases, multiplayer, Game Center, unlockable dogs or skins, Android, and a native Mac app. iPad runs the iPhone layout, and Apple silicon Macs can run the iPad version.

## Risks and open questions

- **App Store name.** Apple has rejected apps with "Flappy" in the title before. Pick a store name early (ideas: *Winged Woof*, *Sky Pup*, *Pup Glider*) and keep "Flappy Dog" as the project name.
- **Art source.** Who draws the dog, bones and background: you, a commissioned artist, or simple shapes for now? Placeholders let M1–M4 go ahead either way.
- **The dog.** Breed, colour and name are still to be chosen.
- **iPad.** Is the shared phone layout enough, or should iPad get a wider play area later?
