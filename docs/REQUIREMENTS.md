# Stronix — Requirements & Feature Plan

## Glossary

| Term | Definition |
|---|---|
| Archive | The tab displaying recent workouts and exercises; also the soft-delete action that sets `isArchived = true` on an exercise. |
| Auto-fill | Automatic population of weight and reps on a new set using historical workout data (progressive match or fallback copy). |
| Current Workout | The in-progress workout being tracked in `CurrentWorkoutView`; not yet persisted to SwiftData until the user taps Save. |
| Dragger | Custom SwiftUI input control combining a `TextField` with a vertical drag gesture for adjusting weight (kg) or reps. |
| Equipment | Free-text property on `Exercise` describing the gear used (e.g., barbell, dumbbell); planned migration to a structured enum. |
| Exercise | A named movement in the user's catalog (e.g., "Bench Press") stored as a SwiftData `@Model` with optional description, equipment, and muscle fields. |
| Home tab | The first tab in `MainView`; currently shows only a "Start Workout" button. |
| ModelContainer | The SwiftData persistence container initialized at app launch with on-disk SQLite storage. |
| Muscle Group | Free-text property on `Exercise` indicating the target muscle; planned migration to a structured enum with color coding. |
| Rest Timer | An `@Observable` countdown timer that auto-starts when a set is completed; state persisted to UserDefaults for background survival. |
| RPE | Rating of Perceived Exertion; a `Codable` enum with `Double` raw values from 6.0 to 10.0 in 0.5 increments, assignable to any set. |
| Set (completed) | A `WorkoutSet` record with `completed = true`; included in volume calculations and persisted on workout finish. |
| Set (uncompleted) | A `WorkoutSet` record with `completed = false`; removed by `Workout.finish()` before saving. |
| Sortable | A protocol requiring a mutable `sortIndex: Int` property with a `reorder()` extension that reassigns sequential indices from 0. |
| Tag | A `Codable` enum on `WorkoutSet` with cases `.warmUp` (W), `.drop` (D), `.failure` (F); displayed as capsule badges. |
| Workout | A SwiftData `@Model` representing a single training session with start/end timestamps and a cascade relationship to `WorkoutExercise`. |
| WorkoutExercise | A SwiftData `@Model` joining a `Workout` to an `Exercise` with a `sortIndex` and a cascade relationship to `WorkoutSet`. |
| WorkoutSet | A SwiftData `@Model` representing one set within a `WorkoutExercise`; stores weight, reps, completed flag, tag, RPE, and comment. |

## User Stories

### Workouts

#### US-01: Start a New Workout

**Status:** Implemented

**User story:** As a lifter, I want to start a new workout with one tap, so that I can begin tracking immediately.

**Acceptance criteria:**
- Tapping "Start Workout" on the Home tab creates a new `Workout` with `start = Date.now` and an empty exercise list
- The user is navigated to `CurrentWorkoutView`
- The Home tab displays a single "Start Workout" button with blue background when no workout is active
- No other content is shown on the Home tab besides the start button

#### US-02: Name and Describe a Workout

**Status:** Implemented

**User story:** As a lifter, I want to name my workout and add a description, so that I can identify it later.

**Acceptance criteria:**
- `CurrentWorkoutView` displays a name `TextField` and a comment `TextField` at the top
- Workout name defaults to an empty string (no validation enforced)
- Workout comment defaults to an empty string
- Both fields accept free-text input and persist to the `Workout` model

#### US-03: Add Exercises to a Workout

**Status:** Implemented

**User story:** As a lifter, I want to add multiple exercises to a workout, so that I can track a full session.

**Acceptance criteria:**
- An "Add exercise" button below the exercise list opens a multi-select sheet (`AddExerciseSheetView`)
- Exercises already in the workout are excluded from the selection list
- Selected exercises are appended to the workout with sequential `sortIndex` values
- Each added exercise receives one empty set by default

#### US-04: Reorder and Remove Exercises

**Status:** Implemented

**User story:** As a lifter, I want to reorder and remove exercises in my workout, so that I can match my actual session flow.

**Acceptance criteria:**
- Exercises can be reordered via drag-to-reorder; `sortIndex` on each `WorkoutExercise` is updated to reflect the new order
- Exercises can be removed via swipe-to-delete; sort indices are recalculated after removal
- The toolbar shows "Cancel" (leading) and "Finish" (trailing)

#### US-05: Cancel a Workout

**Status:** Implemented

**User story:** As a lifter, I want to cancel a workout, so that I can discard an unwanted session.

**Acceptance criteria:**
- Tapping "Cancel" discards the workout without persisting to SwiftData
- When the workout has at least one completed set, a confirmation dialog is shown before discarding (see US-38)
- When the workout has zero completed sets, it is discarded immediately with no confirmation

#### US-06: Finish a Workout and View Summary

**Status:** Implemented

**User story:** As a lifter, I want to finish my workout and see a summary, so that I can review before saving.

**Acceptance criteria:**
- Tapping "Finish" invokes `Workout.finish()` which: (a) removes all uncompleted sets from each exercise, (b) removes exercises with zero remaining sets, (c) recalculates sort indices, (d) stamps `end = Date.now`
- The rest timer is stopped before the summary is shown
- `WorkoutSummarySheet` is presented as a modal with interactive dismiss disabled (`.interactiveDismissDisabled()`)
- The summary displays three statistics: duration (formatted as "Xh Ym"), total completed sets count, and total volume in kg (`Σ(weight × reps)` for completed sets only)
- A per-exercise section lists each exercise name and its completed sets as "weight kg × reps"
- Exercises with zero completed sets do not appear in the summary
- A workout with no completed sets results in a summary showing 0 sets and 0 kg volume with no exercise sections
- TODO: `Workout.finish()` has a `// TODO: validate nil data` comment indicating incomplete validation

#### US-07: Share a Workout as Plain Text

**Status:** Implemented

**User story:** As a lifter, I want to share my workout as plain text, so that I can send it to friends or paste it into a notes app.

**Acceptance criteria:**
- A `ShareLink` button in the summary toolbar opens the iOS system share sheet
- Share text format: date on line 1, duration on line 2, total weight on line 3, blank line, then per-exercise blocks with exercise name followed by indented set lines ("  weight kg × reps"), separated by blank lines
- If an exercise's linked `Exercise` object is nil (deleted), the name displays as empty string in share text
- Weight and reps default to 0 when nil in share text formatting

#### US-08: Save or Cancel from Summary

**Status:** Implemented

**User story:** As a lifter, I want to save or cancel from the summary, so that I can persist my workout or return to editing.

**Acceptance criteria:**
- A save button (checkmark icon, `.confirmationAction` placement) persists the workout to SwiftData and dismisses the sheet
- A cancel button (`.cancellationAction` placement) dismisses the sheet and returns to the workout editor without saving
- The `finish()` mutations are applied in-place; if the user cancels, the workout is not inserted into the SwiftData context

#### US-09: Browse Workout History

**Status:** Implemented

**User story:** As a lifter, I want to browse past workouts, so that I can review my training history.

**Acceptance criteria:**
- The Archive tab shows the 5 most recent workouts with a "See all" link to the full list
- The full workout list is searchable and sorted by start date
- Each workout row displays identifying information (name, date, stats)

#### US-10: View Workout Details

