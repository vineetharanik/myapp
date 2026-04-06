import 'package:flutter/material.dart';
import '../../models/journal_analysis.dart';
import '../../services/local_storage_service.dart';

class EnhancedJournalScreen extends StatefulWidget {
  const EnhancedJournalScreen({super.key});

  @override
  State<EnhancedJournalScreen> createState() => _EnhancedJournalScreenState();
}

class _EnhancedJournalScreenState extends State<EnhancedJournalScreen> {
  final _mainController = TextEditingController();
  final _studyHoursController = TextEditingController(text: '4.0');
  final _dsaProblemsController = TextEditingController(text: '0');
  final _dsaPlatformController = TextEditingController(text: 'LeetCode');
  final _webGoalController = TextEditingController();
  final _energyController = TextEditingController(text: '5');
  final List<String> _distractions = [];
  final List<String> _moods = const [
    'excited',
    'motivated',
    'neutral',
    'tired',
    'stressed',
    'anxious',
    'overwhelmed',
  ];

  late LocalStorageService _storage;
  String _selectedMood = 'neutral';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _storage = LocalStorageService();
    _storage.initialize();
  }

  Future<void> _submitJournal() async {
    if (_mainController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write something about your day.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _storage.initialize();
      final user = _storage.currentUser;
      if (user == null) {
        throw Exception('No active user found. Please sign in again.');
      }

      final now = DateTime.now();
      final studyHours =
          (double.tryParse(_studyHoursController.text) ?? 0).clamp(0, 24)
              .toDouble();
      final dsaProblems =
          (int.tryParse(_dsaProblemsController.text) ?? 0).clamp(0, 200).toInt();
      final energy =
          (int.tryParse(_energyController.text) ?? 5).clamp(1, 10).toInt();
      final rawText = _mainController.text.trim();
      final webGoal = _webGoalController.text.trim();
      final dsaPlatform = _dsaPlatformController.text.trim();

      final skills = _detectSkills(
        text: rawText,
        webGoal: webGoal,
        dsaProblems: dsaProblems,
      );
      final stress = _estimateStress(
        text: rawText,
        mood: _selectedMood,
        energy: energy,
        studyHours: studyHours,
        distractions: _distractions.length,
      );
      final burnout = _estimateBurnout(
        stress: stress,
        energy: energy,
        studyHours: studyHours,
      );
      final analysis = JournalAnalysis(
        summary: _buildSummary(
          studyHours: studyHours,
          dsaProblems: dsaProblems,
          webGoal: webGoal,
          burnout: burnout,
          skills: skills,
        ),
        mood: _selectedMood,
        stressLevel: stress,
        burnoutRisk: burnout,
        keyIssues: [
          if (stress >= 70) 'Stress is elevated.',
          if (energy <= 3) 'Energy levels are low.',
          if (_distractions.length >= 2) 'Distractions affected focus.',
          if (studyHours <= 1) 'Study time was lighter than planned.',
        ],
        suggestions: _buildSuggestions(
          studyHours: studyHours,
          dsaProblems: dsaProblems,
          burnout: burnout,
          distractionCount: _distractions.length,
          skills: skills,
        ),
        motivationMessage: burnout >= 70
            ? 'Protect your recovery tomorrow.'
            : 'Good work. Keep the momentum steady.',
        skillsMentioned: skills,
        skillsProgress: {
          for (final skill in skills)
            skill: _skillProgress(
              skill: skill,
              studyHours: studyHours,
              dsaProblems: dsaProblems,
              webGoal: webGoal,
              text: rawText,
            ),
        },
        studyTimeAnalysis: {
          'actual_hours': studyHours,
          'focus_quality': _focusQuality(stress, energy, _distractions.length),
          'distractions': List<String>.from(_distractions),
        },
        weeklyRecommendations: {
          'study_adjustments': [
            if (studyHours < 3) 'Add one more focused study block tomorrow.',
            if (studyHours >= 6) 'Keep recovery time after long sessions.',
          ],
          'wellness_tips': [
            if (_distractions.isNotEmpty) 'Study with fewer distractions.',
            if (burnout >= 70) 'Sleep more and shorten the next session.',
          ],
          'skill_focus': skills,
        },
      );

      final trackedSkills = skills.where((skill) => skill != 'Other').toList();
      final perSkill =
          trackedSkills.isEmpty ? 0.0 : studyHours / trackedSkills.length;
      final entry = {
        'id': now.millisecondsSinceEpoch.toString(),
        'date': now.toIso8601String(),
        'studyHours': {
          if (trackedSkills.isEmpty && studyHours > 0) 'Other': studyHours,
          for (final skill in trackedSkills) skill: perSkill,
        },
        'tasksCompleted': [
          if (studyHours > 0) 'Studied for ${studyHours.toStringAsFixed(1)} hours',
          if (dsaProblems > 0)
            'Solved $dsaProblems DSA problems${dsaPlatform.isNotEmpty ? ' on $dsaPlatform' : ''}',
          if (webGoal.isNotEmpty) 'Worked on: $webGoal',
        ],
        'mood': analysis.mood,
        'sleepHours': _sleepHoursFromEnergy(energy),
        'breakActivities': {
          'Short Breaks': studyHours <= 0
              ? 0.5
              : (studyHours / 4).clamp(0.5, 2.0).toDouble(),
        },
        'notes': rawText,
        'createdAt': now.toIso8601String(),
      };

      await _storage.saveJournalEntry(user['id'] as String, {
        'entry': entry,
        'analysis': analysis.toJson(),
        'created_at': now.toIso8601String(),
        'timestamp': now.toIso8601String(),
      });

      for (final item in analysis.skillsProgress.entries) {
        final progress = (item.value as num?)?.toDouble() ?? 0.0;
        if (progress > 0) {
          await _storage.updateSkillProgress(
            user['id'] as String,
            item.key,
            progress,
          );
        }
      }

      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Daily Analysis Report'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(analysis.summary),
                const SizedBox(height: 12),
                Text('Mood: ${analysis.mood}'),
                Text('Stress: ${analysis.stressLevel}/100'),
                Text('Burnout: ${analysis.burnoutRisk}/100'),
                if (analysis.skillsMentioned.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text('Skills: ${analysis.skillsMentioned.join(', ')}'),
                ],
                if (analysis.suggestions.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  ...analysis.suggestions.take(3).map((s) => Text('- $s')),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back To Dashboard'),
            ),
          ],
        ),
      );
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<String> _detectSkills({
    required String text,
    required String webGoal,
    required int dsaProblems,
  }) {
    final content = '$text $webGoal'.toLowerCase();
    final skills = <String>{};
    if (dsaProblems > 0 ||
        content.contains('dsa') ||
        content.contains('leetcode') ||
        content.contains('algorithm')) {
      skills.add('DSA');
    }
    if (webGoal.isNotEmpty ||
        content.contains('web') ||
        content.contains('html') ||
        content.contains('css') ||
        content.contains('javascript') ||
        content.contains('react') ||
        content.contains('frontend') ||
        content.contains('backend')) {
      skills.add('Web Dev');
    }
    if (content.contains('ai') ||
        content.contains('ml') ||
        content.contains('machine learning') ||
        content.contains('model')) {
      skills.add('AI/ML');
    }
    if (skills.isEmpty && (double.tryParse(_studyHoursController.text) ?? 0) > 0) {
      skills.add('Other');
    }
    return skills.toList();
  }

  int _estimateStress({
    required String text,
    required String mood,
    required int energy,
    required double studyHours,
    required int distractions,
  }) {
    var stress = 30;
    final content = text.toLowerCase();
    if (mood == 'stressed') stress += 30;
    if (mood == 'anxious' || mood == 'overwhelmed') stress += 35;
    if (mood == 'tired') stress += 15;
    if (mood == 'excited' || mood == 'motivated') stress -= 10;
    if (content.contains('burnout') ||
        content.contains('overwhelmed') ||
        content.contains('exhausted')) {
      stress += 20;
    }
    if (energy <= 3) stress += 20;
    if (energy >= 8) stress -= 10;
    if (studyHours >= 8) stress += 10;
    stress += distractions * 8;
    return stress.clamp(5, 100).toInt();
  }

  int _estimateBurnout({
    required int stress,
    required int energy,
    required double studyHours,
  }) {
    var burnout = (stress * 0.7).round();
    if (studyHours >= 8) burnout += 12;
    if (studyHours <= 2 && energy <= 4) burnout += 8;
    if (energy <= 3) burnout += 15;
    if (_selectedMood == 'overwhelmed') burnout += 12;
    return burnout.clamp(10, 100).toInt();
  }

  List<String> _buildSuggestions({
    required double studyHours,
    required int dsaProblems,
    required int burnout,
    required int distractionCount,
    required List<String> skills,
  }) {
    final suggestions = <String>[
      if (studyHours < 3) 'Add one more focused study block tomorrow.',
      if (dsaProblems == 0 && skills.contains('DSA'))
        'Solve at least 1-2 DSA problems next session.',
      if (distractionCount > 0) 'Reduce distraction triggers before studying.',
      if (burnout >= 70) 'Keep tomorrow lighter and prioritize recovery.',
    ];
    return suggestions.isEmpty
        ? ['Stay consistent and keep logging your progress daily.']
        : suggestions;
  }

  String _buildSummary({
    required double studyHours,
    required int dsaProblems,
    required String webGoal,
    required int burnout,
    required List<String> skills,
  }) {
    final skillText = skills.isEmpty ? 'general study work' : skills.join(', ');
    final hourText = studyHours > 0
        ? '${studyHours.toStringAsFixed(1)} hours of study'
        : 'a lighter academic day';
    final dsaText = dsaProblems > 0 ? ' and solved $dsaProblems DSA problems' : '';
    final goalText = webGoal.isNotEmpty ? ' while working on $webGoal' : '';
    final riskText = burnout >= 70
        ? 'Burnout risk looks elevated, so recovery should be part of tomorrow.'
        : 'Your workload looks manageable if you keep protecting your focus.';
    return 'You logged $hourText$dsaText$goalText, with most activity aligned to $skillText. $riskText';
  }

  double _skillProgress({
    required String skill,
    required double studyHours,
    required int dsaProblems,
    required String webGoal,
    required String text,
  }) {
    if (skill == 'DSA') return (15 + dsaProblems * 8 + studyHours * 4).clamp(10, 100).toDouble();
    if (skill == 'Web Dev') return (20 + (webGoal.isNotEmpty ? 20 : 0) + studyHours * 5).clamp(10, 100).toDouble();
    if (skill == 'AI/ML') return (15 + (text.toLowerCase().contains('model') ? 15 : 0) + studyHours * 4).clamp(10, 100).toDouble();
    return (studyHours * 10).clamp(5, 100).toDouble();
  }

  String _focusQuality(int stress, int energy, int distractions) {
    if (stress >= 75 || energy <= 3 || distractions >= 3) return 'low';
    if (stress >= 45 || energy <= 5 || distractions > 0) return 'medium';
    return 'high';
  }

  double _sleepHoursFromEnergy(int energy) {
    if (energy >= 8) return 8.0;
    if (energy >= 6) return 7.0;
    if (energy >= 4) return 6.5;
    return 5.5;
  }

  void _addDistraction() {
    String value = '';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Distraction'),
        content: TextField(
          onChanged: (text) => value = text,
          decoration: const InputDecoration(hintText: 'e.g. Social media'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (value.trim().isNotEmpty) {
                setState(() => _distractions.add(value.trim()));
              }
            },
            child: const Text('Add'),
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
          'Enhanced Journal',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: 8,
              children: _moods.map((mood) {
                return ChoiceChip(
                  label: Text(mood.toUpperCase()),
                  selected: _selectedMood == mood,
                  onSelected: (_) => setState(() => _selectedMood = mood),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _mainController,
              maxLines: 8,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'What did you do today? What did you study? How did you feel?',
                hintStyle: TextStyle(color: Colors.white70),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: TextField(controller: _studyHoursController, keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Study Hours'))),
                const SizedBox(width: 12),
                Expanded(child: TextField(controller: _dsaProblemsController, keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'DSA Problems'))),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: TextField(controller: _dsaPlatformController, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'DSA Platform'))),
                const SizedBox(width: 12),
                Expanded(child: TextField(controller: _webGoalController, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Web Goal'))),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: TextField(controller: _energyController, keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Energy (1-10)'))),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: _addDistraction,
                  icon: const Icon(Icons.add_circle, color: Colors.white),
                ),
              ],
            ),
            if (_distractions.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _distractions.map((item) {
                  return Chip(
                    label: Text(item),
                    onDeleted: () => setState(() => _distractions.remove(item)),
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _submitJournal,
              child: _isLoading
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Analyze Day With AI'),
            ),
          ],
        ),
      ),
    );
  }
}
