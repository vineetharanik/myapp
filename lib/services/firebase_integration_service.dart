import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/local_storage_service.dart';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final LocalStorageService _localStorage = LocalStorageService();

  // User Management
  static Future<String?> getCurrentUserId() async {
    final user = _auth.currentUser;
    return user?.uid;
  }

  static Future<void> signInAnonymously() async {
    try {
      await _auth.signInAnonymously();
      print('✅ Signed in anonymously');
    } catch (e) {
      print('❌ Anonymous sign-in failed: $e');
    }
  }

  static Future<void> signOut() async {
    await _auth.signOut();
  }

  // Journal Entries
  static Future<void> saveJournalEntry(Map<String, dynamic> journalData) async {
    try {
      final userId = await getCurrentUserId();
      if (userId == null) {
        await signInAnonymously();
        final newUserId = await getCurrentUserId();
        if (newUserId != null) {
          await _firestore.collection('journals').add({
            ...journalData,
            'userId': newUserId,
            'timestamp': FieldValue.serverTimestamp(),
          });
        }
      } else {
        await _firestore.collection('journals').add({
          ...journalData,
          'userId': userId,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
      print('✅ Journal entry saved to Firebase');
    } catch (e) {
      print('❌ Failed to save journal: $e');
      // Fallback to local storage
      await _localStorage.saveJournalEntry(
        journalData['text'] as String,
        journalData,
      );
    }
  }

  static Future<List<Map<String, dynamic>>> getJournalEntries() async {
    try {
      final userId = await getCurrentUserId();
      if (userId == null) return [];

      final snapshot = await _firestore
          .collection('journals')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .limit(50)
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('❌ Failed to get journals: $e');
      // Fallback to local storage
      return await _localStorage.getJournalHistory('user');
    }
  }

  // User Profile
  static Future<void> saveUserProfile(Map<String, dynamic> userData) async {
    try {
      final userId = await getCurrentUserId();
      if (userId == null) return;

      await _firestore.collection('users').doc(userId).set({
        ...userData,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      print('✅ User profile saved to Firebase');
    } catch (e) {
      print('❌ Failed to save profile: $e');
      // Fallback to local storage
      await _localStorage.saveUserProfile(userData);
    }
  }

  static Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final userId = await getCurrentUserId();
      if (userId == null) return null;

      final doc = await _firestore.collection('users').doc(userId).get();
      return doc.data();
    } catch (e) {
      print('❌ Failed to get profile: $e');
      // Fallback to local storage
      return await _localStorage.getUserProfile();
    }
  }

  // Skills Progress
  static Future<void> updateSkillProgress(String skill, int progress) async {
    try {
      final userId = await getCurrentUserId();
      if (userId == null) return;

      await _firestore.collection('skills').doc(userId).set({
        skill: {
          'progress': progress,
          'lastUpdated': FieldValue.serverTimestamp(),
        },
      }, SetOptions(merge: true));
      print('✅ Skill progress updated: $skill = $progress%');
    } catch (e) {
      print('❌ Failed to update skill: $e');
    }
  }

  static Future<Map<String, dynamic>> getSkillProgress() async {
    try {
      final userId = await getCurrentUserId();
      if (userId == null) return {};

      final doc = await _firestore.collection('skills').doc(userId).get();
      return doc.data() ?? {};
    } catch (e) {
      print('❌ Failed to get skills: $e');
      return {};
    }
  }

  // Analytics
  static Future<void> logEvent(
    String eventName,
    Map<String, dynamic>? parameters,
  ) async {
    try {
      // You can use Firebase Analytics here if needed
      print('📊 Event logged: $eventName');
      if (parameters != null) {
        print('📊 Parameters: $parameters');
      }
    } catch (e) {
      print('❌ Failed to log event: $e');
    }
  }

  // Real-time listeners
  static Stream<List<Map<String, dynamic>>> watchJournalEntries() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.value([]);

    return _firestore
        .collection('journals')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  static Stream<Map<String, dynamic>> watchUserProfile() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.value({});

    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((snapshot) => snapshot.data() ?? {});
  }

  // Storage (for PDFs)
  static Future<String> uploadPDFFile(
    String fileName,
    List<int> fileBytes,
  ) async {
    try {
      // This would require Firebase Storage setup
      print('📄 PDF upload not implemented yet');
      return 'local';
    } catch (e) {
      print('❌ Failed to upload PDF: $e');
      return 'local';
    }
  }

  // Sync data between local and Firebase
  static Future<void> syncData() async {
    try {
      final userId = await getCurrentUserId();
      if (userId == null) return;

      // Sync local journals to Firebase
      final localJournals = await _localStorage.getJournalHistory('user');
      for (final journal in localJournals) {
        await saveJournalEntry(journal);
      }

      // Sync local profile to Firebase
      final localProfile = await _localStorage.getUserProfile();
      if (localProfile != null) {
        await saveUserProfile(localProfile);
      }

      print('✅ Data synced to Firebase');
    } catch (e) {
      print('❌ Sync failed: $e');
    }
  }
}
