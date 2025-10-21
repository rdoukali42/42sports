import 'package:flutter/material.dart';
import '../utils/theme.dart';
import '../services/user_service.dart';
import '../utils/constants.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final _userService = UserService();
  int? _selectedAnswer1;
  int? _selectedAnswer2;
  bool _isSubmitting = false;
  bool _showResults = false;
  bool _passed = false;
  int _remainingSeconds = 0;

  @override
  void initState() {
    super.initState();
    _checkCooldown();
  }

  Future<void> _checkCooldown() async {
    final user = await _userService.getUser();
    if (user != null) {
      final canRetake = await _userService.canRetakeQuiz(user.id);
      if (!canRetake) {
        final remaining = await _userService.getRemainingCooldownSeconds(user.id);
        setState(() {
          _remainingSeconds = remaining;
        });
        _startCooldownTimer();
      }
    }
  }

  void _startCooldownTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
        _startCooldownTimer();
      }
    });
  }

  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'What is the version of the actual Hackathon?',
      'options': ['v1', 'v2', 'v3', 'v5'],
      'correctAnswer': 1, // v2
    },
    {
      'question': 'What is the name of our school?',
      'options': ['TUM', 'HHN', '42 Heilbronn', 'Arkadia'],
      'correctAnswer': 2, // 42 Heilbronn
    },
  ];

  Future<void> _submitQuiz() async {
    if (_selectedAnswer1 == null || _selectedAnswer2 == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please answer all questions'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    // Check answers
    final answer1Correct = _selectedAnswer1 == _questions[0]['correctAnswer'];
    final answer2Correct = _selectedAnswer2 == _questions[1]['correctAnswer'];
    final allCorrect = answer1Correct && answer2Correct;

    setState(() {
      _showResults = true;
      _passed = allCorrect;
      _isSubmitting = false;
    });

    if (allCorrect) {
      // Award tokens and mark quiz as completed
      final user = await _userService.getUser();
      if (user != null) {
        print('Quiz passed! Current tokens: ${user.tokens}');
        final newTokenCount = user.tokens + AppConstants.quizRewardTokens;
        print('New token count: $newTokenCount');
        final updatedUser = user.copyWith(tokens: newTokenCount);
        await _userService.saveUser(updatedUser);
        await _userService.markQuizCompleted(user.id);
        
        // Verify the save worked
        final savedUser = await _userService.getUser();
        print('Verified saved tokens: ${savedUser?.tokens}');
      }

      // Show success and close after delay
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.pop(context, true);
        }
      });
    } else {
      // Set cooldown for failed attempt
      final user = await _userService.getUser();
      if (user != null) {
        await _userService.setQuizFailedTime(user.id);
        setState(() {
          _remainingSeconds = 30;
        });
        _startCooldownTimer();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Token Quiz'),
        backgroundColor: AppTheme.pureWhite,
        foregroundColor: AppTheme.deepBlack,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.neonGreen, AppTheme.neonGreen.withOpacity(0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.neonGreen.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.deepBlack.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.quiz,
                      size: 48,
                      color: AppTheme.deepBlack,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Welcome Quiz',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.deepBlack,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Answer correctly to earn 3 tokens!',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.deepBlack,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.deepBlack.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'One-time opportunity',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.deepBlack,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Question 1
            _buildQuestion(
              questionNumber: 1,
              question: _questions[0]['question'],
              options: List<String>.from(_questions[0]['options']),
              selectedAnswer: _selectedAnswer1,
              correctAnswer: _showResults ? _questions[0]['correctAnswer'] : null,
              onSelect: (index) {
                if (!_showResults) {
                  setState(() => _selectedAnswer1 = index);
                }
              },
            ),
            const SizedBox(height: 24),

            // Question 2
            _buildQuestion(
              questionNumber: 2,
              question: _questions[1]['question'],
              options: List<String>.from(_questions[1]['options']),
              selectedAnswer: _selectedAnswer2,
              correctAnswer: _showResults ? _questions[1]['correctAnswer'] : null,
              onSelect: (index) {
                if (!_showResults) {
                  setState(() => _selectedAnswer2 = index);
                }
              },
            ),
            const SizedBox(height: 32),

            // Results or Submit Button
            if (_showResults)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _passed ? Colors.transparent : Colors.red.shade100,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _passed ? AppTheme.neonGreen : Colors.red,
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      _passed ? Icons.check_circle : Icons.cancel,
                      size: 64,
                      color: _passed ? AppTheme.neonGreen : Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _passed ? 'Congratulations! 🎉' : 'Sorry, incorrect answers',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: _passed ? AppTheme.neonGreen : Colors.red.shade900,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _passed
                          ? 'You earned 3 tokens!'
                          : 'Wait 30 seconds to retry the quiz',
                      style: TextStyle(
                        fontSize: 14,
                        color: _passed ? AppTheme.deepBlack : Colors.red.shade900,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (!_passed && _remainingSeconds > 0) ...[
                      const SizedBox(height: 12),
                      Text(
                        'Retry in $_remainingSeconds seconds',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade900,
                        ),
                      ),
                    ],
                  ],
                ),
              )
            else if (_remainingSeconds > 0)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.orange,
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.timer,
                      size: 48,
                      color: Colors.orange.shade900,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Please wait $_remainingSeconds seconds',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade900,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'You can retry the quiz after the cooldown',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.orange.shade900,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            else
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitQuiz,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.neonGreen,
                  foregroundColor: AppTheme.deepBlack,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppTheme.deepBlack,
                        ),
                      )
                    : const Text(
                        'Submit Quiz',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestion({
    required int questionNumber,
    required String question,
    required List<String> options,
    required int? selectedAnswer,
    required int? correctAnswer,
    required Function(int) onSelect,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.pureWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.lightGray, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppTheme.deepBlack.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.neonGreen.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Q$questionNumber',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.deepBlack,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  question,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.deepBlack,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...List.generate(options.length, (index) {
            final isSelected = selectedAnswer == index;
            final isCorrect = correctAnswer == index;
            final showCorrect = correctAnswer != null && isCorrect;
            final showIncorrect = correctAnswer != null && isSelected && !isCorrect;

            Color backgroundColor = AppTheme.pureWhite;
            Color borderColor = AppTheme.lightGray;
            Color textColor = AppTheme.deepBlack;

            if (showCorrect) {
              backgroundColor = AppTheme.neonGreen.withOpacity(0.2);
              borderColor = AppTheme.neonGreen;
            } else if (showIncorrect) {
              backgroundColor = Colors.red.shade50;
              borderColor = Colors.red;
            } else if (isSelected) {
              backgroundColor = AppTheme.neonGreen.withOpacity(0.1);
              borderColor = AppTheme.neonGreen;
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () => onSelect(index),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor, width: 2),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? borderColor : AppTheme.mediumGray,
                            width: 2,
                          ),
                          color: isSelected ? borderColor : Colors.transparent,
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check,
                                size: 16,
                                color: AppTheme.deepBlack,
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          options[index],
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: textColor,
                          ),
                        ),
                      ),
                      if (showCorrect)
                        const Icon(Icons.check_circle, color: AppTheme.neonGreen, size: 20)
                      else if (showIncorrect)
                        const Icon(Icons.cancel, color: Colors.red, size: 20),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
