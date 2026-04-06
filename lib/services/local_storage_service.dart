import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/journal_analysis.dart';

class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  SharedPreferences? _prefs;
  Map<String, dynamic>? _currentUser;

  // Expose prefs for database viewer
  SharedPreferences? get prefs => _prefs;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> saveJournalEntry(
    String userId,
    Map<String, dynamic> journalData,
  ) async {
    final journals = _prefs?.getStringList('journals_$userId') ?? [];
    journals.add(jsonEncode(journalData));
    await _prefs?.setStringList('journals_$userId', journals);
  }

  Future<List<Map<String, dynamic>>> getJournalHistory(
    String userId, {
    int limit = 50,
  }) async {
    final journals = _prefs?.getStringList('journals_$userId') ?? [];
    final entries = journals
        .map((json) {
          try {
            return jsonDecode(json) as Map<String, dynamic>;
          } catch (e) {
            print('Error decoding journal entry: $e');
            return null;
          }
        })
        .where((entry) => entry != null)
        .cast<Map<String, dynamic>>()
        .toList();

    // Sort by timestamp descending with null safety
    entries.sort((a, b) {
      final aTimestamp = _journalSortKey(a);
      final bTimestamp = _journalSortKey(b);
      return bTimestamp.compareTo(aTimestamp);
    });

    return entries.take(limit).toList();
  }

  String _journalSortKey(Map<String, dynamic> entry) {
    final nestedEntry = entry['entry'] as Map<String, dynamic>?;
    return (entry['timestamp'] ??
            entry['created_at'] ??
            entry['createdAt'] ??
            entry['date'] ??
            nestedEntry?['createdAt'] ??
            nestedEntry?['date'] ??
            '')
        .toString();
  }

  Future<List<Map<String, dynamic>>> getChatHistory(String userId) async {
    final chatMessages = _prefs?.getStringList('chat_messages_$userId') ?? [];
    return chatMessages
        .map(
          (msg) => {
            'message': msg,
            'timestamp': DateTime.now().toString(),
            'isBot': false,
          },
        )
        .toList();
  }

  Future<void> _initializeDefaults() async {
    // Initialize default user if no users exist
    final users = _prefs?.getStringList('users') ?? [];
    if (users.isEmpty) {
      await _prefs?.setStringList('users', [
        jsonEncode({
          'id': 'demo_user_1',
          'email': 'demo@example.com',
          'name': 'Demo User',
          'password': 'demo123',
          'createdAt': DateTime.now().toIso8601String(),
        }),
      ]);
    }
  }

  Future<void> clearAllData() async {
    await _prefs?.clear();
    await _initializeDefaults();
  }

  // Authentication simulation
  Future<Map<String, dynamic>> signUpWithEmail(
    String email,
    String password,
  ) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay

    // Check if user already exists
    final users = _prefs?.getStringList('users') ?? [];
    for (String userJson in users) {
      final user = jsonDecode(userJson);
      if (user['email'] == email) {
        throw Exception('An account already exists for this email.');
      }
    }

    // Create new user
    final newUser = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'email': email,
      'name': '',
      'password': password, // In real app, this would be hashed
      'skills': <String>[],
      'goals': '',
      'stressAssessment': <String, int>{},
      'createdAt': DateTime.now().toIso8601String(),
    };

    users.add(jsonEncode(newUser));
    await _prefs?.setStringList('users', users);

    _currentUser = newUser;
    return newUser;
  }

  Future<Map<String, dynamic>> signInWithEmail(
    String email,
    String password,
  ) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay

    final users = _prefs?.getStringList('users') ?? [];
    for (String userJson in users) {
      final user = jsonDecode(userJson);
      if (user['email'] == email && user['password'] == password) {
        _currentUser = user;
        return user;
      }
    }

    throw Exception('No user found for this email or wrong password.');
  }

  Future<void> signOut() async {
    _currentUser = null;
  }

  // Settings Management
  Future<Map<String, dynamic>?> getSettings() async {
    final settingsJson = _prefs?.getString('app_settings');
    if (settingsJson != null) {
      return jsonDecode(settingsJson) as Map<String, dynamic>;
    }
    return null;
  }

  Future<void> saveSettings(Map<String, dynamic> settings) async {
    await _prefs?.setString('app_settings', jsonEncode(settings));
  }

  Map<String, dynamic>? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  // User Profile Management
  Future<void> updateUserProfile({
    required String userId,
    required String name,
    required List<String> skills,
    required String goals,
    required Map<String, dynamic> stressAssessment,
  }) async {
    if (_currentUser == null) return;

    _currentUser!['name'] = name;
    _currentUser!['skills'] = skills;
    _currentUser!['goals'] = goals;
    _currentUser!['stressAssessment'] = stressAssessment;

    // Update in storage
    final users = _prefs?.getStringList('users') ?? [];
    final updatedUsers = <String>[];

    for (String userJson in users) {
      final user = jsonDecode(userJson);
      if (user['id'] == userId) {
        user['name'] = name;
        user['skills'] = skills;
        user['goals'] = goals;
        user['stressAssessment'] = stressAssessment;
        updatedUsers.add(jsonEncode(user));
      } else {
        updatedUsers.add(userJson);
      }
    }

    await _prefs?.setStringList('users', updatedUsers);

    // Initialize skills progress
    for (String skill in skills) {
      await updateSkillProgress(userId, skill, 0.0);
    }
  }

  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    if (_currentUser != null && _currentUser!['id'] == userId) {
      return _currentUser!;
    }

    final users = _prefs?.getStringList('users') ?? [];
    for (String userJson in users) {
      final user = jsonDecode(userJson);
      if (user['id'] == userId) {
        return user;
      }
    }
    return null;
  }

  // Journal Entries
  Future<String> createJournalEntry({
    required String userId,
    required String text,
    required JournalAnalysis analysis,
  }) async {
    final journals = _prefs?.getStringList('journals_$userId') ?? [];

    final entry = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'text': text,
      'analysis': analysis.toJson(),
      'timestamp': DateTime.now().toIso8601String(),
      'mood': analysis.mood,
      'stressLevel': analysis.stressLevel,
      'burnoutRisk': analysis.burnoutRisk,
    };

    journals.add(jsonEncode(entry));
    await _prefs?.setStringList('journals_$userId', journals);

    // Update skills progress if mentioned
    if (analysis.skillsProgress.isNotEmpty) {
      for (String skillName in analysis.skillsProgress.keys) {
        final progress = analysis.skillsProgress[skillName];
        await updateSkillProgress(
          userId,
          skillName,
          progress is int ? progress.toDouble() : progress,
        );
      }
    }

    return entry['id'] as String;
  }

  Future<Map<String, dynamic>?> getLatestJournalEntry(String userId) async {
    final history = await getJournalHistory(userId, limit: 1);
    return history.isNotEmpty ? history.first : null;
  }

  // Skills Progress
  Future<void> updateSkillProgress(
    String userId,
    String skillName,
    double progress,
  ) async {
    final skills = _prefs?.getStringList('skills_$userId') ?? [];

    final existingSkillIndex = skills.indexWhere((json) {
      final skill = jsonDecode(json);
      return skill['skillName'] == skillName;
    });

    final skillData = {
      'skillName': skillName,
      'progress': progress,
      'updatedAt': DateTime.now().toIso8601String(),
    };

    if (existingSkillIndex >= 0) {
      skills[existingSkillIndex] = jsonEncode(skillData);
    } else {
      skills.add(jsonEncode(skillData));
    }

    await _prefs?.setStringList('skills_$userId', skills);
  }

  Future<List<Map<String, dynamic>>> getSkillsProgress(String userId) async {
    final skills = _prefs?.getStringList('skills_$userId') ?? [];
    return skills
        .map((json) => jsonDecode(json) as Map<String, dynamic>)
        .toList();
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
    final studyHours = _prefs?.getStringList('study_hours_$userId') ?? [];
    final dateKey = date.toIso8601String().split('T')[0];

    // Remove existing entry for this date
    studyHours.removeWhere((json) {
      final entry = jsonDecode(json);
      return (entry['date'] as String).startsWith(dateKey);
    });

    final entry = {
      'date': date.toIso8601String(),
      'hours': hours,
      'targetHours': targetHours,
      'focusQuality': focusQuality ?? 'medium',
      'notes': notes ?? '',
      'updatedAt': DateTime.now().toIso8601String(),
    };

    studyHours.add(jsonEncode(entry));
    await _prefs?.setStringList('study_hours_$userId', studyHours);
  }

  Future<List<Map<String, dynamic>>> getWeeklyStudyHours(
    String userId,
    DateTime weekStart,
  ) async {
    final studyHours = _prefs?.getStringList('study_hours_$userId') ?? [];
    final weekEnd = weekStart.add(const Duration(days: 7));

    final weeklyEntries = studyHours
        .map((json) => jsonDecode(json) as Map<String, dynamic>)
        .where((entry) {
          final entryDate = DateTime.parse(entry['date'] as String);
          return entryDate.isAfter(
                weekStart.subtract(const Duration(days: 1)),
              ) &&
              entryDate.isBefore(weekEnd);
        })
        .toList();

    weeklyEntries.sort(
      (a, b) => (a['date'] as String).compareTo(b['date'] as String),
    );
    return weeklyEntries;
  }

  // Weekly Plans
  Future<void> saveWeeklyPlan({
    required String userId,
    required DateTime weekStart,
    required Map<String, dynamic> planContent,
  }) async {
    final plans = _prefs?.getStringList('weekly_plans_$userId') ?? [];
    final weekKey = weekStart.toIso8601String().split('T')[0];

    // Remove existing plan for this week
    plans.removeWhere((json) {
      final plan = jsonDecode(json);
      return (plan['weekStart'] as String).startsWith(weekKey);
    });

    final plan = {
      'weekStart': weekStart.toIso8601String(),
      'planContent': planContent,
      'generatedAt': DateTime.now().toIso8601String(),
    };

    plans.add(jsonEncode(plan));
    await _prefs?.setStringList('weekly_plans_$userId', plans);
  }

  Future<Map<String, dynamic>?> getCurrentWeeklyPlan(String userId) async {
    final plans = _prefs?.getStringList('weekly_plans_$userId') ?? [];
    if (plans.isEmpty) return null;

    final planList = plans
        .map((json) => jsonDecode(json) as Map<String, dynamic>)
        .toList();
    planList.sort(
      (a, b) => (b['weekStart'] as String).compareTo(a['weekStart'] as String),
    );

    return planList.isNotEmpty ? planList.first : null;
  }

  // Chatbot messages (stored locally for demo)
  Future<void> sendChatbotMessage(String userId, String message) async {
    final messages = _prefs?.getStringList('chat_messages_$userId') ?? [];

    final userMessage = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'message': message,
      'isUser': true,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };

    messages.add(jsonEncode(userMessage));
    await _prefs?.setStringList('chat_messages_$userId', messages);

    // Simulate AI response
    await Future.delayed(const Duration(seconds: 2));

    final response = _generateAIResponse(message);
    final botMessage = {
      'id': (DateTime.now().millisecondsSinceEpoch + 1).toString(),
      'message': response,
      'isUser': false,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };

    messages.add(jsonEncode(botMessage));
    await _prefs?.setStringList('chat_messages_$userId', messages);
  }

  Future<List<Map<String, dynamic>>> getChatbotMessages(String userId) async {
    final messages = _prefs?.getStringList('chat_messages_$userId') ?? [];
    return messages
        .map((json) => jsonDecode(json) as Map<String, dynamic>)
        .toList();
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

  // PDF Upload Methods for Notebook Feature
  Future<void> saveUploadedPDF(Map<String, dynamic> pdfData) async {
    final pdfs = _prefs?.getStringList('uploaded_pdfs') ?? [];
    pdfs.add(jsonEncode(pdfData));
    await _prefs?.setStringList('uploaded_pdfs', pdfs);
  }

  Future<List<Map<String, dynamic>>> getUploadedPDFs() async {
    final pdfs = _prefs?.getStringList('uploaded_pdfs') ?? [];

    return pdfs
        .map((pdf) {
          try {
            return jsonDecode(pdf) as Map<String, dynamic>;
          } catch (e) {
            return <String, dynamic>{};
          }
        })
        .where((pdf) => pdf.isNotEmpty)
        .toList();
  }

  Future<void> saveNotebookChatMessage(String message, bool isBot) async {
    final chats = _prefs?.getStringList('notebook_chat_history') ?? [];
    chats.add(
      jsonEncode({
        'message': message,
        'isBot': isBot,
        'timestamp': DateTime.now().toIso8601String(),
      }),
    );
    await _prefs?.setStringList('notebook_chat_history', chats);
  }

  Future<List<Map<String, dynamic>>> getNotebookChatHistory() async {
    final chats = _prefs?.getStringList('notebook_chat_history') ?? [];

    return chats
        .map((chat) {
          try {
            return jsonDecode(chat) as Map<String, dynamic>;
          } catch (e) {
            return <String, dynamic>{};
          }
        })
        .where((chat) => chat.isNotEmpty)
        .toList();
  }
}
