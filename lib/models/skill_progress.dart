class SkillProgress {
  final String id;
  final String skillName; // DSA, Web Dev, AI/ML, etc.
  final double progressPercentage; // 0-100
  final int currentLevel; // 1-5
  final List<String> completedMilestones;
  final List<String> pendingMilestones;
  final String nextRecommendedTask;
  final DateTime lastUpdated;
  final DateTime createdAt;

  SkillProgress({
    required this.id,
    required this.skillName,
    required this.progressPercentage,
    required this.currentLevel,
    required this.completedMilestones,
    required this.pendingMilestones,
    required this.nextRecommendedTask,
    required this.lastUpdated,
    required this.createdAt,
  });

  factory SkillProgress.fromJson(Map<String, dynamic> json) {
    return SkillProgress(
      id: json['id'] as String? ?? '',
      skillName: json['skillName'] as String? ?? '',
      progressPercentage:
          (json['progressPercentage'] as num?)?.toDouble() ?? 0.0,
      currentLevel: json['currentLevel'] as int? ?? 1,
      completedMilestones: List<String>.from(
        json['completedMilestones'] as List? ?? [],
      ),
      pendingMilestones: List<String>.from(
        json['pendingMilestones'] as List? ?? [],
      ),
      nextRecommendedTask: json['nextRecommendedTask'] as String? ?? '',
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'] as String)
          : DateTime.now(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'skillName': skillName,
      'progressPercentage': progressPercentage,
      'currentLevel': currentLevel,
      'completedMilestones': completedMilestones,
      'pendingMilestones': pendingMilestones,
      'nextRecommendedTask': nextRecommendedTask,
      'lastUpdated': lastUpdated.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  String get levelDescription {
    switch (currentLevel) {
      case 1:
        return 'Beginner';
      case 2:
        return 'Novice';
      case 3:
        return 'Intermediate';
      case 4:
        return 'Advanced';
      case 5:
        return 'Expert';
      default:
        return 'Unknown';
    }
  }

  bool get isCompleted {
    return progressPercentage >= 100.0;
  }
}
