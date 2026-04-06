import 'package:flutter/material.dart';
import '../../services/local_storage_service.dart';

class MainDashboardScreen extends StatefulWidget {
  const MainDashboardScreen({super.key});

  @override
  State<MainDashboardScreen> createState() => _MainDashboardScreenState();
}

class _MainDashboardScreenState extends State<MainDashboardScreen> {
  late LocalStorageService _localStorageService;
  Map<String, dynamic>? _userProfile;
  Map<String, dynamic>? _todayAnalysis;
  Map<String, dynamic>? _weeklyPlan;
  bool _isLoading = false;

  // Journal form controllers
  final TextEditingController _studyHoursController = TextEditingController();
  final TextEditingController _whatStudiedController = TextEditingController();
  final TextEditingController _dsaProblemsController = TextEditingController(
    text: '0',
  );
  final TextEditingController _dsaPlatformController = TextEditingController();
  final TextEditingController _goalPracticeController = TextEditingController();
  final TextEditingController _generalNotesController = TextEditingController();

  String _selectedMood = 'neutral';

  @override
  void initState() {
    super.initState();
    _localStorageService = LocalStorageService();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _localStorageService.initialize();

      if (_localStorageService.currentUser != null) {
        final userId = _localStorageService.currentUser!['id'];
        final profile = await _localStorageService.getUserProfile(userId);
        if (profile != null) {
          _userProfile = profile;
        }

        // Load today's analysis if exists
        final todayData = await _localStorageService.getJournalHistory(userId);
        if (todayData.isNotEmpty) {
          _todayAnalysis = todayData.last['analysis'];
        }

        // Load weekly plan
        _weeklyPlan = await _generateWeeklyPlan();
      }
    } catch (e) {
      print('Error loading data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<Map<String, dynamic>> _generateWeeklyPlan() async {
    // Generate personalized weekly plan based on user goals and progress
    final userGoals = _userProfile?['goals']?.toString().toLowerCase() ?? '';
    final skills = _userProfile?['skills'] as List? ?? [];

    Map<String, dynamic> weeklyPlan = {
      'week': DateTime.now().month, // Use month instead of weekOfYear
      'goal': userGoals.contains('web')
          ? 'Web Development'
          : 'General Programming',
      'daily_tasks': [],
      'focus_areas': skills.isNotEmpty
          ? skills
          : ['DSA', 'Problem Solving', 'Projects'],
      'performance_tracking': {
        'study_hours_target': 40, // 8 hours/day
        'dsa_problems_target': 20, // 4 problems/day
        'project_progress': 25, // percentage
      },
    };

    // Generate daily tasks based on goals
    if (userGoals.contains('web')) {
      weeklyPlan['daily_tasks'] = [
        'Monday: HTML/CSS fundamentals',
        'Tuesday: JavaScript basics',
        'Wednesday: DOM manipulation',
        'Thursday: React components',
        'Friday: State management',
        'Saturday: Project practice',
        'Sunday: Review and planning',
      ];
    } else {
      weeklyPlan['daily_tasks'] = [
        'Monday: Array problems',
        'Tuesday: String manipulation',
        'Wednesday: Linked lists',
        'Thursday: Trees and graphs',
        'Friday: Dynamic programming',
        'Saturday: Mock interviews',
        'Sunday: Review weak areas',
      ];
    }

    return weeklyPlan;
  }

  Future<void> _submitJournal() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (_localStorageService.currentUser == null) {
        throw Exception('User not logged in');
      }

      final userId = _localStorageService.currentUser!['id'];

      // Create journal entry
      final journalEntry = {
        'text': _generalNotesController.text.trim(),
        'study_hours': double.tryParse(_studyHoursController.text) ?? 0.0,
        'what_studied': _whatStudiedController.text.trim(),
        'dsa_problems_solved': int.tryParse(_dsaProblemsController.text) ?? 0,
        'dsa_platform': _dsaPlatformController.text.trim(),
        'goal_practice': _goalPracticeController.text.trim(),
        'mood': _selectedMood,
        'date': DateTime.now().toIso8601String(),
      };

      // Send to backend for AI analysis
      final analysis = await _analyzeWithAI(journalEntry);

      // Save to local storage
      await _localStorageService.saveJournalEntry(userId, {
        'entry': journalEntry,
        'analysis': analysis,
        'created_at': DateTime.now().toIso8601String(),
      });

      // Update today's analysis
      setState(() {
        _todayAnalysis = analysis;
      });

      // Regenerate weekly plan based on new data
      final newWeeklyPlan = await _generateWeeklyPlan();
      setState(() {
        _weeklyPlan = newWeeklyPlan;
      });

      // Clear form
      _clearJournalForm();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '🎉 Journal analyzed! Burnout risk: ${analysis['burnout_risk']}/10',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<Map<String, dynamic>> _analyzeWithAI(
    Map<String, dynamic> entry,
  ) async {
    // Simulate AI analysis
    await Future.delayed(const Duration(seconds: 2));

    final studyHours = entry['study_hours'] as double? ?? 0.0;
    final dsaProblems = entry['dsa_problems_solved'] as int? ?? 0;
    final mood = entry['mood'] as String? ?? 'neutral';

    // Calculate burnout risk (1-10 scale)
    int burnoutRisk = 3; // Base risk
    if (studyHours > 10) burnoutRisk += 3;
    if (studyHours > 8) burnoutRisk += 2;
    if (dsaProblems == 0) burnoutRisk += 1;
    if (['stressed', 'anxious', 'overwhelmed'].contains(mood)) burnoutRisk += 2;
    burnoutRisk = burnoutRisk.clamp(1, 10);

    // Extract skills from text
    final text =
        '${entry['what_studied']} ${entry['goal_practice']} ${entry['text']}'
            .toLowerCase();
    final skillsMentioned = <String>[];
    final commonSkills = [
      'python',
      'javascript',
      'react',
      'node',
      'html',
      'css',
      'dsa',
      'algorithms',
    ];

    for (final skill in commonSkills) {
      if (text.contains(skill)) {
        skillsMentioned.add(skill);
      }
    }

    // Calculate skill alignment
    final userSkills = _userProfile?['skills'] as List? ?? [];
    final alignmentScore = userSkills
        .where(
          (skill) => skillsMentioned.any(
            (mentioned) => mentioned.toString().toLowerCase().contains(
              skill.toString().toLowerCase(),
            ),
          ),
        )
        .length;

    final skillAlignment = alignmentScore > 2
        ? 'high'
        : alignmentScore > 1
        ? 'medium'
        : 'low';

    return {
      'burnout_risk': burnoutRisk,
      'skill_alignment': skillAlignment,
      'daily_progress': {
        'study_hours': studyHours,
        'dsa_problems': dsaProblems,
        'skills_mentioned': skillsMentioned,
        'productivity_score': (dsaProblems * 10 + (studyHours * 5)).round(),
      },
      'recommendations': burnoutRisk > 7
          ? [
              '🚨 High burnout risk! Take rest tomorrow',
              'Reduce study hours to 6-8',
            ]
          : burnoutRisk > 5
          ? ['⚠️ Moderate burnout risk', 'Take regular breaks']
          : ['✅ Good balance!', 'Keep up the great work'],
      'mood_analysis': mood,
      'skills_progress': skillsMentioned.asMap().map(
        (key, skill) => MapEntry(skill, 50 + (dsaProblems * 5)),
      ),
    };
  }

  void _clearJournalForm() {
    _studyHoursController.clear();
    _whatStudiedController.clear();
    _dsaProblemsController.clear();
    _dsaPlatformController.clear();
    _goalPracticeController.clear();
    _generalNotesController.clear();
    _selectedMood = 'neutral';
  }

  Widget _buildTodayJournalSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.withOpacity(0.1),
            Colors.purple.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📝 Today\'s Journal',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Study Hours Section
          _buildSectionCard('⏰ Study Hours', [
            TextField(
              controller: _studyHoursController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Hours studied today (e.g., 4.5)',
                hintStyle: TextStyle(color: Colors.white54),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white24),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _whatStudiedController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'What did you study? (e.g., React hooks, DSA arrays)',
                hintStyle: TextStyle(color: Colors.white54),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white24),
                ),
              ),
            ),
          ]),

          const SizedBox(height: 16),

          // DSA Section
          _buildSectionCard('💻 DSA Practice', [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _dsaProblemsController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Problems solved',
                      hintStyle: TextStyle(color: Colors.white54),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white24),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _dsaPlatformController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Platform (LeetCode)',
                      hintStyle: TextStyle(color: Colors.white54),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white24),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ]),

          const SizedBox(height: 16),

          // Goal Practice Section
          _buildSectionCard('🎯 Goal Practice', [
            TextField(
              controller: _goalPracticeController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText:
                    'What did you practice for your goal? (e.g., Built a React component)',
                hintStyle: TextStyle(color: Colors.white54),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white24),
                ),
              ),
            ),
          ]),

          const SizedBox(height: 16),

          // General Notes Section
          _buildSectionCard('📖 General Notes', [
            TextField(
              controller: _generalNotesController,
              maxLines: 4,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Share anything else about your day...',
                hintStyle: TextStyle(color: Colors.white54),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white24),
                ),
              ),
            ),
          ]),

          const SizedBox(height: 16),

          // Mood Selector
          _buildSectionCard('😊 How are you feeling?', [
            Wrap(
              spacing: 8,
              children:
                  [
                    'great',
                    'good',
                    'neutral',
                    'tired',
                    'stressed',
                    'anxious',
                  ].map((mood) {
                    final isSelected = _selectedMood == mood;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedMood = mood),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.blue
                              : Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          mood.toUpperCase(),
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ]),

          const SizedBox(height: 20),

          // Submit Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submitJournal,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      '🤖 Analyze with AI',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildAnalysisSection() {
    if (_todayAnalysis == null) {
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: const Center(
          child: Text(
            'Submit your journal to see AI analysis',
            style: TextStyle(color: Colors.white70),
          ),
        ),
      );
    }

    final analysis = _todayAnalysis!;
    final progress = analysis['daily_progress'] as Map<String, dynamic>? ?? {};

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.withOpacity(0.1), Colors.teal.withOpacity(0.1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📊 Today\'s Analysis',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Burnout Risk
          _buildMetricCard(
            '🔥 Burnout Risk',
            '${analysis['burnout_risk']}/10',
            analysis['burnout_risk'] > 7
                ? Colors.red
                : analysis['burnout_risk'] > 5
                ? Colors.orange
                : Colors.green,
          ),

          // Skill Alignment
          _buildMetricCard(
            '🎯 Skill Alignment',
            analysis['skill_alignment'].toString().toUpperCase(),
            analysis['skill_alignment'] == 'high'
                ? Colors.green
                : analysis['skill_alignment'] == 'medium'
                ? Colors.orange
                : Colors.red,
          ),

          // Study Hours
          _buildMetricCard(
            '⏰ Study Hours',
            '${progress['study_hours'] ?? 0}h',
            Colors.blue,
          ),

          // DSA Problems
          _buildMetricCard(
            '💻 DSA Problems',
            '${progress['dsa_problems'] ?? 0} solved',
            Colors.purple,
          ),

          // Recommendations
          if (analysis['recommendations'] != null) ...[
            const SizedBox(height: 16),
            const Text(
              '💡 Recommendations:',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ...(analysis['recommendations'] as List).map(
              (rec) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(
                  '• $rec',
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyPlanSection() {
    if (_weeklyPlan == null) return const SizedBox.shrink();

    final plan = _weeklyPlan!;
    final tasks = plan['daily_tasks'] as List? ?? [];

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.withOpacity(0.1), Colors.red.withOpacity(0.1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📅 Weekly Plan - ${plan['goal']}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          ...tasks.map(
            (task) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    color: Colors.white70,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      task,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Progress tracking
          const Text(
            '📈 Weekly Targets:',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          ...(plan['performance_tracking'] as Map).entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(
                '• ${entry.key}: ${entry.value}',
                style: const TextStyle(color: Colors.white70),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F23),
      appBar: AppBar(
        title: const Text(
          'DevBalance Dashboard',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/chatbot'),
            icon: const Icon(Icons.chat, color: Colors.white),
            tooltip: 'Chat Assistant',
          ),
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/analytics'),
            icon: const Icon(Icons.analytics, color: Colors.white),
            tooltip: 'Study Analytics',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : SingleChildScrollView(
              child: Column(
                children: [
                  _buildTodayJournalSection(),
                  _buildAnalysisSection(),
                  _buildWeeklyPlanSection(),
                ],
              ),
            ),
    );
  }
}
