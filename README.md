# Flutter SQLite Project

A Flutter application demonstrating SQLite database integration with CRUD operations.

## Features

- ✅ Create, Read, Update, and Delete todos
- 💾 Persistent SQLite database storage
- 🎨 Modern Material Design 3 UI
- 🔄 Swipe to delete functionality
- ☑️ Toggle todo completion status

## Getting Started

### Prerequisites

- Flutter SDK (>=3.0.0)
- Dart SDK

### Installation

1. Install dependencies:
```bash
flutter pub get
```

2. Generate database code (required for Drift):
```bash
flutter pub run build_runner build
```

3. Run the app:
```bash
flutter run
```

**To run on Chrome/Web:**
```bash
flutter run -d chrome
```

## Project Structure

```
lib/
├── main.dart              # Main app entry point and UI
├── database_helper.dart   # SQLite database operations
└── models/
    └── todo.dart         # Todo data model
```

## Database Schema

The app uses a SQLite database with the following schema:

**todos table:**
- `id` (INTEGER PRIMARY KEY AUTOINCREMENT)
- `title` (TEXT NOT NULL)
- `isCompleted` (INTEGER NOT NULL)
- `createdAt` (TEXT NOT NULL)

## Dependencies

- `drift`: Modern SQLite database library for Flutter (supports web via sql.js)
- `sqlite3_flutter_libs`: SQLite libraries for mobile platforms
- `path_provider`: Path utilities for file system access
- `path`: Path manipulation utilities

## Code Generation

This project uses Drift's code generation. After installing dependencies, run:

```bash
flutter pub run build_runner build
```

Or for continuous generation during development:

```bash
flutter pub run build_runner watch
```

## Running on Web (Chrome)

The app now supports web platforms! To run on Chrome:

```bash
flutter run -d chrome
```

Or select Chrome from your device list when running `flutter run`.

## Usage

The app demonstrates a simple todo list with SQLite persistence:

1. **Add Todo**: Tap the floating action button (+) to add a new todo
2. **Toggle Completion**: Tap the checkbox to mark a todo as complete/incomplete
3. **Delete Todo**: Swipe left on a todo item or tap the delete icon
4. **Refresh**: Tap the refresh icon in the app bar to reload todos

## License

This project is open source and available for use.

