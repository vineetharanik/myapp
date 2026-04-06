import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Test script to verify Firebase connection
void main() async {
  print('🔥 Testing Firebase Connection...');
  
  try {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized successfully');
    
    // Test Firestore connection
    final firestore = FirebaseFirestore.instance;
    final testDoc = await firestore.collection('test').add({
      'timestamp': DateTime.now().toIso8601String(),
      'message': 'Firebase connection test',
    });
    
    print('✅ Test document written: ${testDoc.id}');
    
    // Read back the test document
    final snapshot = await firestore.collection('test').doc(testDoc.id).get();
    if (snapshot.exists) {
      final data = snapshot.data() as Map<String, dynamic>;
      print('✅ Test document read successfully: $data');
    } else {
      print('❌ Failed to read test document');
    }
    
    // Test authentication
    final auth = FirebaseAuth.instance;
    final currentUser = auth.currentUser;
    if (currentUser != null) {
      print('✅ Current user: ${currentUser.email}');
    } else {
      print('ℹ️ No user currently signed in');
    }
    
    // List all collections
    final collections = await firestore.listCollections();
    print('📊 Available collections: $collections');
    
    print('🎯 Firebase setup test completed!');
    
  } catch (e) {
    print('❌ Firebase test failed: $e');
    print('🔍 Check your Firebase configuration:');
    print('   - Project ID: ${DefaultFirebaseOptions.currentPlatform.projectId}');
    print('   - API Key: ${DefaultFirebaseOptions.currentPlatform.apiKey?.substring(0, 10)}...');
    print('   - Auth Domain: ${DefaultFirebaseOptions.currentPlatform.authDomain}');
  }
}
