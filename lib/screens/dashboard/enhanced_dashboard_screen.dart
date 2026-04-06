import 'package:flutter/material.dart';
import '../../services/local_storage_service.dart';
import '../chatbot/enhanced_chatbot_screen.dart';

class EnhancedDashboardScreen extends StatefulWidget {
  const EnhancedDashboardScreen({super.key});

  @override
  State<EnhancedDashboardScreen> createState() =>
      _EnhancedDashboardScreenState();
}

class _EnhancedDashboardScreenState extends State<EnhancedDashboardScreen>
    with TickerProviderStateMixin {
  late LocalStorageService _localStorageService;
  Map<String, dynamic>? _userProfile;
  List<Map<String, dynamic>> _journalHistory = [];
  bool _isLoading = true;

  // Real data from journal entries
  List<double> _weeklyStudyHours = [0, 0, 0, 0, 0, 0, 0];
  List<String> _dailyActivities = [];
  int _currentBurnoutRisk = 3;
  double _skillAlignmentProgress = 0.0;
  Map<String, double> _skillProgress = {};

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _localStorageService = LocalStorageService();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _loadDashboardData();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);

    try {
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
    _weeklyStudyHours = [0, 0, 0, 0, 0, 0, 0];
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
      _weeklyStudyHours[dayIndex] += (entry['study_hours'] as double?) ?? 0.0;

      // Create daily activity description
      final activities = <String>[];
      if (entry['what_studied']?.toString().isNotEmpty == true) {
        activities.add(entry['what_studied']);
      }
      if (entry['dsa_problems_solved'] != null &&
          (entry['dsa_problems_solved'] as int) > 0) {
        activities.add('${entry['dsa_problems_solved']} DSA problems');
      }
      if (entry['goal_practice']?.toString().isNotEmpty == true) {
        activities.add(entry['goal_practice']);
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
          IconButton(
            onPressed: () => _showLogoutDialog(),
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : RefreshIndicator(
              onRefresh: _loadDashboardData,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildWelcomeHeader(),
                      const SizedBox(height: 24),
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
                      const SizedBox(height: 24),
                      _buildAIInsightsCard(),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildWelcomeHeader() {
    final userName = _userProfile?['name'] ?? 'Student';
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF00D9FF).withOpacity(0.2),
            const Color(0xFFB829F7).withOpacity(0.2),
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
          Text(
            'Welcome back, $userName! 👋',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Here\'s your learning progress and AI recommendations',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayJournalButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _navigateToJournal(),
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

  void _navigateToJournal() {
    // Navigate to journal screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Journal feature coming soon!'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Widget _buildStudyTimeChart() {
    return _buildDashboardCard(
      '📊 Weekly Study Hours',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 200,
            child: CustomPaint(
              size: const Size(double.infinity, 200),
              painter: StudyTimeBarChartPainter(_weeklyStudyHours),
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
                  'Total: ${_weeklyStudyHours.reduce((a, b) => a + b).toStringAsFixed(1)} hours this week',
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
      onTap: () => _showBurnoutDetails(),
      child: _buildDashboardCard(
        '🔥 Burnout Risk Assessment',
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
                    'Talk to Counselor',
                    Icons.person,
                    Colors.green,
                    () => _showCounselorOptions(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickAction(
                    'AI Chat Support',
                    Icons.chat,
                    const Color(0xFF00D9FF),
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
          ],
        ),
      ),
    );
  }

  Widget _buildSkillAlignmentCard() {
    return GestureDetector(
      onTap: () => _showSkillRoadmap(),
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
              'Tap to view detailed roadmap →',
              style: TextStyle(color: const Color(0xFF00D9FF), fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyTrackingCard() {
    return _buildDashboardCard(
      '📅 Daily Activity Tracking',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AI-Analyzed from Your Journal',
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
            ..._dailyActivities
                .take(5)
                .map(
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
          if (_dailyActivities.length > 5)
            Text(
              '... and ${_dailyActivities.length - 5} more activities',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 11,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWeeklyPlannerCard() {
    return _buildDashboardCard(
      '📋 AI-Generated Weekly Plan',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Focus: Web Development',
            style: TextStyle(
              color: Color(0xFF00D9FF),
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildPlanItem('Monday: Review HTML/CSS fundamentals'),
          _buildPlanItem('Tuesday: JavaScript basics and DOM'),
          _buildPlanItem('Wednesday: React components'),
          _buildPlanItem('Thursday: State management'),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _showFullWeeklyPlan(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.1),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'View Full Plan',
                style: TextStyle(color: Color(0xFF00D9FF)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanItem(String task) {
    return Padding(
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
    );
  }

  Widget _buildAIInsightsCard() {
    return _buildDashboardCard(
      '🤖 AI Insights & Recommendations',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildMetricChip('Productivity', '75%', Colors.green),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricChip(
                  'Burnout Risk',
                  '$_currentBurnoutRisk/10',
                  _getBurnoutRiskColor(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Key Insights:',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ..._generateInsights().map(
            (insight) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: const Color(0xFF00D9FF),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      insight,
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
          const SizedBox(height: 16),
          const Text(
            'Recommendations:',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ..._generateRecommendations().map(
            (rec) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '• $rec',
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

  List<String> _generateInsights() {
    return [
      'Your peak study time appears to be evenings',
      'You perform better with shorter, focused sessions',
      'Consistent daily practice shows better results than cramming',
    ];
  }

  List<String> _generateRecommendations() {
    final recommendations = <String>[];

    if (_currentBurnoutRisk > 7) {
      recommendations.add('🚨 High burnout risk! Consider taking a rest day');
    }
    if (_currentBurnoutRisk > 5) {
      recommendations.add('⚠️ Moderate burnout risk. Increase break frequency');
    }

    final avgHours = _weeklyStudyHours.reduce((a, b) => a + b) / 7;
    if (avgHours < 4) {
      recommendations.add('📈 Consider increasing daily study hours gradually');
    } else if (avgHours > 8) {
      recommendations.add('⏰ Reduce study hours to prevent burnout');
    }

    if (_skillAlignmentProgress < 0.5) {
      recommendations.add('🎯 Focus more on your core skill areas');
    }

    recommendations.add('💪 Keep up the consistent effort!');

    return recommendations;
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

  Widget _buildQuickAction(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(color: color, fontSize: 11),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(color: color.withOpacity(0.8), fontSize: 10),
          ),
        ],
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

  void _showBurnoutDetails() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text(
          'Burnout Risk Details',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Level: $_currentBurnoutRisk/10',
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              _getBurnoutRiskLabel(),
              style: TextStyle(color: _getBurnoutRiskColor()),
            ),
            const SizedBox(height: 16),
            const Text(
              'Recommendations:',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            ..._generateRecommendations().map(
              (rec) => Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text('• $rec', style: TextStyle(color: Colors.white70)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Close',
              style: TextStyle(color: Color(0xFF00D9FF)),
            ),
          ),
        ],
      ),
    );
  }

  void _showCounselorOptions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text(
          'Counselor Support',
          style: TextStyle(color: Colors.white),
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Available Counselors:',
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.person, color: Colors.green),
              title: Text(
                'Dr. Sarah Johnson',
                style: TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                'Specializes in student mental health',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            ListTile(
              leading: Icon(Icons.person, color: Colors.green),
              title: Text(
                'Dr. Michael Chen',
                style: TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                'Focus on academic stress management',
                style: TextStyle(color: Colors.white70),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Close',
              style: TextStyle(color: Color(0xFF00D9FF)),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Session scheduling feature coming soon!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text(
              'Schedule Session',
              style: TextStyle(color: Colors.green),
            ),
          ),
        ],
      ),
    );
  }

  void _showSkillRoadmap() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text(
          'Skill Roadmap',
          style: TextStyle(color: Colors.white),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Your Progress: ${(_skillAlignmentProgress * 100).round()}%',
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),
              ..._skillProgress.entries.map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 100,
                        child: Text(
                          entry.key,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      Expanded(
                        child: LinearProgressIndicator(
                          value: entry.value / 100,
                        ),
                      ),
                      SizedBox(
                        width: 8,
                        child: Text(
                          '${entry.value.round()}%',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Close',
              style: TextStyle(color: Color(0xFF00D9FF)),
            ),
          ),
        ],
      ),
    );
  }

  void _showFullWeeklyPlan() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text(
          'Weekly Plan - Web Development',
          style: TextStyle(color: Colors.white),
        ),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Daily Tasks:',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '• Monday: Review HTML/CSS fundamentals',
                style: TextStyle(color: Colors.white70),
              ),
              Text(
                '• Tuesday: JavaScript basics and DOM',
                style: TextStyle(color: Colors.white70),
              ),
              Text(
                '• Wednesday: React components',
                style: TextStyle(color: Colors.white70),
              ),
              Text(
                '• Thursday: State management',
                style: TextStyle(color: Colors.white70),
              ),
              Text(
                '• Friday: Build mini-project',
                style: TextStyle(color: Colors.white70),
              ),
              Text(
                '• Saturday: Code review and optimization',
                style: TextStyle(color: Colors.white70),
              ),
              Text(
                '• Sunday: Rest and review',
                style: TextStyle(color: Colors.white70),
              ),
              SizedBox(height: 16),
              Text(
                'AI Recommendations:',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '• Focus on consistency over intensity',
                style: TextStyle(color: Colors.white70),
              ),
              Text(
                '• Take breaks every 45 minutes',
                style: TextStyle(color: Colors.white70),
              ),
              Text(
                '• Review previous day\'s concepts before starting new ones',
                style: TextStyle(color: Colors.white70),
              ),
              SizedBox(height: 16),
              Text(
                'Performance Targets:',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '• Study hours: 35',
                style: TextStyle(color: Colors.white70),
              ),
              Text(
                '• DSA problems: 15',
                style: TextStyle(color: Colors.white70),
              ),
              Text(
                '• Project completion: 80%',
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Close',
              style: TextStyle(color: Color(0xFF00D9FF)),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text('Logout', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
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