**Status:** Implemented

**User story:** As a lifter, I want to view workout details, so that I can review a past session.

**Acceptance criteria:**
- `WorkoutDetailView` displays name, comment, duration, sets count, total weight, start/end dates, and per-exercise set listing
- The view is fully read-only (no editing capability)
- If an exercise's linked `Exercise` object is nil, the name displays as "Unknown"
- Duration is computed as `(end ?? Date.now) - start`
- Total volume is computed as `Σ(weight × reps)` across all sets
- Total sets is the count of all `WorkoutSet` records
- TODO: `WorkoutDetailView` has `// TODO: Allow edit` and `// TODO: convert to TextField` comments indicating editing is planned (see US-37)

#### US-11: Delete a Past Workout

**Status:** Implemented

**User story:** As a lifter, I want to delete a past workout, so that I can remove incorrect entries.

**Acceptance criteria:**
- Trailing swipe on a workout in the history list reveals a red "Delete" button
- Tapping Delete shows a confirmation dialog (see US-38); confirming deletes the workout from SwiftData
- Deletion cascades to all associated `WorkoutExercise` and `WorkoutSet` records

### Exercises & Sets

#### US-12: Create an Exercise

**Status:** Implemented

**User story:** As a lifter, I want to create exercises with a name and optional details, so that I can build my exercise catalog.

**Acceptance criteria:**
- The user can create an exercise with a required name and optional description, equipment, and muscle group (all free-text)
- A create button is available in the toolbar and inline in `ExercisesView`
- `ExerciseEditor` is presented as a form sheet with name (required), description, equipment, and muscle fields
- A user-facing error alert is shown if the exercise save fails
- The Save button is disabled when the trimmed name is empty OR matches a non-archived exercise's name (case-insensitive, whitespace-trimmed)
- Archived exercises with the same name do not trigger the duplicate check; editing an exercise without changing its name keeps Save enabled
- Leading and trailing whitespace are trimmed from name, description, equipment, and muscle before saving
- TODO: equipment field should become a picker (see US-33)
- TODO: muscle group field should become a picker allowing multiple selections (see US-32)

#### US-13: Edit an Exercise

**Status:** Implemented

**User story:** As a lifter, I want to edit an exercise's details, so that I can correct mistakes.

**Acceptance criteria:**
- `ExerciseDetailView` displays name, description, muscle, and equipment with an edit button
- The edit button opens `ExerciseEditor` in edit mode, pre-populated with current values
- Changes are persisted to SwiftData on save
- Same duplicate-name and whitespace-trimming rules as US-12 apply when saving edits

#### US-14: Archive an Exercise

**Status:** Implemented

**User story:** As a lifter, I want to archive an exercise I no longer use, so that it does not clutter my list.

**Acceptance criteria:**
- Trailing swipe on an exercise reveals a red "Archive" button
- Tapping Archive shows a confirmation dialog (see US-38); confirming sets `isArchived = true` (soft delete)
- Archived exercises do not appear in the active exercise list
- Archiving does not affect existing `WorkoutExercise` references (`noAction` delete rule on exercise side, `nullify` on back-reference)
- Historical workout data referencing the archived exercise remains intact

#### US-15: Browse Exercises

**Status:** Implemented

**User story:** As a lifter, I want to browse my exercise catalog, so that I can find and manage exercises.

**Acceptance criteria:**
- The Archive tab shows the 5 most recent exercises with a "See all" link and a create button
- The full exercise list is searchable and displays only active (non-archived) exercises

#### US-16: Add and Manage Sets

**Status:** Implemented

**User story:** As a lifter, I want to add, remove, and reorder sets within an exercise during a workout, so that I can track each working set.

**Acceptance criteria:**
- A new set receives `sortIndex = sets.count` when added
- Sets can be removed via swipe-to-delete; sort indices are recalculated after removal
- Sets can be reordered via drag-to-reorder; `sortIndex` is updated on all affected sets
- Tapping a set selects it for editing in the `SetEditorView` bottom panel

#### US-17: Edit Set Weight and Reps

**Status:** Implemented

**User story:** As a lifter, I want to enter weight and reps for a set, so that I can log my performance.

**Acceptance criteria:**
- `SetEditorView` displays two `Dragger` controls: weight (kg, step 2.5) and reps (integer, step 1)
- Both Dragger controls support keyboard entry and vertical drag gesture
- Drag gesture uses `.interactiveSpring` animation on the handle
- Haptic feedback (`.sensoryFeedback(.selection)`) fires on drag value changes
- Weight and reps are optional on the model; nil values are treated as 0 in computed properties

#### US-18: Complete a Set

**Status:** Implemented

**User story:** As a lifter, I want to complete a set, so that I can mark it as done and move on.

**Acceptance criteria:**
- Tapping "Complete set" in `SetEditorView` sets `completed = true` on the set
- Completing a set starts the rest timer with the user's configured default duration
- The set row in the list updates to reflect the completed state

#### US-19: Tag a Set

**Status:** Implemented

**User story:** As a lifter, I want to tag a set as Warm Up, Drop Set, or Failure, so that I can categorize my effort.

**Acceptance criteria:**
- The tag picker in `SetDetailsSheet` offers three options: Warm Up (W), Drop Set (D), Failure (F)
- The tag is clearable (can be set to nil)
- Tags display as capsule badges in the set list row

#### US-20: Record RPE for a Set

**Status:** Implemented

**User story:** As a lifter, I want to record RPE for a set, so that I can track perceived difficulty.

**Acceptance criteria:**
- The RPE picker in `SetDetailsSheet` offers values from 6.0 to 10.0 in 0.5 increments
- Each RPE value displays a human-readable description (e.g., "Could do 4+ more reps" for 6.0)
- RPE is clearable (can be set to nil)
- RPE displays as caption text in the set list row

#### US-21: Add a Comment to a Set

**Status:** Implemented

**User story:** As a lifter, I want to add a comment to a set, so that I can note anything unusual.

**Acceptance criteria:**
- `SetDetailsSheet` includes a free-text comment field
- Comments display as italic caption text below the set's weight × reps in the list row

#### US-22: Auto-Fill Weight and Reps from History

**Status:** Implemented

**User story:** As a lifter, I want weight and reps auto-filled from my last session, so that I save time entering data.

**Acceptance criteria:**
- For set index 0, weight and reps are auto-filled from the first set of the most recent completed historical workout for the same exercise
- For set index N > 0, progressive match is attempted: find a historical workout where sets 0 through N-1 all match the current workout's values exactly (weight AND reps), then use that workout's set N values
- If progressive match fails for set N > 0, weight and reps are copied from set N-1 of the current workout
- Auto-fill triggers on: page load (first set), new set creation, and set selection change
- Auto-fill only considers completed historical workouts (`workout.end != nil`) and excludes the current workout
- Auto-fill returns nil if no historical data exists — the set remains unfilled
- If a historical workout has fewer sets than the current index, progressive match skips it

#### US-23: View Inline Exercise History

**Status:** Implemented

**User story:** As a lifter, I want to see my last 3 sessions for an exercise while working out, so that I can gauge progress.

**Acceptance criteria:**
- The last 3 completed workouts for the current exercise are displayed below the active sets in `WorkoutExerciseView`
- Each history entry shows the date and per-set details (weight × reps)
- History is loaded once via `.task` when the exercise view appears

