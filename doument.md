# Math Spazzel Application Feature Document

## Overview

Math Spazzel is a Flutter-based math and brain-training puzzle application. The app presents short timed levels across multiple puzzle types, tracks level completion, awards stars based on speed, and gives users simple settings for sound, vibration, and themed visuals.

The application is built around three main categories:

- Math Puzzle
- Memory Puzzle
- Train Your Brain

## Main User Flow

1. The user opens the app on the Home screen.
2. The Home screen shows the current coin count, a settings button, and three puzzle categories.
3. The user selects a category.
4. The category screen shows available games with icons, trophy progress, and Play buttons.
5. The user selects a game.
6. The Level Select screen shows available levels, completion state, stars, and locked/unlocked status.
7. The user plays an unlocked level.
8. The gameplay screen loads level data, starts a timer, accepts answers, and shows win or game-over results.
9. On success, the app saves completion in memory, awards stars, unlocks the next level, and adds one coin for the first completion.

## Home Screen Features

- Displays the app heading "Math Games".
- Shows a short subtitle: "Train Your Brain, Improve Your Math Skill".
- Shows the user's current coin count in the top header.
- Provides a Settings button.
- Provides three tappable category cards:
  - Math Puzzle
  - Memory Puzzle
  - Train Your Brain
- Uses animated fade/slide entry effects for a polished launch experience.
- Uses a capped content width so the UI remains phone-like on larger screens.

## Category Features

Each category screen contains:

- A top header with back navigation, coin count, and settings access.
- A title and short description for the selected category.
- A two-column grid of game cards.
- Each game card includes:
  - Game icon
  - Game title
  - Trophy/completed-level count
  - Play button
  - Bounce tap feedback

## Game Categories And Games

### Math Puzzle

| Game | Interaction Type | Timer |
| --- | --- | --- |
| Calculator | Numeric keypad answer | 10 seconds |
| Guess The Sign | Multiple-choice answer | 10 seconds |
| Correct Answer | Multiple-choice answer | 10 seconds |
| Quick Calculation | Numeric keypad answer | 20 seconds |
| Find Missing | Multiple-choice answer | 20 seconds |
| True False | True/false buttons | 20 seconds |
| Complex Calculation | Multiple-choice answer | 20 seconds |
| Dual Game | Two numeric keypad answers | 20 seconds |
| Square Root | Numeric keypad answer | 20 seconds |
| Cube Root | Numeric keypad answer | 20 seconds |
| Root | Numeric keypad answer | 20 seconds |
| Math Grid | Numeric keypad answer in a grid puzzle | 60 seconds |
| Number Pyramid | Numeric keypad answer in a pyramid puzzle | 60 seconds |

### Memory Puzzle

| Game | Interaction Type | Timer |
| --- | --- | --- |
| Mental Arithmetic | Numeric keypad answer, supports negative values | 60 seconds |
| Math Pairs | Match expression cards with equal values | 60 seconds |
| Numeric Memory | Reveal cards that match a target value | 60 seconds |
| Concentration | Flip covered cards and match pairs | 60 seconds |

### Train Your Brain

| Game | Interaction Type | Timer |
| --- | --- | --- |
| Magic Triangle | Place numbers into triangle slots | 60 seconds |
| Picture Puzzle | Solve visual shape equations | 90 seconds |

## Level System

- Most games have 30 levels.
- Number Pyramid has 165 levels.
- Number Pyramid levels are grouped into phase sections loaded from JSON.
- Level 1 is unlocked by default.
- Each next level unlocks only after the previous level is completed.
- Completed levels show:
  - Done badge
  - Filled star rating
  - Highlighted level card
- Locked levels show a lock icon and cannot be opened.

## Gameplay Screen Features

The gameplay screen includes:

- Top game bar with:
  - Back button
  - Game title
  - Hint button where supported
  - Info button placeholder
  - Pause button
- Game panel with:
  - Level number
  - Current score/star count
  - Current coin count
  - Animated circular countdown timer
  - Puzzle display area
- Bottom answer sheet with controls based on the game mode.
- Loading state while level JSON is being read.
- Error state when level data is unavailable.

## Timer And Scoring

- The timer starts only after the level data has loaded.
- The timer pauses while hint and quit dialogs are open.
- If time reaches zero, the round ends with Game Over.
- Stars are awarded only when the level is completed:
  - 3 stars when at least 70 percent of time remains
  - 2 stars when at least 40 percent of time remains
  - 1 star when less than 40 percent remains
- Completion time is shown in the result dialog.

## Progress And Rewards

The app tracks progress in `AppState`:

- Coins
- Completed levels
- Trophy count per game
- Best stars per level
- Best completion time per level
- Sound preference
- Vibration preference
- Dark mode preference

Current behavior:

- The app starts with 45 coins.
- First completion of a level gives 1 coin.
- Replaying a completed level can improve stars and best time.
- Progress is stored in memory for the running app session.

## Hints

- Supported games show a hint button in the gameplay top bar.
- Hints pause the timer while open.
- The app first uses the custom hint from the level JSON when available.
- If a custom hint is not available, the app generates a default hint based on the play mode.
- Hint dialogs do not spend coins in the current implementation.
- Hint button is hidden for Math Pairs, Numeric Memory, and Concentration.

