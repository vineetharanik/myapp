import 'package:flutter/material.dart';
import '../../services/local_storage_service.dart';

class StudyAnalyticsScreen extends StatefulWidget {
  const StudyAnalyticsScreen({super.key});

  @override
  State<StudyAnalyticsScreen> createState() => _StudyAnalyticsScreenState();
}

class _StudyAnalyticsScreenState extends State<StudyAnalyticsScreen> {
  late LocalStorageService _localStorageService;
  List<Map<String, dynamic>> _journalHistory = [];
  Map<String, dynamic>? _userProfile;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _localStorageService = LocalStorageService();
    _loadAnalyticsData();
  }

  Future<void> _loadAnalyticsData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _localStorageService.initialize();

      if (_localStorageService.currentUser != null) {
        final userId = _localStorageService.currentUser!['id'];

        // Get user profile
        final profile = await _localStorageService.getUserProfile(userId);
        if (profile != null) {
          _userProfile = profile;
        }

        // Get journal history
        final history = await _localStorageService.getJournalHistory(
          userId,
          limit: 30,
        );
        setState(() {
          _journalHistory = history;
        });
      }
    } catch (e) {
      print('Error loading analytics: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Map<String, double> _getWeeklyStudyHours() {
    final weeklyData = <String, double>{};
    final now = DateTime.now();

    // Get last 7 days of data
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateStr = date.toString().substring(0, 10); // YYYY-MM-DD

      // Find journals for this date
      double totalHours = 0;
      for (final journal in _journalHistory) {
        final journalDate = DateTime.parse(journal['created_at']);
        if (journalDate.toString().substring(0, 10) == dateStr) {
          final entry = journal['entry'] as Map<String, dynamic>?;
          if (entry != null) {
            totalHours += (entry['study_hours'] as double?) ?? 0.0;
          }
        }
      }

      final days = [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday',
      ];
      weeklyData[days[6 - i]] = totalHours;
    }

    return weeklyData;
  }

  Map<String, int> _getWeeklyDSAProblems() {
    final weeklyData = <String, int>{};
    final now = DateTime.now();

    // Get last 7 days of data
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateStr = date.toString().substring(0, 10);

      // Find journals for this date
      int totalProblems = 0;
      for (final journal in _journalHistory) {
        final journalDate = DateTime.parse(journal['created_at']);
        if (journalDate.toString().substring(0, 10) == dateStr) {
          final entry = journal['entry'] as Map<String, dynamic>?;
          if (entry != null) {
            totalProblems += (entry['dsa_problems_solved'] as int?) ?? 0;
          }
        }
      }

      final days = [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday',
      ];
      weeklyData[days[6 - i]] = totalProblems;
    }

    return weeklyData;
  }

  Map<String, double> _getSkillsProgress() {
    final skillsProgress = <String, double>{};
    final userSkills = _userProfile?['skills'] as List? ?? [];

    for (final skill in userSkills) {
      // Calculate progress based on journal mentions
      int mentions = 0;
      for (final journal in _journalHistory) {
        final entry = journal['entry'] as Map<String, dynamic>?;
        if (entry != null) {
          final text =
              '${entry['what_studied']} ${entry['goal_practice']} ${entry['text']}'
                  .toLowerCase();
          if (text.contains(skill.toString().toLowerCase())) {
            mentions++;
          }
        }
      }

      // Calculate progress percentage
      double progress = (mentions * 10).clamp(0.0, 100.0).toDouble();
      skillsProgress[skill.toString()] = progress;
    }

    return skillsProgress;
  }

  double _getTotalStudyHours() {
    double total = 0;
    for (final journal in _journalHistory) {
      final entry = journal['entry'] as Map<String, dynamic>?;
      if (entry != null) {
        total += (entry['study_hours'] as double?) ?? 0.0;
      }
    }
    return total;
  }

  int _getTotalDSAProblems() {
    int total = 0;
    for (final journal in _journalHistory) {
      final entry = journal['entry'] as Map<String, dynamic>?;
      if (entry != null) {
        total += (entry['dsa_problems_solved'] as int?) ?? 0;
      }
    }
    return total;
  }

  double _getAverageStudyHours() {
    if (_journalHistory.isEmpty) return 0;
    return _getTotalStudyHours() / _journalHistory.length;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0F0F23),
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    final weeklyStudyHours = _getWeeklyStudyHours();
    final weeklyDSAProblems = _getWeeklyDSAProblems();
    final skillsProgress = _getSkillsProgress();
    final maxStudyHours = weeklyStudyHours.values.isNotEmpty
        ? weeklyStudyHours.values.reduce((a, b) => a > b ? a : b)
        : 0.0;
    final maxDSAProblems = weeklyDSAProblems.values.isNotEmpty
        ? weeklyDSAProblems.values.reduce((a, b) => a > b ? a : b)
        : 0;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F23),
      appBar: AppBar(
        title: const Text(
          '📊 Study Analytics',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Cards
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    '⏰ Total Study Hours',
                    '${_getTotalStudyHours().toStringAsFixed(1)}h',
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    '💻 Total DSA Problems',
                    '${_getTotalDSAProblems()}',
                    Colors.purple,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    '📈 Daily Average',
                    '${_getAverageStudyHours().toStringAsFixed(1)}h',
                    Colors.green,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Study Hours Chart
            _buildBarChartCard(
              '📈 Study Hours (Last 7 Days)',
              weeklyStudyHours,
              maxStudyHours,
              Colors.blue,
            ),

            const SizedBox(height: 24),

            // DSA Problems Chart
            _buildBarChartCard(
              '💻 DSA Problems Solved (Last 7 Days)',
              weeklyDSAProblems.map(
                (key, value) => MapEntry(key, value.toDouble()),
              ),
              maxDSAProblems.toDouble(),
              Colors.purple,
            ),

            const SizedBox(height: 24),

            // Skills Progress
            if (skillsProgress.isNotEmpty) ...[
              const Text(
                '🎯 Skills Progress',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ...skillsProgress.entries.map((entry) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            entry.key.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${entry.value.toInt()}%',
                            style: TextStyle(
                              color: entry.value >= 80
                                  ? Colors.green
                                  : entry.value >= 50
                                  ? Colors.orange
                                  : Colors.red,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: entry.value / 100,
                        backgroundColor: Colors.white.withOpacity(0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          entry.value >= 80
                              ? Colors.green
                              : entry.value >= 50
                              ? Colors.orange
                              : Colors.red,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(title, style: TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChartCard(
    String title,
    Map<String, double> data,
    double maxValue,
    Color color,
  ) {
    final days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    return Container(
      padding: const EdgeInsets.all(16),
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
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: days.map((day) {
                final value = data[day] ?? 0.0;
                final barHeight = maxValue > 0 ? (value / maxValue) * 150 : 0.0;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 30,
                      height: barHeight,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      value.toStringAsFixed(1),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