### Rest Timer

#### US-24: Auto-Start Rest Timer on Set Completion

**Status:** Implemented

**User story:** As a lifter, I want the rest timer to start automatically when I complete a set, so that I do not have to start it manually.

**Acceptance criteria:**
- Completing a set auto-starts the rest timer with the user's configured default duration (`defaultRestDuration` from `@AppStorage`, default 90 seconds)
- A local notification is scheduled via `UNUserNotificationCenter` to fire when the timer expires
- The notification title includes the formatted duration; the body reads "Back to work 💪"
- Starting a new timer while one is running replaces the previous timer (cancels old notification, schedules new one)

#### US-25: View Rest Timer Countdown

**Status:** Implemented

**User story:** As a lifter, I want to see the remaining rest time in the workout view, so that I know when to start my next set.

**Acceptance criteria:**
- `TimerView` banner displays at the top of `CurrentWorkoutView` and `WorkoutExerciseView`
- The left side shows elapsed workout time; the right side shows the rest timer countdown
- Timer text uses default style when counting down and turns `.red` when overtime (remaining ≤ 0)
- The timer ticks at 1-second intervals via a `Timer`
- Tapping the timer button opens `RestTimerSheet`

#### US-26: Adjust and Control the Rest Timer

**Status:** Implemented

**User story:** As a lifter, I want to adjust the timer by ±10 seconds or pick a preset, so that I can fine-tune my rest.

**Acceptance criteria:**
- `RestTimerSheet` shows preset duration buttons: 60, 90, 120, 150, and 180 seconds
- Selecting a preset starts (or restarts) the timer with that duration
- When the timer is running, the sheet shows a large countdown display, "of X:XX" total duration label, and -10s / +10s / Cancel buttons
- Adjustments update the duration and re-persist to UserDefaults; if adjustment reduces duration below 0, the timer stops
- A cancel/stop button manually stops the timer
- Pending notifications are cancelled when the timer is stopped or a new timer is started

#### US-27: Receive Notification and Haptic on Timer Expiry

**Status:** Implemented

**User story:** As a lifter, I want a notification and haptic when my rest is done, so that I am alerted even if the app is in the background.

**Acceptance criteria:**
- Notification permission (`[.alert, .sound]`) is requested on first timer start, not at app launch
- If permission is denied, the timer still functions visually and with haptics — only the background notification is lost
- Haptic feedback (`.sensoryFeedback(.success)`) fires exactly once when the timer crosses zero, controlled by a `hapticFired` flag
- The `expired` toggle property signals the haptic trigger

#### US-28: Persist Timer Across App Backgrounding

**Status:** Implemented

**User story:** As a lifter, I want the timer to survive app backgrounding, so that it is accurate when I return.

**Acceptance criteria:**
- Timer state (start timestamp + duration) is persisted to UserDefaults on start and on adjustment
- On app launch, a running timer is restored from UserDefaults if remaining time is > 0
- Expired timers are cleared on restore (not shown as overtime)
- If the app is killed and relaunched, the timer restores from UserDefaults
- UserDefaults keys: `restTimerStart` (epoch Double), `restTimerDuration` (seconds Double)

#### US-29: Configure Default Rest Duration

**Status:** Implemented

**User story:** As a lifter, I want to configure my default rest duration in Settings, so that the auto-start uses my preferred time.

**Acceptance criteria:**
- `SettingsView` includes a "Rest Timer" section with a `Picker` for default duration
- Range: 30 seconds to 300 seconds (5 minutes) in 15-second increments
- The value is persisted via `@AppStorage("defaultRestDuration")` with a default of 90 seconds
- Subsequent set completions use the updated default duration

### Sharing & History

#### US-30: Persist Data with SwiftData

**Status:** Implemented

**User story:** As a lifter, I want my workouts and exercises to persist across app launches, so that I never lose data.

**Acceptance criteria:**
- `ModelContainer` is created at launch with schema `[Exercise, WorkoutSet, Workout, WorkoutExercise]` using the default on-disk `ModelConfiguration` (SQLite)
- The container is injected into the SwiftUI view hierarchy via `.modelContainer()`
- Preview and test configurations use in-memory `ModelConfiguration` (`isStoredInMemoryOnly: true`)
- `ModelContainer` creation failure is a `fatalError` — the app cannot function without it
- `Workout` entity: `id: UUID` (unique), `name: String`, `comment: String`, `start: Date`, `end: Date?`, relationship to `[WorkoutExercise]`
- `WorkoutExercise` entity: `id: UUID` (unique), `comment: String`, `sortIndex: Int`, relationships to `Workout?`, `Exercise?`, `[WorkoutSet]`
- `WorkoutSet` entity: `id: UUID` (unique), `repetitions: Int?`, `weight: Double?`, `completed: Bool`, `minTargetRepetitions: Int?`, `maxTargetRepetitions: Int?`, `tag: Tag?`, `comment: String?`, `rpe: RPE?`, `sortIndex: Int`
- `Exercise` entity: `id: UUID` (unique), `name: String`, `desc: String?`, `equipment: String?`, `muscle: String?`, `isArchived: Bool` (default false), optional relationship to `[WorkoutExercise]?`
- All `id` properties use `@Attribute(.unique)` — SwiftData enforces uniqueness at the SQLite level
- `WorkoutSet.minTargetRepetitions` and `maxTargetRepetitions` exist on the model but are never displayed or editable

#### US-31: Cascade Deletes and Relationship Integrity

**Status:** Implemented

**User story:** As a lifter, I want deleting a workout to remove all its exercises and sets, so that no orphan data remains.

**Acceptance criteria:**
- `Workout` → `WorkoutExercise` uses cascade delete; deleting a workout deletes all its workout exercises
- `WorkoutExercise` → `WorkoutSet` uses cascade delete; deleting a workout exercise deletes all its sets
- `WorkoutExercise` → `Exercise` uses `noAction` delete rule; deleting a workout exercise does not affect the referenced exercise
- `Exercise` → `WorkoutExercise` uses `nullify` delete rule; deleting an exercise sets the exercise reference to nil on associated workout exercises
- Views display "Unknown" for the exercise name when `WorkoutExercise.exercise` is nil
- `WorkoutSet` and `WorkoutExercise` conform to the `Sortable` protocol
- The `reorder()` extension method reassigns sequential indices starting from 0
- All ordered collections are sorted by `sortIndex` ascending when displayed

### Exercises & Catalog Enhancements (Planned)

#### US-32: Structured Muscle Group Enum with Color System

**Status:** Planned

**User story:** As a lifter, I want muscle groups to be structured options with color coding, so that I can filter and visually identify exercises by muscle.

**Acceptance criteria:**
- A `MuscleGroup` enum is defined with cases: chest, back, shoulders, arms, legs, core, fullBody, other
- Each `MuscleGroup` has an associated `Color` and SF Symbol icon
- `Exercise.muscle` migrates from `String?` to `MuscleGroup?` via SwiftData lightweight migration
- `ExerciseEditor` uses a `Picker` for muscle group selection instead of a `TextField`
- The exercise list groups exercises by muscle group with colored section headers
- Existing free-text values that match enum cases auto-migrate; non-matching values become nil
- TODO: define the one-time migration helper for non-matching free-text values