## Pause And Quit

- The pause button opens a quit confirmation dialog.
- The timer pauses while the dialog is displayed.
- The user can:
  - Choose Yes to quit the current game screen
  - Choose No or close the dialog to continue playing

## Result Dialog

After each round, the app shows a result dialog.

When the user wins, it shows:

- "You Win!!!"
- Score/stars
- Completion time
- Filled and empty stars
- Home action
- Share action
- Next-level action when another level exists

When the user loses, it shows:

- "Game Over!!!"
- Restart action
- Share action
- Home action
- Close action returning toward level selection

The share action uses `share_plus` and shares a text result such as the game title, level, and stars earned.

## Answer Controls

The app supports multiple answer input styles:

- Numeric keypad with digits, clear, and backspace.
- Optional negative sign for Mental Arithmetic.
- Multiple-choice answer buttons.
- True and False buttons.
- Magic Triangle number picker.
- Card grid selection for matching and memory games.
- Dual input selection for Dual Game.

## Puzzle Display Types

The app includes custom puzzle displays for:

- Large expression plus answer box.
- Missing-value equation display.
- Centered true/false expression.
- Magic Triangle board with six selectable slots.
- Picture equation rows using circle, triangle, and square drawings.
- Dual Game two-line input display.
- Memory card grids.
- Number Pyramid rows and operators.
- Math Grid row display.

## Sound, Haptics, And Feedback

The feedback system supports:

- Tap sound
- Correct-answer sound
- Wrong-answer sound
- Game-over sound behavior
- Haptic selection click for taps
- Light haptic impact for correct answers
- Stronger vibration for wrong answers and game over

Users can toggle sound and vibration from Settings.

Sound assets:

- `assets/sounds/tick.mp3`
- `assets/sounds/right.mp3`
- `assets/sounds/wrong.mp3`
- `assets/sounds/gameover.mp3`

## Settings Screen

The Settings screen includes:

- Back button
- Sound toggle
- Vibration toggle
- Dark Mode toggle
- Share row
- Rate Us row
- Feedback row
- Privacy Policy row

The Share, Rate Us, Feedback, and Privacy Policy rows are visible UI options. Their tap handlers are placeholders in the current code.

## Visual Design Features

- Uses colorful category themes:
  - Yellow for Math Puzzle
  - Green for Memory Puzzle
  - Purple/blue asset set for Train Your Brain
- Uses SVG and PNG assets for icons, cards, buttons, stars, coins, trophies, and app art.
- Uses custom fonts:
  - Montserrat
  - Poppins
  - OriginalSurfer
  - Moranga
- Uses responsive sizing through `flutter_screenutil`.
- Uses bounce, fade, slide, stagger, shake, and scale animations.
- Uses a max content width through `CappedScaffold` for cleaner large-screen presentation.
- Supports themed asset folders for light and dark visual variants.

## Level Data

All game levels are stored as JSON assets in `assets/levels/`.

Each level can include:

- Level number
- Expression or question text
- Answer
- Choices for multiple-choice games
- Hint
- Custom data such as rows, cards, numbers, target values, and operators

Important loader behavior:

- `loadQuestionFor` loads one level for a selected game.
- `loadLevelGroupsFor` loads grouped level sections, mainly for Number Pyramid.
- Loaded JSON is cached for root bundle reads.

## Technical Stack

- Flutter
- Dart
- Material UI
- `flutter_screenutil` for responsive layout
- `flutter_svg` for SVG rendering
- `flutter_bounceable` for touch feedback
- `audioplayers` for sound effects
- `share_plus` for result sharing

## Main Code Locations

| Area | Path |
| --- | --- |
| App entry | `lib/main.dart` |
| App wrapper and state scope | `lib/app.dart` |
| Home screen | `lib/features/home/presentation/screens/home_screen.dart` |
| Category screens | `lib/features/math_puzzle`, `lib/features/memory_puzzle`, `lib/features/train_brain` |
| Game catalog | `lib/features/games/data/game_catalog.dart` |
| Game model | `lib/features/games/domain/entities/game_config.dart` |
| Level selection | `lib/features/levels/presentation/screens/level_select_screen.dart` |
| Gameplay screen | `lib/features/gameplay/presentation/screens/game_play_screen.dart` |
| Puzzle displays | `lib/features/gameplay/presentation/widgets/puzzle_displays.dart` |
| Level loader | `lib/features/gameplay/data/question_bank.dart` |
| App state | `lib/core/state/app_state.dart` |
| Feedback service | `lib/core/services/app_feedback.dart` |
| Common widgets | `lib/common/widgets/` |
| Level JSON files | `assets/levels/` |

## Current Implementation Notes

- The app is a local Flutter app with in-memory progress state.
- Settings toggles update the app state immediately.
- Dark mode preference is available in state and used for themed asset selection; the main MaterialApp currently uses the light theme.
- Some settings rows are prepared in the UI but do not yet navigate to full feature pages.
- The test suite validates home navigation, level loading, puzzle logic, timer behavior, hints, result dialogs, settings, feedback assets, and overflow behavior on phone-sized screens.
