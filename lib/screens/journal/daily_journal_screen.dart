import 'package:flutter/material.dart';
import '../../services/local_storage_service.dart';

class DailyJournalScreen extends StatefulWidget {
  const DailyJournalScreen({super.key});

  @override
  State<DailyJournalScreen> createState() => _DailyJournalScreenState();
}

class _DailyJournalScreenState extends State<DailyJournalScreen> {
  final TextEditingController _studyHoursController = TextEditingController();
  final TextEditingController _whatStudiedController = TextEditingController();
  final TextEditingController _dsaProblemsController = TextEditingController(
    text: '0',
  );
  final TextEditingController _dsaPlatformController = TextEditingController();
  final TextEditingController _goalPracticeController = TextEditingController();
  final TextEditingController _generalNotesController = TextEditingController();
  final TextEditingController _gamesPlayedController = TextEditingController();

  String _selectedMood = 'neutral';
  bool _isLoading = false;
  late LocalStorageService _localStorageService;

  @override
  void initState() {
    super.initState();
    _localStorageService = LocalStorageService();
  }

  Future<void> _submitJournal() async {
    if (_studyHoursController.text.isEmpty ||
        _whatStudiedController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in study hours and what you studied'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _localStorageService.initialize();

      if (_localStorageService.currentUser == null) {
        throw Exception('User not logged in');
      }

      final userId = _localStorageService.currentUser!['id'];

      // Create journal entry
      final journalEntry = {
        'study_hours': double.tryParse(_studyHoursController.text) ?? 0.0,
        'what_studied': _whatStudiedController.text.trim(),
        'dsa_problems_solved': int.tryParse(_dsaProblemsController.text) ?? 0,
        'dsa_platform': _dsaPlatformController.text.trim(),
        'goal_practice': _goalPracticeController.text.trim(),
        'general_notes': _generalNotesController.text.trim(),
        'games_played': _gamesPlayedController.text.trim(),
        'mood': _selectedMood,
        'date': DateTime.now().toIso8601String(),
      };

      // Save to local storage
      await _localStorageService.saveJournalEntry(userId, {
        'entry': journalEntry,
        'created_at': DateTime.now().toIso8601String(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Journal entry saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Clear form
      _clearForm();

      // Go back to dashboard
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _clearForm() {
    _studyHoursController.clear();
    _whatStudiedController.clear();
    _dsaProblemsController.text = '0';
    _dsaPlatformController.clear();
    _goalPracticeController.clear();
    _generalNotesController.clear();
    _gamesPlayedController.clear();
    _selectedMood = 'neutral';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F23),
      appBar: AppBar(
        title: const Text(
          "Today's Journal",
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
            _buildSectionCard('⏰ Study Time', [
              TextField(
                controller: _studyHoursController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'How many hours did you study today?',
                  hintStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _whatStudiedController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText:
                      'What did you study? (e.g., React hooks, DSA arrays)',
                  hintStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ]),

            const SizedBox(height: 20),

            _buildSectionCard('💻 DSA Practice', [
              TextField(
                controller: _dsaProblemsController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'How many DSA problems did you solve?',
                  hintStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _dsaPlatformController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Which platform? (LeetCode, Codeforces, etc.)',
                  hintStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ]),

            const SizedBox(height: 20),

            _buildSectionCard('🎯 Goal Practice', [
              TextField(
                controller: _goalPracticeController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText:
                      'What did you practice for your goal? (e.g., Built a React component)',
                  hintStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ]),

            const SizedBox(height: 20),

            _buildSectionCard('🎮 Entertainment', [
              TextField(
                controller: _gamesPlayedController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'What games did you play today?',
                  hintStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ]),

            const SizedBox(height: 20),

            _buildSectionCard('📝 General Notes', [
              TextField(
                controller: _generalNotesController,
                maxLines: 4,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Anything else about your day...',
                  hintStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ]),

            const SizedBox(height: 20),

            _buildSectionCard('😊 How are you feeling?', [
              Wrap(
                spacing: 8,
                children:
                    [
                      'great',
                      'good',
                      'neutral',
                      'tired',
                      'stressed',
                      'anxious',
                    ].map((mood) {
                      final isSelected = _selectedMood == mood;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedMood = mood),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF00D9FF)
                                : Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            mood.toUpperCase(),
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ]),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitJournal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00D9FF),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Save Journal Entry',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(String title, List<Widget> children) {
    return Container(
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
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}
