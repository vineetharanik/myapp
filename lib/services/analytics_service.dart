import '../models/journal_entry.dart';
import '../models/burnout_score.dart';
import '../models/skill_progress.dart';
import '../models/weekly_plan.dart';

class AnalyticsService {
  // Calculate burnout score from journal entries
  static BurnoutScore calculateBurnoutScore(List<JournalEntry> entries) {
    if (entries.isEmpty) {
      return BurnoutScore(
        id: 'default',
        date: DateTime.now(),
        score: 25.0, // Default low risk
        factors: {
          'study_hours': 0.0,
          'sleep': 0.0,
          'stress': 0.0,
          'breaks': 0.0,
        },
        riskLevel: 'low',
        recommendations: ['Start journaling to get personalized insights'],
        createdAt: DateTime.now(),
      );
    }

    // Get last 7 days of entries
    final recentEntries = entries.take(7).toList();

    // Calculate factors
    double totalStudyHours = 0.0;
    double avgSleepHours = 0.0;
    double totalStressScore = 0.0;
    double totalBreakHours = 0.0;

    for (final entry in recentEntries) {
      totalStudyHours += entry.totalStudyHours;
      avgSleepHours += entry.sleepHours;
      totalStressScore += entry.stressScore;
      totalBreakHours += entry.totalBreakHours;
    }

    avgSleepHours = avgSleepHours / recentEntries.length;
    totalStressScore = totalStressScore / recentEntries.length;

    // Calculate burnout score (0-100)
    double score = 0.0;

    // Study hours factor (30% weight)
    if (totalStudyHours > 56) {
      // > 8 hours/day
      score += 30.0;
    } else if (totalStudyHours > 42) {
      // > 6 hours/day
      score += 20.0;
    } else if (totalStudyHours > 28) {
      // > 4 hours/day
      score += 10.0;
    }

    // Sleep factor (25% weight)
    if (avgSleepHours < 6) {
      score += 25.0;
    } else if (avgSleepHours < 7) {
      score += 15.0;
    } else if (avgSleepHours < 8) {
      score += 5.0;
    }

    // Stress factor (35% weight)
    score += (totalStressScore / 100.0) * 35.0;

    // Break factor (10% weight) - less break time increases risk
    if (totalBreakHours < 7) {
      // < 1 hour/day
      score += 10.0;
    } else if (totalBreakHours < 14) {
      // < 2 hours/day
      score += 5.0;
    }

    score = score.clamp(0.0, 100.0).toDouble();

    // Determine risk level
    String riskLevel;
    if (score <= 30) {
      riskLevel = 'low';
    } else if (score <= 70) {
      riskLevel = 'moderate';
    } else {
      riskLevel = 'high';
    }

    // Generate recommendations
    final recommendations = <String>[];
    if (totalStudyHours > 56) {
      recommendations.add('Reduce daily study hours to 6-8 hours');
    }
    if (avgSleepHours < 7) {
      recommendations.add('Aim for 7-9 hours of sleep per night');
    }
    if (totalStressScore > 50) {
      recommendations.add('Practice stress management techniques');
    }
    if (totalBreakHours < 7) {
      recommendations.add('Take regular breaks during study sessions');
    }
    if (recommendations.isEmpty) {
      recommendations.add('Maintain your current healthy habits');
    }

    return BurnoutScore(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      score: score,
      factors: {
        'study_hours': totalStudyHours,
        'sleep': avgSleepHours,
        'stress': totalStressScore,
        'breaks': totalBreakHours,
      },
      riskLevel: riskLevel,
      recommendations: recommendations,
      createdAt: DateTime.now(),
    );
  }