#### US-33: Structured Equipment Enum

**Status:** Planned

**User story:** As a lifter, I want equipment types to be structured options, so that the app can provide equipment-aware defaults.

**Acceptance criteria:**
- An `Equipment` enum is defined with cases: barbell, dumbbell, machine, cable, bodyweight, other
- `Exercise.equipment` migrates from `String?` to `Equipment?`
- `ExerciseEditor` uses a `Picker` for equipment selection
- The Dragger step size adapts based on equipment: 2.5 for barbell, 1.0 for dumbbell, 5.0 for machine
- TODO: define step sizes for cable, bodyweight, and other equipment types

#### US-34: Exercise Illustration System

**Status:** Planned

**User story:** As a lifter, I want to see illustrations for exercises, so that I can verify proper form.

**Acceptance criteria:**
- The app bundles illustration assets for the 20–30 most common exercises as asset catalog images (PDF or SVG)
- `ExerciseDetailView` displays the illustration when available
- The workout exercise list shows a small thumbnail (40×40pt) next to the exercise name
- Exercises without illustrations show a fallback SF Symbol based on muscle group (requires US-32)
- The app may support animated illustrations (two-frame loop) using `TimelineView` + image swap
- TODO: identify asset source and licensing for exercise illustrations

#### US-35: Exercise Statistics with Pinnable Charts

**Status:** Planned

**User story:** As a lifter, I want to see progress charts for an exercise, so that I can track improvement over time.

**Acceptance criteria:**
- `ExerciseDetailView` shows at least one chart (estimated 1RM over time) when history exists using Swift Charts (`import Charts`)
- Three chart types are available: 1RM trend (Epley formula: `weight × (1 + reps / 30)`), volume per session, max weight per session
- The user can pin/unpin charts to the Home dashboard
- Pinned charts persist across app launches (stored in UserDefaults or SwiftData)
- The Home dashboard displays pinned charts below the activity calendar (requires US-42)
- TODO: define the pinned chart storage model (UserDefaults array vs. SwiftData entity)

#### US-36: Median Set Count Auto-Creation

**Status:** Planned

**User story:** As a lifter, I want the app to auto-create the typical number of sets when I add an exercise, so that I save time.

**Acceptance criteria:**
- When an exercise is added to a workout, the app queries the last 30 days of history for that exercise
- If ≥3 completed workouts exist, the median set count is calculated and that many sets are auto-created
- Each auto-created set is pre-filled using the existing auto-fill logic (per US-22)
- If insufficient history exists, 1 set is created (current behavior)
- Auto-created sets are capped at a maximum of 10
- The median calculation uses only completed sets from finished workouts

### Workout Enhancements (Planned)

#### US-37: Editable Workout History

**Status:** Planned

**User story:** As a lifter, I want to edit a completed workout's details, so that I can fix mistakes after saving.

**Acceptance criteria:**
- `WorkoutDetailView` supports an edit mode toggle (toolbar "Edit" / "Done")
- In edit mode, workout name and comment become `TextField`s
- In edit mode, start and end times become enabled `DatePicker`s
- Changes auto-save to SwiftData (no explicit save button)
- TODO: define whether individual set weight/reps values are editable in this view
- TODO: define undo/cancel-edit behavior (copy-on-write pattern vs. auto-save)

#### US-38: Destructive Action Confirmations

**Status:** Implemented

**User story:** As a lifter, I want confirmation before destructive actions, so that I do not accidentally lose data.

**Acceptance criteria:**
- An `.alert` is shown before cancelling a workout that has at least one completed set
- Cancelling a workout with zero completed sets dismisses immediately with no confirmation
- An `.alert` is shown before deleting a workout from the history list (in both `WorkoutsView` and `ArchiveView`)
- An `.alert` is shown before archiving an exercise (in both `ExercisesView` and `ArchiveView`)
- Destructive actions use SwiftUI's `role: .destructive` button, which renders in red
- Deletion and archive rows are revealed via trailing swipe (`.swipeActions`, `allowsFullSwipe: false`) so the row stays in place until the user confirms

#### US-39: Repeat Workout from History

**Status:** Planned

**User story:** As a lifter, I want to repeat a past workout, so that I do not have to recreate it manually each session.

**Acceptance criteria:**
- A "Repeat" action is available on completed workouts (in detail view toolbar and/or list context menu)
- "Repeat" creates a new workout with the same exercises in the same order, pre-filling each set's weight and reps from the source workout
- A "Repeat Blank" option creates the same exercises with empty sets (same count as source)
- The new workout uses the current date/time as its start time
- The app navigates to `CurrentWorkoutView` with the new workout
- Deep copy creates new UUIDs for all entities to avoid SwiftData conflicts

#### US-40: Workout Templates

**Status:** Planned

**User story:** As a lifter, I want to save and reuse workout templates, so that I can start structured sessions with one tap.

**Acceptance criteria:**
- The user can create, edit, and delete workout templates
- A template has a name and an ordered list of exercises with target set counts
- Tapping a template starts a new workout pre-populated with the template's exercises and auto-created sets
- The workout summary sheet offers "Save as Template" to create a template from the current workout
- Templates are reorderable on the Home tab
- New SwiftData models: `WorkoutTemplate` (name, sortIndex) and `TemplateExercise` (exercise, targetSetCount, sortIndex)
- TODO: define whether templates support grouping into plans (e.g., "Push/Pull/Legs")

### Rest Timer Enhancements (Planned)

#### US-41: Flow-Optimized Set Completion Toolbar

**Status:** Planned

**User story:** As a lifter, I want a keyboard toolbar that lets me flow from weight to reps to completion, so that I can log sets faster.

**Acceptance criteria:**
- An accessory toolbar appears above the system keyboard whenever either Dragger `TextField` is focused (`.toolbar { ToolbarItemGroup(placement: .keyboard) }`)
- The toolbar includes directional buttons ("← Weight" / "Reps →") to move focus between weight and reps fields
- The toolbar includes a prominent "✓ Complete" button that marks the current set as completed, starts the rest timer, and advances to the next uncompleted set
- The keyboard is dismissed after completing a set
- Requires lifting `@FocusState` from `Dragger` internals to the parent `SetEditorView`
- TODO: verify toolbar height does not obscure content on iPhone SE-sized devices

#### US-42: Sticky Timer Banner Across Workout Navigation

**Status:** Planned

**User story:** As a lifter, I want the timer banner to remain visible when navigating between exercises, so that I never lose sight of my rest countdown.

**Acceptance criteria:**
- The timer banner remains visible when navigating from the workout exercise list into an individual exercise view
- The banner shows both elapsed workout time and rest timer countdown
- The banner is tappable to open the rest timer sheet from any depth in the navigation stack
- The banner does not interfere with the navigation bar or list scroll behavior
- Implementation uses `.safeAreaInset(edge: .top)` on the `NavigationStack` in `CurrentWorkoutView`; the duplicate `TimerView` in `WorkoutExerciseView` is removed
- TODO: verify `.safeAreaInset` propagates to pushed views in `NavigationStack`

#### US-43: Actionable Rest Timer Notifications

**Status:** Planned

**User story:** As a lifter, I want to extend my rest timer from the lock screen notification, so that I do not have to open the app.

