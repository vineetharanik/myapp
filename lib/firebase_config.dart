import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseConfig {
  static Future<FirebaseApp> initializeFirebase() async {
    // Initialize Firebase
    return await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "your-api-key-here",
        authDomain: "your-project-id.firebaseapp.com",
        projectId: "your-project-id",
        storageBucket: "your-project-id.appspot.com",
        messagingSenderId: "123456789",
        appId: "your-app-id-here",
        measurementId: "your-measurement-id-here",
      ),
    );
  }

  static Future<void> setupFirestoreRules() async {
    final firestore = FirebaseFirestore.instance;

    // Create collections if they don't exist
    await firestore.collection('users').add({'test': 'setup'});
    await firestore.collection('journals').add({'test': 'setup'});
    await firestore.collection('skills').add({'test': 'setup'});
    await firestore.collection('pdfs').add({'test': 'setup'});
  }

  static Future<void> createSampleData() async {
    final firestore = FirebaseFirestore.instance;

    // Sample user data
    await firestore.collection('users').doc('sample-user').set({
      'name': 'Sample User',
      'email': 'sample@example.com',
      'skills': ['Flutter', 'Dart', 'Firebase'],
      'goals': ['Learn Firebase', 'Deploy App'],
      'createdAt': DateTime.now().toIso8601String(),
    });

    // Sample journal entry
    await firestore.collection('journals').add({
      'userId': 'sample-user',
      'text': 'Today I learned about Firebase deployment!',
      'studyHours': 4.0,
      'sleepHours': 7.0,
      'mood': 'excited',
      'date': DateTime.now().toIso8601String(),
      'analysis': {
        'productivity': 85,
        'burnoutRisk': 20,
        'recommendations': ['Keep learning!', 'Take breaks'],
      },
    });

    // Sample skills data
    await firestore.collection('skills').doc('sample-user').set({
      'Flutter': {
        'progress': 75,
        'lastStudied': DateTime.now().toIso8601String(),
      },
      'Dart': {'progress': 80, 'lastStudied': DateTime.now().toIso8601String()},
      'Firebase': {
        'progress': 45,
        'lastStudied': DateTime.now().toIso8601String(),
      },
    });
  }
}
