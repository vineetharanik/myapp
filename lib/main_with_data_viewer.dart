import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/splash/splash_screen.dart' as splash;
import 'screens/login/login_screen.dart';
import 'screens/registration/new_registration_screen.dart';
import 'screens/dashboard/comprehensive_dashboard.dart';
import 'screens/journal/enhanced_journal_screen.dart';
import 'screens/chatbot/chatbot_screen.dart';
import 'screens/admin/data_viewer_screen.dart';
import 'screens/notebook/notebook_screen_local.dart';
import 'services/local_storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorageService().initialize();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const DevBalanceApp());
}

class DevBalanceApp extends StatelessWidget {
  const DevBalanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DevBalance AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0A0A0F),
        primaryColor: const Color(0xFF00D9FF),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00D9FF),
          secondary: Color(0xFFB829F7),
          surface: Color(0xFF1A1A2E),
        ),
      ),
      home: const splash.SplashScreen(),
      routes: {
        '/': (context) => const splash.SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const NewRegistrationScreen(),
        '/dashboard': (context) => const ComprehensiveDashboard(),
        '/journal': (context) => const EnhancedJournalScreen(),
        '/chatbot': (context) => const ChatbotScreen(),
        '/data-viewer': (context) => const DataViewerScreen(),
        '/notebook': (context) => const NotebookScreenLocal(),
      },
    );
  }
}
