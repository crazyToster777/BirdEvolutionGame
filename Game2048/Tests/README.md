# Game2048 Tests

This directory contains unit tests for the Game2048 application.

## Test Files

### Game2048ModelTests.swift
Tests for the core game logic (`Game2048Model`):
- Game initialization
- Move logic in all directions (left, right, up, down)
- Tile merging
- Win condition (reaching 2048)
- Game over detection
- Random tile generation
- Edge cases (multiple merges, consecutive tiles)

### Game2048ViewModelTests.swift
Tests for the view model (`Game2048ViewModel`):
- Initialization and game state
- Move handling and score updates
- Best score persistence
- Game over and win state management
- Game reset functionality
- Combine publishers

## Running Tests

### Using Xcode
1. Open the project in Xcode
2. Press `Cmd + U` to run all tests
3. Or select individual test methods and press `Cmd + U`

### Using Command Line
```bash
xcodebuild test -scheme Game2048 -destination 'platform=iOS Simulator,name=iPhone 15'
```

## Test Coverage

The tests cover:
- ✅ Core game mechanics
- ✅ State management
- ✅ Win/lose conditions
- ✅ Score tracking
- ✅ Edge cases and boundary conditions

## Notes

- Tests use XCTest framework
- ViewModel tests use Combine for async testing
- All tests are isolated and independent
- Mock data is used to ensure deterministic results
