import 'package:flutter/material.dart';
import '../../services/local_storage_service.dart';

class SkillRoadmapScreen extends StatefulWidget {
  const SkillRoadmapScreen({super.key});

  @override
  State<SkillRoadmapScreen> createState() => _SkillRoadmapScreenState();
}

class _SkillRoadmapScreenState extends State<SkillRoadmapScreen> {
  Map<String, dynamic>? _userProfile;
  List<Map<String, dynamic>> _journalHistory = [];
  Map<String, double> _skillProgress = {};
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
        _journalHistory = await _localStorageService.getJournalHistory(userId, limit: 30);
        
        _calculateSkillProgress();
      }
    } catch (e) {
      print('Error loading data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _calculateSkillProgress() {
    _skillProgress = {};
    
    // Initialize user skills
    if (_userProfile != null) {
      final userSkills = (_userProfile!['skills'] as List?) ?? [];
      for (final skill in userSkills) {
        _skillProgress[skill.toString()] = 0.0;
      }
    }

    // Process journal entries
    for (final journal in _journalHistory) {
      final entry = journal['entry'] as Map<String, dynamic>?;
      if (entry == null) continue;
      
      final studiedSkills = _extractSkillsFromEntry(entry);
      for (final skill in studiedSkills) {
        _skillProgress[skill] = (_skillProgress[skill] ?? 0) + 5.0;
      }
    }

    // Cap at 100%
    for (final skill in _skillProgress.keys) {
      _skillProgress[skill] = _skillProgress[skill]!.clamp(0.0, 100.0);
    }
  }

  List<String> _extractSkillsFromEntry(Map<String, dynamic> entry) {
    final text = '${entry['what_studied'] ?? ''} ${entry['goal_practice'] ?? ''}'.toLowerCase();
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
                  ..._skillProgress.keys.map((skill) => _buildSkillRoadmap(skill)),
                ],
              ),
            ),
    );
  }

  Widget _buildOverallProgress() {
    final totalSkills = _skillProgress.length;
    final avgProgress = totalSkills > 0 
        ? _skillProgress.values.reduce((a, b) => a + b) / totalSkills 
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
    final progress = _skillProgress[skill] ?? 0.0;
    final roadmap = _getSkillRoadmap(skill);
    final currentLevel = _getCurrentLevel(progress);

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
                '${progress.round()}%',
                style: TextStyle(
                  color: progress > 75 ? Colors.green :
                         progress > 50 ? Colors.orange : Colors.red,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress / 100.0,
            backgroundColor: Colors.white.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(
              progress > 75 ? Colors.green :
              progress > 50 ? Colors.orange : Colors.red
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
            final isCompleted = index < currentLevel;
            final isCurrent = index == currentLevel;
            
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isCompleted ? Colors.green.withOpacity(0.1) :
                       isCurrent ? const Color(0xFF00D9FF).withOpacity(0.1) :
                       Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isCompleted ? Colors.green.withOpacity(0.3) :
                         isCurrent ? const Color(0xFF00D9FF).withOpacity(0.3) :
                         Colors.white.withOpacity(0.1),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isCompleted ? Icons.check_circle :
                    isCurrent ? Icons.radio_button_checked :
                    Icons.radio_button_unchecked,
                    color: isCompleted ? Colors.green :
                           isCurrent ? const Color(0xFF00D9FF) :
                           Colors.white.withOpacity(0.5),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      level,
                      style: TextStyle(
                        color: isCompleted ? Colors.green :
                               isCurrent ? const Color(0xFF00D9FF) :
                               Colors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  int _getCurrentLevel(double progress) {
    if (progress >= 90) return 4;
    if (progress >= 70) return 3;
    if (progress >= 40) return 2;
    if (progress >= 15) return 1;
    return 0;
  }

  List<String> _getSkillRoadmap(String skill) {
    switch (skill.toLowerCase()) {
      case 'javascript':
        return [
          'Learn basic syntax and data types',
          'Understand functions and scope',
          'Master DOM manipulation',
          'Learn ES6+ features',
          'Advanced patterns and frameworks',
        ];
      case 'react':
        return [
          'Learn JSX and components',
          'Understand state and props',
          'Master hooks (useState, useEffect)',
          'Learn context and routing',
          'Advanced patterns and performance',
        ];
      case 'python':
        return [
          'Learn basic syntax and data types',
          'Understand functions and OOP',
          'Master file handling and modules',
          'Learn popular libraries',
          'Advanced concepts and frameworks',
        ];
      case 'dsa':
        return [
          'Learn basic data structures',
          'Master sorting and searching',
          'Understand trees and graphs',
          'Learn dynamic programming',
          'Advanced algorithms and optimization',
        ];
      default:
        return [
          'Learn fundamentals',
          'Practice basic problems',
          'Build small projects',
          'Advanced concepts',
          'Master level proficiency',
        ];
    }
  }
}
