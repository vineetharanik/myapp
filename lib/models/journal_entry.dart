class JournalEntry {
  final String id;
  final DateTime date;
  final Map<String, double> studyHours; // DSA, Web, AI, Other
  final List<String> tasksCompleted;
  final String mood; // happy, neutral, stressed, exhausted
  final double sleepHours;
  final Map<String, double> breakActivities; // games, scrolling, etc.
  final String notes;
  final DateTime createdAt;

  JournalEntry({
    required this.id,
    required this.date,
    required this.studyHours,
    required this.tasksCompleted,
    required this.mood,
    required this.sleepHours,
    required this.breakActivities,
    required this.notes,
    required this.createdAt,
  });

  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    return JournalEntry(
      id: json['id'] as String? ?? '',
      date: json['date'] != null
          ? DateTime.parse(json['date'] as String)
          : DateTime.now(),
      studyHours: Map<String, double>.from(json['studyHours'] as Map? ?? {}),
      tasksCompleted: List<String>.from(json['tasksCompleted'] as List? ?? []),
      mood: json['mood'] as String? ?? 'neutral',
      sleepHours: (json['sleepHours'] as num?)?.toDouble() ?? 0.0,
      breakActivities: Map<String, double>.from(
        json['breakActivities'] as Map? ?? {},
      ),
      notes: json['notes'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'studyHours': studyHours,
      'tasksCompleted': tasksCompleted,
      'mood': mood,
      'sleepHours': sleepHours,
      'breakActivities': breakActivities,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  double get totalStudyHours {
    return studyHours.values.fold(0.0, (sum, hours) => sum + hours);
  }

  double get totalBreakHours {
    return breakActivities.values.fold(0.0, (sum, hours) => sum + hours);
  }

  int get stressScore {
    switch (mood) {
      case 'happy':
        return 0;
      case 'excited':
      case 'motivated':
      case 'productive':
      case 'focused':
        return 15;
      case 'neutral':
        return 25;
      case 'tired':
        return 60;
      case 'stressed':
        return 75;
      case 'anxious':
        return 85;
      case 'overwhelmed':
      case 'exhausted':
        return 100;
      default:
        return 50;
    }
  }
}
