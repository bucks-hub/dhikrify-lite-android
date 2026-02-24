# Dhikrify Lite 🕌

[![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)](https://github.com/bucks-hub/dhikrify-lite-android/releases)
[![Platform](https://img.shields.io/badge/platform-Android-green.svg)](https://www.android.com/)
[![License](https://img.shields.io/badge/license-MIT-orange.svg)](LICENSE)

**Dhikrify Lite** is an intelligent Islamic Zikr counter app that uses continuous Arabic speech recognition to automatically count your Adhkar. Perfect for keeping track of your daily Zikr without manual counting!

## ✨ Features

- 🎤 **Continuous Speech Recognition** - WhatsApp-style always-on recording
- 🔄 **Real-time Counting** - Instantly detects and counts as you speak
- 📊 **Multiple Phrase Support** - Built-in support for 6 common Zikr phrases
- 🌙 **Background Recording** - Works even when your phone is locked
- 📈 **Statistics Tracking** - Session and total count tracking
- ➕ **Custom Phrases** - Add your own Zikr with voice input
- 🔄 **Auto-Sorting** - Recently detected phrases move to the top
- 🎨 **Minimalist Design** - Clean black and white interface
- 🔒 **Privacy First** - Audio processed on-device, never saved
- 🆓 **Completely Free** - No ads, no subscriptions

## 📱 Screenshots

<!-- TODO: Add screenshots here -->
*Coming soon - Install the app to see it in action!*

## 🕋 Supported Zikr Phrases

The app comes with 6 pre-configured common Zikr phrases:

1. **سبحان الله** (Subhanallah) - Glory be to Allah
2. **الحمد لله** (Alhamdulillah) - Praise be to Allah
3. **الله أكبر** (Allahu Akbar) - Allah is the Greatest
4. **لا إله إلا الله** (La ilaha illa Allah) - There is no god but Allah
5. **أستغفر الله** (Astaghfirullah) - I seek forgiveness from Allah
6. **لا حول ولا قوة إلا بالله** (La hawla wa la quwwata illa billah) - There is no power except with Allah

Plus, you can add unlimited custom phrases with voice input!

## 📥 Installation

### For Users (Easy Install)

1. **Download the APK:**
   - Go to [Releases](https://github.com/bucks-hub/dhikrify-lite-android/releases)
   - Download `Dhikrify-Lite-v1.0.0.apk`

2. **Install:**
   - Open the downloaded APK file
   - If prompted, enable "Install from Unknown Sources"
   - Tap "Install"

3. **Grant Permissions:**
   - Open the app
   - Allow microphone access when prompted
   - Start counting your Zikr!

### For Developers (Build from Source)

**Prerequisites:**
- Flutter SDK (^3.10.8)
- Android Studio / Xcode
- Dart SDK
- Git

**Clone and Build:**

```bash
# Clone the repository
git clone https://github.com/bucks-hub/dhikrify-lite-android.git
cd dhikrify-lite-android

# Get dependencies
flutter pub get

# Generate Hive adapters
flutter pub run build_runner build

# Run on connected device
flutter run

# Build release APK
flutter build apk --release
```

The APK will be in `build/app/outputs/flutter-apk/app-release.apk`

## 🎯 How to Use

1. **Press the Record Button** - Large circular button at the bottom
2. **Start Reciting** - Speak your Zikr phrases clearly in Arabic
3. **Watch Counts Update** - Each phrase is automatically counted in real-time
4. **View Statistics** - Tap the stats icon to see detailed counts
5. **Add Custom Phrases** - Use "Add Phrase" with voice input
6. **Background Mode** - Works even when phone is locked or app is minimized

## 🏗️ Built With

- **Flutter** - Cross-platform UI framework
- **Dart** - Programming language
- **Android Native (Kotlin)** - Continuous speech recognition
- **Hive** - Local database for phrase storage
- **Provider** - State management
- **Speech Recognition API** - Google's Arabic speech recognition
- **Amiri Font** - Beautiful Arabic typography

## 🔧 Technical Details

### Architecture

```
lib/
├── models/          # Data models (Zikr phrases)
├── services/        # Business logic (transcription, storage, matching)
├── providers/       # State management
├── screens/         # UI screens
├── widgets/         # Reusable components
└── utils/           # Utilities (Arabic normalizer, theme, constants)
```

### Native Implementation

- **Android**: Kotlin with `SpeechRecognizer` API for continuous recognition
- **Platform Channels**: Flutter ↔ Native communication
- **Audio Configuration**: Optimized for Arabic speech detection
- **Error Recovery**: Auto-restart on recognition errors

## 📊 App Permissions

- **Microphone** - Required for speech recognition
- **Internet** - Required for Google's speech recognition API
- **Foreground Service** - For background recording
- **Wake Lock** - To keep device awake during recording

**Privacy:** Audio is only used for real-time transcription and is NEVER saved to disk.

## 🤝 Contributing

Contributions are welcome! Here's how:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Ideas for Contributions

- [ ] iOS native implementation
- [ ] Offline speech recognition
- [ ] Export statistics to CSV
- [ ] Dark mode theme option
- [ ] Widget for home screen
- [ ] More default Zikr phrases
- [ ] Multiple language support
- [ ] Cloud backup/sync

## 🐛 Known Issues

- Speech recognition requires active internet connection
- Occasional gaps in continuous recording (auto-restarts within 1 second)
- Arabic recognition accuracy depends on pronunciation

## 📝 Changelog

### Version 1.0.0 (2024-02-23)
- ✨ Initial release
- 🎤 Continuous Arabic speech recognition
- 📊 Session and total count tracking
- ➕ Custom phrase support with voice input
- 🔄 Auto-sorting by recent detection
- 🎨 Minimalist black and white design
- 🌙 Background recording support

## 📧 Contact & Support

- **Issues:** [GitHub Issues](https://github.com/bucks-hub/dhikrify-lite-android/issues)
- **Developer:** bucks-hub

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Built with ❤️ for the Muslim community
- Arabic font: [Amiri Font](https://fonts.google.com/specimen/Amiri)
- Speech recognition powered by Google Cloud Speech API
- Co-developed with Claude Sonnet 4.5

## ⭐ Show Your Support

If you find this app useful, please:
- ⭐ Star this repository
- 🐛 Report bugs
- 💡 Suggest new features
- 🤝 Contribute code
- 📢 Share with friends

---

**Made with 🤲 for continuous Dhikr** | © 2024 Dhikrify Lite