  // Calculate skill progress from journal entries - only for user's registered skills
  static Map<String, SkillProgress> calculateSkillProgress(
    List<JournalEntry> entries,
    List<String> userSkills,
    {List<Map<String, dynamic>> history = const []}
  ) {
    final trackedSkills = <String>{};
    trackedSkills.addAll(
      userSkills
          .map(_canonicalSkillName)
          .where((skill) => skill.isNotEmpty && skill != 'Other'),
    );

    for (final entry in entries) {
      trackedSkills.addAll(
        entry.studyHours.keys
            .map(_canonicalSkillName)
            .where((skill) => skill.isNotEmpty && skill != 'Other'),
      );
      trackedSkills.addAll(_detectSkillsFromText(entry.notes));
      trackedSkills.addAll(
        _detectSkillsFromText(entry.tasksCompleted.join(' ')),
      );
    }

    for (final journal in history) {
      final analysis = Map<String, dynamic>.from(journal['analysis'] as Map? ?? {});
      trackedSkills.addAll(
        List<String>.from(analysis['skills_mentioned'] as List? ?? [])
            .map(_canonicalSkillName)
            .where((skill) => skill.isNotEmpty && skill != 'Other'),
      );
      trackedSkills.addAll(
        Map<String, dynamic>.from(analysis['skills_progress'] as Map? ?? {})
            .keys
            .map(_canonicalSkillName)
            .where((skill) => skill.isNotEmpty && skill != 'Other'),
      );
    }

    if (trackedSkills.isEmpty) {
      return {};
    }

    final skillProgress = <String, SkillProgress>{};
    final aiProgressSamples = <String, List<double>>{};
    final heuristicHits = <String, int>{};

    for (final skill in trackedSkills) {
      skillProgress[skill] = SkillProgress(
        id: skill,
        skillName: skill,
        progressPercentage: 0.0,
        currentLevel: 1,
        completedMilestones: [],
        pendingMilestones: _getSkillMilestones(skill),
        nextRecommendedTask: _getFirstMilestone(skill),
        lastUpdated: DateTime.now(),
        createdAt: DateTime.now(),
      );
      heuristicHits[skill] = 0;
    }

    for (final journal in history) {
      final analysis = Map<String, dynamic>.from(journal['analysis'] as Map? ?? {});
      final progressMap = Map<String, dynamic>.from(
        analysis['skills_progress'] as Map? ?? {},
      );

      for (final progressEntry in progressMap.entries) {
        final skill = _canonicalSkillName(progressEntry.key);
        if (!trackedSkills.contains(skill)) continue;

        final parsedProgress = _parseProgress(progressEntry.value);
        if (parsedProgress <= 0) continue;

        aiProgressSamples.putIfAbsent(skill, () => []).add(parsedProgress);
      }
    }

    // Process entries to update progress
    for (final entry in entries) {
      // Safe access to potentially null fields
      final text = '${entry.tasksCompleted.join(' ')} ${entry.notes}'
          .toLowerCase();

      for (final skill in trackedSkills) {
        final keywords = _getSkillKeywords(skill);
        bool hasActivity = false;

        for (final keyword in keywords) {
          if (text.contains(keyword)) {
            hasActivity = true;
            break;
          }
        }

        if ((entry.studyHours[skill] ?? 0) > 0) {
          hasActivity = true;
        }

        if (hasActivity) {
          heuristicHits[skill] = (heuristicHits[skill] ?? 0) + 1;
        }
      }
    }

    for (final skill in trackedSkills) {
      final currentProgress = skillProgress[skill]!;
      final aiSamples = aiProgressSamples[skill] ?? const <double>[];
      final aiProgress = aiSamples.isEmpty
          ? 0.0
          : aiSamples.reduce((a, b) => a + b) / aiSamples.length;
      final heuristicProgress =
          ((heuristicHits[skill] ?? 0) * 12.5).clamp(0, 100).toDouble();
      final newProgress = (aiProgress > 0
              ? aiProgress.clamp(0.0, 100.0)
              : heuristicProgress)
          .toDouble();

      final completedMilestones = <String>[];
      final pendingMilestones = List<String>.from(
        currentProgress.pendingMilestones,
      );
      final milestoneCount = (newProgress / 20)
          .floor()
          .clamp(0, pendingMilestones.length)
          .toInt();
      for (int i = 0; i < milestoneCount; i++) {
        completedMilestones.add(pendingMilestones.removeAt(0));
      }

      int newLevel = 1;
      if (newProgress >= 80) {
        newLevel = 5;
      } else if (newProgress >= 60) {
        newLevel = 4;
      } else if (newProgress >= 40) {
        newLevel = 3;
      } else if (newProgress >= 20) {
        newLevel = 2;
      }

      skillProgress[skill] = SkillProgress(
        id: currentProgress.id,
        skillName: currentProgress.skillName,
        progressPercentage: newProgress,
        currentLevel: newLevel,
        completedMilestones: completedMilestones,
        pendingMilestones: pendingMilestones,
        nextRecommendedTask: pendingMilestones.isNotEmpty
            ? pendingMilestones.first
            : 'Skill mastered!',
        lastUpdated: DateTime.now(),
        createdAt: currentProgress.createdAt,
      );
    }

    return skillProgress;
  }

