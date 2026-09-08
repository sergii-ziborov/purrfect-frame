# Purrfect Frame

**Catch the perfect group photo.**

Four characters, one assignment, one shutter. Someone blinks, someone turns away, someone jumps, someone photobombs a neighbor. You keep the exact frame you pressed — including the misses worth showing someone.

[![Platform](https://img.shields.io/badge/platform-iPhone%20%C2%B7%20iPad%20%C2%B7%20iOS%2018%2B-000000)](#app-target)
[![Language](https://img.shields.io/badge/Swift-6-F05138)](#build-and-run)
[![UI](https://img.shields.io/badge/UI-SwiftUI-0A84FF)](#build-and-run)
[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)

## Play

Each round has **one** readable job:

- Get all 4 looking
- Catch two in mid-air
- No overlapping faces
- Nobody blinking
- Catch Butter in a jump
- Everyone sitting still

Tap the shutter. The game freezes that millisecond and scores it. A near-miss is not an error screen — it is a portrait with a caption.

Worlds in this release:

1. **Cat Café** — expressive faces, bad timing, warm light
2. **Penguin Parade** — one silhouette, several attitudes (unlocks after four café successes)

Characters are flat rigs (body, head, eyes, ears, paws), not photoreal fur. That is a production choice: animation has to be readable, and every round has to be *winnable*.

## How a round is built

The main risk in a timing game is an impossible shot. Purrfect Frame does not roll four independent loops and hope they overlap.

1. Place a success window on the timeline.
2. Pose every character so the assignment is true inside that window.
3. Layer blinks, turns, jumps, and photobombs *around* it.

You can still miss. You cannot be handed a round where the good frame never happens.

## App target

- iPhone and iPad (universal)
- iOS 18+
- Portrait on iPhone; portrait and landscape on iPad
- No account, no tracking, no network
- Photos permission only if you tap **Save to Photos**

Bundle ID: `com.sergiiziborov.purrfectframe`

## Build and run

```bash
brew install xcodegen   # if needed
cd purrfect-frame
xcodegen generate
open PurrfectFrame.xcodeproj
```

Select an iPhone or iPad simulator, then Run.

Unit tests cover the timeline guarantee and the shot evaluator:

```bash
xcodebuild test \
  -scheme PurrfectFrame \
  -destination 'platform=iOS Simulator,id=<SIMULATOR_UDID>'
```

## Project layout

```
PurrfectFrame/
  App/              # scene, navigation, round session
  Game/Engine/      # missions, seeded timeline, evaluation
  Game/Characters/  # part-based cats and penguins
  Game/Stage/       # café / parade composition
  Features/         # home, camera, result, worlds, collection
  Persistence/      # local stars and saved shots
```

## Privacy

Shots live on device. See [PRIVACY.md](PRIVACY.md).

## License

[MIT](LICENSE). The name *Purrfect Frame* and the character names are part of this project.
