# ExpensePro

A professional expense tracker application built with Flutter.

## Features
- **Clean Architecture**: MVVM pattern with Provider.
- **Local Storage**: Hive for offline persistence.
- **Localization**: English and Bengali support.
- **Theme**: Light and Dark mode.
- **Dashboard**: Summary cards and transaction list.

## Getting Started

1.  **Install Dependencies**:
    ```bash
    flutter pub get
    ```

2.  **Generate Code (Hive Adapters & Localization)**:
    ```bash
    flutter pub run build_runner build --delete-conflicting-outputs
    ```
    *Note: You might need to run this whenever you change models annotated with @HiveType.*

3.  **Run the App**:
    ```bash
    flutter run
    ```

## Project Structure
- `lib/models`: Data models (Transaction, Category, User).
- `lib/viewmodels`: State management (Providers).
- `lib/views`: UI Screens and Widgets.
- `lib/services`: Data services (Hive, Auth).
- `lib/utils`: Constants, Theme, Colors.
- `lib/l10n`: Localization files (.arb).

## Dependencies
- provider
- hive_flutter
- intl
- fl_chart
- uuid
- google_fonts
