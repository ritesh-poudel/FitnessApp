# Vitality

A daily habit tracker for iOS, built with SwiftUI. Vitality tracks health and
productivity habits against per-day goals, and includes a focus timer that logs
a completion when it finishes.

The interface follows a Swiss-modernist design system: a strict 4pt grid, flat
surfaces bounded by hairline rules rather than shadows, uppercase kerned labels,
oversized numerals, and a single flat accent color per category.

---

## Requirements

| | |
|---|---|
| Xcode | 26.6 or later |
| iOS deployment target | 26.5 |
| Swift | 5.0 |
| Dependencies | None — no SPM, CocoaPods, or Carthage |

There is no dependency-fetching step. Open the project and build.

---

## Running the app in Xcode

1. Clone the repository and open `Vitality.xcodeproj`.

   ```sh
   git clone <repository-url>
   cd test
   open Vitality.xcodeproj
   ```

2. Select the **Vitality** scheme and an iOS Simulator from the toolbar's
   run-destination menu. Any iPhone simulator running iOS 26.5+ works.

   To see the Dynamic Island, pick an iPhone 14 Pro or later — for example
   **iPhone 17 Pro**. Older simulators have no Dynamic Island hardware to render.

3. Press **Run** (`Cmd + R`).

### Running on a physical device

The project ships with no development team set, so signing must be configured
once per contributor:

1. Select the **Vitality** project in the navigator, then the **Vitality** target.
2. Open **Signing & Capabilities**.
3. Check **Automatically manage signing** and choose your team.
4. Change the bundle identifier from `na.Vitality` to something unique to you
   (for example `com.yourname.Vitality`), since the default will collide.

Do not commit your team ID or bundle identifier changes.

### If the app launches to a blank white screen

This is almost always a stale build rather than a code problem. Clean the build
folder with **Product → Clean Build Folder** (`Cmd + Shift + K`) and run again.
If it persists, delete the app from the simulator and reset the simulator via
**Device → Erase All Content and Settings**.

---

## Building and testing from the command line

Build:

```sh
xcodebuild -project Vitality.xcodeproj \
           -scheme Vitality \
           -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
           build
```

Run the full test suite:

```sh
xcodebuild test -project Vitality.xcodeproj \
                -scheme Vitality \
                -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```

Run a single test class:

```sh
xcodebuild test -project Vitality.xcodeproj \
                -scheme Vitality \
                -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
                -only-testing:VitalityUITests/FocusTimerUITests
```

Substitute any simulator name from `xcrun simctl list devices available`.

> **Note on reading results:** `xcodebuild` prints `** TEST SUCCEEDED **` in some
> cases where no test actually ran. Check the process exit code (`echo $?` — `0`
> means pass, `65` means failure) rather than trusting that line alone. A
> simulator left in a bad state reports `Invalid device state` and fails the
> install before any test executes; `xcrun simctl shutdown` followed by a fresh
> boot clears it.

---

## Project structure

```
Vitality/
├── VitalityApp.swift                   App entry point
├── Models/
│   ├── Habit.swift                     Habit, daily goal, completion counts
│   ├── HabitCategory.swift             Health / productivity + presentation
│   ├── FocusSession.swift              A running focus timer
│   └── FocusActivityAttributes.swift   Live Activity payload (shared type)
├── ViewModels/
│   └── DashboardViewModel.swift        Habit state, day rollover, timer control
├── Views/
│   ├── ContentView.swift               Tab container
│   ├── DashboardView.swift             "Today" screen
│   ├── SettingsView.swift              Settings screen
│   └── Components/
│       ├── HabitCardView.swift         One habit: counts, progress, controls
│       ├── ProgressBarView.swift       Flat square progress track
│       └── RuleView.swift              Hairline rule
├── Services/
│   ├── StorageService.swift            UserDefaults persistence (actor)
│   └── LiveActivityService.swift       ActivityKit wrapper
└── Utilities/
    ├── Constants/
    │   ├── AppConstants.swift          App info, storage keys, limits
    │   └── Theme.swift                 Design tokens — spacing, color, motion
    └── Extensions/
        └── View+Extensions.swift       cardStyle(), labelStyle()

VitalityWidgets/                        Live Activity — NOT YET AN XCODE TARGET
├── VitalityWidgetsBundle.swift
└── FocusLiveActivity.swift
```

The Xcode project uses **synchronized folder groups**, so files added to these
directories on disk are picked up automatically. There is no need to edit
`project.pbxproj` to add a new Swift file.

> `Vitality/Views/ContentView 2.swift` is an unrelated leftover file ("FitTrack
> Pro") that is not part of the build and is not referenced by the app. It is
> safe to ignore, and a good candidate for deletion.

---

## Design system

All visual tokens live in `Utilities/Constants/Theme.swift`. Change them there
rather than hardcoding values in views.

- **Spacing** — a 4pt base unit (`Theme.Spacing.xs` through `.xxl`). Every gap in
  the UI is a multiple of it.
- **Color** — `canvas`, `surface`, `ink`, and `rule` are functions of the current
  `ColorScheme`, so views take `@Environment(\.colorScheme)` and pass it in. Both
  light and dark are supported and should be checked for any UI change.
- **Category accents** — signal red for health, signal blue for productivity,
  defined once as `HabitCategory.accent`. `tint` forwards to it; there is a single
  source of truth for the palette.
- **Structure** — borders and `RuleView`, never shadows. Corners are square apart
  from `Theme.Radius.control`.
- **Type** — `.labelStyle()` applies the uppercase, kerned treatment used by every
  section head and metadata line.

---

## Focus timer and Live Activity

Starting a focus session on a habit card runs a 25-minute countdown
(`FocusSession.defaultDuration`). When it completes, the app logs one completion
for that habit automatically. Only one session runs at a time — starting a second
cancels the first.

The countdown renders with `Text(timerInterval:)`, so it ticks without the view
holding a timer of its own.

### Enabling the Dynamic Island

**The Live Activity does not appear yet.** The code is written and ready in
`VitalityWidgets/`, but it needs a widget extension target, which must be created
in Xcode. `LiveActivityService` no-ops safely until then, so the in-app timer works
correctly regardless.

To wire it up:

1. **File → New → Target → Widget Extension**. Name it `VitalityWidgets`, check
   **Include Live Activity**, and uncheck **Include Configuration Intent**.
2. Replace the generated source files with the two already in `VitalityWidgets/`.
3. Select `Vitality/Models/FocusActivityAttributes.swift` and, in the File
   Inspector, check **both** the `Vitality` and `VitalityWidgets` boxes under
   Target Membership. The type must be identical on both sides or the activity
   payload will not decode.
4. Add `NSSupportsLiveActivities` = `YES` to the **app** target's Info.plist.

The Dynamic Island requires an iPhone 14 Pro or later, on device or in the
simulator.

---

## Contributing

- Match the conventions of surrounding code: the existing comment density, naming,
  and `// MARK:` section organization.
- Pull design values from `Theme` instead of introducing new literals.
- Check any UI change in both light and dark mode.
- Keep view models free of view code; keep persistence behind `StorageService`.
- Run the test suite before opening a pull request.
