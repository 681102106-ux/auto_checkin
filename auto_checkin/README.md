# Auto Check-In Application

This Flutter application is designed to facilitate attendance management for classes. Users can create classes, check in for attendance, and manage scores for students.

## Features

- **User Authentication**: Users can log in to access the application.
- **Class Management**: Users can create and edit classes.
- **Attendance Tracking**: Users can check in for classes and manage attendance records.
- **Score Management**: Users can set and manage scores for students.

## Project Structure

```
auto_checkin
├── lib
│   ├── main.dart
│   ├── models
│   │   ├── attendance.dart
│   │   ├── course.dart
│   │   ├── score.dart
│   │   └── student.dart
│   └── screens
│       ├── check_in_screen.dart
│       ├── create_class_screen.dart
│       ├── edit_class_screen.dart
│       ├── home_screen.dart
│       ├── login_screen.dart
│       ├── set_score_screen.dart
│       └── settings_screen.dart
├── pubspec.yaml
└── README.md
```

## Setup Instructions

1. Clone the repository to your local machine.
2. Navigate to the project directory.
3. Run `flutter pub get` to install the necessary dependencies.
4. Use `flutter run` to start the application on your device or emulator.

## Usage Guidelines

- **Login**: Start by logging in to the application.
- **Home Screen**: From the home screen, you can navigate to create classes or set scores.
- **Create Class**: Use the create class screen to add new classes and set initial scores.
- **Edit Class**: Each class will have an edit button to modify class details as needed.
- **Check In**: Users can check in for classes from the check-in screen.
- **Set Scores**: Manage student scores through the set score screen.

## Contributing

Contributions are welcome! Please open an issue or submit a pull request for any enhancements or bug fixes.