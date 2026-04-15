import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../services/local_storage_service.dart';

class EnhancedChatbotScreen extends StatefulWidget {
  const EnhancedChatbotScreen({super.key});

  @override
  State<EnhancedChatbotScreen> createState() => _EnhancedChatbotScreenState();
}

class _EnhancedChatbotScreenState extends State<EnhancedChatbotScreen>
    with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isTyping = false;
  late LocalStorageService _localStorageService;
  late AnimationController _typingController;
  late Animation<double> _typingAnimation;

  // AI API Configuration
  static const String _apiKey = 'AIzaSyB5p6WJ7Q8R9X2T3Y4V5U6W7X8Y9Z0A1B2C3';
  static const String _apiUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent';

  @override
  void initState() {
    super.initState();
    _localStorageService = LocalStorageService();
    _typingController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _typingAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _typingController, curve: Curves.easeInOut),
    );
    _addBotMessage(
      "Hello! I'm your AI mental health and learning assistant. I can help you with:\n\n🧘 **Mental Health Support** - Stress management, anxiety coping, burnout prevention\n📚 **Learning Guidance** - Study strategies, skill development, productivity tips\n🎯 **Personal Advice** - Based on your journal entries and progress\n\nHow are you feeling today, and how can I help you?",
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _typingController.dispose();
    super.dispose();
  }

  void _addBotMessage(String message) {
    setState(() {
      _messages.add({
        'text': message,
        'isBot': true,
        'timestamp': DateTime.now(),
      });
    });
    _scrollToBottom();
  }

  void _addUserMessage(String message) {
    setState(() {
      _messages.add({
        'text': message,
        'isBot': false,
        'timestamp': DateTime.now(),
      });
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // Scroll to bottom logic would go here
      }
    });
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    _addUserMessage(message);
    _messageController.clear();

    setState(() {
      _isTyping = true;
    });
    _typingController.repeat(reverse: true);

    try {
      // Get user data for personalized responses
      Map<String, dynamic>? userProfile;
      List<Map<String, dynamic>>? journalHistory;

      if (_localStorageService.currentUser != null) {
        final userId = _localStorageService.currentUser!['id'];
        userProfile = await _localStorageService.getUserProfile(userId);
        journalHistory = await _localStorageService.getJournalHistory(
          userId,
          limit: 10,
        );
      }

      // Generate personalized context
      final context = _buildPersonalizedContext(userProfile, journalHistory);

      // Get AI response from real API
      final response = await _getAIResponse(message, context);
      _addBotMessage(response);
    } catch (e) {
      if (!mounted) return;

      print('Error getting AI response: $e');
      _addBotMessage(
        "I'm having trouble connecting to my AI brain right now. Let me provide some general advice instead:\n\n🧘 **Quick Stress Relief**:\n- Try deep breathing: 4-7-8 technique\n- Take a 10-minute break\n- Stretch or walk around\n\n📚 **Study Tips**:\n- Use Pomodoro technique (25min study, 5min break)\n- Stay hydrated and well-rested\n- Break complex topics into smaller chunks\n\nWould you like to try again, or is there something specific I can help you with?",
      );
    } finally {
      if (mounted) {
        setState(() {
          _isTyping = false;
        });
        _typingController.stop();
        _typingController.reset();
      }
    }
  }

  String _buildPersonalizedContext(
    Map<String, dynamic>? userProfile,
    List<Map<String, dynamic>>? journalHistory,
  ) {
    if (userProfile == null && journalHistory == null) {
      return "User is new to the app.";
    }

    final context = <String>[];

    // Add user profile information
    if (userProfile != null) {
      final userName = userProfile['name'] ?? 'Student';
      final userSkills = (userProfile['skills'] as List?) ?? [];
      final userGoals = userProfile['goals'] ?? 'general learning';

      context.add("User name: $userName");
      context.add("User skills: ${userSkills.join(', ')}");
      context.add("User goals: $userGoals");
    }

    // Add recent journal data
    if (journalHistory != null && journalHistory.isNotEmpty) {
      double totalStudyHours = 0;
      int totalDSAProblems = 0;
      List<String> recentMoods = [];

      for (final journal in journalHistory.take(5)) {
        final entry = journal['entry'] as Map<String, dynamic>?;
        if (entry != null) {
          totalStudyHours += (entry['study_hours'] as double?) ?? 0.0;
          totalDSAProblems += (entry['dsa_problems_solved'] as int?) ?? 0;
          if (entry['mood'] != null) {
            recentMoods.add(entry['mood']);
          }
        }
      }

      context.add("Recent study hours: ${totalStudyHours.toStringAsFixed(1)}");
      context.add("Recent DSA problems: $totalDSAProblems");
      context.add("Recent moods: ${recentMoods.join(', ')}");
    }

    return context.join('\n');
  }

  Future<String> _getAIResponse(String userMessage, String context) async {
    final prompt =
        '''
You are a compassionate and knowledgeable AI assistant specializing in student mental health and learning optimization. You have access to the user's context:

$context

User message: $userMessage

Please provide a helpful, personalized response that:
1. Shows empathy and understanding
2. Provides practical, actionable advice
3. References their specific context when relevant
4. Uses appropriate emojis for visual appeal
5. Keeps responses conversational but informative
6. Focuses on mental health, study strategies, and personal growth

Format your response with clear sections and use markdown-style formatting with **bold** for emphasis.
''';

    final response = await http.post(
      Uri.parse('$_apiUrl?key=$_apiKey'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': prompt},
            ],
          },
        ],
        'generationConfig': {
          'temperature': 0.7,
          'topK': 40,
          'topP': 0.95,
          'maxOutputTokens': 1024,
        },
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final aiResponse =
          data['candidates']?[0]?['content']?['parts']?[0]?['text'] ??
          "I apologize, but I couldn't generate a response. Please try again.";
      return aiResponse;
    } else {
      throw Exception('API Error: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color(0xFF00D9FF), const Color(0xFFB829F7)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.psychology,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'AI Mental Health Assistant',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white),
            onPressed: _showInfoDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages area
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF0A0A0F),
                    const Color(0xFF1A1A2E).withOpacity(0.3),
                  ],
                ),
              ),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length + (_isTyping ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _messages.length && _isTyping) {
                    return _buildTypingIndicator();
                  }
                  final message = _messages[index];
                  return _buildMessageBubble(message);
                },
              ),
            ),
          ),

          // Quick action buttons
          _buildQuickActions(),

          // Input area
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildQuickActionButton(
              'Feeling stressed?',
              'I\'m feeling stressed and overwhelmed',
            ),
            const SizedBox(width: 8),
            _buildQuickActionButton(
              'Study help',
              'Can you help me study better?',
            ),
            const SizedBox(width: 8),
            _buildQuickActionButton(
              'Burnout',
              'I think I might be burning out',
            ),
            const SizedBox(width: 8),
            _buildQuickActionButton(
              'Motivation',
              'I need motivation to keep going',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(String label, String message) {
    return GestureDetector(
      onTap: () {
        _messageController.text = message;
        _sendMessage();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final isBot = message['isBot'] as bool;
    final text = message['text'] as String;
    final timestamp = message['timestamp'] as DateTime;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isBot
            ? MainAxisAlignment.start
            : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isBot) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color(0xFF00D9FF), const Color(0xFFB829F7)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.psychology,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isBot
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: isBot
                        ? LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.1),
                              Colors.white.withOpacity(0.05),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : LinearGradient(
                            colors: [
                              const Color(0xFF00D9FF).withOpacity(0.2),
                              const Color(0xFFB829F7).withOpacity(0.1),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isBot
                          ? Colors.white.withOpacity(0.2)
                          : const Color(0xFF00D9FF).withOpacity(0.3),
                    ),
                  ),
                  child: _formatMessage(text),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTime(timestamp),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
          if (!isBot) ...[
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 18),
            ),
          ],
        ],
      ),
    );
  }

  Widget _formatMessage(String text) {
    // Simple markdown-like formatting
    final lines = text.split('\n');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) {
        if (line.startsWith('**') && line.endsWith('**')) {
          return Text(
            line.replaceAll('**', ''),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              height: 1.4,
            ),
          );
        } else if (line.startsWith('🧘') ||
            line.startsWith('📚') ||
            line.startsWith('🎯')) {
          return Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              line,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
                height: 1.4,
              ),
            ),
          );
        } else if (line.startsWith('•')) {
          return Padding(
            padding: const EdgeInsets.only(left: 16, top: 4),
            child: Text(
              line,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
                height: 1.4,
              ),
            ),
          );
        } else {
          return Text(
            line,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
              height: 1.4,
            ),
          );
        }
      }).toList(),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFF00D9FF), const Color(0xFFB829F7)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.psychology, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 8),
          AnimatedBuilder(
            animation: _typingAnimation,
            builder: (context, child) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildDot(0),
                    const SizedBox(width: 4),
                    _buildDot(1),
                    const SizedBox(width: 4),
                    _buildDot(2),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return AnimatedBuilder(
      animation: _typingAnimation,
      builder: (context, child) {
        final delay = index * 0.2;
        final animationValue = (_typingAnimation.value - delay).clamp(0.0, 1.0);
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.6 * animationValue),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      },
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E).withOpacity(0.8),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Type your message...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFF00D9FF), const Color(0xFFB829F7)],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: IconButton(
              icon: _isTyping
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                      ),
                    )
                  : const Icon(Icons.send, color: Colors.white),
              onPressed: _isTyping ? null : _sendMessage,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text(
          'About Your AI Assistant',
          style: TextStyle(color: Colors.white),
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Powered by Google Gemini AI',
              style: TextStyle(
                color: Color(0xFF00D9FF),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text('I can help you with:', style: TextStyle(color: Colors.white)),
            SizedBox(height: 4),
            Text(
              '• Mental health support and stress management',
              style: TextStyle(color: Colors.white70),
            ),
            Text(
              '• Study strategies and productivity tips',
              style: TextStyle(color: Colors.white70),
            ),
            Text(
              '• Personalized advice based on your journal',
              style: TextStyle(color: Colors.white70),
            ),
            Text(
              '• Burnout prevention and wellness guidance',
              style: TextStyle(color: Colors.white70),
            ),
            SizedBox(height: 12),
            Text(
              'Your conversations are private and secure.',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Got it!',
              style: TextStyle(color: Color(0xFF00D9FF)),
            ),
          ),
        ],
      ),
    );
  }
}
