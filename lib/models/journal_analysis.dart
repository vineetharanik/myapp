class JournalAnalysis {
  final String summary;
  final String mood;
  final int stressLevel;
  final int burnoutRisk;
  final List<String> keyIssues;
  final List<String> suggestions;
  final String motivationMessage;
  final List<String> skillsMentioned;
  final Map<String, dynamic> skillsProgress;
  final Map<String, dynamic> studyTimeAnalysis;
  final Map<String, dynamic> weeklyRecommendations;

  JournalAnalysis({
    required this.summary,
    required this.mood,
    required this.stressLevel,
    required this.burnoutRisk,
    required this.keyIssues,
    required this.suggestions,
    required this.motivationMessage,
    required this.skillsMentioned,
    required this.skillsProgress,
    required this.studyTimeAnalysis,
    required this.weeklyRecommendations,
  });

  factory JournalAnalysis.fromJson(Map<String, dynamic> json) {
    return JournalAnalysis(
      summary: json['summary'] ?? '',
      mood: json['mood'] ?? 'neutral',
      stressLevel: (json['stress_level'] as num?)?.toInt() ?? 0,
      burnoutRisk: (json['burnout_risk'] as num?)?.toInt() ?? 0,
      keyIssues: List<String>.from(json['key_issues'] ?? []),
      suggestions: List<String>.from(json['suggestions'] ?? []),
      motivationMessage: json['motivation_message'] ?? '',
      skillsMentioned: List<String>.from(json['skills_mentioned'] ?? []),
      skillsProgress: Map<String, dynamic>.from(json['skills_progress'] ?? {}),
      studyTimeAnalysis: Map<String, dynamic>.from(
        json['study_time_analysis'] ?? {},
      ),
      weeklyRecommendations: Map<String, dynamic>.from(
        json['weekly_recommendations'] ?? {},
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'summary': summary,
      'mood': mood,
      'stress_level': stressLevel,
      'burnout_risk': burnoutRisk,
      'key_issues': keyIssues,
      'suggestions': suggestions,
      'motivation_message': motivationMessage,
      'skills_mentioned': skillsMentioned,
      'skills_progress': skillsProgress,
      'study_time_analysis': studyTimeAnalysis,
      'weekly_recommendations': weeklyRecommendations,
    };
  }
}
