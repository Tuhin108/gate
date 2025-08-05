# 🚪 Gate Survey App

> A comprehensive Flutter mobile application for professional gate installation surveying and planning

[![Flutter](https://img.shields.io/badge/Flutter-3.x-blue?style=flat-square&logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-blue?style=flat-square&logo=dart)](https://dart.dev)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-lightgrey?style=flat-square)](https://flutter.dev/docs/development/tools/sdk/release-notes)

## 📖 Overview

Gate Survey App is a professional mobile application designed for contractors, surveyors, and installers to efficiently conduct comprehensive gate installation surveys. The app streamlines the process of collecting measurements, capturing site photos, and generating intelligent recommendations for both sliding and swing gate installations.

## 🔥 Download the App 
*Head to Apk Folder and You will find "app-release.apk", Download the file, Install it and you are good to go...*

## ✨ Key Features

### 🎯 **Smart Survey System**
- **Dual Gate Types**: Complete support for sliding and swing gate surveys
- **Intelligent Recommendations**: AI-powered gate type suggestions based on measurements
- **Visual Documentation**: Integrated camera functionality for site photography
- **Image Superimposition**: Overlay gate drawings on site photos for better visualization

### 📊 **Professional Data Management**
- **CSV Export**: Export all survey data to CSV format for external processing
- **Structured Data Storage**: Organized survey data with comprehensive details
- **Survey History**: Track and review all completed surveys
- **Data Persistence**: Reliable local storage of survey information

### 🎨 **Modern User Interface**
- **Material Design**: Clean, professional interface following Material Design principles
- **Intuitive Navigation**: Easy-to-use screens with logical flow
- **Responsive Layout**: Optimized for various screen sizes
- **Visual Feedback**: Clear indicators and recommendations display

## 📱 Screenshots

*Coming Soon - Screenshots will be added once the app is built*

## 🏗️ Architecture

### **Project Structure**
```
lib/
├── main.dart                 # App entry point
├── models/
│   └── survey_data.dart     # Data models for gate surveys
├── screens/
│   ├── home_screen.dart     # Main dashboard
│   ├── sliding_gate_survey_screen.dart
│   └── swing_gate_survey_screen.dart
├── widgets/
│   ├── dimension_input.dart # Custom input widgets
│   ├── image_input.dart
│   ├── gate_recommendation.dart
│   └── superimpose_image_input.dart
└── utils/
    └── gate_logic.dart      # Business logic for recommendations
```

### **Data Models**
- **Abstract Base Class**: `GateSurveyData` for common properties
- **Sliding Gates**: `SlidingGateSurveyData` with parking space and direction
- **Swing Gates**: `SwingGateSurveyData` with opening angles and directions

## 🚀 Getting Started

### **Prerequisites**
- Flutter SDK 3.x or higher
- Dart SDK 3.x or higher
- Android Studio / VS Code with Flutter extensions
- Android device/emulator or iOS device/simulator

### **Installation**

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/gate-survey-app.git
   cd gate-survey-app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Add app logo**
   - Place your logo image in `assets/images/logo.png`

4. **Run the application**
   ```bash
   flutter run
   ```

### **Building for Production**

**Android APK:**
```bash
flutter build apk --release
```

**Android App Bundle:**
```bash
flutter build appbundle --release
```

**iOS:**
```bash
flutter build ios --release
```

## 📋 Usage Guide

### **Creating a Survey**

1. **Launch the App**: Open Gate Survey App from your device
2. **Choose Gate Type**: Select either "Sliding Gate Survey" or "Swing Gate Survey"
3. **Capture Site Photo**: Take or select a photo of the installation location
4. **Enter Measurements**: Input all required dimensions and specifications
5. **Set Parameters**: Configure opening directions, angles, and special provisions
6. **Get Recommendation**: Tap "Get Gate Recommendation" for AI-powered suggestions
7. **Superimpose Drawing**: Optionally overlay gate drawings on the site photo
8. **Save Survey**: Complete and save your survey data

### **Managing Surveys**

- **View History**: All completed surveys appear on the home screen
- **Export Data**: Use the download button to export surveys as CSV
- **Review Details**: Tap any survey item to view recommendations

## 🔧 Key Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `image_picker` | ^1.1.0 | Camera and gallery image selection |
| `path_provider` | ^2.1.3 | Local file system access |
| `csv` | ^5.1.1 | CSV file generation and export |
| `path` | ^1.9.0 | File path manipulation utilities |

## 🤖 CI/CD Pipeline

The project includes GitHub Actions workflow for automated Android builds:

- **Triggers**: Push to main branch, Pull requests
- **Build Process**: Flutter setup, dependency installation, APK generation
- **Artifacts**: Automatic upload of release APK files

## 🎯 Gate Recommendation Logic

### **Sliding Gates**
- **Double Sliding**: Large openings (>6m) with adequate parking space (>3m)
- **Single Sliding**: Standard openings (>3m) with moderate parking space (>1.5m)
- **Compact Sliding**: Small openings (≤3m) with limited parking space (>1m)

### **Swing Gates**
- **Double Swing**: Wide openings (>4m) with full opening angles (≥90°)
- **Single Swing**: Standard openings (>2m) with adequate opening angle (≥90°)
- **Compact Swing**: Small openings (≤2m) with limited opening angles (<90°)


## 🤝 Contributing


### **Development Guidelines**
- Follow Flutter/Dart style guidelines
- Maintain comprehensive documentation
- Include unit tests for new features
- Ensure responsive design across devices


## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Material Design team for design principles
- Open source community for invaluable packages and tools

---

<div align="center">

**Made by Tuhin with ❤️ for the construction and installation industry**



</div>
