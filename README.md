# Protein Tracker

A modern, user-friendly Flutter application for tracking daily protein intake. Built with Material Design 3 and supporting multiple languages.

![Protein Tracker](https://raw.githubusercontent.com/yourusername/protein_tracker/main/screenshots/app_preview.png)

## Features

- 📊 Track daily protein intake with a beautiful circular progress indicator
- 🎯 Set and adjust daily protein goals
- 📝 Add protein entries with custom sources
- 🔄 Quick access to recent entries
- 📱 Modern Material Design 3 UI
- 🌍 Multi-language support:
  - English
  - German (Deutsch)
  - French (Français)
  - Spanish (Español)
  - Italian (Italiano)
  - Portuguese (Português)
  - Japanese (日本語)
- 🎨 Customizable app color theme
- 📅 View history of past entries
- ✏️ Edit and delete entries
- 💾 Persistent storage of data

## Getting Started

### Prerequisites

- Flutter SDK (3.32.0 or higher)
- Dart SDK (3.0.0 or higher)
- Android Studio / VS Code with Flutter extensions

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/protein_tracker.git
```

2. Navigate to the project directory:
```bash
cd protein_tracker
```

3. Install dependencies:
```bash
flutter pub get
```

4. Run the app:
```bash
flutter run
```

## Usage

### Adding Protein Entries
- Tap the "+" button to add a new protein entry
- Enter the protein source (optional)
- Enter the protein amount in grams
- Tap "Add Entry" to save

### Managing Entries
- Long press any entry to edit or delete
- View your daily progress in the circular indicator
- Access your history through the history icon in the app bar

### Settings
- Access settings through the gear icon in the app bar
- Adjust your daily protein goal
- Change the app's color theme
- Select your preferred language

## Development

### Project Structure
```
lib/
  ├── main.dart           # Main application file
  ├── generated/          # Generated localization files
  └── assets/
      └── translations/   # Localization files
          ├── app_en.arb  # English translations
          ├── app_de.arb  # German translations
          └── ...
```

### Building for Production

To build the release APK:
```bash
flutter build apk --release
```

The APK will be located at:
```
build/app/outputs/flutter-apk/app-release.apk
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Flutter team for the amazing framework
- Material Design team for the beautiful design system
- All contributors who have helped improve the app