  // Generate weekly plan from journal data
  static WeeklyPlan generateWeeklyPlan(
    List<JournalEntry> entries,
    Map<String, SkillProgress> skillProgress,
  ) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));

    // Analyze recent performance
    final recentEntries = entries.take(7).toList();
    double avgStudyHours = 0.0;
    int totalDSAProblems = 0;
    String dominantSkill = 'DSA';

    if (recentEntries.isNotEmpty) {
      for (final entry in recentEntries) {
        avgStudyHours += entry.totalStudyHours;
        // Extract DSA problems from tasks
        for (final task in entry.tasksCompleted) {
          if (task.toLowerCase().contains('problem') ||
              task.toLowerCase().contains('dsa')) {
            totalDSAProblems++;
          }
        }
      }
      avgStudyHours = avgStudyHours / recentEntries.length;
    }

    // Determine focus goal based on skill progress
    double highestProgress = 0.0;
    for (final skill in skillProgress.entries) {
      if (skill.value.progressPercentage > highestProgress) {
        highestProgress = skill.value.progressPercentage;
        dominantSkill = skill.key;
      }
    }

    // Generate targets
    final targets = <String, dynamic>{};
    targets['study_hours'] = (avgStudyHours * 7).round().clamp(20, 50);
    targets['dsa_problems'] = (totalDSAProblems + 1).clamp(3, 10);
    targets[dominantSkill.toLowerCase()] = 'Continue current progress';

    // Generate daily tasks
    final dailyTasks = <String>[];
    final days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    for (int i = 0; i < days.length; i++) {
      String task;
      if (i < 5) {
        // Weekdays
        if (i % 2 == 0) {
          task = '${days[i]}: Focus on $dominantSkill fundamentals';
        } else {
          task =
              '${days[i]}: Practice ${targets['dsa_problems'] ~/ 5} DSA problems';
        }
      } else {
        // Weekends
        task = '${days[i]}: ${i == 5 ? 'Project work' : 'Review and rest'}';
      }
      dailyTasks.add(task);
    }

    // Generate recommendations
    final recommendations = <String>[];
    if (avgStudyHours < 4) {
      recommendations.add('Increase daily study time gradually');
    } else if (avgStudyHours > 8) {
      recommendations.add('Consider reducing study hours to prevent burnout');
    }
    if (totalDSAProblems < 3) {
      recommendations.add('Focus on solving more DSA problems');
    }
    recommendations.add('Take regular breaks and maintain work-life balance');

    return WeeklyPlan(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      weekStart: weekStart,
      weekEnd: weekEnd,
      focusGoal: dominantSkill,
      targets: targets,
      dailyTasks: dailyTasks,
      recommendations: recommendations,
      completionPercentage: 0.0, // Will be updated as tasks are completed
      createdAt: DateTime.now(),
    );
  }

  static List<String> _getSkillKeywords(String skill) {
    switch (skill.toLowerCase()) {
      case 'dsa':
        return ['dsa', 'algorithm', 'data structure', 'leetcode', 'codeforces'];
      case 'web dev':
      case 'web development':
        return [
          'html',
          'css',
          'javascript',
          'react',
          'node',
          'web',
          'frontend',
          'backend',
        ];
      case 'ai/ml':
      case 'ai':
      case 'ml':
      case 'machine learning':
        return [
          'machine learning',
          'ai',
          'ml',
          'neural',
          'tensorflow',
          'pytorch',
          'python',
        ];
      default:
        return [skill.toLowerCase()];
    }
  }

  static List<String> _getSkillMilestones(String skill) {
    switch (skill) {
      case 'DSA':
        return [
          'Learn basic data structures',
          'Master sorting algorithms',
          'Understand tree and graph algorithms',
          'Solve medium-level problems consistently',
          'Handle complex algorithmic challenges',
        ];
      case 'Web Dev':
        return [
          'Master HTML/CSS fundamentals',
          'Learn JavaScript basics',
          'Build responsive layouts',
          'Master frontend frameworks',
          'Full-stack application development',
        ];
      case 'AI/ML':
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
          'Mastery level',
        ];
    }
  }

  static String _getFirstMilestone(String skill) {
    final milestones = _getSkillMilestones(skill);
    return milestones.isNotEmpty ? milestones.first : 'Start learning';
  }

  static String _canonicalSkillName(String rawSkill) {
    final skill = rawSkill.trim().toLowerCase();
    if (skill.isEmpty) return '';

    if (skill.contains('dsa') ||
        skill.contains('problem solving') ||
        skill.contains('algorithm') ||
        skill.contains('data structure')) {
      return 'DSA';
    }

    if (skill.contains('web') ||
        skill.contains('frontend') ||
        skill.contains('backend') ||
        skill.contains('html') ||
        skill.contains('css') ||
        skill.contains('javascript') ||
        skill.contains('react')) {
      return 'Web Dev';
    }

    if (skill.contains('ai') ||
        skill.contains('ml') ||
        skill.contains('machine learning') ||
        skill.contains('deep learning')) {
      return 'AI/ML';
    }

    return rawSkill.trim();
  }

  static Set<String> _detectSkillsFromText(String text) {
    final normalized = text.toLowerCase();
    final detected = <String>{};

    if (_getSkillKeywords('DSA').any(normalized.contains)) {
      detected.add('DSA');
    }
    if (_getSkillKeywords('Web Dev').any(normalized.contains)) {
      detected.add('Web Dev');
    }
    if (_getSkillKeywords('AI/ML').any(normalized.contains)) {
      detected.add('AI/ML');
    }

    return detected;
  }

  static double _parseProgress(dynamic value) {
    if (value is num) {
      return value.toDouble().clamp(0.0, 100.0).toDouble();
    }

    final parsed = double.tryParse(value.toString().replaceAll('%', '').trim());
    if (parsed == null) return 0.0;
    return parsed.clamp(0.0, 100.0).toDouble();
  }
}
