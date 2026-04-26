# `main` vs `claude` — Feature Comparison

Snapshot taken **2026-04-23**.

- `main` @ `cfe80bf` "Rubiks and timer view" (Kennard's working branch)
- `claude` @ `d79c7a1` "Redesign all views with unified palette" (redesign branch)

The `claude` branch forked from `main` at `05150bd` ("remove testing") and contains a full UI/UX overhaul of every screen plus a new shared `Palette` file. `main` subsequently received two commits from Kennard (`7ea8c8b`, `cfe80bf`) that are **not** on `claude` — those are listed in the final section so nothing is lost.

---

## 1. New file — `Palette.swift`

Only exists on `claude`. A tiny constants enum that gives every view a shared color vocabulary.

- 4 feature accents, one per mode, spaced around the color wheel:
  - `stopwatch` — amber
  - `timer` — violet
  - `rubiks` — teal
  - `chess` — indigo
- 4 neutrals for immersive dark screens: `ink` (near-black bg), `paper` (white), `chalk` (55% white text), `smoke` (12% white chips/dividers).

Every other view on `claude` consumes these tokens, so changing one value re-themes the whole app.

---

## 2. `ContentView.swift` — Home / main menu

| Aspect | `main` | `claude` |
| --- | --- | --- |
| Layout | Segmented picker (Stopwatch/Timer) on top, Rubik's + Chess stacked below as full-width `.bordered` buttons | 2×2 gradient card grid in two labeled sections: **CLOCKS** and **GAMES** |
| Entry to Stopwatch/Timer | Picker toggle embedded in the home screen | Dedicated `NavigationLink` cards — each clock pushes its own screen |
| Card design | System bordered buttons with `.glassEffect()` | 170pt min-height cards with per-mode `LinearGradient`, 40pt SF Symbol, bold title + subtitle, 24pt corner radius, soft shadow |
| Press feedback | None | Custom `CardButtonStyle` — spring scale to 0.97 on press |
| Hero / intro | Title only ("Game Clock") | "Four ways to time." headline + tagline "Everyday clocks and two dedicated game modes." |
| Section labels | Only "Games" | Both "CLOCKS" and "GAMES" with tracked caption styling (matches iOS section-header conventions) |
| Background | Default | `systemGroupedBackground` so the gradient cards pop |
| Nav title | "Game Clock" (large) | "GameClock" |

---

## 3. `StopwatchView.swift` — Count-up clock

| Aspect | `main` | `claude` |
| --- | --- | --- |
| Tick source | `Timer.scheduledTimer` every 0.01s updating a `displayTime: String` | `TimelineView(.animation(paused: !isRunning))` — no manual timer, SwiftUI drives the redraw |
| Time display | 64pt thin, not monospaced | 84pt thin, `.monospacedDigit()`, scales down on narrow screens |
| Format bug on `main` | Reset writes `"00:00.00"` but the initial state and running display use `"00.00.00"` (dot instead of colon) | Single `format()` helper used everywhere — always `mm:ss.xx` |
| Pause behaviour on `main` | "pause" accumulates `finalTime += ...` but the formatter reads `finalTime + Date().timeIntervalSince(startTime)` only `isRunning`, producing drift after resume | `accumulated` is updated only on pause; running value is `accumulated + now - startTime` — resume is exact |
| Buttons | Play/Pause + Reset (colored backgrounds: green / red / blue) | 80pt circular buttons with subtle tinted fills and strokes in `Palette.stopwatch` (amber) |
| Reset disabled state | Not disabled when nothing to reset | Dimmed + `.disabled` when `accumulated == 0 && !isRunning` |
| Haptics | None | Medium impact on start/pause, warning notification on reset |

---

## 4. `TimerView.swift` — Countdown

| Aspect | `main` | `claude` |
| --- | --- | --- |
| Input | 3 wheel pickers bound to a single `duration` TimeInterval via computed `Binding`s | 3 wheel pickers bound to separate `hours`/`minutes`/`seconds` state (simpler) |
| Labels | "hrs" / "min" / "sec" inside the picker rows | External "hours"/"min"/"sec" labels next to each wheel |
| Tick source | `Timer.scheduledTimer` every 1.0s decrementing duration | `TimelineView(.animation(paused: isPaused))` reading `endDate.timeIntervalSince(ctx.date)` — drift-free, sub-second smooth |
| Pause / resume | Not supported — only Start and Stop/Reset | Pause + Resume + Cancel — full lifecycle |
| Progress ring | None | Circular progress ring around the countdown: `Circle().trim(from: 0, to: progress)` stroked with a `Palette.timer` `LinearGradient`, rotated -90° |
| Countdown text | 80pt thin monospaced inside a plain `VStack` | 58pt thin monospaced inside a 260×260 ring, with "Paused" caption when paused |
| Format | Always `HH:MM:SS` | `mm:ss` under an hour, `h:mm:ss` at or above — matches system Timer app |
| Buttons | "Start" (green circle) and "Stop" (red circle) | Circular Cancel + Start/Pause/Resume using `Palette.timer` tinted backgrounds; primary label swaps based on state |
| Empty-state affordance | Stop disabled only when `duration == 0` | Both buttons dim to 0.4 opacity and disable until time is set |
| Finish feedback | None | Success notification haptic |
| Animations | `.animation(.default, value: isRunning)` | Spring transition between picker ↔ countdown views |

---

## 5. `RubiksView.swift` — Cube-solve timer

| Aspect | `main` | `claude` |
| --- | --- | --- |
| Sensor pads | Two 800pt circles inside 400pt-wide frames; left one is mirror-flipped with `scaleEffect(x: -1)` | Two circles sized via `GeometryReader` (`geo.size.height * 1.4` in `geo.size.width * 0.5` frames) — scales across iPad/iPhone |
| Sensor tint | `.yellow` idle, `.green` when ready | `Palette.paper` idle, `Palette.rubiks` (teal) when ready |
| Page background | Default system | `Palette.ink` edge-to-edge dark canvas |
| Time display | 80pt bold monospaced | 108pt bold monospaced, with a spring scale-up to 1.08 on finish (celebration pulse) |
| Time text color | `.primary` running, `.yellow` ready, `.red` finished | `Palette.paper` running, `Palette.rubiks` ready/finished |
| Status line | Plain `.headline` secondary text | Tracked caption inside a tinted capsule "chip" with `Palette.rubiks`-tinted background and stroke |
| Best-time memory | None | `@AppStorage("rubiks.bestTime")` — persists across launches |
| "NEW BEST" feedback | None | Trophy-icon capsule chip appears under the timer when the solve beats the stored best |
| Best-time display | None | "BEST m:ss.xx" chip visible on idle/finished when a record exists |
| History | `RubiksResult` struct defined, `history` array populated but never shown; empty `RubiksHistoryView` file stub | History path not built yet — time is shown only for the current solve |
| Info / onboarding | Book-icon button that is wired to an empty action | `info.circle` button opens a `.sheet(.medium)` explainer with 3 teal-icon `Label` rows and a "Got it" button |
| Reset button | Visible arrow.trianglehead button bottom-center | No manual reset — flow is: finish → both-up returns to idle automatically |
| Top chrome | None | Landscape-safe top bar: 44pt glass back chevron (left), glass info button (right) — navigation bar hidden |
| Haptics | Medium impact on ready and finish | Medium on start, success on new best, heavy on normal finish |
| Gesture sensor | Internal `SensorView` mirrored via scaleEffect | Cleaner `SensorPad` helper (no mirroring needed — layout does it) |
| Landscape lock | `.landscapeRight` + idle timer disabled | `.landscapeRight`, nav bar hidden, `ignoresSafeArea()` |
| Timer text animation | None | Celebration spring on finish, smooth text via `TimelineView` |

---

## 6. `ChessView.swift` — Two-player chess clock

| Aspect | `main` | `claude` |
| --- | --- | --- |
| Starting time | Hard-coded `3600.0` per side | Presets: **1 / 3 / 5 / 10 / 15 / 30 min** chosen in a setup overlay |
| Increment (Fischer bonus) | Not supported | Presets: **No bonus / +2s / +5s / +10s** — selected bonus is added to the side that just completed a move |
| Move counters | Not tracked | Per-side move count displayed under the time ("N moves") |
| Setup screen | None — starts at 01:00:00 on each side | Dedicated `setupOverlay` with crown icon, title, two chip rows (GAME LENGTH, INCREMENT PER MOVE), Play button, and a "Tap the active clock to pass turn." hint |
| Time format | Always `mm:ss` | `mm:ss` normally, switches to `s.x` tenths once under 10 seconds (matches pro chess clocks) |
| Low-time visual | None | Active side flashes red once time ≤ 10s |
| Active side indicator | White background on active, gray.opacity(0.3) on inactive, black text | `Palette.paper` active / `Palette.smoke` inactive, plus an `Palette.chess` (indigo) capsule bar anchored to the bottom of the active half |
| Background | `.black.opacity(0.45)` behind the two halves, no page treatment | `Palette.ink` full-screen, halves clipped to a 40pt rounded rectangle with 10pt padding |
| Tick interval | `0.01s` | `0.05s` (still visually smooth, lighter on CPU) |
| Time-out / winner screen | None — clock just keeps ticking to negative | Dedicated `gameOverOverlay`: crown icon, "Time's up", winner name ("Left wins" / "Right wins"), Play Again button, error haptic |
| Pause indication | No badge | Top-anchored "PAUSED" capsule with pause icon + tracked caption |
| Controls | Play/Pause + Stop nested in `GlassEffectContainer` | Same pattern but sized smaller (56pt), animated reveal of the Stop button only when paused, `Palette.chess` tint on Play |
| Back chevron | Not present (nav bar relied on system) | 44pt glass back chevron top-left, nav bar hidden for an immersive landscape feel |
| Haptics | None | Medium impact on start and on each move tap, error notification on time-out |
| Landscape forcing | `landscapeRight` on appear | Same, plus nav bar hidden and cleanup on disappear |

---

## 7. Cross-cutting UX / polish on `claude` only

- **Unified palette** via `Palette.swift`, applied to every screen.
- **Drift-free timekeeping** — countdown and count-up both use `TimelineView` with `endDate`/`accumulated` math; `main` relies on recurring `Timer` ticks that accumulate rounding error.
- **Haptic language**: medium for actions, success for wins, error for losses, warning for destructive resets — consistent across views.
- **Monospaced digits** everywhere a number counts, preventing layout jitter.
- **Landscape-immersive game screens** — both Rubik's and Chess hide the navigation bar and provide their own back chevron (glass button, 44pt hit target).
- **State-driven disabled / dimmed buttons** (Stopwatch Reset, Timer Cancel/Start) instead of always-enabled controls.
- **Single-source formatters** — each view has one `format()` helper, so the displayed time can't disagree with itself (fixes the `"00.00.00"` vs `"00:00.00"` bug in `main`'s Stopwatch).
- **Reusable `chip()` helper** in ChessView for the setup pills.
- **Press-scale animation** on home-screen cards.
- **Progress ring** around the Timer countdown.
- **Best-time persistence** in Rubik's via `@AppStorage`.

