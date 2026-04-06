import 'package:flutter/material.dart';
import 'dart:math';
import 'screens/splash/splash_screen.dart' as splash;
import 'screens/login/login_screen.dart';
import 'screens/registration/new_registration_screen.dart';
import 'screens/dashboard/main_dashboard_screen.dart';
import 'screens/chatbot/chatbot_screen.dart';
import 'screens/admin/data_viewer_screen.dart';
import 'services/local_storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorageService().initialize();
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
        '/dashboard': (context) => const MainDashboardScreen(),
        '/chatbot': (context) => const ChatbotScreen(),
        '/data-viewer': (context) => const DataViewerScreen(),
      },
    );
  }
}

// Reusable widgets
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final double borderRadius;
  
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

class NeonButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isSecondary;
  final IconData? icon;
  
  const NeonButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isSecondary = false,
    this.icon,
  });

  @override
  State<NeonButton> createState() => _NeonButtonState();
}

class _NeonButtonState extends State<NeonButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: widget.isSecondary
                    ? const Color(0xFFB829F7).withOpacity(_animation.value * 0.5)
                    : const Color(0xFF00D9FF).withOpacity(_animation.value * 0.5),
                blurRadius: 20,
                spreadRadius: widget.isSecondary ? 2 : 3,
              ),
              BoxShadow(
                color: widget.isSecondary
                    ? const Color(0xFFB829F7).withOpacity(_animation.value * 0.3)
                    : const Color(0xFF00D9FF).withOpacity(_animation.value * 0.3),
                blurRadius: 40,
                spreadRadius: widget.isSecondary ? 4 : 6,
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: widget.onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.isSecondary
                  ? const Color(0xFFB829F7)
                  : const Color(0xFF00D9FF),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.icon != null) ...[
                  Icon(widget.icon, size: 20),
                  const SizedBox(width: 8),
                ],
                Text(
                  widget.text,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
