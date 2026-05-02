import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../models/journal_entry.dart';
import '../../models/burnout_score.dart';
import '../../models/skill_progress.dart';
import '../../models/weekly_plan.dart';
import '../../services/local_storage_service.dart';
import '../../services/analytics_service.dart';
import '../skills/enhanced_skill_roadmap_screen.dart';
import '../burnout/burnout_details_screen.dart';
import '../chatbot/enhanced_chatbot_screen.dart';
import '../notebook/notebook_screen.dart';
import '../journal/enhanced_journal_screen.dart';
import '../settings/settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class DayEntry {
  DateTime date;
  Map<String, double> studyHours;
  List<String> tasksCompleted;
  String mood;
  double sleepHours;
  double totalStudyHours;
  String aiSummary;
  List<String> aiSuggestions;
  List<String> skillsDetected;
  int burnoutRisk;
  int stressLevel;

  DayEntry({
    required this.date,
    required this.studyHours,
    required this.tasksCompleted,
    required this.mood,
    required this.sleepHours,
    required this.totalStudyHours,
    required this.aiSummary,
    required this.aiSuggestions,
    required this.skillsDetected,
    required this.burnoutRisk,
    required this.stressLevel,
  });
}

// Enhanced detail screens for navigation
class WeeklyPlanDetailsScreen extends StatelessWidget {
  final WeeklyPlan weeklyPlan;