---

## 8. Things on `main` that `claude` does NOT have yet

Because `claude` forked before Kennard's latest two commits, the following exist on `main` but are missing on `claude`:

- **`RubiksHistoryView.swift`** — stub file with a `RubiksResult` model (id, rubiksTime, date) and an empty view. Kennard has begun scaffolding a history/log screen for past solves; `claude`'s Rubik's redesign tracks only the single best time via `@AppStorage`, not a full history list.
- **Rubik's in-memory history array** — `main`'s `RubiksView` inserts each finished solve into a `[RubiksResult]` array (not displayed yet).
- **Timer wheel bindings using a single `duration`** — `main` stores one `TimeInterval` and derives hours/min/sec through computed `Binding`s; `claude` uses three independent `@State` ints. Functionally equivalent for the user, but `main`'s shape is what the history view would eventually read from.
- **Rubik's 2-digit minutes formatter** (from commit `7ea8c8b`) — `main`'s format is `%02d:%02d.%02d`; `claude`'s is also `%01d:%02d.%02d` — trivial difference, note-worthy only because it came from Ken's latest commit.
- **`WorkspaceSettings.xcsettings` + `Breakpoints_v2.xcbkptlist`** — Xcode workspace / debugger metadata added in Ken's commits. Non-functional, personal to Kennard's machine.

If the `claude` work is ever merged back, these items either need to be preserved by merging (not rebasing onto an older main) or consciously re-adopted — in particular the `RubiksHistoryView` scaffold, if it's something Kennard wants to keep building on.

---

## 9. File-by-file change footprint

```
GameClock_CH2/ChessView.swift           +459  (full rewrite, ~3.5× original)
GameClock_CH2/ContentView.swift         +185  (full rewrite)
GameClock_CH2/Palette.swift             +23   (new file)
GameClock_CH2/RubiksView.swift          +353  (full rewrite)
GameClock_CH2/StopwatchView.swift       +160  (full rewrite)
GameClock_CH2/TimerView.swift           +288  (full rewrite)
GameClock_CH2/RubiksHistoryView.swift   —     (absent on claude; present on main)
```

Total: 1015 insertions, 514 deletions across 11 files (including Xcode workspace metadata).