**Acceptance criteria:**
- A `UNNotificationCategory` is registered at app launch with three `UNNotificationAction` items: +30s, +60s, +90s
- Tapping an action extends the rest timer duration without opening the app
- The notification content uses `categoryIdentifier` matching the registered category
- The notification uses `.timeSensitive` interruption level
- A `UNUserNotificationCenterDelegate` handles action responses and updates `RestTimer.duration`
- Delivered notifications are cleared when the user opens the rest timer sheet

#### US-44: Equipment-Aware Rest Timer Defaults

**Status:** Planned

**User story:** As a lifter, I want different default rest durations per equipment type, so that compound lifts get more rest than isolation work.

**Acceptance criteria:**
- Settings displays three rest timer default pickers: "Barbell" (default 120s), "Dumbbell" (default 90s), "Other" (default 60s)
- When a set is completed, the rest timer starts with the duration matching the current exercise's equipment type
- If the exercise has no equipment set, the "Other" default is used
- Requires US-33 (structured equipment enum) or a mapping from free-text equipment strings
- `@AppStorage` keys: `defaultRestDurationBarbell`, `defaultRestDurationDumbbell`, `defaultRestDurationOther`

### Platform Integrations

#### US-45: Home Screen Widget

**Status:** Planned

**User story:** As a lifter, I want a Home Screen widget showing days since my last workout, so that I have a passive accountability nudge.

**Acceptance criteria:**
- A `.systemSmall` widget displays "Last Workout" label and the number of days since the last completed workout in large rounded font
- The widget refreshes daily (`.after(startOfTomorrow)` timeline policy)
- Tapping the widget opens the app to the Home tab
- The widget uses the app's accent color for visual consistency
- Data sharing uses an App Group container (`group.com.stronix.shared`) for SwiftData access from the widget extension
- The main app's `ModelContainer` configuration is updated to use the App Group container URL
- A `.systemMedium` widget variant may additionally show a mini 7-day activity calendar
- TODO: define one-time migration strategy for existing users' data from default container to App Group container

#### US-46: Apple Watch Companion

**Status:** Planned

**User story:** As a lifter, I want to see my rest timer and workout status on my Apple Watch, so that I do not have to pull out my phone mid-set.

**Acceptance criteria:**
- The watch app displays elapsed workout time when a workout is active on the phone
- The watch app displays the rest timer countdown, including overtime in red
- The watch app shows the current exercise name and completed/total set count
- The watch app allows starting, stopping, and extending the rest timer from the wrist
- Phone↔Watch communication uses `WCSession` (`WatchConnectivity` framework)
- `updateApplicationContext` is used for guaranteed state delivery; `sendMessage` for real-time timer updates when reachable
- The watch app shows a "Start on iPhone" prompt when no workout is active
- TODO: define watch UI layout (single `TabView` with timer page and info page vs. other structure)

#### US-47: HealthKit Workout Sync

**Status:** Planned

**User story:** As a lifter, I want my completed workouts saved to Apple Health, so that my strength training appears in my overall fitness data.

**Acceptance criteria:**
- The app requests HealthKit write authorization for `HKWorkoutType` and optionally `HKQuantityType(.activeEnergyBurned)`
- Authorization is requested only when the user enables the feature in Settings, not at launch
- When enabled, an `HKWorkout` with `activityType: .traditionalStrengthTraining` is saved on workout finish with start/end dates
- Estimated active energy burned is included (heuristic: 0.08 kcal/kg/min × duration; body weight from HealthKit if authorized, else 70 kg default)
- Settings includes a "Save to Apple Health" toggle (default: off)
- The `HealthKitManager` is implemented as an `actor` for thread safety
- The save flow does not crash or block if HealthKit is unavailable or authorization is denied
- `Info.plist` includes `NSHealthShareUsageDescription` and `NSHealthUpdateUsageDescription`

#### US-48: App Intents for Shortcuts

**Status:** Planned

**User story:** As a lifter, I want to start a workout via Siri or the Shortcuts app, so that I can integrate stronix into my automation workflows.

**Acceptance criteria:**
- An `AppIntent` for "Start Workout" is registered, discoverable in Shortcuts and Siri, with `openAppWhenRun = true`
- An `AppShortcutsProvider` defines default phrases (e.g., "Start my workout in Stronix")
- A deep-link URL scheme (`stronix://start-workout`) is handled by a `DeepLinkRouter` that drives `NavigationPath` state in `MainView`
- An `AppEntity` for `Exercise` supports parameterized queries
- All intents use the modern App Intents framework (not legacy SiriKit `INIntent`)
- A "Start from Template" intent is parameterized by template name (requires US-40)
- TODO: define behavior when an intent fires while a workout is already active

### Data & Backup

#### US-49: JSON Backup and Restore

**Status:** Planned

**User story:** As a lifter, I want to export and import my data as a JSON file, so that I have a backup if I lose my device.

**Acceptance criteria:**
- A "Export Data" action in Settings encodes the full object graph (`Exercise`, `Workout`, `WorkoutExercise`, `WorkoutSet`) to a single JSON file using `JSONEncoder` with `.iso8601` date strategy and `.sortedKeys`
- The export file uses a custom UTType (`com.stronix.backup` / `.stronix.json`) registered in `Info.plist`
- Export is shared via `ShareLink`; import uses `.fileImporter` modifier
- Import matches records on UUID: duplicates are skipped, new records are merged
- The export format includes a schema version field for forward compatibility
- The app validates JSON structure and surfaces user-facing errors for malformed files via `ErrorHandler`
- The user can choose between "merge" (add missing) and "replace" (wipe + restore) import modes
- TODO: define behavior for importing data from a newer schema version

#### US-50: SwiftData Schema Migration Strategy

**Status:** Planned

**User story:** As a lifter, I want app updates to preserve my data even when the data model changes, so that I never lose workouts.

**Acceptance criteria:**
- A `VersionedSchema` is defined for the current (V1) model layout
- A `SchemaMigrationPlan` is registered with the `ModelContainer`
- Each model-breaking change adds a new schema version with an appropriate `MigrationStage`
- Custom migrations are covered by unit tests that seed V(N-1) data and verify V(N) output
- Migration events are logged via `os.Logger` (subsystem: Persistence)
- This is a prerequisite for US-32 (muscle group enum) and US-33 (equipment enum)

#### US-51: Data Integrity Validation and Orphan Cleanup

**Status:** Planned

**User story:** As a lifter, I want the app to validate my data before saving and clean up orphaned records, so that my database stays healthy.

**Acceptance criteria:**
- Pre-save validation in `Workout.finish()` checks: non-empty workout name (warn or auto-generate), non-nil weight and reps on completed sets
- Validation failures are surfaced to the user via the existing `ErrorHandler` mechanism
- A background orphan cleanup runs on app launch, scanning for `WorkoutExercise` records with nil `workout` or nil `exercise` references and deleting them
- Orphan cleanup does not delete data that is part of an active (unfinished) workout
- All validation issues and orphan removals are logged via `os.Logger`

#### US-52: iCloud Sync via CloudKit

**Status:** Planned

**User story:** As a lifter, I want my data to sync across my devices via iCloud, so that I can use stronix on my iPhone and iPad.

