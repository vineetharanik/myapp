import 'package:flutter/material.dart';
import '../../models/skill_progress.dart';
import '../../services/local_storage_service.dart';
import '../../services/analytics_service.dart';
import '../../models/journal_entry.dart';

class EnhancedSkillRoadmapScreen extends StatefulWidget {
  const EnhancedSkillRoadmapScreen({super.key});

  @override
  State<EnhancedSkillRoadmapScreen> createState() =>
      _EnhancedSkillRoadmapScreenState();
}

class _EnhancedSkillRoadmapScreenState
    extends State<EnhancedSkillRoadmapScreen> {
  Map<String, dynamic>? _userProfile;
  final List<JournalEntry> _journalHistory = [];
  Map<String, SkillProgress> _skillProgress = {};
  bool _isLoading = true;
  late LocalStorageService _localStorageService;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      _localStorageService = LocalStorageService();
      await _localStorageService.initialize();

      if (_localStorageService.currentUser != null) {
        final userId = _localStorageService.currentUser!['id'];

        _userProfile = await _localStorageService.getUserProfile(userId);
        final rawJournalHistory = await _localStorageService.getJournalHistory(
          userId,
          limit: 30,
        );

        // Get user skills
        final userSkills =
            (_userProfile!['skills'] as List?)?.cast<String>() ?? <String>[];

        // Convert journal entries properly
        final entries = rawJournalHistory
            .map((journal) {
              final entryData = journal['entry'] as Map<String, dynamic>?;
              if (entryData == null) return null;
              return JournalEntry.fromJson(entryData);
            })
            .where((entry) => entry != null)
            .cast<JournalEntry>()
            .toList();

        // Calculate skill progress only for user's registered skills
        _skillProgress = AnalyticsService.calculateSkillProgress(
          entries,
          userSkills,
        );
      }
    } catch (e) {
      print('Error loading data: $e');
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
          'Skill Roadmap',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildOverallProgress(),
                  const SizedBox(height: 24),
                  ..._skillProgress.keys.map(
                    (skill) => _buildSkillRoadmap(skill),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildOverallProgress() {
    final totalSkills = _skillProgress.length;
    final avgProgress = totalSkills > 0
        ? _skillProgress.values
                  .map((p) => p.progressPercentage)
                  .reduce((a, b) => a + b) /
              totalSkills
        : 0.0;

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
          const Text(
            'Overall Progress',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: avgProgress / 100.0,
            backgroundColor: Colors.white.withOpacity(0.2),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00D9FF)),
          ),
          const SizedBox(height: 8),
          Text(
            '${avgProgress.round()}% Complete',
            style: const TextStyle(
              color: Color(0xFF00D9FF),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillRoadmap(String skill) {
    final progress = _skillProgress[skill]!;
    final roadmap = _getSkillRoadmap(skill);
    final currentLevel = _getCurrentLevel(progress.progressPercentage);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                skill,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${progress.progressPercentage.round()}%',
                style: TextStyle(
                  color: progress.progressPercentage > 75
                      ? Colors.green
                      : progress.progressPercentage > 50
                      ? Colors.orange
                      : Colors.red,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress.progressPercentage / 100.0,
            backgroundColor: Colors.white.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(
              progress.progressPercentage > 75
                  ? Colors.green
                  : progress.progressPercentage > 50
                  ? Colors.orange
                  : Colors.red,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Current Level: $currentLevel',
            style: const TextStyle(
              color: Color(0xFF00D9FF),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ...roadmap.asMap().entries.map((entry) {
            final index = entry.key;
            final level = entry.value;
            final isCompleted = progress.completedMilestones.contains(level);
            final isCurrent = index == progress.completedMilestones.length;

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isCompleted
                    ? Colors.green.withOpacity(0.1)
                    : isCurrent
                    ? const Color(0xFF00D9FF).withOpacity(0.1)
                    : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isCompleted
                      ? Colors.green.withOpacity(0.3)
                      : isCurrent
                      ? const Color(0xFF00D9FF).withOpacity(0.3)
                      : Colors.white.withOpacity(0.1),
                ),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () =>
                        _toggleMilestoneCompletion(skill, level, isCompleted),
                    child: Icon(
                      isCompleted
                          ? Icons.check_circle
                          : isCurrent
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      color: isCompleted
                          ? Colors.green
                          : isCurrent
                          ? const Color(0xFF00D9FF)
                          : Colors.white.withOpacity(0.5),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      level,
                      style: TextStyle(
                        color: isCompleted
                            ? Colors.green
                            : isCurrent
                            ? const Color(0xFF00D9FF)
                            : Colors.white.withOpacity(0.7),
                        fontSize: 14,
                        decoration: isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                  ),
                  if (isCurrent)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00D9FF).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF00D9FF).withOpacity(0.5),
                        ),
                      ),
                      child: const Text(
                        'CURRENT',
                        style: TextStyle(
                          color: Color(0xFF00D9FF),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            );
          }),
          const SizedBox(height: 12),
          Text(
            'Tap milestones to mark as completed',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 11,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  void _toggleMilestoneCompletion(
    String skill,
    String milestone,
    bool isCompleted,
  ) async {
    try {
      final userId = _localStorageService.currentUser!['id'];
      final progress = _skillProgress[skill]!;

      final updatedCompletedMilestones = List<String>.from(
        progress.completedMilestones,
      );
      final updatedPendingMilestones = List<String>.from(
        progress.pendingMilestones,
      );

      if (isCompleted) {
        // Uncomplete
        updatedCompletedMilestones.remove(milestone);
        updatedPendingMilestones.insert(0, milestone);
      } else {
        // Complete
        updatedCompletedMilestones.add(milestone);
        updatedPendingMilestones.remove(milestone);
      }

      // Recalculate progress based on completed milestones
      final newProgress = (updatedCompletedMilestones.length * 20.0).clamp(
        0.0,
        100.0,
      );

      // Calculate new level
      int newLevel = 1;
      if (newProgress >= 80) {
        newLevel = 5;
      } else if (newProgress >= 60)
        newLevel = 4;
      else if (newProgress >= 40)
        newLevel = 3;
      else if (newProgress >= 20)
        newLevel = 2;

      // Update skill progress
      final updatedProgress = SkillProgress(
        id: progress.id,
        skillName: progress.skillName,
        progressPercentage: newProgress,
        currentLevel: newLevel,
        completedMilestones: updatedCompletedMilestones,
        pendingMilestones: updatedPendingMilestones,
        nextRecommendedTask: updatedPendingMilestones.isNotEmpty
            ? updatedPendingMilestones.first
            : 'Skill mastered!',
        lastUpdated: DateTime.now(),
        createdAt: progress.createdAt,
      );

      // Save updated progress to journal as a special entry
      final progressEntry = JournalEntry(
        id: 'progress_${DateTime.now().millisecondsSinceEpoch}',
        date: DateTime.now(),
        studyHours: {'DSA': 0.0, 'Web Dev': 0.0, 'AI/ML': 0.0, 'Other': 0.0},
        tasksCompleted: ['Completed milestone: $milestone for $skill'],
        mood: 'neutral',
        sleepHours: 0.0,
        breakActivities: {'games': 0.0, 'scrolling': 0.0},
        notes:
            'Skill progress updated: $skill - ${newProgress.round()}% complete',
        createdAt: DateTime.now(),
      );

      await _localStorageService.saveJournalEntry(userId, {
        'entry': progressEntry.toJson(),
        'created_at': DateTime.now().toIso8601String(),
      });

      // Update local state
      setState(() {
        _skillProgress[skill] = updatedProgress;
      });

      // Show feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isCompleted
                ? 'Milestone marked as incomplete'
                : 'Milestone completed! 🎉',
          ),
          backgroundColor: isCompleted ? Colors.orange : Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating milestone: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  int _getCurrentLevel(double progress) {
    if (progress >= 80) return 4;
    if (progress >= 60) return 3;
    if (progress >= 40) return 2;
    if (progress >= 20) return 1;
    return 0;
  }

  List<String> _getSkillRoadmap(String skill) {
    switch (skill.toLowerCase()) {
      case 'dsa':
        return [
          'Learn basic data structures',
          'Master sorting algorithms',
          'Understand trees and graphs',
          'Learn dynamic programming',
          'Advanced algorithms and optimization',
        ];
      case 'web dev':
      case 'web development':
        return [
          'Learn HTML/CSS fundamentals',
          'Master JavaScript basics',
          'Build responsive layouts',
          'Learn modern frameworks (React/Vue)',
          'Full-stack development',
        ];
      case 'ai/ml':
      case 'ai':
      case 'ml':
      case 'machine learning':
        return [
          'Learn Python basics',
          'Understand ML fundamentals',
          'Master data preprocessing',
          'Build neural network models',
          'Deploy ML applications',
        ];
      default:
        return [
          'Learn fundamentals',
          'Practice basic concepts',
          'Build small projects',
          'Advanced techniques',
          'Master level proficiency',
        ];
    }
  }
}
