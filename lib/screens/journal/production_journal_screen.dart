import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/journal_entry.dart';
import '../../services/local_storage_service.dart';

class ProductionJournalScreen extends StatefulWidget {
  const ProductionJournalScreen({super.key});

  @override
  State<ProductionJournalScreen> createState() =>
      _ProductionJournalScreenState();
}

class _ProductionJournalScreenState extends State<ProductionJournalScreen> {
  final _formKey = GlobalKey<FormState>();

  // Study hours controllers
  final _dsaHoursController = TextEditingController();
  final _webHoursController = TextEditingController();
  final _aiHoursController = TextEditingController();
  final _otherHoursController = TextEditingController();

  // Other controllers
  final _tasksController = TextEditingController();
  final _sleepHoursController = TextEditingController();
  final _gamesHoursController = TextEditingController();
  final _scrollingHoursController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedMood = 'neutral';
  bool _isLoading = false;
  late LocalStorageService _localStorageService;

  @override
  void initState() {
    super.initState();
    _localStorageService = LocalStorageService();
  }

  @override
  void dispose() {
    _dsaHoursController.dispose();
    _webHoursController.dispose();
    _aiHoursController.dispose();
    _otherHoursController.dispose();
    _tasksController.dispose();
    _sleepHoursController.dispose();
    _gamesHoursController.dispose();
    _scrollingHoursController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submitJournal() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _localStorageService.initialize();

      if (_localStorageService.currentUser == null) {
        throw Exception('User not logged in');
      }

      final userId = _localStorageService.currentUser!['id'];

      // Create structured journal entry
      final journalEntry = JournalEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        date: DateTime.now(),
        studyHours: {
          'DSA': double.tryParse(_dsaHoursController.text) ?? 0.0,
          'Web Dev': double.tryParse(_webHoursController.text) ?? 0.0,
          'AI/ML': double.tryParse(_aiHoursController.text) ?? 0.0,
          'Other': double.tryParse(_otherHoursController.text) ?? 0.0,
        },
        tasksCompleted: _tasksController.text
            .split(',')
            .map((task) => task.trim())
            .where((task) => task.isNotEmpty)
            .toList(),
        mood: _selectedMood,
        sleepHours: double.tryParse(_sleepHoursController.text) ?? 0.0,
        breakActivities: {
          'games': double.tryParse(_gamesHoursController.text) ?? 0.0,
          'scrolling': double.tryParse(_scrollingHoursController.text) ?? 0.0,
        },
        notes: _notesController.text.trim(),
        createdAt: DateTime.now(),
      );

      // Save to local storage
      await _localStorageService.saveJournalEntry(userId, {
        'entry': journalEntry.toJson(),
        'created_at': DateTime.now().toIso8601String(),
      });

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✅ Journal entry saved! Total study: ${journalEntry.totalStudyHours.toStringAsFixed(1)} hours',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );

        // Clear form and go back
        _clearForm();
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _clearForm() {
    _dsaHoursController.clear();
    _webHoursController.clear();
    _aiHoursController.clear();
    _otherHoursController.clear();
    _tasksController.clear();
    _sleepHoursController.clear();
    _gamesHoursController.clear();
    _scrollingHoursController.clear();
    _notesController.clear();
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
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStudyHoursSection(),
              const SizedBox(height: 24),
              _buildTasksSection(),
              const SizedBox(height: 24),
              _buildLifestyleSection(),
              const SizedBox(height: 24),
              _buildMoodSection(),
              const SizedBox(height: 24),
              _buildNotesSection(),
              const SizedBox(height: 32),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStudyHoursSection() {
    return _buildSectionCard(
      '📊 Study Hours (Today)',
      'Track your learning time by category',
      children: [
        Row(
          children: [
            Expanded(child: _buildHoursField('DSA', _dsaHoursController)),
            const SizedBox(width: 12),
            Expanded(child: _buildHoursField('Web Dev', _webHoursController)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildHoursField('AI/ML', _aiHoursController)),
            const SizedBox(width: 12),
            Expanded(child: _buildHoursField('Other', _otherHoursController)),
          ],
        ),
      ],
    );
  }

  Widget _buildHoursField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
          ],
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: '0.0',
            hintStyle: const TextStyle(color: Colors.white54),
            filled: true,
            fillColor: Colors.white.withOpacity(0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            suffixText: 'hrs',
            suffixStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Required';
            }
            final hours = double.tryParse(value);
            if (hours == null || hours < 0 || hours > 24) {
              return 'Enter 0-24';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildTasksSection() {
    return _buildSectionCard(
      '📝 Tasks Completed',
      'What did you accomplish today?',
      children: [
        TextFormField(
          controller: _tasksController,
          style: const TextStyle(color: Colors.white),
          maxLines: 3,
          decoration: InputDecoration(
            hintText:
                'e.g., Solved 3 DSA problems, Built React component, Reviewed ML concepts',
            hintStyle: const TextStyle(color: Colors.white54),
            filled: true,
            fillColor: Colors.white.withOpacity(0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please describe your tasks';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildLifestyleSection() {
    return _buildSectionCard(
      '🌙 Lifestyle & Breaks',
      'Sleep and relaxation time',
      children: [
        Row(
          children: [
            Expanded(
              child: _buildLabeledField(
                'Sleep Hours',
                _sleepHoursController,
                'hours',
                (value) {
                  final hours = double.tryParse(value ?? '');
                  if (hours == null || hours < 0 || hours > 24) {
                    return 'Enter 0-24';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildLabeledField(
                'Gaming',
                _gamesHoursController,
                'hours',
                null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildLabeledField(
          'Social Media/Scrolling',
          _scrollingHoursController,
          'hours',
          null,
        ),
      ],
    );
  }

  Widget _buildLabeledField(
    String label,
    TextEditingController controller,
    String suffix,
    String? Function(String?)? validator,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
          ],
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: '0.0',
            hintStyle: const TextStyle(color: Colors.white54),
            filled: true,
            fillColor: Colors.white.withOpacity(0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            suffixText: suffix,
            suffixStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildMoodSection() {
    return _buildSectionCard(
      '😊 How are you feeling?',
      'Your current mood and energy level',
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildMoodOption('happy', '😊 Happy'),
            _buildMoodOption('neutral', '😐 Neutral'),
            _buildMoodOption('stressed', '😰 Stressed'),
            _buildMoodOption('exhausted', '😴 Exhausted'),
          ],
        ),
      ],
    );
  }

  Widget _buildMoodOption(String value, String label) {
    final isSelected = _selectedMood == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedMood = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF00D9FF)
              : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF00D9FF)
                : Colors.white.withOpacity(0.2),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildNotesSection() {
    return _buildSectionCard(
      '📄 Additional Notes',
      'Anything else you want to remember',
      children: [
        TextFormField(
          controller: _notesController,
          style: const TextStyle(color: Colors.white),
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Thoughts, challenges, achievements, or ideas...',
            hintStyle: const TextStyle(color: Colors.white54),
            filled: true,
            fillColor: Colors.white.withOpacity(0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionCard(
    String title,
    String subtitle, {
    required List<Widget> children,
  }) {
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
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
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
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text('Saving...'),
                ],
              )
            : const Text(
                'Save Journal Entry',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
