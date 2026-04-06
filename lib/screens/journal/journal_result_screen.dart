import 'package:flutter/material.dart';
import '../../models/journal_analysis.dart';

class JournalResultScreen extends StatelessWidget {
  final JournalAnalysis analysis;

  const JournalResultScreen({super.key, required this.analysis});

  String _getMoodEmoji() {
    switch (analysis.mood.toLowerCase()) {
      case 'positive':
        return '😊';
      case 'negative':
        return '😔';
      case 'stressed':
        return '😫';
      case 'motivated':
        return '🚀';
      default:
        return '😐';
    }
  }

  Color _getStressColor() {
    if (analysis.stressLevel < 30) return Colors.green;
    if (analysis.stressLevel < 70) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      appBar: AppBar(
        title: const Text('Journal Insights'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Mood and Stress
            Row(
              children: [
                Expanded(
                  child: Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Text('Mood', style: TextStyle(fontSize: 16)),
                          const SizedBox(height: 8),
                          Text('${_getMoodEmoji()} ${analysis.mood.toUpperCase()}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Text('Stress Level', style: TextStyle(fontSize: 16)),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: analysis.stressLevel / 100,
                            backgroundColor: Colors.grey[200],
                            color: _getStressColor(),
                            minHeight: 12,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          const SizedBox(height: 4),
                          Text('${analysis.stressLevel}%', style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Motivation Message
            Card(
              color: Colors.teal[50],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: BorderSide(color: Colors.teal.shade200),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.lightbulb, color: Colors.teal),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        analysis.motivationMessage,
                        style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.teal),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Summary
            _buildSectionCard('Summary', Icons.description, analysis.summary),
            const SizedBox(height: 16),

            // Key Issues
            _buildListCard('Key Issues', Icons.warning_amber, analysis.keyIssues),
            const SizedBox(height: 16),

            // Suggestions
            _buildListCard('Actionable Suggestions', Icons.check_circle_outline, analysis.suggestions),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(String title, IconData icon, String content) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blueGrey),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            Text(content, style: const TextStyle(fontSize: 15, height: 1.4)),
          ],
        ),
      ),
    );
  }

  Widget _buildListCard(String title, IconData icon, List<String> items) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blueGrey),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            if (items.isEmpty)
              const Text('None detected.', style: TextStyle(fontStyle: FontStyle.italic))
            else
              ...items.map((item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Expanded(child: Text(item, style: const TextStyle(fontSize: 15, height: 1.4))),
                      ],
                    ),
                  )),
          ],
        ),
      ),
    );
  }
}
