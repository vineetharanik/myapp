import 'package:flutter/material.dart';
import '../../services/local_storage_service.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isTyping = false;
  late LocalStorageService _localStorageService;

  @override
  void initState() {
    super.initState();
    _localStorageService = LocalStorageService();
    _addBotMessage(
      "Hello! I'm your AI mental health assistant. I'm here to help you manage stress and improve your well-being. How are you feeling today?",
    );
  }

  void _addBotMessage(String message) {
    setState(() {
      _messages.add({
        'text': message,
        'isBot': true,
        'timestamp': DateTime.now(),
      });
    });
  }

  void _addUserMessage(String message) {
    setState(() {
      _messages.add({
        'text': message,
        'isBot': false,
        'timestamp': DateTime.now(),
      });
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

      // Send message to local storage and get AI response
      await _localStorageService.sendChatbotMessage(
        _localStorageService.currentUser!['id'],
        message,
      );

      // Simulate AI response delay
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      final response = _generatePersonalizedResponse(
        message,
        userProfile,
        journalHistory,
      );
      _addBotMessage(response);

      setState(() {
        _isTyping = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isTyping = false;
      });

      _addBotMessage(
        "I'm having trouble connecting right now. Please try again later.",
      );
    }
  }

  String _generatePersonalizedResponse(
    String userMessage,
    Map<String, dynamic>? userProfile,
    List<Map<String, dynamic>>? journalHistory,
  ) {
    final lowerMessage = userMessage.toLowerCase();

    // Extract user data for personalization
    final userName = userProfile?['name'] ?? 'there';
    final userSkills = (userProfile?['skills'] as List?) ?? [];
    final userGoals = userProfile?['goals'] ?? '';
    final stressLevel = userProfile?['stressAssessment']?['stress_level'] ?? 50;

    // Calculate study stats from journal
    double totalStudyHours = 0;
    int totalDSAProblems = 0;
    String recentMood = 'neutral';

    if (journalHistory != null) {
      for (final journal in journalHistory.take(5)) {
        final entry = journal['entry'] as Map<String, dynamic>?;
        if (entry != null) {
          totalStudyHours += (entry['study_hours'] as double?) ?? 0.0;
          totalDSAProblems += (entry['dsa_problems_solved'] as int?) ?? 0;
          recentMood = entry['mood'] ?? 'neutral';
        }
      }
    }

    // Personalized stress responses
    if (lowerMessage.contains('stress') || lowerMessage.contains('stressed')) {
      return "Hey $userName! I notice you're feeling stressed. Based on your recent activity, you've studied ${totalStudyHours.toStringAsFixed(1)} hours this week. Since your stress level is currently $stressLevel%, let me suggest:\n\n🧘 **Quick Relief**:\n- Try the 4-7-8 breathing exercise right now\n- Take a 10-minute break from screens\n- Listen to calming music\n\n📊 **Your Pattern**: You tend to study more when stressed. Consider breaking study sessions into 25-minute chunks with 5-minute breaks.\n\nWould you like me to help you create a more balanced study schedule?";
    }

    if (lowerMessage.contains('anxiety') || lowerMessage.contains('anxious')) {
      return "I understand you're feeling anxious, $userName. Your recent journal shows you've been working on ${userGoals.isEmpty ? 'various topics' : userGoals}. That's great progress!\n\n🧘 **Immediate Anxiety Relief**:\n- Ground yourself: Name 5 things you can see right now\n- 5-4-3-2-1 breathing technique\n- Splash cold water on your face\n\n🎯 **Focus Strategy**: Since you're learning ${userSkills.join(', ')}, try breaking complex topics into smaller, manageable chunks.\n\nHow about we tackle one specific topic that's causing you the most anxiety right now?";
    }

    if (lowerMessage.contains('burnout') ||
        lowerMessage.contains('burned out')) {
      return "Burnout is serious, $userName. You've completed $totalDSAProblems DSA problems with ${totalStudyHours.toStringAsFixed(1)} study hours this week. That's intense work!\n\n🔥 **Recovery Plan**:\n- Take tomorrow completely OFF from studying\n- Get 8+ hours of sleep tonight\n- Do something enjoyable - completely unrelated to coding\n- Schedule a 30-minute 'worry time' tomorrow, then let it go\n\n📈 **Prevention**: Your burnout risk correlates with long study sessions. Let's aim for max 6 hours/day with regular breaks.\n\nReady to create a more sustainable study plan together?";
    }

    if (lowerMessage.contains('study') || lowerMessage.contains('studying')) {
      // Add specific study suggestions based on skills
      if (userSkills.contains('javascript') || userSkills.contains('react')) {
        return "Hey $userName! I can see from your journals that you're consistently working on ${userSkills.join(', ')}.\n\n📚 **Optimized Study Plan**:\n- Based on your $totalDSAProblems DSA problems this week, try these topics:\n- **JavaScript/React**: Practice component composition\n- Work on a small project this weekend\n- Review async/await patterns\n\nWhat specific JavaScript concept is challenging you most?";
      }
      if (userSkills.contains('python') || userSkills.contains('django')) {
        return "Hey $userName! I can see from your journals that you're consistently working on ${userSkills.join(', ')}.\n\n📚 **Optimized Study Plan**:\n- Based on your $totalDSAProblems DSA problems this week, try these topics:\n- **Python/Django**: Build a web scraper or API project\n- Practice data structures daily\n- Review OOP concepts\n\nWhich Python framework are you most interested in?";
      }
      if (userSkills.contains('dsa') || userSkills.contains('algorithms')) {
        return "Hey $userName! I can see from your journals that you're consistently working on ${userSkills.join(', ')}.\n\n📚 **Optimized Study Plan**:\n- Based on your $totalDSAProblems DSA problems this week, try these topics:\n- **DSA Focus**: Based on $totalDSAProblems problems, try:\n  - Arrays & Strings tomorrow\n  - Linked Lists & Trees in 2 days\n  - Dynamic Programming in 3 days\n\nWould you like me to create a personalized DSA practice schedule?";
      }

      return "Hey $userName! I can see from your journals that you're consistently working on ${userSkills.join(', ')}.\n\n📚 **Optimized Study Plan**:\n- Based on your $totalDSAProblems DSA problems this week, try these topics:\n- **General Tips**:\n- Use Pomodoro: 25min study, 5min break\n- Review yesterday's material before starting new topics\n- Take breaks every 45-60 minutes\n\nWhat subject would you like to focus on today?";
    }

    if (lowerMessage.contains('sleep') || lowerMessage.contains('tired')) {
      return "I notice you mentioned feeling tired, $userName. Your recent mood has been mostly '$recentMood'. Sleep is crucial for learning!\n\n😴 **Sleep Optimization**:\n- Aim for 7-9 hours tonight\n- No screens 1 hour before bed\n- Try the 10-3-2-1 sleep method\n\n📊 **Your Pattern**: You study best when well-rested. Consider adjusting your schedule to study during your peak energy hours.\n\nWould you like tips for better sleep hygiene?";
    }

    if (lowerMessage.contains('help') ||
        lowerMessage.contains('sad') ||
        lowerMessage.contains('depressed')) {
      return "I'm here for you, $userName. It takes courage to reach out, and I'm glad you did.\n\n🤗 **Immediate Support**:\n- You're not alone - many students feel this way\n- These feelings are valid and temporary\n- Tomorrow is always a new opportunity\n\n📞 **Resources**:\n- Campus counseling: Free and confidential\n- Crisis hotline: 988\n- Trusted friends, family, or faculty\n\nWhat's been on your mind lately that I can help you with?";
    }

    // Default response with personalization
    return "Thanks for sharing, $userName! I see you're working on ${userGoals.isEmpty ? 'your skills' : userGoals} and have been studying consistently. Your recent mood has been '$recentMood'.\n\n📊 **Your Stats This Week**:\n- Study hours: ${totalStudyHours.toStringAsFixed(1)}\n- DSA problems: $totalDSAProblems\n- Skills practiced: ${userSkills.join(', ')}\n\nKeep up the great work! Is there anything specific about your progress you'd like to discuss?";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        title: const Text('AI Mental Health Assistant'),
        backgroundColor: const Color(0xFF1A1A2E),
        foregroundColor: const Color(0xFF00D9FF),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Messages
          Expanded(
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

          // Input area
          _buildInputArea(),
        ],
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
                color: const Color(0xFF00D9FF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.psychology,
                color: Colors.white,
                size: 20,
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
                    color: isBot
                        ? Colors.white.withOpacity(0.1)
                        : const Color(0xFF00D9FF).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isBot
                          ? Colors.white.withOpacity(0.2)
                          : const Color(0xFF00D9FF).withOpacity(0.5),
                    ),
                  ),
                  child: Text(
                    text,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
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
              child: const Icon(Icons.person, color: Colors.white, size: 20),
            ),
          ],
        ],
      ),
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
              color: const Color(0xFF00D9FF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.psychology, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 8),
          Container(
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
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300 + (index * 100)),
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
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
              color: const Color(0xFF00D9FF),
              borderRadius: BorderRadius.circular(24),
            ),
            child: IconButton(
              icon: _isTyping
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
}
