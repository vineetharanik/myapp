import 'dart:typed_data';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/journal_analysis.dart';
import 'dart:async';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  late FirebaseAuth _auth;
  late FirebaseFirestore _firestore;
  late FirebaseDatabase _realtimeDB;
  late FirebaseStorage _storage;
  User? _currentUser;

  // Initialize Firebase
  Future<void> initialize() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    _auth = FirebaseAuth.instance;
    _firestore = FirebaseFirestore.instance;
    _realtimeDB = FirebaseDatabase.instance;

    // Listen to auth changes
    _auth.authStateChanges().listen((User? user) {
      _currentUser = user;
    });
  }

  // Get current user
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  // Authentication
  Future<UserCredential> signUpWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result;
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  Future<UserCredential> signInWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result;
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  String _handleAuthError(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'weak-password':
          return 'The password provided is too weak.';
        case 'email-already-in-use':
          return 'An account already exists for this email.';
        case 'user-not-found':
          return 'No user found for this email.';
        case 'wrong-password':
          return 'Wrong password provided.';
        case 'invalid-email':
          return 'The email address is not valid.';
        default:
          return 'Authentication failed: ${error.message}';
      }
    }
    return 'Authentication failed: $error';
  }

  // User Profile Management
  Future<void> createUserProfile({
    required String userId,
    required String name,
    required String email,
    required List<String> skills,
    required String goals,
    required Map<String, dynamic> stressAssessment,
  }) async {
    try {
      await _firestore.collection('users').doc(userId).set({
        'name': name,
        'email': email,
        'skills': skills,
        'goals': goals,
        'stressAssessment': stressAssessment,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Initialize skills progress
      for (String skill in skills) {
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('skills')
            .doc(skill)
            .set({
              'skillName': skill,
              'progress': 0.0,
              'createdAt': FieldValue.serverTimestamp(),
              'updatedAt': FieldValue.serverTimestamp(),
            });
      }
    } catch (e) {
      throw Exception('Failed to create user profile: $e');
    }
  }

  Future<DocumentSnapshot> getUserProfile(String userId) async {
    try {
      return await _firestore.collection('users').doc(userId).get();
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }

  // Journal Entries
  Future<String> createJournalEntry({
    required String userId,
    required String text,
    required JournalAnalysis analysis,
  }) async {
    try {
      DocumentReference docRef = await _firestore
          .collection('users')
          .doc(userId)
          .collection('journals')
          .add({
            'text': text,
            'analysis': analysis.toJson(),
            'timestamp': FieldValue.serverTimestamp(),
            'mood': analysis.mood,
            'stressLevel': analysis.stressLevel,
            'burnoutRisk': analysis.burnoutRisk,
          });

      // Update skills progress if mentioned
      if (analysis.skillsProgress.isNotEmpty) {
        await _updateSkillsProgress(userId, analysis.skillsProgress);
      }

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create journal entry: $e');
    }
  }

  Future<List<DocumentSnapshot>> getJournalHistory(
    String userId, {
    int limit = 50,
  }) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('journals')
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs;
    } catch (e) {
      throw Exception('Failed to get journal history: $e');
    }
  }

  Future<DocumentSnapshot?> getLatestJournalEntry(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('journals')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      return snapshot.docs.isNotEmpty ? snapshot.docs.first : null;
    } catch (e) {
      throw Exception('Failed to get latest journal entry: $e');
    }
  }

  // Skills Progress
  Future<void> _updateSkillsProgress(
    String userId,
    Map<String, dynamic> skillsProgress,
  ) async {
    try {
      WriteBatch batch = _firestore.batch();

      skillsProgress.forEach((skillName, progress) {
        DocumentReference skillRef = _firestore
            .collection('users')
            .doc(userId)
            .collection('skills')
            .doc(skillName);

        batch.set(skillRef, {
          'skillName': skillName,
          'progress': progress is int ? progress.toDouble() : progress,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      });

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to update skills progress: $e');
    }
  }

  Future<List<DocumentSnapshot>> getSkillsProgress(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('skills')
          .orderBy('updatedAt', descending: true)
          .get();

      return snapshot.docs;
    } catch (e) {
      throw Exception('Failed to get skills progress: $e');
    }
  }

  // Study Hours Tracking
  Future<void> updateStudyHours({
    required String userId,
    required DateTime date,
    required double hours,
    required double targetHours,
    String? focusQuality,
    String? notes,
  }) async {
    try {
      String dateKey = date.toIso8601String().split('T')[0];

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('studyHours')
          .doc(dateKey)
          .set({
            'date': date,
            'hours': hours,
            'targetHours': targetHours,
            'focusQuality': focusQuality ?? 'medium',
            'notes': notes ?? '',
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to update study hours: $e');
    }
  }

  Future<List<DocumentSnapshot>> getWeeklyStudyHours(
    String userId,
    DateTime weekStart,
  ) async {
    try {
      DateTime weekEnd = weekStart.add(const Duration(days: 7));

      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('studyHours')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(weekStart))
          .where('date', isLessThan: Timestamp.fromDate(weekEnd))
          .orderBy('date')
          .get();

      return snapshot.docs;
    } catch (e) {
      throw Exception('Failed to get weekly study hours: $e');
    }
  }

  // Weekly Plans
  Future<void> saveWeeklyPlan({
    required String userId,
    required DateTime weekStart,
    required Map<String, dynamic> planContent,
  }) async {
    try {
      String weekKey = weekStart.toIso8601String().split('T')[0];

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('weeklyPlans')
          .doc(weekKey)
          .set({
            'weekStart': Timestamp.fromDate(weekStart),
            'planContent': planContent,
            'generatedAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      throw Exception('Failed to save weekly plan: $e');
    }
  }

  Future<DocumentSnapshot?> getCurrentWeeklyPlan(String userId) async {
    try {
      DateTime now = DateTime.now();
      DateTime weekStart = now.subtract(Duration(days: now.weekday - 1));

      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('weeklyPlans')
          .where(
            'weekStart',
            isLessThanOrEqualTo: Timestamp.fromDate(weekStart),
          )
          .orderBy('weekStart', descending: true)
          .limit(1)
          .get();

      return snapshot.docs.isNotEmpty ? snapshot.docs.first : null;
    } catch (e) {
      throw Exception('Failed to get current weekly plan: $e');
    }
  }

  // Real-time chatbot messages
  Stream<DatabaseEvent> getChatbotMessages(String userId) {
    return _realtimeDB.ref('users/$userId/chatbot/messages').onValue;
  }

  Future<void> sendChatbotMessage(String userId, String message) async {
    try {
      String messageId = DateTime.now().millisecondsSinceEpoch.toString();

      await _realtimeDB.ref('users/$userId/chatbot/messages/$messageId').set({
        'id': messageId,
        'message': message,
        'isUser': true,
        'timestamp': ServerValue.timestamp,
      });

      // Trigger AI response (in real implementation, this would call your AI service)
      _triggerAIResponse(userId, message);
    } catch (e) {
      throw Exception('Failed to send chatbot message: $e');
    }
  }

  Future<void> _triggerAIResponse(String userId, String userMessage) async {
    // Simulate AI response delay
    await Future.delayed(const Duration(seconds: 2));

    String response = _generateAIResponse(userMessage);
    String messageId = (DateTime.now().millisecondsSinceEpoch + 1).toString();

    await _realtimeDB.ref('users/$userId/chatbot/messages/$messageId').set({
      'id': messageId,
      'message': response,
      'isUser': false,
      'timestamp': ServerValue.timestamp,
    });
  }

  String _generateAIResponse(String userMessage) {
    final lowerMessage = userMessage.toLowerCase();

    if (lowerMessage.contains('stress') || lowerMessage.contains('stressed')) {
      return "I understand you're feeling stressed. Let me help you with some coping strategies:\n\n1. **Deep Breathing**: Try the 4-7-8 technique - breathe in for 4, hold for 7, exhale for 8.\n2. **Take a Break**: Step away from your studies for 15-20 minutes.\n3. **Progressive Muscle Relaxation**: Tense and release each muscle group.\n\nWould you like me to guide you through a quick relaxation exercise?";
    }

    if (lowerMessage.contains('anxiety') || lowerMessage.contains('anxious')) {
      return "Anxiety can be overwhelming, especially with academic pressures. Here are some immediate strategies:\n\n🧘 **Grounding Technique**: Name 5 things you can see, 4 you can touch, 3 you can hear, 2 you can smell, 1 you can taste.\n\n📝 **Write It Down**: Journaling your thoughts can help process anxiety.\n\n🚶 **Move Your Body**: Even a short walk can reduce anxiety.\n\nHow long have you been feeling this way?";
    }

    if (lowerMessage.contains('burnout') ||
        lowerMessage.contains('burned out')) {
      return "Burnout is serious and requires attention. Here's what I recommend:\n\n🔥 **Immediate Steps**:\n- Take at least one full day off from studying\n- Get 7-9 hours of sleep tonight\n- Connect with friends or family\n\n📊 **Long-term Prevention**:\n- Set realistic study goals\n- Schedule regular breaks\n- Practice saying 'no' to extra commitments\n\nHave you spoken with a counselor about these feelings?";
    }

    if (lowerMessage.contains('study') || lowerMessage.contains('studying')) {
      return "Let me help you create a better study routine:\n\n📚 **Effective Study Techniques**:\n- Pomodoro Technique: 25 min study, 5 min break\n- Active recall instead of passive reading\n- Study at the same time daily\n\n🧠 **Brain Health**:\n- Stay hydrated\n- Get enough sleep\n- Exercise regularly\n\nWhat subject are you finding most challenging right now?";
    }

    if (lowerMessage.contains('help') ||
        lowerMessage.contains('sad') ||
        lowerMessage.contains('depressed')) {
      return "I'm really glad you reached out for help. That takes courage.\n\n🤗 **Immediate Support**:\n- You're not alone in feeling this way\n- These feelings are temporary\n- You've overcome challenges before\n\n📞 **Professional Resources**:\n- Campus counseling services\n- Crisis hotline: 988 (US)\n- Talk to a trusted friend or family member\n\nWould you like me to help you find mental health resources in your area?";
    }

    return "Thank you for sharing that with me. It sounds like you're dealing with a lot right now. Remember that it's okay to not be okay, and taking care of your mental health is just as important as your academic success.\n\nWould you like to talk more about what's on your mind, or would you prefer some general coping strategies?";
  }

  // Notebook LLM Support Methods
  Future<String> uploadPDFFile(
    String userId,
    String fileName,
    List<int> fileBytes,
  ) async {
    try {
      final ref = _storage.ref().child('users/$userId/pdfs/$fileName');
      final uploadTask = ref.putData(Uint8List.fromList(fileBytes));

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload PDF: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getUserPDFs(String userId) async {
    try {
      final snapshot = await _storage
          .ref()
          .child('users/$userId/pdfs')
          .listAll();

      final pdfs = <Map<String, dynamic>>[];
      for (final ref in snapshot.items) {
        final downloadUrl = await ref.getDownloadURL();
        final metadata = await ref.getMetadata();

        pdfs.add({
          'name': ref.name,
          'downloadUrl': downloadUrl,
          'size': metadata.size,
          'uploadedAt': metadata.timeCreated,
        });
      }

      return pdfs;
    } catch (e) {
      print('Error getting user PDFs: $e');
      return [];
    }
  }

  Future<void> saveChatMessage(
    String userId,
    String message,
    bool isBot,
  ) async {
    try {
      await _firestore.collection('users').doc(userId).collection('chats').add({
        'message': message,
        'isBot': isBot,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error saving chat message: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getChatHistory(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('chats')
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
    } catch (e) {
      print('Error getting chat history: $e');
      return [];
    }
  }
}
