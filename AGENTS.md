# AGENTS.md

This file provides guidance to coding agents when working with code in this repository.

## Project

Stronix — native iOS weightlifting tracker. SwiftUI + SwiftData, **zero external dependencies** (only Apple frameworks: SwiftData, UserNotifications, CoreHaptics, AVFoundation, OSLog). Do not add packages.

Swift 5.0, iOS 17.5 deployment target (test target: 18.6), Xcode project (not SPM), single shared scheme `Stronix`.

## Build & Test

Requires full Xcode, not Command Line Tools. If `xcodebuild` errors with `requires Xcode, but active developer directory '/Library/Developer/CommandLineTools'`, run `sudo xcode-select -s /Applications/Xcode.app`.

```bash
# Build
xcodebuild -project Stronix.xcodeproj -scheme Stronix -destination 'platform=iOS Simulator,name=iPhone 16' build

# All tests
xcodebuild -project Stronix.xcodeproj -scheme Stronix -destination 'platform=iOS Simulator,name=iPhone 16' test

# Single test suite / single test (swift-testing: Suite/method name, no `test` prefix)
xcodebuild ... test -only-testing:StronixTests/WorkoutTests
xcodebuild ... test -only-testing:StronixTests/WorkoutTests/initDefaults
```

Tests use **swift-testing** (`import Testing`, `@Test`, `#expect`), not XCTest.

### Signing

`Shared.xcconfig` is the base config for all targets and `#include?`s the gitignored `Local.xcconfig` (copy from `Local.example.xcconfig`) for `STRONIX_TEAM_ID` / `STRONIX_BUNDLE_PREFIX`. Editing `Local.xcconfig` requires closing and reopening the Xcode project to take effect.

## Architecture

### Data model

SwiftData `@Model` classes in `Stronix/Models/`, all `final` (required for the `UniquelyNamed` keypath conformance). Add a new model to `StronixSchema.models` — the single schema declaration that both `StronixApp.container` and `Preview Content/PreviewContainer.swift` build from.

Session graph: `Workout` → (cascade) `WorkoutExercise` → (cascade) `WorkoutSet`. `WorkoutExercise.exercise` is `.noAction`/nullify onto the catalog `Exercise`, so deleting workout data never touches the catalog.

Catalog: `Exercise` ↔ `Equipment` (single, nullify) and ↔ `MuscleGroup` (many-to-many, split into `primaryMuscles` / `secondaryMuscles` via explicit `inverse:` on the `Exercise` side). `Tag` and `RPE` are `Codable` enums stored inline on `WorkoutSet`.

Deletion is **soft** for the catalog: `Exercise.isArchived` + `Exercise.activePredicate`; always filter queries with it.

### Ordering

`Sortable` protocol (`var sortIndex: Int`) with `Array.reorder()` reassigning 0..n. `WorkoutExercise` and `WorkoutSet` conform. Never read `workoutExercises`/`sets` directly for display — use `sortedExercises` / `sortedSets`, and call `reorder()` after any mutation that changes order.

### Domain logic lives on the models

Business rules are model methods/computed properties, not view code or view models. Notable:

- `Workout.finish()` — drops uncompleted sets, removes emptied exercises, normalizes nil weight/reps to 0, auto-names from date if blank, stamps `end`. Reads as the single "commit the session" mutation.
- `Workout.duration` / `numberOfSets` / `totalVolume` / `hasCompletedSets` / `shareText(in:)`.
- `Workout.totalVolume` — training volume (Σ weight × reps), **not** a weight. Which sets count
  is decided solely by `Workout.countsTowardVolume(_:)` (currently completed sets only); every
  display reads that one property, so never recompute volume in a view.
- `WorkoutExercise.autoFillValues(for:using:)` — suggestion engine. Set 0 copies the first set of the most recent finished workout; set N tries a *progressive match* (a past workout whose sets 0..N-1 match the current workout exactly), else copies set N-1. History comes from `WorkoutExercise.fetchHistory(for:excluding:using:)`, which filters to `workout?.end != nil` and excludes the current workout in Swift (optional comparison isn't expressible in `#Predicate`).
- `isDuplicateName(_:excludingID:in:)` — supplied by the `UniquelyNamed` protocol
  (`Stronix/Models/UniquelyNamed.swift`), conformed to by `Exercise`, `Equipment`, and
  `MuscleGroup`. Conform new catalog models to it rather than writing a name check; supply
  `duplicateScope` to narrow which rows compete (as `Exercise` does to ignore archived ones)
  and `nameComparisonProperties` to keep the per-keystroke fetch cheap.

### App wiring

No singletons, no view models. State is injected through the SwiftUI environment from `StronixApp`:

- `ErrorHandler` (`@Observable`) — call `errorHandler.show(message)` for user-facing failures; the alert comes from `.withErrorHandler()` applied once in `MainView`. Every mutation that persists (create, edit, delete, archive) wraps `try context.save()` in a `do/catch` that logs *and* shows a message — don't rely on autosave silently succeeding. Views injecting `ErrorHandler` need `.environment(ErrorHandler())` in their `#Preview` or the preview traps.
- `RestTimer` (`@Observable`) — shared countdown. Survives backgrounding/relaunch by persisting start epoch + duration to UserDefaults and scheduling a `UNNotificationRequest`; keep those three (ticking, defaults, notification) consistent on every state change.
- `Log` (`Stronix/Utils/Log.swift`) — OSLog categories `persistence`, `navigation`, `workout`. Use these, not `print`.

`Equipment` and `MuscleGroup` get default rows at container creation from `EquipmentSeeder` / `MuscleGroupSeeder`, both no-ops when the table is non-empty.

Views are grouped by tab under `Stronix/Views/` (`Home/`, `Archive/`, `Settings/`), matching `MainView`'s three tabs. Views own `@Query` and `@Environment(\.modelContext)` directly and call `context.save()` themselves. `WorkoutEditorView` serves both "new workout" and "edit history" modes — new workouts are unmanaged objects until save, edit mode operates on managed ones, and the delete path differs accordingly.

## Requirements doc

`docs/REQUIREMENTS.md` is the single source of truth for product scope: glossary, user stories `US-NN` with acceptance criteria and a `Status:` line, non-functional requirements, bugs (`BUG-NN`), roadmap. When implementing or changing behavior, update the relevant story's acceptance criteria and status in the same change (history shows `docs:` commits paired with `feat:`).

## Conventions

- Commits: conventional prefixes (`feat:`, `fix:`, `docs:`, `test:`, `refactor:`), lowercase imperative summary.
- Swift files start with the standard Xcode header comment block.
- Doc comments (`///`) on non-obvious model methods explaining the algorithm; avoid narrative inline comments.
- Weight is always kilograms; formatting goes through `AppFormatter`.
- `.agents/` is a gitignored agent scratchpad; files there may be stale snapshots — read source, not `.agents/scratchpad/stronix-codebase.md`.
