# 🚀 Firebase Deployment & Database Setup Guide

## 📋 Step 1: Create Firebase Project

### 1. Go to Firebase Console
- Visit: https://console.firebase.google.com/
- Click **"Add project"**
- Enter project name: `devbalance-app`
- Enable **Google Analytics** (optional)
- Click **"Create project"**

### 2. Add Web App to Project
- In your Firebase project, click **"Add app"**
- Select **"Web"** (</> icon)
- App nickname: `DevBalance Web App`
- Click **"Register app"**
- Copy the **Firebase SDK configuration** (we'll use this next)

## 🔧 Step 2: Update Firebase Configuration

### 1. Replace FirebaseConfig with your actual config:
```dart
// In lib/firebase_config.dart
static Future<FirebaseApp> initializeFirebase() async {
  return await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "YOUR_ACTUAL_API_KEY",
      authDomain: "your-project-id.firebaseapp.com",
      projectId: "your-project-id",
      storageBucket: "your-project-id.appspot.com",
      messagingSenderId: "YOUR_SENDER_ID",
      appId: "YOUR_APP_ID",
      measurementId: "YOUR_MEASUREMENT_ID",
    ),
  );
}
```

### 2. Update main.dart to use Firebase:
```dart
import 'package:flutter/material.dart';
import 'firebase_config.dart';
import 'screens/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseConfig.initializeFirebase();
  await FirebaseConfig.setupFirestoreRules();
  runApp(const DevBalanceApp());
}
```

## 🗄️ Step 3: Firestore Database Setup

### 1. Create Collections
Your app will automatically create these collections:
- `users` - User profiles and settings
- `journals` - Journal entries with AI analysis
- `skills` - Skills progress tracking
- `pdfs` - Uploaded PDF documents

### 2. Set Firestore Security Rules
Go to **Firestore Database → Rules** and set:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### 3. Create Indexes
Go to **Firestore Database → Indexes** and create:
- `journals` collection: `userId` (ascending), `date` (descending)

## 🚀 Step 4: Deploy to Firebase Hosting

### 1. Install Firebase CLI
```bash
# Install Node.js first (if not installed)
# Then install Firebase CLI
npm install -g firebase-tools
```

### 2. Login to Firebase
```bash
firebase login
```

### 3. Initialize Firebase Hosting
```bash
firebase init hosting
```
- Select your Firebase project
- Set public directory as `build/web`
- Configure as single-page app: **Yes**
- Overwrite index.html: **No**

### 4. Deploy
```bash
# Build the Flutter web app
flutter build web --web-renderer canvaskit

# Deploy to Firebase
firebase deploy
```

## 📊 Step 5: View Your Database

### 1. Firebase Console
- Go to: https://console.firebase.google.com/
- Select your project
- Click **"Firestore Database"**

### 2. View Collections
You'll see:
- `users` - User profiles
- `journals` - Daily journal entries
- `skills` - Skills progress
- `pdfs` - Uploaded documents

### 3. Sample Data Structure
```json
// users/{userId}
{
  "name": "John Doe",
  "email": "john@example.com",
  "skills": ["Flutter", "Dart"],
  "goals": ["Learn Firebase"],
  "createdAt": "2024-04-04T10:00:00Z"
}

// journals/{journalId}
{
  "userId": "user123",
  "text": "Today I learned Firebase!",
  "studyHours": 4.0,
  "sleepHours": 7.0,
  "mood": "excited",
  "date": "2024-04-04T10:00:00Z",
  "analysis": {
    "productivity": 85,
    "burnoutRisk": 20
  }
}

// skills/{userId}
{
  "Flutter": {
    "progress": 75,
    "lastStudied": "2024-04-04T10:00:00Z"
  },
  "Dart": {
    "progress": 80,
    "lastStudied": "2024-04-04T10:00:00Z"
  }
}
```

## 🔍 Step 6: Monitor Your App

### 1. Real-time Database View
- Watch data changes in real-time
- See journal entries as users create them
- Monitor skills progress updates

### 2. Analytics
- Go to **Analytics** tab in Firebase Console
- Track user engagement
- Monitor app performance

### 3. Storage (for PDFs)
- Go to **Storage** tab
- View uploaded PDF files
- Monitor storage usage

## 🎯 Quick Start Commands

```bash
# Build and deploy
flutter build web --web-renderer canvaskit
firebase deploy

# View logs
firebase logs

# Open console
firebase open console

# View deployed app
firebase open hosting:site
```

## 📱 Your Live App URL
After deployment, your app will be available at:
`https://your-project-id.web.app`

## 🔐 Authentication Setup (Optional)

To enable user authentication:
1. Go to **Authentication** in Firebase Console
2. Enable **Email/Password** sign-in method
3. Enable **Google** sign-in method
4. Update your app to use FirebaseAuth

---

**🎉 Your app will be live with Firebase backend!**
