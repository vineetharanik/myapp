# DevBalance AI - Student Wellness & Academic Performance Tracker

A comprehensive Flutter application designed to help students maintain mental wellness, track academic progress, and optimize study habits through AI-powered insights and personalized recommendations.

## Features

### Dashboard Analytics
- Real-time academic performance metrics
- Study time visualization and trends
- Burnout risk assessment with visual indicators
- Skill development progress tracking
- Weekly planning and goal setting

### Journal & Mood Tracking
- Daily journal entries with AI-powered analysis
- Mood tracking and emotional wellness monitoring
- Personalized AI suggestions based on entries
- Study pattern recognition and optimization

### Skill Development
- Enhanced skill roadmap visualization
- Progress tracking for technical and soft skills
- Personalized learning recommendations
- Achievement milestones and badges

### AI Chatbot Assistant
- 24/7 academic and wellness support
- Study tips and stress management advice
- Personalized recommendations based on user data
- Interactive problem-solving assistance

### Notebook & Study Tools
- Digital notebook for organizing study materials
- Integration with journal entries for comprehensive tracking
- Study session planning and time management
- Resource organization and categorization

### Burnout Prevention
- Comprehensive burnout risk assessment
- Stress level monitoring and alerts
- Wellness recommendations and coping strategies
- Work-life balance optimization

## Technology Stack

### Frontend (Flutter)
- **Framework**: Flutter 3.x (SDK ^3.11.4)
- **Language**: Dart
- **State Management**: StatefulWidget pattern
- **UI Components**: Material Design 3
- **Charts**: Custom Flutter painters and charts

### Backend Services
- **Database**: Firebase Firestore (cloud_firestore: ^5.0.0)
- **Authentication**: Firebase Auth (firebase_auth: ^5.0.0)
- **Storage**: Firebase Storage (firebase_storage: ^12.0.0)
- **Real-time Database**: Firebase Database (firebase_database: ^11.0.0)
- **Core Services**: Firebase Core (firebase_core: ^3.0.0)

### Key Dependencies
- **HTTP Client**: http: ^1.6.0
- **Local Storage**: shared_preferences: ^2.2.2
- **File Handling**: file_picker: ^10.3.10
- **Icons**: cupertino_icons: ^1.0.8

### AI/ML Services
- **Custom Analytics**: Pattern recognition and insights
- **Academic AI**: Personalized recommendations
- **Data Analysis**: Study pattern optimization

### Platform Support
- **Web** (Chrome, Edge, Safari)
- **Windows Desktop**
- **Android**
- **iOS**
- **Linux**
- **macOS**

## Installation & Setup

### Prerequisites
- Flutter SDK (>= 3.0.0)
- Dart SDK (>= 2.17.0)
- Node.js (for web development)
- Git

### Quick Start

