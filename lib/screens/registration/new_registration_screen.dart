import 'package:flutter/material.dart';
import '../dashboard/production_dashboard_screen.dart';
import '../../services/local_storage_service.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _goalsController = TextEditingController();

  // Selected skills
  final List<String> _selectedSkills = [];

  // Assessment test answers
  final List<int> _stressAnswers = List.filled(10, 0);
  int _currentQuestion = 0;
  bool _showAssessment = false;
  bool _isLoading = false;
  bool _obscurePassword = true;

  final List<String> _availableSkills = [
    'Artificial Intelligence & Machine Learning',
    'AI Engineering',
    'Web Development',
    'Mobile App Development',
    'Data Science',
    'Cloud Computing',
    'DevOps',
    'Cybersecurity',
    'Blockchain',
    'Game Development',
  ];

  final List<String> _stressQuestions = [
    "How often do you feel overwhelmed by your workload?",
    "How well do you sleep at night?",
    "How often do you take breaks during study sessions?",
    "How stressed do you feel about deadlines?",
    "How often do you exercise or engage in physical activity?",
    "How would you rate your work-life balance?",
    "How often do you feel anxious about your academic performance?",
    "How well do you manage your time effectively?",
    "How often do you feel burned out or exhausted?",
    "How satisfied are you with your current study routine?",
  ];

  final List<String> _answerOptions = [
    "Never",
    "Rarely",
    "Sometimes",
    "Often",
    "Always",
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _goalsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_showAssessment) {
      return _buildAssessmentScreen();
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        title: const Text('Create Account'),
        backgroundColor: const Color(0xFF1A1A2E),
        foregroundColor: const Color(0xFF00D9FF),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
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
              // Logo and Welcome
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF00D9FF), Color(0xFFB829F7)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Icon(
                        Icons.psychology,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Join DevBalance AI',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00D9FF),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Start your personalized wellness journey',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Combined Information Section
              _buildSectionCard('Your Information', [
                _buildTextField(
                  'Full Name',
                  _nameController,
                  'Enter your full name',
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  'Email',
                  _emailController,
                  'Enter your email',
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  'Password',
                  _passwordController,
                  'Create a password',
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.white.withOpacity(0.6),
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  'Your Goals',
                  _goalsController,
                  'What do you want to achieve? (e.g., Master AI, Get 3.5 GPA, Build portfolio projects)',
                ),
              ]),

              const SizedBox(height: 24),

              // Skills Selection
              _buildSkillsSection(),

              const SizedBox(height: 32),

              // Assessment Button
              NeonButton(
                text: 'Take Stress Assessment',
                icon: Icons.psychology,
                onPressed: () {
                  if (_formKey.currentState!.validate() &&
                      _selectedSkills.isNotEmpty) {
                    setState(() {
                      _showAssessment = true;
                      _currentQuestion = 0;
                    });
                  } else if (_selectedSkills.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please select at least one skill'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard(String title, List<Widget> children) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF00D9FF),
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    String hint, {
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withOpacity(0.9),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter $label';
            }
            if (label == 'Email' && !value.contains('@')) {
              return 'Please enter a valid email';
            }
            if (label == 'Password' && value.length < 6) {
              return 'Password must be at least 6 characters';
            }
            return null;
          },
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            suffixIcon: suffixIcon,
            hintText: hint,
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
            filled: true,
            fillColor: Colors.white.withOpacity(0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF00D9FF)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSkillsSection() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Your Skills',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF00D9FF),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose the skills you want to develop (select at least one)',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _availableSkills.map((skill) {
              final isSelected = _selectedSkills.contains(skill);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedSkills.remove(skill);
                    } else {
                      _selectedSkills.add(skill);
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: isSelected
                        ? const Color(0xFF00D9FF).withOpacity(0.2)
                        : Colors.white.withOpacity(0.1),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF00D9FF)
                          : Colors.white.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    skill,
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected
                          ? const Color(0xFF00D9FF)
                          : Colors.white.withOpacity(0.8),
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAssessmentScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        title: Text(
          'Stress Assessment (${_currentQuestion + 1}/${_stressQuestions.length})',
        ),
        backgroundColor: const Color(0xFF1A1A2E),
        foregroundColor: const Color(0xFF00D9FF),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            setState(() {
              _showAssessment = false;
            });
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress Bar
            LinearProgressIndicator(
              value: (_currentQuestion + 1) / _stressQuestions.length,
              backgroundColor: Colors.white.withOpacity(0.2),
              color: const Color(0xFF00D9FF),
              minHeight: 8,
            ),
            const SizedBox(height: 32),

            // Question
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Question',
                    style: TextStyle(fontSize: 16, color: Color(0xFF00D9FF)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _stressQuestions[_currentQuestion],
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Answer Options
            ...List.generate(5, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _stressAnswers[_currentQuestion] = index + 1;
                    });
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _stressAnswers[_currentQuestion] == index + 1
                            ? const Color(0xFF00D9FF)
                            : Colors.white.withOpacity(0.3),
                        width: _stressAnswers[_currentQuestion] == index + 1
                            ? 2
                            : 1,
                      ),
                      color: _stressAnswers[_currentQuestion] == index + 1
                          ? const Color(0xFF00D9FF).withOpacity(0.2)
                          : Colors.white.withOpacity(0.05),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _stressAnswers[_currentQuestion] == index + 1
                              ? Icons.radio_button_checked
                              : Icons.radio_button_unchecked,
                          color: _stressAnswers[_currentQuestion] == index + 1
                              ? const Color(0xFF00D9FF)
                              : Colors.white.withOpacity(0.6),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _answerOptions[index],
                            style: TextStyle(
                              fontSize: 16,
                              color:
                                  _stressAnswers[_currentQuestion] == index + 1
                                  ? const Color(0xFF00D9FF)
                                  : Colors.white.withOpacity(0.8),
                              fontWeight:
                                  _stressAnswers[_currentQuestion] == index + 1
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),

            const Spacer(),

            // Navigation Buttons
            Row(
              children: [
                if (_currentQuestion > 0)
                  Expanded(
                    child: NeonButton(
                      text: 'Previous',
                      isSecondary: true,
                      onPressed: () {
                        setState(() {
                          _currentQuestion--;
                        });
                      },
                    ),
                  ),
                if (_currentQuestion > 0) const SizedBox(width: 12),
                Expanded(
                  child: NeonButton(
                    text: _currentQuestion == _stressQuestions.length - 1
                        ? 'Complete'
                        : 'Next',
                    onPressed: _stressAnswers[_currentQuestion] > 0
                        ? () {
                            if (_currentQuestion ==
                                _stressQuestions.length - 1) {
                              _submitRegistration();
                            } else {
                              setState(() {
                                _currentQuestion++;
                              });
                            }
                          }
                        : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> _submitToBackend(List<int> answers) async {
    try {
      // Simulate HTTP request to backend
      await Future.delayed(const Duration(seconds: 1));

      // Calculate stress level based on answers
      final totalScore = answers.fold(0, (sum, score) => sum + score);
      final stressLevel = (totalScore / answers.length * 20).round();

      return {
        'stress_level': stressLevel,
        'risk_level': stressLevel > 70
            ? 'high'
            : stressLevel > 40
            ? 'medium'
            : 'low',
        'recommendations': [
          'Take regular breaks',
          'Practice deep breathing',
          'Get enough sleep',
        ],
      };
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<void> _submitRegistration() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Create user account with local storage
      final localStorageService = LocalStorageService();
      await localStorageService.initialize();

      final userCredential = await localStorageService.signUpWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
      );

      // Submit assessment to backend
      final stressResult = await _submitToBackend(_stressAnswers);

      // Create user profile in local storage
      await localStorageService.updateUserProfile(
        userId: userCredential['id'],
        name: _nameController.text.trim(),
        skills: _selectedSkills,
        goals: _goalsController.text.trim(),
        stressAssessment: stressResult,
      );

      // Navigate to dashboard
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const ProductionDashboardScreen(),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

// Reusable components
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final double borderRadius;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

class NeonButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isSecondary;
  final IconData? icon;

  const NeonButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isSecondary = false,
    this.icon,
  });

  @override
  State<NeonButton> createState() => _NeonButtonState();
}

class _NeonButtonState extends State<NeonButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = widget.isSecondary
        ? const Color(0xFFB829F7)
        : const Color(0xFF00D9FF);

    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return GestureDetector(
          onTap: widget.onPressed,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: widget.isSecondary
                  ? null
                  : const LinearGradient(
                      colors: [Color(0xFFB829F7), Color(0xFF00D9FF)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
              color: widget.isSecondary ? Colors.transparent : null,
              border: widget.isSecondary
                  ? Border.all(color: primaryColor.withOpacity(0.5), width: 2)
                  : null,
              boxShadow: widget.isSecondary || widget.onPressed == null
                  ? []
                  : [
                      BoxShadow(
                        color: const Color(
                          0xFFB829F7,
                        ).withOpacity(0.3 * _glowAnimation.value),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                      BoxShadow(
                        color: const Color(
                          0xFF00D9FF,
                        ).withOpacity(0.3 * _glowAnimation.value),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.icon != null) ...[
                  Icon(
                    widget.icon,
                    color: widget.isSecondary ? primaryColor : Colors.white,
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  widget.text,
                  style: TextStyle(
                    color: widget.onPressed == null
                        ? Colors.white.withOpacity(0.5)
                        : widget.isSecondary
                        ? primaryColor
                        : Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
