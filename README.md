# flappydog

A tap-to-fly iPhone game in Swift (SwiftUI + SpriteKit). A winged pup flies through gaps between bone pillars. See [PLAN.md](PLAN.md) for the full design.

## Run

Open `FlappyDog.xcodeproj` in Xcode 27, pick an iPhone simulator and press Run. Or from the terminal:

```bash
xcodebuild -project FlappyDog.xcodeproj -scheme FlappyDog -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build
```

Tests (Swift Testing for the game logic, XCTest for the Play → score → crash → Play again flow):

```bash
xcodebuild test -project FlappyDog.xcodeproj -scheme FlappyDog -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```

## TestFlight

Needs a paid [Apple Developer Program](https://developer.apple.com/programs/) membership.

1. Join the program and sign in to Xcode with that account (Xcode > Settings > Accounts).
2. In [App Store Connect](https://appstoreconnect.apple.com) create an app with bundle ID `com.socivolve.flappydog`. Apple has rejected names with "Flappy" before, so pick a store name such as *Sky Pup*.
3. Upload (your team ID is under developer.apple.com > Membership):

   ```bash
   TEAM_ID=ABCDE12345 scripts/testflight.sh
   ```

4. Once the build has processed, add yourself under TestFlight > Internal Testing and install it with the TestFlight app.

Privacy details: no data collected (see `FlappyDog/PrivacyInfo.xcprivacy`); export compliance is answered in the Info.plist.

## Layout

- `FlappyDog/Game/GameWorld.swift`: all rules (gravity, flap, pillars, collisions, score). No SpriteKit, fully unit-tested.
- `FlappyDog/Game/GameConfig.swift`: tuning values for Normal and Relaxed mode.
- `FlappyDog/Game/GameScene.swift`: draws the world, parallax park, crash shake and flash.
- `FlappyDog/Game/Art.swift`: every sprite, drawn in code with CoreGraphics.
- `FlappyDog/Views/`: Home, HUD, Pause, Game over and Settings screens.
- `scripts/`: regenerate the app icon (`make_icon.swift`) and sound effects (`make_sounds.py`).
