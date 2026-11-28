---
name: flutter-motion-and-worst-case
description: Use when adding or reviewing animation/motion in a VetMatch screen, or when checking a screen against worst-case data (long Turkish names, empty lists, counts of 0/1, missing optional fields). Flutter translation of Emil Kowalski's platform-neutral motion and "break the UI" principles.
---

# Motion and worst-case data in VetMatch (Flutter)

Adapted from Emil Kowalski's `animate`, `review-animations` and `break-ui` skills
(https://github.com/emilkowalski/skills, MIT). Only the platform-neutral rules are
kept; values are translated to Flutter.

## Motion

### 1. Gate: should it animate at all?

| How often the user sees it | Decision |
| --- | --- |
| Many times a day (tab switch, list scroll, filter chip toggle) | No animation, or near-instant and subtle |
| Occasional (bottom sheet, dialog, snackbar, page push) | Standard motion |
| Rare (first eligibility "havuza girdi", match accepted) | The only place for delight |

Name the purpose before writing code: feedback, spatial consistency (where it came
from / went), state change, bridging a jarring change, or (rare tier only) delight.
No purpose, no animation. Data the user reads (distances, ratings, dates) never moves
for style.

### 2. Ingredients

- Prefer Flutter's built-in transitions (`go_router` page transitions, `showModalBottomSheet`, `SnackBar`, `AnimatedSwitcher`, implicit `Animated*` widgets) before writing an `AnimationController`.
- Animate opacity and transforms (`FadeTransition`, `ScaleTransition`, `SlideTransition`). Avoid animating layout size every frame, except expanding sections (`AnimatedSize`).
- Never scale from 0. Enter from `scale: 0.95` plus opacity 0.
- Curves: entering/exiting `Curves.easeOutQuint` (= cubic-bezier(0.23, 1, 0.32, 1)); moving on screen `Curves.easeInOutQuart` (= (0.77, 0, 0.175, 1)); sheets/drawers `Cubic(0.32, 0.72, 0, 1)`. Never `Curves.easeIn` on UI: it delays the moment the user is watching.
- Durations: press feedback 100–160 ms, small popovers 125–200 ms, menus 150–250 ms, dialogs/sheets 200–500 ms. Other UI stays under 300 ms.
- Interruptible: things the user can trigger twice quickly (toggles, chips) use implicit animations that retarget from the current value, not controllers that restart from zero.
- Exit the way it entered. Deliberate actions (hold to confirm) can be slow; the system's response snaps.
- Group entrances: stagger 30–80 ms between items, never block interaction while it plays.
- Reduced motion: when `MediaQuery.disableAnimationsOf(context)` is true, drop movement and keep only short fades.

Put shared curves and durations in `lib/core/` once and reuse them; don't scatter literals.

## Worst-case data

Demo data is picked to look good. Before calling a screen done, render it with the
realistic worst case for every value it shows (add a fixture next to `lib/data/fake/`
data, don't hand-edit widgets to fake it):

- Long, real Turkish names and clinic names: `Ayşegül Karaosmanoğlu-Büyükçekmeceli`, `Malatya Büyükşehir Kayısı Veteriner Polikliniği ve Acil Hayvan Hastanesi`. Also two-letter names (`Su`).
- Turkish casing: use locale-aware upper/lower case (`i`/`İ`, `ı`/`I`); never `toUpperCase()` on user text for display.
- Missing optional fields (no rejection reason, no clinic phone): omit the line, don't print `null` or a lone dash.
- Counts of 0, 1 and large (`0 yorum`, `1 yorum`, `1.284 yorum`): format numbers with `intl` in `tr_TR`; give every list an empty state that says what to do next.
- Numbers, dates, distances and chip numbers are never truncated.
- Long text in a `Row`: wrap the text in `Expanded`/`Flexible`; decide per field whether it wraps (names, titles) or ends with `TextOverflow.ellipsis` (secondary info) and show the full value on the detail screen.
- Check at the narrowest phone width (320 dp), with system font size at its largest, and in dark mode.

Report what broke as a table (field, worst-case value, what happens, fix) and let the
user decide the cases that have more than one right answer before fixing.
