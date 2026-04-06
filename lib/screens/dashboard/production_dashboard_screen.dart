import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../models/journal_entry.dart';
import '../../models/burnout_score.dart';
import '../../models/skill_progress.dart';
import '../../models/weekly_plan.dart';
import '../../services/local_storage_service.dart';
import '../../services/analytics_service.dart';
import '../journal/production_journal_screen.dart';
import '../skills/enhanced_skill_roadmap_screen.dart';
import '../burnout/burnout_details_screen.dart';
import '../chatbot/enhanced_chatbot_screen.dart';

class ProductionDashboardScreen extends StatefulWidget {
  const ProductionDashboardScreen({super.key});

  @override
  State<ProductionDashboardScreen> createState() =>
      _ProductionDashboardScreenState();
}

class _ProductionDashboardScreenState extends State<ProductionDashboardScreen> {
  late LocalStorageService _localStorageService;

  // Data models
  List<JournalEntry> _journalEntries = [];
  BurnoutScore? _burnoutScore;
  Map<String, SkillProgress> _skillProgress = {};
  WeeklyPlan? _weeklyPlan;

  bool _isLoading = true;

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

        // Load user profile to get registered skills
        final userProfile = await _localStorageService.getUserProfile(userId);
        final userSkills =
            (userProfile?['skills'] as List?)?.cast<String>() ?? <String>[];

        // Load raw journal entries
        final rawJournalHistory = await _localStorageService.getJournalHistory(
          userId,
          limit: 30,
        );

        // Convert to JournalEntry models
        _journalEntries = rawJournalHistory
            .map((journal) {
              final entry = journal['entry'] as Map<String, dynamic>?;
              if (entry == null) return null;

              return JournalEntry.fromJson(entry);
            })
            .where((entry) => entry != null)
            .cast<JournalEntry>()
            .toList();

