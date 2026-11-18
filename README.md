# PilotEpisode

iOS movie app pulling genres, movie lists, details, trailers, and reviews from TMDB. 100% programmatic UIKit—no Storyboards, no XIBs—split into VIPER modules (`Genre`, `MovieList`, `MovieDetail`).

## Why It's Like This

* **No Storyboard:** Everything is laid out in code with `NSLayoutConstraint`. Easier to read, easier to debug, nothing hidden in XML.
* **Tests that don't crash:** `GenreUnitTests`, `MovieListUnitTests`, and `MovieDetailUnitTests` all run on mock interactors. Async callbacks are handled properly with `XCTestExpectation` so nothing weird out.

## Where Everything Lives

```
PilotEpisode/
├── Genre/          # Genre list VIPER stack
├── MovieList/      # Movies by genre VIPER stack
├── MovieDetail/    # Movie details, trailer, and reviews VIPER stack
├── Services/       # TMDB API calls
├── Config.plist    # Drop your TMDB API key here
└── PilotEpisodeTests/
    ├── GenreUnitTests.swift
    ├── MovieListUnitTests.swift
    ├── MovieDetailUnitTests.swift
    └── MockCollections/
```

## Running It
1. Open PilotEpisode/PilotEpisode.xcodeproj in Xcode.
2. Put your TMDB API credentials inside PilotEpisode/Config.plist.
3. Run on a simulator (Cmd + R).
4. Run the tests (Cmd + U).

## If I Had More Time
- Put TMDBService behind a protocol so it can be mocked straight into the real Interactors instead of mocking at the Interactor level.
- Add CoreData caching so it handles offline states and pagination smoother.
- Write UI tests for the navigation flow.
