class WeeklyPlan {
  final String id;
  final DateTime weekStart;
  final DateTime weekEnd;
  final String focusGoal;
  final Map<String, dynamic> targets; // DSA, Web Dev, AI/ML targets
  final List<String> dailyTasks;
  final List<String> recommendations;
  final double completionPercentage;
  final DateTime createdAt;

  WeeklyPlan({
    required this.id,
    required this.weekStart,
    required this.weekEnd,
    required this.focusGoal,
    required this.targets,
    required this.dailyTasks,
    required this.recommendations,
    required this.completionPercentage,
    required this.createdAt,
  });

  factory WeeklyPlan.fromJson(Map<String, dynamic> json) {
    return WeeklyPlan(
      id: json['id'] as String? ?? '',
      weekStart: json['weekStart'] != null
          ? DateTime.parse(json['weekStart'] as String)
          : DateTime.now(),
      weekEnd: json['weekEnd'] != null
          ? DateTime.parse(json['weekEnd'] as String)
          : DateTime.now(),
      focusGoal: json['focusGoal'] as String? ?? '',
      targets: Map<String, dynamic>.from(json['targets'] as Map? ?? {}),
      dailyTasks: List<String>.from(json['dailyTasks'] as List? ?? []),
      recommendations: List<String>.from(
        json['recommendations'] as List? ?? [],
      ),
      completionPercentage:
          (json['completionPercentage'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'weekStart': weekStart.toIso8601String(),
      'weekEnd': weekEnd.toIso8601String(),
      'focusGoal': focusGoal,
      'targets': targets,
      'dailyTasks': dailyTasks,
      'recommendations': recommendations,
      'completionPercentage': completionPercentage,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  bool get isCompleted {
    return completionPercentage >= 100.0;
  }

  String get weekDescription {
    return '${weekStart.day}-${weekEnd.day} ${_getMonthName(weekStart.month)}';
  }

  String _getMonthName(int month) {
    if (month < 1 || month > 12) return 'Unknown';
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }
}
