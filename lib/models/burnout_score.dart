import 'package:flutter/material.dart';

class BurnoutScore {
  final String id;
  final DateTime date;
  final double score; // 0-100
  final Map<String, double> factors; // study_hours, sleep, stress, breaks
  final String riskLevel; // low, moderate, high
  final List<String> recommendations;
  final DateTime createdAt;

  BurnoutScore({
    required this.id,
    required this.date,
    required this.score,
    required this.factors,
    required this.riskLevel,
    required this.recommendations,
    required this.createdAt,
  });

  factory BurnoutScore.fromJson(Map<String, dynamic> json) {
    return BurnoutScore(
      id: json['id'] as String? ?? '',
      date: json['date'] != null
          ? DateTime.parse(json['date'] as String)
          : DateTime.now(),
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
      factors: Map<String, double>.from(json['factors'] as Map? ?? {}),
      riskLevel: json['riskLevel'] as String? ?? 'low',
      recommendations: List<String>.from(
        json['recommendations'] as List? ?? [],
      ),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'score': score,
      'factors': factors,
      'riskLevel': riskLevel,
      'recommendations': recommendations,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Color get riskColor {
    if (score <= 30) return Colors.green;
    if (score <= 70) return Colors.orange;
    return Colors.red;
  }

  String get riskDescription {
    if (score <= 30) return 'Healthy - Low burnout risk';
    if (score <= 70) return 'Moderate stress - Monitor closely';
    return 'High burnout risk - Immediate action needed';
  }
}