  const WeeklyPlanDetailsScreen({super.key, required this.weeklyPlan});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        title: const Text('📋 AI Weekly Plan Details'),
        backgroundColor: const Color(0xFF1A1A2E),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with progress
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF00D9FF).withOpacity(0.2),
                    const Color(0xFF00D9FF).withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF00D9FF).withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.emoji_events,
                        color: const Color(0xFF00D9FF),
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'This Week\'s Focus',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              weeklyPlan.focusGoal,
                              style: const TextStyle(
                                color: Color(0xFF00D9FF),
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        weeklyPlan.weekDescription,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: weeklyPlan.completionPercentage >= 75
                              ? Colors.green.withOpacity(0.2)
                              : weeklyPlan.completionPercentage >= 50
                              ? Colors.orange.withOpacity(0.2)
                              : Colors.red.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: weeklyPlan.completionPercentage >= 75
                                ? Colors.green
                                : weeklyPlan.completionPercentage >= 50
                                ? Colors.orange
                                : Colors.red,
                          ),
                        ),
                        child: Text(
                          '${weeklyPlan.completionPercentage.round()}% Complete',
                          style: TextStyle(
                            color: weeklyPlan.completionPercentage >= 75
                                ? Colors.green
                                : weeklyPlan.completionPercentage >= 50
                                ? Colors.orange
                                : Colors.red,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: weeklyPlan.completionPercentage / 100.0,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      weeklyPlan.completionPercentage >= 75
                          ? Colors.green
                          : weeklyPlan.completionPercentage >= 50
                          ? Colors.orange
                          : Colors.red,
                    ),
                    minHeight: 8,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // All Tasks Section
            _buildSectionCard(
              '🎯 All Tasks for This Week',
              'Your AI-curated learning journey',
              Icons.task_alt,
              Colors.blue,
              Column(
                children: weeklyPlan.dailyTasks.asMap().entries.map((entry) {
                  final priority = entry.key + 1;
                  final task = entry.value;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: _getPriorityColor(
                              priority - 1,
                            ).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _getPriorityColor(priority - 1),
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '$priority',
                              style: TextStyle(
                                color: _getPriorityColor(priority - 1),
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            task,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.check_circle_outline,
                          color: Colors.green.withOpacity(0.6),
                          size: 20,
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 24),

            // Detailed Targets
            _buildSectionCard(
              '🎯 Weekly Learning Targets',
              'Specific goals to achieve mastery',
              Icons.track_changes,
              Colors.green,
              Column(
                children: weeklyPlan.targets.entries.map((target) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.trending_up, color: Colors.green, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                target.key,
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                target.value.toString(),
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 24),

            // AI Recommendations & Encouragement
            _buildSectionCard(
              '🤖 AI Insights & Encouragement',
              'Personalized recommendations for your success',
              Icons.psychology,
              Colors.purple,
              Column(
                children: weeklyPlan.recommendations.map((recommendation) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.purple.withOpacity(0.1),
                          Colors.purple.withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.purple.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.lightbulb,
                              color: Colors.purple,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                recommendation,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _getEncouragementMessage(),
                          style: TextStyle(
                            color: Colors.purple.withOpacity(0.8),
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 24),

            // Motivational Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.orange.withOpacity(0.2),
                    Colors.red.withOpacity(0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Icon(Icons.emoji_objects, color: Colors.orange, size: 40),
                  const SizedBox(height: 12),
                  const Text(
                    '💪 Keep Going!',
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Every step forward is progress. You\'re doing amazing!',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Remember: Small consistent efforts lead to extraordinary results!',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    Widget child,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(padding: const EdgeInsets.all(16), child: child),
        ],
      ),
    );
  }

  Color _getPriorityColor(int index) {
    if (index == 0) return Colors.red;
    if (index == 1) return Colors.orange;
    if (index == 2) return Colors.blue;
    return Colors.green;
  }

  String _getEncouragementMessage() {
    final messages = [
      'You\'re building momentum! Keep it up! 🔥',
      'Every expert was once a beginner. You\'re on your way! 🌟',
      'Progress is progress, no matter how small! 💪',
      'Your consistency is your superpower! ⚡',
      'Trust the process and keep showing up! 🎯',
      'You\'re creating the future you! 🚀',
    ];
    return messages[(weeklyPlan.focusGoal.length +
            weeklyPlan.dailyTasks.length) %
        messages.length];
  }
}

class DailyActivityDetailsScreen extends StatelessWidget {
  final List<JournalEntry> journalEntries;
  final List<DayEntry> consolidatedEntries;

  const DailyActivityDetailsScreen({
    super.key,
    required this.journalEntries,
    required this.consolidatedEntries,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        title: Text(
          '📅 Daily Activity Details (${consolidatedEntries.length} days)',
        ),
        backgroundColor: const Color(0xFF1A1A2E),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Stats
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF00D9FF).withOpacity(0.2),
                    const Color(0xFF00D9FF).withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF00D9FF).withOpacity(0.3),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(
                        '📚',
                        'Study Days',
                        '${consolidatedEntries.where((e) => e.totalStudyHours > 0).length}',
                      ),
                      _buildStatItem(
                        '⏰',
                        'Total Hours',
                        consolidatedEntries
                            .fold(0.0, (sum, e) => sum + e.totalStudyHours)
                            .toStringAsFixed(1),
                      ),
                      _buildStatItem(
                        '🎯',
                        'Tasks Done',
                        '${consolidatedEntries.fold(0, (sum, e) => sum + e.tasksCompleted.length)}',
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Detailed Daily Breakdown
            Text(
              '📊 Detailed Daily Analysis',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            ...consolidatedEntries.map(
              (dayEntry) => _buildDetailedDayCard(dayEntry),
            ),

            const SizedBox(height: 24),

            // Encouragement Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.green.withOpacity(0.2),
                    Colors.blue.withOpacity(0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Icon(Icons.trending_up, color: Colors.green, size: 40),
                  const SizedBox(height: 12),
                  const Text(
                    '🎉 Amazing Progress!',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getMotivationalMessage(),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Remember: Every journal entry is a step toward your goals!',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String emoji, String label, String value) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF00D9FF),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildDetailedDayCard(DayEntry dayEntry) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Day Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF00D9FF).withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00D9FF).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _getDayName(dayEntry.date.weekday),
                    style: const TextStyle(
                      color: Color(0xFF00D9FF),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${dayEntry.date.day}/${dayEntry.date.month}/${dayEntry.date.year}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                if (dayEntry.totalStudyHours > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${dayEntry.totalStudyHours.toStringAsFixed(1)}h studied',
                      style: const TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Detailed Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Study Hours Breakdown
                if (dayEntry.studyHours.isNotEmpty) ...[
                  _buildDetailSection(
                    '📚 Study Sessions',
                    'Detailed breakdown by category',
                    Icons.schedule,
                    Colors.blue,
                    Column(
                      children: dayEntry.studyHours.entries
                          .where((entry) => entry.value > 0)
                          .map(
                            (entry) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Center(
                                      child: Text(
                                        entry.key.substring(0, 3).toUpperCase(),
                                        style: const TextStyle(
                                          color: Colors.blue,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          entry.key,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          '${entry.value.toStringAsFixed(1)} hours focused learning',
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(
                                              0.7,
                                            ),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '${entry.value.toStringAsFixed(1)}h',
                                    style: const TextStyle(
                                      color: Colors.blue,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],

                // Tasks Completed
                if (dayEntry.tasksCompleted.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildDetailSection(
                    '✅ Tasks Completed',
                    'Great job on these accomplishments',
                    Icons.task_alt,
                    Colors.green,
                    Column(
                      children: dayEntry.tasksCompleted.asMap().entries.map((
                        entry,
                      ) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.check,
                                    color: Colors.green,
                                    size: 16,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  entry.value,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              Text(
                                '#${entry.key + 1}',
                                style: TextStyle(
                                  color: Colors.green.withOpacity(0.6),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],

                // Mood & Wellness
                if (dayEntry.mood.isNotEmpty || dayEntry.sleepHours > 0) ...[
                  const SizedBox(height: 16),
                  _buildDetailSection(
                    '🧘 Wellness Check',
                    'Your mental and physical well-being',
                    Icons.favorite,
                    Colors.purple,
                    Column(
                      children: [
                        if (dayEntry.mood.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.mood,
                                  color: Colors.purple,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Today\'s Mood',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        dayEntry.mood,
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.8),
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getMoodColor(
                                      dayEntry.mood,
                                    ).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    _getMoodEmoji(dayEntry.mood),
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (dayEntry.sleepHours > 0)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.bedtime,
                                  color: Colors.indigo,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Sleep Duration',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '${dayEntry.sleepHours.toStringAsFixed(1)} hours',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.8),
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        _getSleepQuality(dayEntry.sleepHours),
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.6),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  _getSleepIcon(dayEntry.sleepHours),
                                  color: _getSleepColor(dayEntry.sleepHours),
                                  size: 24,
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],

                if (dayEntry.aiSummary.isNotEmpty ||
                    dayEntry.aiSuggestions.isNotEmpty ||
                    dayEntry.skillsDetected.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildDetailSection(
                    'AI Daily Report',
                    'Structured insight from your journal entry',
                    Icons.auto_awesome,
                    const Color(0xFF00D9FF),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (dayEntry.aiSummary.isNotEmpty)
                          Text(
                            dayEntry.aiSummary,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.85),
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                        if (dayEntry.skillsDetected.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: dayEntry.skillsDetected
                                .map(
                                  (skill) => Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFF00D9FF,
                                      ).withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      skill,
                                      style: const TextStyle(
                                        color: Color(0xFF00D9FF),
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                        if (dayEntry.aiSuggestions.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          ...dayEntry.aiSuggestions
                              .take(3)
                              .map(
                                (suggestion) => Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: Text(
                                    '- $suggestion',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.75),
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                        ],
                      ],
                    ),
                  ),
                ],

                // Daily Encouragement
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.orange.withOpacity(0.1),
                        Colors.yellow.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.emoji_objects, color: Colors.orange, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _getDailyEncouragement(dayEntry),
                          style: TextStyle(
                            color: Colors.orange.withOpacity(0.9),
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    Widget child,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
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

  Color _getMoodColor(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy':
      case 'excited':
        return Colors.yellow;
      case 'focused':
      case 'productive':
        return Colors.green;
      case 'tired':
      case 'stressed':
        return Colors.orange;
      case 'sad':
      case 'anxious':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  String _getMoodEmoji(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy':
        return '😊';
      case 'excited':
        return '🎉';
      case 'focused':
        return '🎯';
      case 'productive':
        return '💪';
      case 'tired':
        return '😴';
      case 'stressed':
        return '😰';
      case 'sad':
        return '😢';
      case 'anxious':
        return '😟';
      default:
        return '😐';
    }
  }

  String _getSleepQuality(double hours) {
    if (hours >= 8) return 'Excellent rest! 💤';
    if (hours >= 7) return 'Good sleep! 😴';
    if (hours >= 6) return 'Fair rest 😌';
    if (hours >= 5) return 'Could use more rest 😪';
    return 'Prioritize rest tonight! 🛏️';
  }

  IconData _getSleepIcon(double hours) {
    if (hours >= 8) return Icons.bedtime;
    if (hours >= 7) return Icons.hotel;
    if (hours >= 6) return Icons.night_shelter;
    return Icons.warning;
  }

  Color _getSleepColor(double hours) {
    if (hours >= 8) return Colors.green;
    if (hours >= 7) return Colors.blue;
    if (hours >= 6) return Colors.orange;
    return Colors.red;
  }

  String _getDailyEncouragement(DayEntry dayEntry) {
    if (dayEntry.totalStudyHours > 6) {
      return 'Incredible dedication! Your hard work is paying off! 🌟';
    } else if (dayEntry.totalStudyHours > 4) {
      return 'Great focus today! You\'re building momentum! 💪';
    } else if (dayEntry.totalStudyHours > 2) {
      return 'Consistent effort wins the race! Keep going! 🎯';
    } else if (dayEntry.tasksCompleted.isNotEmpty) {
      return 'Every task completed is a victory! Well done! ✅';
    } else {
      return 'Every day is a new opportunity! Tomorrow is fresh start! 🌅';
    }
  }

  String _getMotivationalMessage() {
    final totalHours = consolidatedEntries.fold(
      0.0,
      (sum, e) => sum + e.totalStudyHours,
    );
    final totalTasks = consolidatedEntries.fold(
      0,
      (sum, e) => sum + e.tasksCompleted.length,
    );

    if (totalHours > 20) {
      return 'You\'ve accumulated over ${totalHours.toStringAsFixed(1)} hours of focused learning! That\'s incredible dedication! 🚀';
    } else if (totalTasks > 15) {
      return 'You\'ve completed $totalTasks tasks! Each task is building your expertise! 🎯';
    } else if (consolidatedEntries.length > 7) {
      return '${consolidatedEntries.length} days of consistent tracking! Your discipline is inspiring! 💪';
    } else {
      return 'Every journey begins with a single step. You\'re on your way to greatness! 🌟';
    }
  }
}

class _DashboardScreenState extends State<DashboardScreen> {
  late LocalStorageService _localStorageService;

  // Data models
  List<JournalEntry> _journalEntries = [];
  List<Map<String, dynamic>> _rawJournalHistory = [];
  BurnoutScore? _burnoutScore;
  Map<String, SkillProgress> _skillProgress = {};
  WeeklyPlan? _weeklyPlan;
  int _studyStreak = 0;

  // AI Analysis Data
  List<Map<String, dynamic>> _enhancedEntries = [];
  List<String> _aiBurnoutRecommendations = [];
  Map<String, Map<String, dynamic>> _aiSkillInsights = {};
  List<String> _aiWeeklyRecommendations = [];

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
        _rawJournalHistory = rawJournalHistory;

        // Convert to JournalEntry models
        _journalEntries = rawJournalHistory
            .map((journal) {
              return _normalizeStoredEntry(journal);
            })
            .where((entry) => entry != null)
            .cast<JournalEntry>()
            .toList();
        _journalEntries.sort((a, b) => b.date.compareTo(a.date));

        // Calculate study streak
        _studyStreak = _calculateStudyStreak();

        // Generate analytics using the service with user skills
        _burnoutScore = AnalyticsService.calculateBurnoutScore(_journalEntries);
        _skillProgress = AnalyticsService.calculateSkillProgress(
          _journalEntries,
          userSkills,
          history: rawJournalHistory,
        );
        _weeklyPlan = AnalyticsService.generateWeeklyPlan(
          _journalEntries,
          _skillProgress,
        );
      }
    } catch (e) {
      print('Error loading dashboard data: $e');
      print('Stack trace: ${StackTrace.current}');

      // Set default values to prevent crashes
      _journalEntries = [];
      _rawJournalHistory = [];
      _burnoutScore = null;
      _skillProgress = {};
      _weeklyPlan = null;
      _studyStreak = 0;

      // Show error to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading dashboard: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  int _calculateStudyStreak() {
    if (_journalEntries.isEmpty) return 0;

    int streak = 0;
    DateTime currentDate = DateTime.now();

    for (int i = 0; i < 365; i++) {
      // Check up to a year
      final checkDate = currentDate.subtract(Duration(days: i));

      // Check if there's a journal entry for this date
      bool hasEntry = _journalEntries.any(
        (entry) =>
            entry.date.year == checkDate.year &&
            entry.date.month == checkDate.month &&
            entry.date.day == checkDate.day &&
            entry.totalStudyHours > 0,
      ); // Must have studied

      if (hasEntry) {
        streak++;
      } else if (i > 0) {
        // Allow today to not have entry yet
        break;
      }
    }

    return streak;
  }

  // Real-time AI analysis for graphs and activities
  Future<void> _performRealTimeAIAnalysis() async {
      try {
        // AI-powered analysis of recent activities
        if (_journalEntries.isNotEmpty) {
          // Analyze study patterns and generate insights
          final recentEntries = _journalEntries.take(7).toList();

          // Create enhanced entries with AI analysis
          final enhancedEntries = <Map<String, dynamic>>[];

          for (final entry in recentEntries) {
            // Generate AI insights for each entry
            final aiSummary = await _generateAIInsight(entry);
            final aiSuggestions = await _generateAISuggestions(entry);
            final detectedSkills = await _detectSkillsFromEntry(entry);

            // Create enhanced entry data
            enhancedEntries.add({
              'entry': entry,
              'aiSummary': aiSummary,
              'aiSuggestions': aiSuggestions,
              'detectedSkills': detectedSkills,
            });
          }

          // Update burnout risk with AI precision
          if (_burnoutScore != null) {
            final aiRecommendations = await _generateAIRecommendations(
              _burnoutScore!.score,
            );
            // Store AI recommendations in dashboard state
            _aiBurnoutRecommendations = aiRecommendations;
          }

          // Enhance skill progress with AI predictions
          for (final skillName in _skillProgress.keys) {
            final skill = _skillProgress[skillName]!;
            final aiPrediction = await _generateSkillPrediction(skill);
            final aiRecommendations = await _generateSkillRecommendations(
              skill,
            );

            // Store AI insights in dashboard state
            _aiSkillInsights[skillName] = {
              'prediction': aiPrediction,
              'recommendations': aiRecommendations,
            };
          }

          // Generate AI-enhanced weekly plan
          if (_weeklyPlan != null) {
            final aiRecommendations = await _generateWeeklyAIRecommendations(
              _weeklyPlan!,
            );
            _aiWeeklyRecommendations = aiRecommendations;
          }

          // Store enhanced entries for display
          _enhancedEntries = enhancedEntries;
        }
      } catch (e) {
        print('Error in real-time AI analysis: $e');
        // Continue without AI analysis if it fails
      }
    }

    // AI Insight Generation
    Future<String> _generateAIInsight(JournalEntry entry) async {
      // Simulate AI analysis (in real app, use actual AI API)
      final insights = [
        "Great consistency in your studies!",
        "Your focus time shows excellent concentration.",
        "Consider balancing theory with more practice problems.",
        "Your study schedule is well-structured for learning.",
        "Amazing progress in problem-solving skills!",
      ];

      return insights[DateTime.now().millisecond % insights.length];
    }

    // AI Suggestions Generation
    Future<List<String>> _generateAISuggestions(JournalEntry entry) async {
      final suggestions = <String>[];

      // Calculate total study hours
      final totalHours = entry.studyHours.values.fold(
        0.0,
        (sum, hours) => sum + hours,
      );

      if (totalHours > 8) {
        suggestions.add("Consider taking more breaks to maintain focus");
      }
      if (entry.mood == 'stressed' || entry.mood == 'exhausted') {
        suggestions.add("Try meditation or light exercise to reduce stress");
      }
      if (entry.tasksCompleted.length < 3) {
        suggestions.add("Increase daily practice for better problem-solving");
      }
      if (entry.sleepHours < 6) {
        suggestions.add("Prioritize sleep for better learning retention");
      }

      return suggestions.isEmpty
          ? ["Keep up the great work! You're on track."]
          : suggestions;
    }

    // AI Skill Detection
    Future<List<String>> _detectSkillsFromEntry(JournalEntry entry) async {
      final detectedSkills = <String>[];
      final text = "${entry.tasksCompleted.join(' ')} ${entry.notes}"
          .toLowerCase();

      // AI-powered skill detection
      final skillKeywords = {
        'react': ['react', 'jsx', 'component', 'hooks'],
        'javascript': ['javascript', 'js', 'es6', 'async', 'promise'],
        'python': ['python', 'django', 'flask', 'numpy'],
        'data structures': [
          'array',
          'linked list',
          'tree',
          'graph',
          'stack',
          'queue',
        ],
        'algorithms': [
          'sorting',
          'searching',
          'dynamic programming',
          'recursion',
        ],
        'database': ['sql', 'mysql', 'mongodb', 'query'],
        'web development': ['html', 'css', 'frontend', 'backend'],
      };

      for (final skill in skillKeywords.keys) {
        for (final keyword in skillKeywords[skill]!) {
          if (text.contains(keyword)) {
            detectedSkills.add(skill);
            break;
          }
        }
      }

      return detectedSkills;
    }

    // AI Recommendations for Burnout
    Future<List<String>> _generateAIRecommendations(double burnoutScore) async {
      final recommendations = <String>[];

      if (burnoutScore > 70) {
        recommendations.addAll([
          "Immediate rest required - take a day off",
          "Reduce study hours by 30% for this week",
          "Focus on relaxation techniques",
        ]);
      } else if (burnoutScore > 50) {
        recommendations.addAll([
          "Increase break frequency during study sessions",
          "Consider lighter study topics for 2-3 days",
          "Practice mindfulness exercises",
        ]);
      } else {
        recommendations.addAll([
          "Maintain current study pace",
          "Continue good work-life balance",
          "Consider adding new challenging topics",
        ]);
      }

      return recommendations;
    }

    // AI Skill Prediction
    Future<String> _generateSkillPrediction(SkillProgress skill) async {
      if (skill.progressPercentage > 80) {
        return "Ready for advanced ${skill.skillName} concepts!";
      } else if (skill.progressPercentage > 50) {
        return "Good progress! Focus on intermediate ${skill.skillName} topics.";
      } else {
        return "Building foundation in ${skill.skillName} - keep practicing!";
      }
    }

    // AI Skill Recommendations
    Future<List<String>> _generateSkillRecommendations(
      SkillProgress skill,
    ) async {
      final recommendations = <String>[];

      if (skill.progressPercentage < 30) {
        recommendations.add("Focus on basic ${skill.skillName} fundamentals");
        recommendations.add("Practice daily for 30 minutes");
      } else if (skill.progressPercentage < 60) {
        recommendations.add("Work on intermediate ${skill.skillName} projects");
        recommendations.add("Join study groups for collaborative learning");
      } else {
        recommendations.add("Tackle advanced ${skill.skillName} challenges");
        recommendations.add("Help others learn ${skill.skillName}");
      }

      return recommendations;
    }

    // AI Weekly Recommendations
    Future<List<String>> _generateWeeklyAIRecommendations(
      WeeklyPlan plan,
    ) async {
      final recommendations = <String>[];

      recommendations.add(
        "Based on your progress: ${plan.completionPercentage > 70 ? 'Excellent pace!' : 'Increase consistency'}",
      );
      recommendations.add(
        "AI suggests: ${plan.focusGoal.contains('web') ? 'Focus on React hooks' : 'Practice more algorithms'}",
      );
      recommendations.add(
        "Optimal study time: ${plan.dailyTasks.length > 5 ? 'Reduce to 5 tasks' : 'Add 1 more challenge'}",
      );

      return recommendations;
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
              MaterialPageRoute(builder: (_) => const NotebookScreen()),
            ),
            icon: const Icon(Icons.school, color: Color(0xFF00D9FF)),
            tooltip: '📚 Study Helper',
          ),
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EnhancedChatbotScreen()),
            ),
            icon: const Icon(Icons.chat, color: Colors.white),
            tooltip: 'AI Chat Assistant',
          ),
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
            icon: const Icon(Icons.settings, color: Colors.white),
            tooltip: 'Settings',
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
                    _buildStudyStreakCard(),
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
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStudyStreakCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.withOpacity(0.2), Colors.red.withOpacity(0.2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '🔥 Study Streak',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Keep it going!',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          Column(
            children: [
              Text(
                '$_studyStreak',
                style: const TextStyle(
                  color: Colors.orange,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'days',
                style: TextStyle(color: Colors.orange, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTodayJournalButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const EnhancedJournalScreen()),
          );
          if (!mounted) return;
          await _loadDashboardData();
        },
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
            Icon(Icons.book, color: Colors.white),
            SizedBox(width: 8),
            Text(
              "📝 Write Journal",
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
      onTap: () => _showBurnoutActionDialog(),
      child: _buildDashboardCard(
        '🔥 Burnout Risk Indicator',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: (_burnoutScore?.riskColor ?? Colors.grey).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: (_burnoutScore?.riskColor ?? Colors.grey).withOpacity(0.5),
                    ),
                  ),
                  child: Text(
                    _burnoutScore?.riskLevel.toUpperCase() ?? 'UNKNOWN',
                    style: TextStyle(
                      color: _burnoutScore?.riskColor ?? Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.touch_app,
                  color: _burnoutScore?.riskColor ?? Colors.grey,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  'Tap for help',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: (_burnoutScore?.score ?? 0) / 100.0,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                _burnoutScore?.riskColor ?? Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildQuickAction(
                    '📞 Call Counselor',
                    'green',
                    () => _showCounselorDialog(),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildQuickAction(
                    '🧘 Quick Relief',
                    'blue',
                    () => _showQuickReliefDialog(),
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
    // Consolidate entries by day
    final consolidatedEntries = _consolidateEntriesByDay();

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DailyActivityDetailsScreen(
            journalEntries: _journalEntries,
            consolidatedEntries: consolidatedEntries,
          ),
        ),
      ),
      child: _buildDashboardCard(
        '📅 Daily Activity Tracking (AI Analyzed)',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Timeline from your journal entries and analysis:',
                  style: TextStyle(
                    color: const Color(0xFF00D9FF),
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00D9FF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF00D9FF).withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    '${consolidatedEntries.length} days',
                    style: const TextStyle(
                      color: Color(0xFF00D9FF),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (consolidatedEntries.isEmpty)
              Text(
                'No journal entries yet. Start journaling to see your daily activities!',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 14,
                ),
              )
            else
              ...consolidatedEntries
                  .take(7)
                  .map(
                    (dayEntry) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.05),
                            Colors.white.withOpacity(0.02),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF00D9FF,
                                  ).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _getDayName(dayEntry.date.weekday),
                                  style: const TextStyle(
                                    color: Color(0xFF00D9FF),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${dayEntry.date.day}/${dayEntry.date.month}',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.6),
                                  fontSize: 11,
                                ),
                              ),
                              const Spacer(),
                              if (dayEntry.totalStudyHours > 0)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '${dayEntry.totalStudyHours.toStringAsFixed(1)}h',
                                    style: const TextStyle(
                                      color: Colors.green,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Consolidated study hours
                          if (dayEntry.studyHours.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.schedule,
                                        color: Colors.blue,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Study Time',
                                        style: TextStyle(
                                          color: Colors.blue,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 4,
                                    children: dayEntry.studyHours.entries
                                        .where((entry) => entry.value > 0)
                                        .map(
                                          (entry) => Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.blue.withOpacity(
                                                0.2,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              '${entry.key}: ${entry.value.toStringAsFixed(1)}h',
                                              style: const TextStyle(
                                                color: Colors.blue,
                                                fontSize: 10,
                                              ),
                                            ),
                                          ),
                                        )
                                        .toList(),
                                  ),
                                ],
                              ),
                            ),

                          // Consolidated tasks
                          if (dayEntry.tasksCompleted.isNotEmpty)
                            Container(
                              margin: const EdgeInsets.only(top: 6),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.task_alt,
                                        color: Colors.green,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Tasks (${dayEntry.tasksCompleted.length})',
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    dayEntry.tasksCompleted.take(3).join(', ') +
                                        (dayEntry.tasksCompleted.length > 3
                                            ? '...'
                                            : ''),
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          if (dayEntry.aiSummary.isNotEmpty)
                            Container(
                              margin: const EdgeInsets.only(top: 6),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00D9FF).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.auto_awesome,
                                        color: Color(0xFF00D9FF),
                                        size: 14,
                                      ),
                                      const SizedBox(width: 4),
                                      const Text(
                                        'AI Report',
                                        style: TextStyle(
                                          color: Color(0xFF00D9FF),
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const Spacer(),
                                      if (dayEntry.skillsDetected.isNotEmpty)
                                        Text(
                                          dayEntry.skillsDetected.join(', '),
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(
                                              0.7,
                                            ),
                                            fontSize: 10,
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    dayEntry.aiSummary,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.85),
                                      fontSize: 11,
                                      height: 1.35,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // Mood and sleep
                          if (dayEntry.mood.isNotEmpty ||
                              dayEntry.sleepHours > 0)
                            Container(
                              margin: const EdgeInsets.only(top: 6),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.purple.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  if (dayEntry.mood.isNotEmpty) ...[
                                    Icon(
                                      Icons.mood,
                                      color: Colors.purple,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Mood: ${dayEntry.mood}',
                                      style: TextStyle(
                                        color: Colors.purple,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                  if (dayEntry.mood.isNotEmpty &&
                                      dayEntry.sleepHours > 0)
                                    const SizedBox(width: 12),
                                  if (dayEntry.sleepHours > 0) ...[
                                    Icon(
                                      Icons.bedtime,
                                      color: Colors.indigo,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Sleep: ${dayEntry.sleepHours.toStringAsFixed(1)}h',
                                      style: TextStyle(
                                        color: Colors.indigo,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
            const SizedBox(height: 8),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.touch_app,
                    color: const Color(0xFF00D9FF),
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Tap for detailed daily analysis →',
                    style: TextStyle(
                      color: const Color(0xFF00D9FF),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<DayEntry> _consolidateEntriesByDay() {
    final Map<DateTime, DayEntry> dayMap = {};

    for (final entry in _journalEntries) {
      final dateKey = DateTime(
        entry.date.year,
        entry.date.month,
        entry.date.day,
      );

      if (!dayMap.containsKey(dateKey)) {
        dayMap[dateKey] = DayEntry(
          date: dateKey,
          studyHours: {},
          tasksCompleted: [],
          mood: '',
          sleepHours: 0,
          totalStudyHours: 0,
          aiSummary: '',
          aiSuggestions: [],
          skillsDetected: [],
          burnoutRisk: 0,
          stressLevel: 0,
        );
      }

      final dayEntry = dayMap[dateKey]!;

      // Consolidate study hours
      for (final category in entry.studyHours.entries) {
        dayEntry.studyHours[category.key] =
            (dayEntry.studyHours[category.key] ?? 0) + category.value;
        dayEntry.totalStudyHours += category.value;
      }

      // Consolidate tasks
      dayEntry.tasksCompleted.addAll(entry.tasksCompleted);

      // Use the latest mood and sleep
      dayEntry.mood = entry.mood;
      dayEntry.sleepHours = entry.sleepHours;
    }

    for (final journal in _rawJournalHistory) {
      final entry = _normalizeStoredEntry(journal);
      if (entry == null) continue;

      final dateKey = DateTime(
        entry.date.year,
        entry.date.month,
        entry.date.day,
      );
      final dayEntry = dayMap[dateKey];
      if (dayEntry == null) continue;

      final analysis = Map<String, dynamic>.from(
        journal['analysis'] as Map? ?? {},
      );
      final summary = (analysis['summary'] as String? ?? '').trim();
      if (summary.isNotEmpty) {
        dayEntry.aiSummary = summary;
      }

      dayEntry.burnoutRisk = math.max(
        dayEntry.burnoutRisk,
        (analysis['burnout_risk'] as num?)?.toInt() ?? 0,
      );
      dayEntry.stressLevel = math.max(
        dayEntry.stressLevel,
        (analysis['stress_level'] as num?)?.toInt() ?? 0,
      );

      for (final suggestion in List<String>.from(
        analysis['suggestions'] as List? ?? [],
      )) {
        if (!dayEntry.aiSuggestions.contains(suggestion)) {
          dayEntry.aiSuggestions.add(suggestion);
        }
      }

      final detectedSkills = <String>{
        ...List<String>.from(
          analysis['skills_mentioned'] as List? ?? [],
        ).map(_canonicalSkillName),
        ...Map<String, dynamic>.from(
          analysis['skills_progress'] as Map? ?? {},
        ).keys.map(_canonicalSkillName),
      }.where((skill) => skill.isNotEmpty && skill != 'Other');

      for (final skill in detectedSkills) {
        if (!dayEntry.skillsDetected.contains(skill)) {
          dayEntry.skillsDetected.add(skill);
        }
      }
    }

    // Sort by date descending
    final consolidatedList = dayMap.values.toList();
    consolidatedList.sort((a, b) => b.date.compareTo(a.date));

    return consolidatedList;
  }

  JournalEntry? _normalizeStoredEntry(Map<String, dynamic> journal) {
    final rawEntry = Map<String, dynamic>.from(
      journal['entry'] as Map? ?? journal,
    );
    if (rawEntry.isEmpty) return null;

    if (rawEntry.containsKey('studyHours')) {
      final normalizedEntry = Map<String, dynamic>.from(rawEntry);
      normalizedEntry['createdAt'] =
          normalizedEntry['createdAt'] ??
          journal['created_at'] ??
          journal['timestamp'] ??
          normalizedEntry['date'];
      return JournalEntry.fromJson(normalizedEntry);
    }

    final analysis = Map<String, dynamic>.from(
      journal['analysis'] as Map? ?? {},
    );
    final text = (rawEntry['text'] as String? ?? '').trim();
    final studyHours = (rawEntry['study_hours'] as num?)?.toDouble() ?? 0.0;
    final dsaProblems = (rawEntry['dsa_problems_solved'] as num?)?.toInt() ?? 0;
    final dsaPlatform = (rawEntry['dsa_platform'] as String? ?? '').trim();
    final webGoal = (rawEntry['web_goal'] as String? ?? '').trim();
    final date = _parseDate(
      rawEntry['date'] ??
          journal['created_at'] ??
          journal['timestamp'] ??
          journal['createdAt'],
    );
    final mood =
        (rawEntry['mood'] ??
                rawEntry['mood_before'] ??
                analysis['mood'] ??
                'neutral')
            .toString();

    final skillBuckets = <String>{};
    if (dsaProblems > 0 ||
        dsaPlatform.isNotEmpty ||
        _containsAny(text.toLowerCase(), const [
          'dsa',
          'leetcode',
          'algorithm',
          'data structure',
        ])) {
      skillBuckets.add('DSA');
    }
    if (webGoal.isNotEmpty ||
        _containsAny(text.toLowerCase(), const [
          'web',
          'html',
          'css',
          'javascript',
          'react',
          'frontend',
          'backend',
        ])) {
      skillBuckets.add('Web Dev');
    }
    if (_containsAny(text.toLowerCase(), const [
      'ai',
      'ml',
      'machine learning',
      'model',
      'neural',
    ])) {
      skillBuckets.add('AI/ML');
    }
    if (skillBuckets.isEmpty && studyHours > 0) {
      skillBuckets.add('Other');
    }

    final breakdown = <String, double>{};
    final splitHours = skillBuckets.isEmpty
        ? 0.0
        : studyHours / skillBuckets.length;
    for (final skill in skillBuckets) {
      breakdown[skill] = splitHours;
    }

    return JournalEntry(
      id: (rawEntry['id'] ?? date.millisecondsSinceEpoch.toString()).toString(),
      date: date,
      studyHours: breakdown,
      tasksCompleted: [
        if (studyHours > 0)
          'Studied for ${studyHours.toStringAsFixed(1)} hours',
        if (dsaProblems > 0)
          'Solved $dsaProblems DSA problems${dsaPlatform.isNotEmpty ? ' on $dsaPlatform' : ''}',
        if (webGoal.isNotEmpty) 'Worked on: $webGoal',
      ],
      mood: mood,
      sleepHours:
          (rawEntry['sleepHours'] as num?)?.toDouble() ??
          _estimateSleepHours((rawEntry['energy_level'] as num?)?.toInt() ?? 6),
      breakActivities: {
        'Short Breaks': math.max(0.5, studyHours / 4).toDouble(),
      },
      notes: text,
      createdAt: _parseDate(
        rawEntry['createdAt'] ??
            journal['created_at'] ??
            journal['timestamp'] ??
            rawEntry['date'],
        fallback: date,
      ),
    );
  }

  DateTime _parseDate(dynamic rawValue, {DateTime? fallback}) {
    if (rawValue is String && rawValue.isNotEmpty) {
      return DateTime.tryParse(rawValue) ?? fallback ?? DateTime.now();
    }
    return fallback ?? DateTime.now();
  }

  bool _containsAny(String text, List<String> keywords) {
    for (final keyword in keywords) {
      if (text.contains(keyword)) return true;
    }
    return false;
  }

  String _canonicalSkillName(String rawSkill) {
    final normalized = rawSkill.trim().toLowerCase();
    if (normalized.contains('dsa') ||
        normalized.contains('problem solving') ||
        normalized.contains('algorithm')) {
      return 'DSA';
    }
    if (normalized.contains('web') ||
        normalized.contains('html') ||
        normalized.contains('css') ||
        normalized.contains('javascript') ||
        normalized.contains('react')) {
      return 'Web Dev';
    }
    if (normalized.contains('ai') ||
        normalized.contains('ml') ||
        normalized.contains('machine learning')) {
      return 'AI/ML';
    }
    return rawSkill.trim();
  }

  double _estimateSleepHours(int energyLevel) {
    if (energyLevel >= 8) return 8.0;
    if (energyLevel >= 6) return 7.0;
    if (energyLevel >= 4) return 6.5;
    return 5.5;
  }

  Widget _buildWeeklyPlannerCard() {
    if (_weeklyPlan == null) {
      return _buildDashboardCard(
        '📋 AI Weekly Planner',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'No data available yet',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start journaling to get your personalized weekly plan',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => WeeklyPlanDetailsScreen(weeklyPlan: _weeklyPlan!),
        ),
      ),
      child: _buildDashboardCard(
        '📋 AI Weekly Planner',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'This Week\'s Focus',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _weeklyPlan!.focusGoal,
                        style: const TextStyle(
                          color: Color(0xFF00D9FF),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _weeklyPlan!.completionPercentage >= 75
                        ? Colors.green.withOpacity(0.2)
                        : _weeklyPlan!.completionPercentage >= 50
                        ? Colors.orange.withOpacity(0.2)
                        : Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _weeklyPlan!.completionPercentage >= 75
                          ? Colors.green
                          : _weeklyPlan!.completionPercentage >= 50
                          ? Colors.orange
                          : Colors.red,
                    ),
                  ),
                  child: Text(
                    '${_weeklyPlan!.completionPercentage.round()}% Complete',
                    style: TextStyle(
                      color: _weeklyPlan!.completionPercentage >= 75
                          ? Colors.green
                          : _weeklyPlan!.completionPercentage >= 50
                          ? Colors.orange
                          : Colors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _weeklyPlan!.weekDescription,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 16),

            // Enhanced daily tasks with priority indicators
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.03),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Icon(
                          Icons.task_alt,
                          color: const Color(0xFF00D9FF),
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Priority Tasks',
                          style: const TextStyle(
                            color: Color(0xFF00D9FF),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ...(_weeklyPlan!.dailyTasks)
                      .take(4)
                      .toList()
                      .asMap()
                      .entries
                      .map(
                        (entry) => Padding(
                          padding: EdgeInsets.only(
                            left: 12,
                            right: 12,
                            bottom:
                                entry.key < _weeklyPlan!.dailyTasks.length - 1
                                ? 8
                                : 12,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: _getPriorityColor(
                                    entry.key,
                                  ).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _getPriorityColor(entry.key),
                                    width: 1,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    '${entry.key + 1}',
                                    style: TextStyle(
                                      color: _getPriorityColor(entry.key),
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  entry.value,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.white.withOpacity(0.4),
                                size: 12,
                              ),
                            ],
                          ),
                        ),
                      ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Enhanced targets section
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF00D9FF).withOpacity(0.1),
                    const Color(0xFF00D9FF).withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF00D9FF).withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.track_changes,
                        color: const Color(0xFF00D9FF),
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Weekly Targets',
                        style: const TextStyle(
                          color: Color(0xFF00D9FF),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...(_weeklyPlan!.targets).entries.map(
                    (target) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            color: Colors.green,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${target.key}: ${target.value}',
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
                ],
              ),
            ),

            const SizedBox(height: 12),

            // AI insights section
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.purple.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.psychology, color: Colors.purple, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'AI Insights',
                        style: TextStyle(
                          color: Colors.purple,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...(_weeklyPlan!.recommendations)
                      .take(2)
                      .map(
                        (recommendation) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.lightbulb_outline,
                                color: Colors.purple,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  recommendation,
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
                ],
              ),
            ),

            const SizedBox(height: 12),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.touch_app,
                    color: const Color(0xFF00D9FF),
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Tap for detailed weekly plan →',
                    style: TextStyle(
                      color: const Color(0xFF00D9FF),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getPriorityColor(int index) {
    if (index == 0) return Colors.red; // High priority
    if (index == 1) return Colors.orange; // Medium-high priority
    if (index == 2) return Colors.blue; // Medium priority
    return Colors.green; // Lower priority
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

  // Interactive Burnout Methods
  void _showBurnoutActionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text(
          '🔥 Burnout Support Options',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildActionOption(
              '📞 Connect with Counselor',
              'Speak with a mental health professional',
              'green',
              () => _showCounselorDialog(),
            ),
            const SizedBox(height: 12),
            _buildActionOption(
              '🧘 Quick Relief Exercises',
              'Immediate stress reduction techniques',
              'blue',
              () => _showQuickReliefDialog(),
            ),
            const SizedBox(height: 12),
            _buildActionOption(
              '📊 Detailed Analysis',
              'View comprehensive burnout report',
              'orange',
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BurnoutDetailsScreen(
                    burnoutRisk: _burnoutScore!.score.round(),
                  ),
                ),
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

  void _showCounselorDialog() {
    final counselors = [
      {
        'name': 'Dr. Sarah Johnson',
        'phone': '+1-800-273-8255',
        'specialty': 'Student Mental Health',
      },
      {
        'name': 'Dr. Michael Chen',
        'phone': '+1-800-950-6264',
        'specialty': 'Academic Stress',
      },
      {
        'name': 'Dr. Emily Rodriguez',
        'phone': '+1-800-799-4889',
        'specialty': 'Burnout Recovery',
      },
      {
        'name': 'Dr. James Wilson',
        'phone': '+1-800-273-8255',
        'specialty': 'Crisis Intervention',
      },
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text(
          '📞 Mental Health Counselors',
          style: TextStyle(color: Colors.white),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: counselors.length,
            itemBuilder: (context, index) {
              final counselor = counselors[index];
              return Card(
                color: Colors.white.withOpacity(0.05),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFF00D9FF),
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  title: Text(
                    counselor['name']!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    '${counselor['specialty']}\n${counselor['phone']}',
                    style: TextStyle(color: Colors.white.withOpacity(0.7)),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.phone, color: Colors.green),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Call ${counselor['phone']} for immediate support',
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                  ),
                ),
              );
            },
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

  void _showQuickReliefDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text(
          '🧘 Quick Relief Exercises',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildReliefExercise(
              '🫁 Deep Breathing',
              '4-7-8 Technique: Breathe in 4s, hold 7s, exhale 8s',
              () => _startBreathingExercise(context),
            ),
            const SizedBox(height: 12),
            _buildReliefExercise(
              '💪 Progressive Muscle Relaxation',
              'Tense and release each muscle group for 5 seconds',
              () => _startMuscleRelaxation(context),
            ),
            const SizedBox(height: 12),
            _buildReliefExercise(
              '🎯 Grounding Technique',
              'Name 5 things you see, 4 you touch, 3 you hear',
              () => _startGroundingExercise(),
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

  Widget _buildActionOption(
    String title,
    String description,
    String color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color == 'green'
              ? Colors.green.withOpacity(0.1)
              : color == 'blue'
              ? Colors.blue.withOpacity(0.1)
              : Colors.orange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: color == 'green'
                ? Colors.green.withOpacity(0.3)
                : color == 'blue'
                ? Colors.blue.withOpacity(0.3)
                : Colors.orange.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.arrow_forward,
              color: color == 'green'
                  ? Colors.green
                  : color == 'blue'
                  ? Colors.blue
                  : Colors.orange,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: color == 'green'
                          ? Colors.green
                          : color == 'blue'
                          ? Colors.blue
                          : Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReliefExercise(
    String title,
    String instructions,
    VoidCallback onStart,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            instructions,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: onStart,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 36),
            ),
            child: const Text('Start Exercise'),
          ),
        ],
      ),
    );
  }

  void _startBreathingExercise(BuildContext context) {
    Navigator.pop(context);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text(
          '🫁 Breathing Exercise',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Follow the breathing pattern:\n\nInhale for 4 seconds...\nHold for 7 seconds...\nExhale for 8 seconds...\n\nRepeat 5 times.',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Done',
              style: TextStyle(color: Color(0xFF00D9FF)),
            ),
          ),
        ],
      ),
    );
  }

  void _startMuscleRelaxation(BuildContext context) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Starting Progressive Muscle Relaxation...'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _startGroundingExercise() {
    Navigator.pop(context);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text(
          '🎯 Grounding Exercise',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Look around and name:\n\n5 things you can SEE\n4 things you can TOUCH\n3 things you can HEAR\n2 things you can SMELL\n1 thing you can TASTE',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Done',
              style: TextStyle(color: Color(0xFF00D9FF)),
            ),
          ),
        ],
      ),
    );
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