        // Generate analytics using the service with user skills
        _burnoutScore = AnalyticsService.calculateBurnoutScore(_journalEntries);
        _skillProgress = AnalyticsService.calculateSkillProgress(
          _journalEntries,
          userSkills,
        );
        _weeklyPlan = AnalyticsService.generateWeeklyPlan(
          _journalEntries,
          _skillProgress,
        );
      }
    } catch (e) {
      print('Error loading dashboard data: $e');
      // Show error to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
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
          MaterialPageRoute(builder: (_) => const ProductionJournalScreen()),
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
    // Get last 7 days of study data
    final now = DateTime.now();
    final weekData = <String, Map<String, double>>{};

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dayKey = _getDayName(date.weekday);

      // Find entries for this day
      final dayEntries = _journalEntries.where((entry) {
        return entry.date.year == date.year &&
            entry.date.month == date.month &&
            entry.date.day == date.day;
      }).toList();

      // Sum study hours by category
      final dailyHours = <String, double>{};
      for (final entry in dayEntries) {
        for (final category in entry.studyHours.entries) {
          dailyHours[category.key] =
              (dailyHours[category.key] ?? 0) + category.value;
        }
      }

      weekData[dayKey] = dailyHours;
    }

    return _buildDashboardCard(
      '📊 Daily Study Time (Last 7 Days)',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 200,
            child: CustomPaint(
              size: const Size(double.infinity, 200),
              painter: StudyTimeBarChartPainter(weekData),
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
          _buildStudyTimeLegend(),
        ],
      ),
    );
  }

  Widget _buildStudyTimeLegend() {
    final categories = ['DSA', 'Web Dev', 'AI/ML', 'Other'];
    final colors = [Colors.green, Colors.blue, Colors.purple, Colors.orange];

    return Wrap(
      spacing: 12,
      children: List.generate(categories.length, (index) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: colors[index],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              categories[index],
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 11,
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildBurnoutRiskCard() {
    if (_burnoutScore == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              BurnoutDetailsScreen(burnoutRisk: _burnoutScore!.score.round()),
        ),
      ),
      child: _buildDashboardCard(
        '🔥 Burnout Risk Indicator',
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
                    color: _burnoutScore!.riskColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _burnoutScore!.riskColor.withOpacity(0.5),
                    ),
                  ),
                  child: Text(
                    _burnoutScore!.riskLevel.toUpperCase(),
                    style: TextStyle(
                      color: _burnoutScore!.riskColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: _burnoutScore!.score / 100.0,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                _burnoutScore!.riskColor,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Score: ${_burnoutScore!.score.round()}/100',
              style: TextStyle(
                color: _burnoutScore!.riskColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _burnoutScore!.riskDescription,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
              ),
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
                          burnoutRisk: _burnoutScore!.score.round(),
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
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Tap for detailed analysis →',
                style: TextStyle(color: const Color(0xFF00D9FF), fontSize: 11),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillAlignmentCard() {
    if (_skillProgress.isEmpty) return const SizedBox.shrink();

    // Calculate overall alignment
    final totalSkills = _skillProgress.length;
    final avgProgress =
        _skillProgress.values
            .map((skill) => skill.progressPercentage)
            .reduce((a, b) => a + b) /
        totalSkills;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const EnhancedSkillRoadmapScreen()),
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
                  '${avgProgress.round()}%',
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
              value: avgProgress / 100.0,
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
                            value: (entry.value.progressPercentage / 100.0)
                                .clamp(0.0, 1.0),
                            backgroundColor: Colors.white.withOpacity(0.1),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              entry.value.progressPercentage > 75
                                  ? Colors.green
                                  : entry.value.progressPercentage > 50
                                  ? Colors.orange
                                  : Colors.red,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${entry.value.progressPercentage.round()}%',
                          style: TextStyle(
                            color: entry.value.progressPercentage > 75
                                ? Colors.green
                                : entry.value.progressPercentage > 50
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
            Center(
              child: Text(
                'Tap to view detailed roadmap →',
                style: TextStyle(color: const Color(0xFF00D9FF), fontSize: 11),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyTrackingCard() {
    return _buildDashboardCard(
      '📅 Daily Activity Tracking (AI Analyzed)',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Timeline from your journal entries:',
            style: TextStyle(
              color: const Color(0xFF00D9FF),
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 16),
          if (_journalEntries.isEmpty)
            Text(
              'No journal entries yet. Start journaling to see your daily activities!',
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 14,
              ),
            )
          else
            ..._journalEntries
                .take(7)
                .map(
                  (entry) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getDayName(entry.date.weekday),
                          style: const TextStyle(
                            color: Color(0xFF00D9FF),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (entry.studyHours['DSA']! > 0)
                          Text(
                            '• DSA: ${entry.studyHours['DSA']!.toStringAsFixed(1)} hrs',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 11,
                            ),
                          ),
                        if (entry.studyHours['Web Dev']! > 0)
                          Text(
                            '• Web Dev: ${entry.studyHours['Web Dev']!.toStringAsFixed(1)} hrs',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 11,
                            ),
                          ),
                        if (entry.studyHours['AI/ML']! > 0)
                          Text(
                            '• AI/ML: ${entry.studyHours['AI/ML']!.toStringAsFixed(1)} hrs',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 11,
                            ),
                          ),
                        if (entry.tasksCompleted.isNotEmpty)
                          Text(
                            '• Tasks: ${entry.tasksCompleted.join(', ')}',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 11,
                            ),
                          ),
                        if (entry.breakActivities['games']! > 0)
                          Text(
                            '• Games: ${entry.breakActivities['games']!.toStringAsFixed(1)} hrs',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 11,
                            ),
                          ),
                        Text(
                          '• Mood: ${entry.mood}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 11,
                          ),
                        ),
                        Text(
                          '• Sleep: ${entry.sleepHours.toStringAsFixed(1)} hrs',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 11,
                          ),
                        ),
                      ],
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
            'Focus: ${_weeklyPlan!.focusGoal}',
            style: const TextStyle(
              color: Color(0xFF00D9FF),
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _weeklyPlan!.weekDescription,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),
          ...(_weeklyPlan!.dailyTasks)
              .take(4)
              .map(
                (task) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
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
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF00D9FF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Weekly Targets:',
                  style: const TextStyle(
                    color: Color(0xFF00D9FF),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                ...(_weeklyPlan!.targets).entries.map(
                  (target) => Text(
                    '• ${target.key}: ${target.value}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Generated from your journal inputs',
            style: TextStyle(
              color: const Color(0xFF00D9FF),
              fontSize: 10,
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

  String _getDayName(int weekday) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return days[weekday - 1];
  }
}

// Custom painter for study time bar chart with categories
class StudyTimeBarChartPainter extends CustomPainter {
  final Map<String, Map<String, double>> data;
  final List<Color> colors = [
    Colors.green,
    Colors.blue,
    Colors.purple,
    Colors.orange,
  ];
  final List<String> categories = ['DSA', 'Web Dev', 'AI/ML', 'Other'];

  StudyTimeBarChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final days = data.keys.toList();
    final barWidth = (size.width - 40) / days.length;
    final spacing = 40.0 / (days.length - 1);

    // Find max value for scaling
    double maxValue = 0;
    for (final dayData in data.values) {
      for (final hours in dayData.values) {
        maxValue = math.max(maxValue, hours);
      }
    }
    maxValue = maxValue > 0 ? maxValue : 10.0;

    for (int i = 0; i < days.length; i++) {
      final day = days[i];
      final dayData = data[day]!;
      final left = i * (barWidth + spacing) + 20;

      // Draw stacked bars for each category
      double currentHeight = 0;
      for (int j = 0; j < categories.length; j++) {
        final category = categories[j];
        final hours = dayData[category] ?? 0.0;

        if (hours > 0) {
          final height = (hours / maxValue) * (size.height - 40);
          final top = size.height - height - currentHeight - 20;

          final paint = Paint()
            ..shader = LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [colors[j], colors[j].withOpacity(0.7)],
            ).createShader(Rect.fromLTWH(left, top, barWidth - 8, height));

          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(left, top, barWidth - 8, height),
              const Radius.circular(2),
            ),
            paint,
          );

          currentHeight += height;
        }
      }

      // Draw total value on top
      final totalHours = dayData.values.fold(0.0, (sum, hours) => sum + hours);
      if (totalHours > 0) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: totalHours.toStringAsFixed(1),
            style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 9),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(
            left + (barWidth - 8 - textPainter.width) / 2,
            size.height - currentHeight - 30,
          ),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