**Acceptance criteria:**
- `ModelContainer` is configured with `ModelConfiguration` setting `cloudKitDatabase: .private` when sync is enabled
- Settings includes a toggle to enable/disable iCloud sync (default: off)
- Merge conflicts use last-writer-wins at the record level
- User preferences (rest duration, weight unit) sync via `NSUbiquitousKeyValueStore`
- The app degrades gracefully when iCloud is unavailable (offline-first)
- Settings displays sync status (synced / syncing / error)
- Requires an iCloud container entitlement (`iCloud.com.stronix.data`)
- Requires US-50 (schema migrations must be stable before enabling sync) and US-49 (JSON backup as fallback)

### Accessibility & Localization

#### US-53: Accessibility Audit and VoiceOver Support

**Status:** Planned

**User story:** As a lifter who uses VoiceOver, I want all controls to be accessible, so that I can use the app effectively.

**Acceptance criteria:**
- The Dragger control has `.accessibilityElement(children: .ignore)` on the container, with `.accessibilityLabel` (e.g., "Weight"), `.accessibilityValue` (e.g., "80 kg"), and `.accessibilityAdjustableAction` for increment/decrement
- All icon-only buttons (timer, tag, add set) have `.accessibilityLabel` values
- The app supports Dynamic Type up to `.accessibility3` without layout breakage
- The activity calendar (US-42) has per-cell accessibility labels (e.g., "Monday April 27, workout completed")
- TODO: define accessibility labels for all icon-only buttons across the app

#### US-54: Localization Foundation

**Status:** Planned

**User story:** As a lifter, I want the app available in my language, so that I can use it without reading English.

**Acceptance criteria:**
- A `Localizable.xcstrings` String Catalog is the single source of truth for all user-facing strings
- All `Text("literal")` calls use SwiftUI's automatic localization lookup via the `.xcstrings` file
- `AppFormatter.date()` uses `Date.FormatStyle` or locale-aware `DateFormatter` (no hardcoded format strings like `"d MMM yyyy 'at' HH:mm"`)
- Number formatting (weights, reps, volume) respects the user's locale decimal separator
- The infrastructure supports adding languages without code changes
- TODO: define initial set of supported languages (at minimum English and Portuguese Brazilian)

#### US-55: Weight Unit Setting

**Status:** Planned

**User story:** As a lifter, I want to choose between kg and lbs, so that I can use my preferred unit system.

**Acceptance criteria:**
- Settings includes a "Weight Unit" picker (kg / lbs)
- All weight displays convert from internal kg to the selected unit
- All weight inputs convert from the selected unit back to kg for storage
- The Dragger step size adapts: 2.5 kg → 5 lbs for barbell, 1 kg → 2.5 lbs for dumbbell
- The unit label in the Dragger reflects the selected unit ("kg" or "lbs")
- The workout summary, history, and share text display weights in the selected unit
- Conversion uses `Measurement<UnitMass>` for precision; display uses appropriate decimal places
- `@AppStorage("weightUnit")` stores the selection

### Delight & Feedback

#### US-56: Haptic and Sound Micro-Rewards on Set Completion

**Status:** Implemented

**User story:** As a lifter, I want satisfying feedback when I complete a set, so that the app reinforces my workout habit.

**Acceptance criteria:**
- `.sensoryFeedback(.success)` fires when a set is marked completed
- System sound 1103 (Tink) plays on set completion via `AudioServicesPlaySystemSound`
- A stronger haptic (`.success` followed by `.impact(.heavy)`) fires on workout save
- A "Sound effects" toggle in Settings (default: on) gates sound playback; stored via `@AppStorage("soundEffectsEnabled")`
- System sounds respect the device silent switch

#### US-57: Dragger Boundary Haptics

**Status:** Implemented

**User story:** As a lifter, I want to feel a haptic when the Dragger hits its minimum value, so that I know I have reached the boundary.

**Acceptance criteria:**
- The Dragger fires `.sensoryFeedback(.error)` when the value is clamped at the minimum boundary (0)
- The boundary haptic fires only once per drag gesture (not continuously while held at boundary)
- The Dragger may support a configurable maximum value with the same boundary feedback

#### US-58: Dragger Audio Feedback

**Status:** Planned

**User story:** As a lifter, I want a subtle sound on each Dragger step change, so that the control feels like a physical dial.

**Acceptance criteria:**
- System sound 1157 (picker tick) plays on each value step change during a drag gesture
- Sound respects the "Sound effects" setting from US-56
- Sound respects the device silent switch
- Sound does not play during keyboard text entry (only during drag gesture)

#### US-59: Unfinished Workout Reminder

**Status:** Planned

**User story:** As a lifter, I want a reminder if I forget about an active workout, so that I do not lose my progress.

**Acceptance criteria:**
- When the app moves to background with an active workout containing ≥1 completed set, a repeating notification is scheduled every 15 minutes: "You have an unfinished workout. Tap to continue."
- The notification is cancelled when the workout is saved or cancelled
- The notification body includes the workout name
- Tapping the notification opens the app to the active workout
- The active workout is persisted to SwiftData on backgrounding to prevent data loss (marked with an `isCurrentWorkout` flag)
- TODO: define resume flow when the app launches with an existing `isCurrentWorkout` workout

#### US-60: Activity Heatmap Dashboard

**Status:** Planned

**User story:** As a lifter, I want to see my recent workout activity on the Home tab, so that I stay motivated and consistent.

