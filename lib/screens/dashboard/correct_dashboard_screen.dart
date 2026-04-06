import 'package:flutter/material.dart';
import '../../services/local_storage_service.dart';
import '../journal/daily_journal_screen.dart';
import '../skills/skill_roadmap_screen.dart';
import '../burnout/burnout_details_screen.dart';
import '../chatbot/enhanced_chatbot_screen.dart';

class CorrectDashboardScreen extends StatefulWidget {
  const CorrectDashboardScreen({super.key});

  @override
  State<CorrectDashboardScreen> createState() => _CorrectDashboardScreenState();
}

class _CorrectDashboardScreenState extends State<CorrectDashboardScreen> {
  late LocalStorageService _localStorageService;
  Map<String, dynamic>? _userProfile;
  List<Map<String, dynamic>> _journalHistory = [];
  bool _isLoading = true;

  // Real data from journal entries
  List<double> _dailyStudyHours = [0, 0, 0, 0, 0, 0, 0];
  List<String> _dailyActivities = [];
  int _currentBurnoutRisk = 3;
  double _skillAlignmentProgress = 0.0;
  Map<String, double> _skillProgress = {};
  Map<String, dynamic>? _weeklyPlan;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);

    try {
      _localStorageService = LocalStorageService();
      await _localStorageService.initialize();

      if (_localStorageService.currentUser != null) {
        final userId = _localStorageService.currentUser!['id'];

        // Load user profile
        _userProfile = await _localStorageService.getUserProfile(userId);

        // Load journal history
        _journalHistory = await _localStorageService.getJournalHistory(
          userId,
          limit: 30,
        );

        // Process real data from journal entries
        _processJournalData();

        // Generate AI weekly plan
        _weeklyPlan = _generateWeeklyPlan();
      }
    } catch (e) {
      print('Error loading dashboard data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _processJournalData() {
    if (_journalHistory.isEmpty) return;

    // Initialize weekly data
    _dailyStudyHours = [0, 0, 0, 0, 0, 0, 0];
    _dailyActivities = [];
    _skillProgress = {};

    DateTime now = DateTime.now();
    DateTime weekStart = now.subtract(Duration(days: now.weekday - 1));

    // Process each journal entry
    for (final journal in _journalHistory) {
      final entry = journal['entry'] as Map<String, dynamic>?;
      if (entry == null) continue;

      final entryDate = DateTime.parse(entry['date']);
      final dayIndex = (entryDate.difference(weekStart).inDays).clamp(0, 6);

      // Add study hours
      _dailyStudyHours[dayIndex] += (entry['study_hours'] as double?) ?? 0.0;

      // Create daily activity description
      final activities = <String>[];
      if (entry['dsa_problems_solved'] != null &&
          (entry['dsa_problems_solved'] as int) > 0) {
        activities.add('${entry['dsa_problems_solved']} DSA problems');
      }
      if (entry['what_studied']?.toString().isNotEmpty == true) {
        activities.add(entry['what_studied']);
      }
      if (entry['goal_practice']?.toString().isNotEmpty == true) {
        activities.add(entry['goal_practice']);
      }
      if (entry['games_played']?.toString().isNotEmpty == true) {
        activities.add('played ${entry['games_played']}');
      }
      if (entry['mood']?.toString().isNotEmpty == true) {
        activities.add('mood: ${entry['mood']}');
      }

      if (activities.isNotEmpty) {
        _dailyActivities.add(
          '${_getDayName(dayIndex)}: ${activities.join(', ')}',
        );
      }

      // Calculate burnout risk based on recent entries
      final studyHours = entry['study_hours'] as double? ?? 0.0;
      final mood = entry['mood'] as String? ?? 'neutral';

      if (studyHours > 10) _currentBurnoutRisk += 2;
      if (studyHours > 8) _currentBurnoutRisk += 1;
      if (['stressed', 'anxious', 'overwhelmed'].contains(mood)) {
        _currentBurnoutRisk += 2;
      }

      // Track skill progress
      final studiedSkills = _extractSkillsFromEntry(entry);
      for (final skill in studiedSkills) {
        _skillProgress[skill] = (_skillProgress[skill] ?? 0) + 5.0;
      }
    }

    _currentBurnoutRisk = _currentBurnoutRisk.clamp(1, 10);

    // Calculate skill alignment based on user goals
    if (_userProfile != null) {
      final userSkills = (_userProfile!['skills'] as List?) ?? [];
      final alignedSkills = userSkills
          .where((skill) => _skillProgress.containsKey(skill))
          .length;
      _skillAlignmentProgress = userSkills.isEmpty
          ? 0.0
          : alignedSkills / userSkills.length;
    }
  }

  List<String> _extractSkillsFromEntry(Map<String, dynamic> entry) {
    final text =
        '${entry['what_studied'] ?? ''} ${entry['goal_practice'] ?? ''}'
            .toLowerCase();
    final skills = <String>[];

    final skillKeywords = {
      'javascript': 'JavaScript',
      'react': 'React',
      'node': 'Node.js',
      'python': 'Python',
      'django': 'Django',
      'html': 'HTML',
      'css': 'CSS',
      'dsa': 'DSA',
      'algorithms': 'Algorithms',
      'data structures': 'Data Structures',
    };

    for (final keyword in skillKeywords.keys) {
      if (text.contains(keyword)) {
        skills.add(skillKeywords[keyword]!);
      }
    }

    return skills;
  }

  String _getDayName(int index) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return days[index];
  }

  Map<String, dynamic> _generateWeeklyPlan() {
    final userGoals = _userProfile?['goals']?.toString().toLowerCase() ?? '';
    final avgStudyHours = _dailyStudyHours.reduce((a, b) => a + b) / 7;

    return {
      'week': DateTime.now().weekOfMonth,
      'focus_goal': userGoals.contains('web')
          ? 'Web Development'
          : 'DSA Mastery',
      'daily_tasks': [
        'Monday: ${avgStudyHours > 6 ? 'Light study' : 'Focus on fundamentals'}',
        'Tuesday: Practice problems + 1 DSA problem',
        'Wednesday: ${userGoals.contains('web') ? 'React components' : 'Algorithm practice'}',
        'Thursday: Code review and optimization',
        'Friday: Mini-project development',
        'Saturday: Mock interview practice',
        'Sunday: Rest and review',
      ],
      'ai_recommendations': [
        'Based on your journal: ${_currentBurnoutRisk > 7 ? 'Take more breaks' : 'Good consistency'}',
        'Target: ${avgStudyHours < 4 ? 'Increase study time gradually' : 'Maintain current pace'}',
        'Focus: ${_skillAlignmentProgress < 0.5 ? 'Core skills' : 'Advanced topics'}',
      ],
      'performance_targets': {
        'study_hours': (avgStudyHours * 7).round(),
        'dsa_problems': 7, // 1 per day
        'project_completion': 80,
      },
    };
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
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EnhancedChatbotScreen()),
            ),
            icon: const Icon(Icons.chat, color: Colors.white),
            tooltip: 'AI Chat Assistant',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : RefreshIndicator(
              onRefresh: _loadDashboardData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTodayJournalButton(),
                    const SizedBox(height: 24),
                    _buildStudyTimeChart(),
                    const SizedBox(height: 24),
                    _buildBurnoutRiskCard(),
                    const SizedBox(height: 24),
                    _buildSkillAlignmentCard(),
                    const SizedBox(height: 24),
                    _buildDailyTrackingCard(),
                    const SizedBox(height: 24),
                    _buildWeeklyPlannerCard(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTodayJournalButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const DailyJournalScreen()),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00D9FF),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.edit, color: Colors.white),
            SizedBox(width: 8),
            Text(
              "Write Today's Journal",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudyTimeChart() {
    return _buildDashboardCard(
      '📊 Daily Study Time (Hours)',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 200,
            child: CustomPaint(
              size: const Size(double.infinity, 200),
              painter: StudyTimeBarChartPainter(_dailyStudyHours),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                .map(
                  (day) => Text(
                    day,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.trending_up, color: Colors.green, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Total: ${_dailyStudyHours.reduce((a, b) => a + b).toStringAsFixed(1)} hours this week',
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBurnoutRiskCard() {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              BurnoutDetailsScreen(burnoutRisk: _currentBurnoutRisk),
        ),
      ),
      child: _buildDashboardCard(
        '🔥 Burnout Risk',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Current Risk Level',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getBurnoutRiskColor().withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _getBurnoutRiskColor().withOpacity(0.5),
                    ),
                  ),
                  child: Text(
                    _getBurnoutRiskLabel(),
                    style: TextStyle(
                      color: _getBurnoutRiskColor(),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: _currentBurnoutRisk / 10.0,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(_getBurnoutRiskColor()),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildQuickAction(
                    '👥 Counselors',
                    'View available counselors',
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BurnoutDetailsScreen(
                          burnoutRisk: _currentBurnoutRisk,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickAction(
                    '🤖 AI Chat',
                    'Talk to AI assistant',
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EnhancedChatbotScreen(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Tap to see details →',
              style: TextStyle(color: const Color(0xFF00D9FF), fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillAlignmentCard() {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SkillRoadmapScreen()),
      ),
      child: _buildDashboardCard(
        '🎯 Skill Alignment Progress',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Overall Progress',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
                Text(
                  '${(_skillAlignmentProgress * 100).round()}%',
                  style: const TextStyle(
                    color: Color(0xFF00D9FF),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: _skillAlignmentProgress,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF00D9FF),
              ),
            ),
            const SizedBox(height: 16),
            ..._skillProgress.entries
                .take(4)
                .map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 80,
                          child: Text(
                            entry.key,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Expanded(
                          child: LinearProgressIndicator(
                            value: (entry.value / 100).clamp(0.0, 1.0),
                            backgroundColor: Colors.white.withOpacity(0.1),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              entry.value > 75
                                  ? Colors.green
                                  : entry.value > 50
                                  ? Colors.orange
                                  : Colors.red,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${entry.value.round()}%',
                          style: TextStyle(
                            color: entry.value > 75
                                ? Colors.green
                                : entry.value > 50
                                ? Colors.orange
                                : Colors.red,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            const SizedBox(height: 12),
            Text(
              'Tap to view roadmap →',
              style: TextStyle(color: const Color(0xFF00D9FF), fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyTrackingCard() {
    return _buildDashboardCard(
      '📅 Daily Tracking (AI Analyzed)',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'From your journal entries:',
            style: TextStyle(
              color: const Color(0xFF00D9FF),
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 16),
          if (_dailyActivities.isEmpty)
            Text(
              'No journal entries yet. Start journaling to see your daily activities!',
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 14,
              ),
            )
          else
            ..._dailyActivities.map(
              (activity) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  activity,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWeeklyPlannerCard() {
    if (_weeklyPlan == null) return const SizedBox.shrink();

    return _buildDashboardCard(
      '📋 AI Weekly Planner',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Focus: ${_weeklyPlan!['focus_goal']}',
            style: const TextStyle(
              color: Color(0xFF00D9FF),
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...(_weeklyPlan!['daily_tasks'] as List)
              .take(4)
              .map(
                (task) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        color: const Color(0xFF00D9FF),
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          task,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          const SizedBox(height: 12),
          Text(
            'Generated from your journal inputs',
            style: TextStyle(
              color: const Color(0xFF00D9FF),
              fontSize: 11,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardCard(String title, {required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.05),
            Colors.white.withOpacity(0.02),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildQuickAction(String title, String subtitle, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF00D9FF),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Color _getBurnoutRiskColor() {
    if (_currentBurnoutRisk >= 8) return Colors.red;
    if (_currentBurnoutRisk >= 5) return Colors.orange;
    return Colors.green;
  }

  String _getBurnoutRiskLabel() {
    if (_currentBurnoutRisk >= 8) return 'HIGH';
    if (_currentBurnoutRisk >= 5) return 'MODERATE';
    return 'LOW';
  }
}

// Custom painter for study time bar chart
class StudyTimeBarChartPainter extends CustomPainter {
  final List<double> data;

  StudyTimeBarChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    final maxVal = data.isNotEmpty
        ? data.reduce((a, b) => a > b ? a : b)
        : 10.0;
    final barWidth = (size.width - 40) / data.length;
    final spacing = 40.0 / (data.length - 1);

    for (int i = 0; i < data.length; i++) {
      final height = maxVal > 0 ? (data[i] / maxVal) * (size.height - 40) : 0.0;
      final left = i * (barWidth + spacing) + 20;
      final top = size.height - height - 20;

      // Draw bar with gradient
      final gradientPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF00D9FF),
            const Color(0xFFB829F7).withOpacity(0.8),
          ],
        ).createShader(Rect.fromLTWH(left, top, barWidth - 8, height));

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(left, top, barWidth - 8, height),
          const Radius.circular(4),
        ),
        gradientPaint,
      );

      // Draw value on top
      final textPainter = TextPainter(
        text: TextSpan(
          text: data[i].toStringAsFixed(1),
          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 10),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(left + (barWidth - 8 - textPainter.width) / 2, top - 15),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Extension for DateTime
extension DateTimeExtensions on DateTime {
  int get weekOfMonth {
    final firstDayOfMonth = DateTime(year, month, 1);
    final firstMonday = firstDayOfMonth.add(
      Duration(days: (8 - firstDayOfMonth.weekday) % 7),
    );
    if (isBefore(firstMonday)) return 0;
    final weekNumber = ((difference(firstMonday).inDays) / 7).floor() + 1;
    return weekNumber;
  }
}
