import 'package:flutter/material.dart';
import '../chatbot/enhanced_chatbot_screen.dart';

class BurnoutDetailsScreen extends StatefulWidget {
  final int burnoutRisk;
  const BurnoutDetailsScreen({super.key, required this.burnoutRisk});

  @override
  State<BurnoutDetailsScreen> createState() => _BurnoutDetailsScreenState();
}

class _BurnoutDetailsScreenState extends State<BurnoutDetailsScreen> {
  final List<Map<String, dynamic>> _counselors = [
    {
      'name': 'Dr. Sarah Johnson',
      'specialty': 'Student Mental Health',
      'experience': '10+ years',
      'rating': 4.8,
      'available': true,
      'image': '👩‍⚕️',
    },
    {
      'name': 'Dr. Michael Chen',
      'specialty': 'Academic Stress Management',
      'experience': '8+ years',
      'rating': 4.7,
      'available': true,
      'image': '👨‍⚕️',
    },
    {
      'name': 'Dr. Emily Rodriguez',
      'specialty': 'Burnout Prevention',
      'experience': '12+ years',
      'rating': 4.9,
      'available': false,
      'image': '👩‍⚕️',
    },
    {
      'name': 'Dr. James Wilson',
      'specialty': 'Career Counseling',
      'experience': '6+ years',
      'rating': 4.6,
      'available': true,
      'image': '👨‍⚕️',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final riskLevel = _getRiskLevel(widget.burnoutRisk);
    final riskColor = _getRiskColor(widget.burnoutRisk);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F23),
      appBar: AppBar(
        title: const Text(
          'Burnout Risk Details',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRiskOverview(riskLevel, riskColor),
            const SizedBox(height: 24),
            _buildQuickActions(riskColor),
            const SizedBox(height: 24),
            _buildCounselorsSection(),
            const SizedBox(height: 24),
            _buildAIChatSection(),
            const SizedBox(height: 24),
            _buildRecommendations(),
          ],
        ),
      ),
    );
  }

  Widget _buildRiskOverview(String riskLevel, Color riskColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [riskColor.withOpacity(0.2), riskColor.withOpacity(0.1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: riskColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Current Risk Level',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: riskColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: riskColor.withOpacity(0.5)),
                ),
                child: Text(
                  riskLevel,
                  style: TextStyle(
                    color: riskColor,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: widget.burnoutRisk / 10.0,
            backgroundColor: Colors.white.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(riskColor),
          ),
          const SizedBox(height: 12),
          Text(
            'Risk Score: ${widget.burnoutRisk}/10',
            style: TextStyle(
              color: riskColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _getRiskDescription(widget.burnoutRisk),
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(Color riskColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                '🧘',
                'Breathing Exercise',
                '5-minute quick relief',
                () => _showBreathingExercise(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                '🎵',
                'Relaxing Music',
                'Calm your mind',
                () => _showMusicOptions(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                '📝',
                'Journal Entry',
                'Express your feelings',
                () => Navigator.pop(context),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                '🚶',
                'Take a Walk',
                'Get some fresh air',
                () => _showWalkReminder(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(
    String emoji,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCounselorsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Available Counselors',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ..._counselors.map((counselor) => _buildCounselorCard(counselor)),
      ],
    );
  }

  Widget _buildCounselorCard(Map<String, dynamic> counselor) {
    final isAvailable = counselor['available'] as bool;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Text(counselor['image'], style: const TextStyle(fontSize: 40)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  counselor['name'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  counselor['specialty'],
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '${counselor['experience']} experience',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 12),
                        const SizedBox(width: 2),
                        Text(
                          '${counselor['rating']}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isAvailable
                      ? Colors.green.withOpacity(0.2)
                      : Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isAvailable
                        ? Colors.green.withOpacity(0.5)
                        : Colors.red.withOpacity(0.5),
                  ),
                ),
                child: Text(
                  isAvailable ? 'Available' : 'Busy',
                  style: TextStyle(
                    color: isAvailable ? Colors.green : Colors.red,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              if (isAvailable)
                ElevatedButton(
                  onPressed: () => _scheduleSession(counselor),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00D9FF),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Book',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAIChatSection() {
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
            'AI Mental Health Assistant',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Get instant support from our AI assistant trained to help with stress, anxiety, and burnout management.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const EnhancedChatbotScreen(),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00D9FF),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Start AI Chat',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendations() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Personalized Recommendations',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ..._getRecommendations().map(
          (recommendation) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: const Color(0xFF00D9FF),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    recommendation,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _getRiskLevel(int risk) {
    if (risk >= 8) return 'HIGH';
    if (risk >= 5) return 'MODERATE';
    return 'LOW';
  }

  Color _getRiskColor(int risk) {
    if (risk >= 8) return Colors.red;
    if (risk >= 5) return Colors.orange;
    return Colors.green;
  }

  String _getRiskDescription(int risk) {
    if (risk >= 8) {
      return 'Your burnout risk is high. Immediate action is recommended. Consider taking a break and seeking support.';
    } else if (risk >= 5) {
      return 'Your burnout risk is moderate. Pay attention to warning signs and practice self-care.';
    } else {
      return 'Your burnout risk is low. Keep up the good work with healthy habits.';
    }
  }

  List<String> _getRecommendations() {
    final recommendations = <String>[];

    if (widget.burnoutRisk >= 8) {
      recommendations.addAll([
        '🚨 Take at least one full day off from studying',
        '🚨 Get 8+ hours of sleep tonight',
        '🚨 Practice deep breathing exercises',
        '🚨 Consider talking to a counselor',
      ]);
    } else if (widget.burnoutRisk >= 5) {
      recommendations.addAll([
        '⚠️ Take regular breaks every 45-60 minutes',
        '⚠️ Practice mindfulness or meditation',
        '⚠️ Maintain a consistent sleep schedule',
        '⚠️ Limit study sessions to 6 hours max',
      ]);
    } else {
      recommendations.addAll([
        '✅ Continue your healthy study habits',
        '✅ Maintain work-life balance',
        '✅ Keep practicing stress management',
        '✅ Stay connected with friends and family',
      ]);
    }

    return recommendations;
  }

  void _showBreathingExercise() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text(
          '4-7-8 Breathing Exercise',
          style: TextStyle(color: Colors.white),
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Follow this pattern:', style: TextStyle(color: Colors.white)),
            SizedBox(height: 12),
            Text(
              '1. Breathe in for 4 seconds',
              style: TextStyle(color: Colors.white70),
            ),
            Text(
              '2. Hold for 7 seconds',
              style: TextStyle(color: Colors.white70),
            ),
            Text(
              '3. Exhale for 8 seconds',
              style: TextStyle(color: Colors.white70),
            ),
            SizedBox(height: 12),
            Text(
              'Repeat 3-4 times to calm your nervous system.',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Got it',
              style: TextStyle(color: Color(0xFF00D9FF)),
            ),
          ),
        ],
      ),
    );
  }

  void _showMusicOptions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text(
          'Relaxing Music',
          style: TextStyle(color: Colors.white),
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Try these calming playlists:',
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 12),
            Text(
              '🎵 Lo-fi study beats',
              style: TextStyle(color: Colors.white70),
            ),
            Text('🎵 Nature sounds', style: TextStyle(color: Colors.white70)),
            Text('🎵 Classical music', style: TextStyle(color: Colors.white70)),
            Text(
              '🎵 Meditation music',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Close',
              style: TextStyle(color: Color(0xFF00D9FF)),
            ),
          ),
        ],
      ),
    );
  }

  void _showWalkReminder() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text('Take a Walk', style: TextStyle(color: Colors.white)),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Benefits of a short walk:',
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 12),
            Text(
              '🚶 Reduces stress hormones',
              style: TextStyle(color: Colors.white70),
            ),
            Text(
              '🚶 Improves blood circulation',
              style: TextStyle(color: Colors.white70),
            ),
            Text(
              '🚶 Clears your mind',
              style: TextStyle(color: Colors.white70),
            ),
            Text(
              '🚶 Boosts creativity',
              style: TextStyle(color: Colors.white70),
            ),
            SizedBox(height: 12),
            Text(
              'Even 10-15 minutes can help!',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'I\'ll go for a walk',
              style: TextStyle(color: Color(0xFF00D9FF)),
            ),
          ),
        ],
      ),
    );
  }

  void _scheduleSession(Map<String, dynamic> counselor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: Text(
          'Schedule with ${counselor['name']}',
          style: const TextStyle(color: Colors.white),
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Session booking feature coming soon!',
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 12),
            Text('For now, you can:', style: TextStyle(color: Colors.white70)),
            Text(
              '• Email the counselor directly',
              style: TextStyle(color: Colors.white70),
            ),
            Text(
              '• Call the counseling center',
              style: TextStyle(color: Colors.white70),
            ),
            Text(
              '• Use the AI chat for immediate support',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Close',
              style: TextStyle(color: Color(0xFF00D9FF)),
            ),
          ),
        ],
      ),
    );
  }
}
