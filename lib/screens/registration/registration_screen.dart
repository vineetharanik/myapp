import 'package:flutter/material.dart';
import '../dashboard/main_dashboard_screen.dart';
import '../../services/api_service.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _goalsController = TextEditingController();
  final _skillsController = TextEditingController();

  // Assessment test answers
  final List<int> _stressAnswers = List.filled(10, 0);
  int _currentQuestion = 0;
  bool _showAssessment = false;
  bool _isLoading = false;

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
  Widget build(BuildContext context) {
    if (_showAssessment) {
      return _buildAssessmentScreen();
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        title: const Text('Student Registration'),
        backgroundColor: const Color(0xFF1A1A2E),
        foregroundColor: const Color(0xFF00D9FF),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Welcome to DevBalance AI',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00D9FF),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Let\'s set up your personalized wellness and productivity journey',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 32),

              // Personal Information
              _buildSectionCard('Personal Information', [
                _buildTextField(
                  'Full Name',
                  _nameController,
                  'Enter your full name',
                ),
                _buildTextField(
                  'Email',
                  _emailController,
                  'Enter your email',
                  keyboardType: TextInputType.emailAddress,
                ),
              ]),

              const SizedBox(height: 24),

              // Academic Goals
              _buildSectionCard('Academic Goals', [
                _buildTextField(
                  'Your Goals',
                  _goalsController,
                  'What do you want to achieve? (e.g., Master Python, Get 3.5 GPA, Complete project)',
                  maxLines: 3,
                ),
                _buildTextField(
                  'Skills to Learn',
                  _skillsController,
                  'What skills do you need to develop? (e.g., Data structures, Machine learning, Web development)',
                  maxLines: 3,
                ),
              ]),

              const SizedBox(height: 32),

              // Assessment Button
              NeonButton(
                text: 'Take Stress Assessment',
                icon: Icons.psychology,
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    setState(() {
                      _showAssessment = true;
                      _currentQuestion = 0;
                    });
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
              fontSize: 20,
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
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter $label';
              }
              return null;
            },
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
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
            ),
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
                      fontSize: 20,
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
                              _submitAssessment();
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

  Future<void> _submitAssessment() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Submit assessment to backend
      final result = await ApiService.assessStress(_stressAnswers);

      // Store user data (in a real app, you'd send this to backend)
      // userData is stored but not used for now

      // Navigate to dashboard
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainDashboardScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
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