1. **Clone the repository**
   ```bash
   git clone https://github.com/vineetharanik/myapp.git
   cd myapp
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Enable Developer Mode** (Windows only)
   ```bash
   start ms-settings:developers
   ```

4. **Run the application**
   ```bash
   # For Web (Chrome)
   flutter run -d chrome
   
   # For Desktop
   flutter run -d windows
   
   # For Mobile
   flutter run
   ```

### Firebase Setup

1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Enable Authentication, Firestore, and Storage
3. Download configuration files and place them in the appropriate directories
4. Update `firebase_options.dart` with your project credentials

## Project Structure

```bash
lib/
├── models/                    # Data models and entities
│   ├── journal_entry.dart
│   ├── burnout_score.dart
│   ├── skill_progress.dart
│   ├── weekly_plan.dart
│   └── journal_analysis.dart
├── screens/                   # UI screens and pages
│   ├── dashboard/            # Main dashboard screens
│   │   ├── dashboard_screen.dart
│   │   ├── correct_dashboard_screen.dart
│   │   ├── enhanced_dashboard_screen.dart
│   │   └── production_dashboard_screen.dart
│   ├── journal/              # Journal and mood tracking
│   │   ├── journal_screen.dart
│   │   ├── daily_journal_screen.dart
│   │   ├── enhanced_journal_screen.dart
│   │   ├── journal_result_screen.dart
│   │   └── production_journal_screen.dart
│   ├── skills/               # Skill development
│   │   ├── skill_roadmap_screen.dart
│   │   └── enhanced_skill_roadmap_screen.dart
│   ├── burnout/              # Burnout prevention
│   │   └── burnout_details_screen.dart
│   ├── chatbot/              # AI assistant
│   │   ├── chatbot_screen.dart
│   │   └── enhanced_chatbot_screen.dart
│   ├── notebook/             # Study tools
│   │   ├── notebook_screen.dart
│   │   └── notebook_screen_local.dart
│   ├── admin/               # Admin tools
│   │   ├── data_viewer_screen.dart
│   │   └── full_database_viewer.dart
│   ├── analytics/           # Analytics and insights
│   │   └── study_analytics_screen.dart
│   ├── login/               # Authentication
│   │   └── login_screen.dart
│   ├── registration/        # User registration
│   │   ├── registration_screen.dart
│   │   └── new_registration_screen.dart
│   ├── settings/            # App settings
│   │   └── settings_screen.dart
│   ├── splash/              # App initialization
│   │   └── splash_screen.dart
│   └── title/               # App title screen
│       └── title_screen.dart
├── services/                  # Business logic and APIs
│   ├── local_storage_service.dart
│   ├── analytics_service.dart
│   ├── api_service.dart
│   ├── auth_service.dart
│   ├── firebase_service.dart
│   ├── firebase_integration_service.dart
│   └── academic_ai_service.dart
├── firebase_config.dart         # Firebase configuration
├── firebase_options.dart        # Firebase options
└── main.dart                   # Application entry point
```

## Key Components

### Dashboard Screen
- **ProductionDashboardScreen**: Main dashboard with comprehensive analytics
- **StudyTimeBarChartPainter**: Custom visualization for study time
- **BurnoutRiskIndicator**: Visual burnout risk assessment
- **SkillProgressChart**: Skill development tracking

### Analytics Engine
- **Pattern Recognition**: Identifies study patterns and trends
- **Risk Assessment**: Calculates burnout and stress levels
- **Recommendation System**: Provides personalized suggestions
- **Progress Tracking**: Monitors academic and wellness metrics

## Development Commands

```bash
# Development
flutter run                    # Run in debug mode
flutter run --release         # Run in release mode
flutter build web             # Build for web deployment
flutter clean                 # Clean build cache

# Testing
flutter test                  # Run unit tests
flutter analyze              # Static code analysis

# Deployment
flutter build apk            # Build Android APK
flutter build ios            # Build iOS app
flutter build web            # Build web app
```

## Analytics & Monitoring

The application includes comprehensive analytics for:
- Study time distribution
- Mood patterns and trends
- Skill acquisition rates
- Burnout risk factors
- Academic performance metrics

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## Documentation

- [Database Guide](DATABASE_GUIDE.md) - Database setup and management
- [Deployment Steps](DEPLOYMENT_STEPS.md) - Application deployment guide
- [Firebase Setup](FIREBASE_DEPLOYMENT_GUIDE.md) - Firebase configuration
- [Troubleshooting](DATABASE_TROUBLESHOOTING.md) - Common issues and solutions
- [Setup Guide](SETUP.md) - Detailed setup instructions
- [Step by Step Guide](STEP_BY_STEP_GUIDE.md) - Comprehensive setup walkthrough
- [Features Complete](FEATURES_COMPLETE.md) - Complete feature documentation
- [Image Placement Guide](figure_placement_guide.md) - Image and media placement
- [Corrected Image Placements](CORRECTED_IMAGE_PLACEMENTS.md) - Updated image references
- [README Complete](README_COMPLETE.md) - Alternative comprehensive documentation

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Flutter team for the amazing framework
- Firebase for backend services
- The open-source community for valuable libraries and tools

## Support

For support and questions:
- Create an issue in the GitHub repository
- Check the [Troubleshooting Guide](DATABASE_TROUBLESHOOTING.md)
- Review the [Setup Documentation](SETUP.md)

---

**Built with ❤️ for student wellness and academic success**
