# PilotEpisode

iOS movie app pulling genres, movie lists, details, trailers, and reviews from TMDB. 100% programmatic UIKit—no Storyboards, no XIBs—split into VIPER modules (`Genre`, `MovieList`, `MovieDetail`).

## Why It's Like This

* **No Storyboard:** Everything is laid out in code with `NSLayoutConstraint`. Easier to read, easier to debug, nothing hidden in XML.
* **Tests that don't crash:** `GenreUnitTests`, `MovieListUnitTests`, and `MovieDetailUnitTests` all run on mock interactors. Async callbacks are handled properly with `XCTestExpectation` so nothing behaves weirdly.

## Where Everything Happened

```
PilotEpisode/
├── Modules/
├──├── Genres
├──├── MovieList/
├──├── MovieDetail/
├── Services/
└── PilotEpisodeTests/
    ├── GenreUnitTests.swift
    ├── MovieListUnitTests.swift
    ├── MovieDetailUnitTests.swift
    └── MockCollections/
```

## Running It
1. Open `PilotEpisode/PilotEpisode.xcodeproj` in Xcode.
2. Rename your credentials template to `Config.plist` and add your TMDB API token.
3. Run on a simulator (`Cmd + R`).
4. Run the tests (`Cmd + U`).

## If I Had More Time
- Add CoreData caching so it handles offline states and pagination smoother.
- Write UI tests for the main navigation flow.
- Add pull-to-refresh and empty/error state illustrations across all modules.