**Acceptance criteria:**
- The Home tab displays a 28-day calendar grid showing which days had completed workouts
- Today is visually distinguished with a border ring
- Workout days are filled with the app's accent color
- A 7-day summary row shows workout count, total sets, and total volume in kg
- The "Start Workout" button remains prominent below the dashboard
- Tapping a workout day may navigate to that workout's detail view
- The calendar uses `Calendar.current` for week layout (respects locale's first weekday)
- Workouts are queried from SwiftData with a date predicate (last 28 days, `end != nil`)

### Infrastructure (Planned)

#### US-61: Security and Privacy Hardening

**Status:** Planned

**User story:** As a lifter, I want the app to meet App Store privacy requirements, so that it can be published and my data is protected.

**Acceptance criteria:**
- A valid `PrivacyInfo.xcprivacy` manifest declares all accessed API categories
- The manifest declares `NSPrivacyTracking = false` and an empty `NSPrivacyTrackingDomains` array
- `NSPrivacyAccessedAPICategoryUserDefaults` is declared with reason `CA92.1` (app functionality)
- The SwiftData store uses `FileProtectionType.complete` for at-rest encryption when the device is locked
- The app includes no third-party SDKs requiring privacy manifest entries
- The `ShareLink` content is visible to the user before sharing (preview in summary sheet)

#### US-62: Feature-Flag Infrastructure

**Status:** Planned

**User story:** As a developer, I want to gate unfinished features behind flags, so that I can merge to main without shipping half-done work.

**Acceptance criteria:**
- A `FeatureFlag` enum lists all gated features with default-off values, conforming to `CaseIterable`
- Flags are backed by `UserDefaults` with keys namespaced as `ff_<flag_name>`
- In `DEBUG` builds, a developer settings screen (accessible via long-press on the app version label in Settings) lists all flags with toggles
- In `RELEASE` builds, flags are read-only (no user-facing toggle)
- The feature-flag system introduces no external dependencies
- Flag state is logged on launch via `os.Logger`

#### US-63: Observability — Structured Logging and MetricKit

**Status:** Planned

**User story:** As a developer, I want crash reports and performance metrics, so that I can diagnose issues from TestFlight users.

**Acceptance criteria:**
- A `MetricsManager` class conforms to `MXMetricManagerSubscriber` and is registered with `MXMetricManager.shared` at app launch
- Received `MXDiagnosticPayload` crash reports are logged via `os.Logger` at `.fault` level
- The latest `MXMetricPayload` summary is persisted locally for developer review
- All existing `os.Logger` call sites use appropriate log levels (`.debug`, `.info`, `.error`, `.fault`)
- `os.Signpost` intervals are added around SwiftData fetch operations in `autoFillValues` and `fetchHistory`
- The `Log.navigation` category is used in `NavigationStack` destination changes

#### US-64: CI Pipeline, Linting, and Release Automation

**Status:** Planned

**User story:** As a developer, I want automated builds, tests, and linting, so that regressions are caught before merging.

**Acceptance criteria:**
- An Xcode Cloud workflow builds and runs all tests on every push to `main`
- A TestFlight distribution lane is triggered by version tags (e.g., `v1.1.0`)
- Code style is enforced via SwiftLint or swift-format as a build phase (warning on violations, error on critical rules)
- The linter is not added as a SwiftPM runtime dependency (zero runtime deps preserved)
- TestFlight release notes are auto-generated from git commit history via `ci_scripts/ci_post_xcodebuild.sh`
- The CI workflow fails if any test fails

#### US-65: Test Coverage Expansion and UI Test Scaffolding

**Status:** Planned

**User story:** As a developer, I want comprehensive test coverage, so that complex logic is verified automatically.

**Acceptance criteria:**
- Unit tests exist for `autoFillValues`, `progressiveMatch`, and `fetchHistory` using an in-memory SwiftData container (`TestModelContainer` helper)
- Unit tests exist for `Workout.finish()` verifying uncompleted set removal and empty exercise cleanup
- Unit tests exist for `RestTimer` start, tick, expiry, and UserDefaults persistence (using mock `UserDefaults(suiteName:)`)
- Snapshot tests exist for at least `HomeView`, `CurrentWorkoutView`, and `SetEditorView` using `ImageRenderer`
- A `StronixUITests` target exists with at least one end-to-end smoke test (launch → start workout → add exercise → complete set → finish workout)
- CI enforces a minimum test coverage threshold (target: 60% line coverage)

#### US-66: Accessibility Test Infrastructure

**Status:** Planned

**User story:** As a developer, I want automated accessibility checks, so that VoiceOver regressions are caught in CI.

**Acceptance criteria:**
- UI tests include assertions verifying that the Dragger, "Complete set" button, and timer controls are accessible via VoiceOver (`XCUIElement.isAccessibilityElement`, `.label`, `.value`)
- Snapshot tests include at least one variant at `accessibilityExtraExtraExtraLarge` Dynamic Type size
- The CI pipeline runs `xcrun simctl accessibility audit` (Xcode 15+) and fails on critical violations
- TODO: define the set of "critical violations" that should fail CI vs. produce warnings

#### US-67: Performance — Query Optimization and Pagination

**Status:** Planned

**User story:** As a lifter with a large workout history, I want the app to remain fast, so that logging sets does not slow me down.

**Acceptance criteria:**
- SwiftData fetch operations in `autoFillValues` and `fetchHistory` use `fetchLimit` to cap result size
- The `Workout` model declares a SwiftData `#Index` on the `start` property for date-range queries
- `WorkoutsView` implements pagination (load 20 workouts at a time, load more on scroll)
- The `RestTimer` tick handler is profiled with `os.Signpost` and documented as acceptable
- The app remains responsive (< 100ms for any SwiftData query) with 500+ workouts in the database
- If exercise illustrations are bundled (US-34), decoded images are cached via `NSCache` with a configurable memory limit

## Bugs

Known unintended behavior. Each bug follows the template: id, title, status (Open / Fixed), description, reproduction steps, and suspected cause (when known).

#### BUG-01: Archive History row flickers during swipe-to-delete confirmation

**Status:** Open

**Description:** When swiping a workout row in the Archive tab's History section and tapping Delete, the row disappears, the confirmation alert appears, the row briefly reappears under the alert, then disappears again once the alert is dismissed. The actual deletion only happens when the user confirms, as intended, but the intermediate visual state is jarring.

**Reproduction steps:**
1. Open the Archive tab (must contain at least one workout in the History section)
2. Swipe left on a workout row until the red Delete button appears
3. Tap Delete
4. Observe: row vanishes, alert appears, row flickers back in, then vanishes again

**Affected screens:**
- `ArchiveView` (Archive tab, History section) — confirmed

**Not affected:**
- `WorkoutsView` (the "See all" workouts screen) — same pattern works cleanly
- `ExercisesView` — soft-delete archive works cleanly after the fix that decoupled the alert's `isPresented` binding from the `pendingArchive` optional

**Suspected cause:** Interaction between `.swipeActions` and the `ForEach(workouts.prefix(5))` source in `ArchiveView`. The `prefix(5)` slice may produce a new identity on each render, causing SwiftUI to reconcile the row tree while the swipe gesture is active. A proposed fix is to materialize and explicitly identify the slice (e.g., `ForEach(Array(workouts.prefix(5)), id: \.id)`). Not yet verified. Further investigation may need Instruments (SwiftUI template) to observe the render graph during the gesture.

**Workaround:** None — the deletion still works correctly, only the animation is affected.

## Non-Functional Requirements

- **NFR-01** — Platform: The app targets iOS 17.5 or later, built with Xcode 15.4+ using Swift 5 and SwiftUI.
- **NFR-02** — Platform: The app has zero external dependencies — only Apple SDK frameworks are used.
- **NFR-03** — Platform: Build signing configuration uses `.xcconfig` files; `Local.xcconfig` is gitignored and `Local.example.xcconfig` is provided as a template.
- **NFR-04** — Offline: The app functions fully offline with no network calls; no network entitlements are requested.
- **NFR-05** — Privacy: All user data is stored on-device via SwiftData (SQLite) and UserDefaults; no data is transmitted externally.
- **NFR-06** — Privacy: No analytics, crash reporting, or telemetry frameworks are included.
- **NFR-07** — Privacy: Notification permission is requested only when the rest timer is first started, not at app launch.
- **NFR-08** — Data Storage: Primary storage is SwiftData with on-disk SQLite (default `ModelConfiguration`); secondary storage is UserDefaults for rest timer state and settings.
- **NFR-09** — Data Storage: No schema versioning or migration plan exists — single schema version (v1).
- **NFR-10** — Performance: The `Dragger` control provides immediate visual feedback on drag gestures using `.interactiveSpring` animation.
- **NFR-11** — Performance: Haptic feedback fires on drag value changes (`.sensoryFeedback(.selection)`) and on rest timer expiry (`.sensoryFeedback(.success)`).
- **NFR-12** — Performance: The rest timer ticks at 1-second intervals and restores accurately from UserDefaults after backgrounding.
- **NFR-13** — Accessibility: The app relies on SwiftUI's built-in accessibility support for standard controls; no explicit accessibility modifiers (`.accessibilityLabel`, `.accessibilityHint`, `.accessibilityValue`) are present on any view.
- **NFR-14** — Accessibility: The `Dragger` custom control lacks VoiceOver annotations and is likely unusable with assistive technologies.
- **NFR-15** — Logging: The app uses `os.Logger` with subsystem-based categories: `Persistence` (CRUD operations), `Navigation` (defined but unused), `Workout` (lifecycle events).
- **NFR-16** — Logging: Logs do not include user-identifiable information; weight/rep values are logged for debugging.
- **NFR-17** — Error Handling: A centralized `ErrorHandler` (`@Observable`) displays user-facing error alerts, injected into the SwiftUI environment at the app root via `.withErrorHandler()` on `MainView`.
- **NFR-18** — Error Handling: Save failures in exercise creation/editing trigger an error alert; `ModelContainer` creation failure is a `fatalError`.
- **NFR-19** — Testing: The app uses the Swift Testing framework (`import Testing`) for unit tests.
- **NFR-20** — Testing: 9 test files with ~49 tests cover model logic (init, computed properties, sorting, append, remove, move), formatters, `Sortable`, `SoundEffects` enabled-flag gating, and `Dragger` step math with floor clamping; auto-fill logic, `RestTimer`, `Workout.finish()`, `Workout.shareText`, `RPE` labels, `Tag.shortLabel`, all views, `ErrorHandler`, and integration tests are not covered.

## Roadmap

This roadmap organizes all user stories into delivery waves by priority. Implemented stories are struck through in the Done section. Planned stories are grouped into three waves by impact-to-effort ratio. Future non-functional improvements that do not yet have NFR IDs are listed separately.

### Done

- ~~US-01: Start a New Workout~~
- ~~US-02: Name and Describe a Workout~~
- ~~US-03: Add Exercises to a Workout~~
- ~~US-04: Reorder and Remove Exercises~~
- ~~US-05: Cancel a Workout~~
- ~~US-06: Finish a Workout and View Summary~~
- ~~US-07: Share a Workout as Plain Text~~
- ~~US-08: Save or Cancel from Summary~~
- ~~US-09: Browse Workout History~~
- ~~US-10: View Workout Details~~
- ~~US-11: Delete a Past Workout~~
- ~~US-12: Create an Exercise~~
- ~~US-13: Edit an Exercise~~
- ~~US-14: Archive an Exercise~~
- ~~US-15: Browse Exercises~~
- ~~US-16: Add and Manage Sets~~
- ~~US-17: Edit Set Weight and Reps~~
- ~~US-18: Complete a Set~~
- ~~US-19: Tag a Set~~
- ~~US-20: Record RPE for a Set~~
- ~~US-21: Add a Comment to a Set~~
- ~~US-22: Auto-Fill Weight and Reps from History~~
- ~~US-23: View Inline Exercise History~~
- ~~US-24: Auto-Start Rest Timer on Set Completion~~
- ~~US-25: View Rest Timer Countdown~~
- ~~US-26: Adjust and Control the Rest Timer~~
- ~~US-27: Receive Notification and Haptic on Timer Expiry~~
- ~~US-28: Persist Timer Across App Backgrounding~~
- ~~US-29: Configure Default Rest Duration~~
- ~~US-30: Persist Data with SwiftData~~
- ~~US-31: Cascade Deletes and Relationship Integrity~~
- ~~US-38: Destructive Action Confirmations~~
- ~~US-56: Haptic and Sound Micro-Rewards on Set Completion~~
- ~~US-57: Dragger Boundary Haptics~~

### Planned Waves

| Wave | Items | Theme | Status |
|---|---|---|---|
| Wave 1 | US-41: Flow-Optimized Set Completion Toolbar | In-workout friction | Planned |
| Wave 1 | US-33: Structured Equipment Enum | Data model | Planned |
| Wave 1 | US-42: Sticky Timer Banner | In-workout friction | Planned |
| Wave 1 | US-53: Accessibility Audit and VoiceOver | Accessibility | Planned |
| Wave 1 | US-37: Editable Workout History | Workout enhancements | Planned |
| Wave 1 | US-61: Security and Privacy Hardening | Infrastructure | Planned |
| Wave 1 | US-50: SwiftData Schema Migration Strategy | Infrastructure | Planned |
| Wave 1 | US-51: Data Integrity Validation | Infrastructure | Planned |
| Wave 1 | US-62: Feature-Flag Infrastructure | Infrastructure | Planned |
| Wave 2 | US-60: Activity Heatmap Dashboard | Progress visibility | Planned |
| Wave 2 | US-39: Repeat Workout from History | Workflow efficiency | Planned |
| Wave 2 | US-55: Weight Unit Setting | Internationalization | Planned |
| Wave 2 | US-43: Actionable Rest Timer Notifications | In-workout friction | Planned |
| Wave 2 | US-32: Structured Muscle Group Enum | Data model | Planned |
| Wave 2 | US-36: Median Set Count Auto-Creation | Workflow efficiency | Planned |
| Wave 2 | US-45: Home Screen Widget | Platform reach | Planned |
| Wave 2 | US-54: Localization Foundation | Internationalization | Planned |
| Wave 2 | US-49: JSON Backup and Restore | Data safety | Planned |
| Wave 2 | US-63: Observability — Logging and MetricKit | Infrastructure | Planned |
| Wave 2 | US-64: CI Pipeline and Linting | Infrastructure | Planned |
| Wave 2 | US-65: Test Coverage Expansion | Infrastructure | Planned |
| Wave 3 | US-35: Exercise Statistics with Pinnable Charts | Progress visibility | Planned |
| Wave 3 | US-40: Workout Templates | Workflow efficiency | Planned |
| Wave 3 | US-47: HealthKit Workout Sync | Platform integration | Planned |
| Wave 3 | US-34: Exercise Illustration System | Catalog richness | Planned |
| Wave 3 | US-46: Apple Watch Companion | Platform integration | Planned |
| Wave 3 | US-44: Equipment-Aware Rest Timer Defaults | Personalization | Planned |
| Wave 3 | US-59: Unfinished Workout Reminder | Safety | Planned |
| Wave 3 | US-48: App Intents for Shortcuts | Platform integration | Planned |
| Wave 3 | US-58: Dragger Audio Feedback | Delight | Planned |
| Wave 3 | US-52: iCloud Sync via CloudKit | Data sync | Planned |
| Wave 3 | US-66: Accessibility Test Infrastructure | Infrastructure | Planned |
| Wave 3 | US-67: Performance — Query Optimization | Infrastructure | Planned |

### Known Bugs

- BUG-01: Archive History row flickers during swipe-to-delete confirmation — Open

### Future NFRs

- Wave 1 — App Privacy Manifest (`PrivacyInfo.xcprivacy`) compliance (covered by US-61)
- Wave 2 — Full localization infrastructure with String Catalogs (en, pt-BR)
- Wave 2 — Crash reporting via MetricKit (zero-dependency, OS-delivered diagnostics)
- Wave 2 — Automated CI pipeline with test coverage gates
- Wave 3 — iCloud sync for cross-device data portability
- Wave 3 — Automated accessibility testing in CI (`simctl accessibility audit`)
- Wave 3 — SwiftData query performance optimization with `#Index` and pagination
- Wave 3 — Data-at-rest encryption via `FileProtectionType.complete`
