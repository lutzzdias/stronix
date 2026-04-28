# Stronix

A focused, no-frills iOS workout tracker for serious lifters.

## Why Stronix?

Stronix is a weightlifting workout tracker for iOS. It does one thing: log your 
sets while stays out of the way during your workout.

It's built for solo lifters who want friction-free set logging, not a social 
network or a coaching platform. Open the app, start a workout, tap through your 
sets. No accounts, no feeds, no upsells.

The entire app runs on native Apple frameworks: SwiftUI, SwiftData,  
UserNotifications, CoreHaptics, with zero external dependencies. It's designed 
around the actual set - rest - set loop, and it respects your time and your 
data.

Inspired by [Iron](https://github.com/kabouzeid/Iron).

| ![Home](assets/home.png) | ![Current Workout](assets/current-workout.png) | ![Archive](assets/archive.png) |
| --- | --- | --- |

## Features

- Create and track workouts with exercises, sets, weight, and reps
- Rest timer with haptic feedback, local notifications, and configurable defaults
- Auto-fill weight and reps from previous sets or workout history
- Exercise history shown inline during workouts
- Workout finish summary with share-as-text
- Exercise and workout archive with soft delete
- Drag-to-reorder exercises and sets

## Tech

- Swift 5 / SwiftUI / SwiftData
- iOS 17.5+, Xcode 15.4+
- Zero external dependencies: native Apple frameworks only (UserNotifications, 
  CoreHaptics, etc.)
- `@Observable` shared state (e.g., `RestTimer`)
- SwiftUI environment for dependency injection, no singletons
- Data model: `Workout`, `WorkoutExercise`, `WorkoutSet`, plus `Exercise` and 
  `Tag`

## Getting Started

### Prerequisites

- Xcode 15.4+
- iOS 17.5+

### Setup

1. Clone the repo
2. Copy the signing config template:
   ```
   cp Local.xcconfig.template Local.xcconfig
   ```
3. Edit `Local.xcconfig` with your values:
   ```
   STRONIX_TEAM_ID = YOUR_TEAM_ID_HERE
   STRONIX_BUNDLE_PREFIX = com.yourname
   ```
   Find your Team ID at [developer.apple.com/account](https://developer.apple.com/account) > Membership Details.
4. Open `Stronix.xcodeproj` and build (⌘B)

> `Local.xcconfig` is gitignored — each contributor maintains their own. If you 
> change `Local.xcconfig` while Xcode is open, close and reopen the project for 
> the new values to take effect.

## Documentation

All product requirements, user stories (with acceptance criteria), 
non-functional requirements, and the roadmap live in a single file:

- **[docs/REQUIREMENTS.md](docs/REQUIREMENTS.md)**
