import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:university_quiz_app/providers/quiz_provider.dart';
import 'package:university_quiz_app/models/quiz_question.dart';
import 'package:university_quiz_app/screens/results_screen.dart'; // You'll create this

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentQuestionIndex = 0;
  Map<int, int?> _selectedAnswers = {}; // questionIndex -> selectedOptionIndex
  bool _showFeedback = false;

  @override
  Widget build(BuildContext context) {
    final quizProvider = Provider.of<QuizProvider>(context, listen: false);
    final List<QuizQuestion> questions = quizProvider.questions;

    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quiz')),
        body: const Center(child: Text('No questions available.')),
      );
    }

    final currentQuestion = questions[_currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Quiz: Question ${_currentQuestionIndex + 1}/${questions.length}',
        ),
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () {
            quizProvider.reset(); // Reset provider state
            Navigator.of(
              context,
            ).popUntil((route) => route.isFirst); // Go back to home
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              currentQuestion.questionText,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ...List.generate(currentQuestion.options.length, (index) {
              bool isSelected =
                  _selectedAnswers[_currentQuestionIndex] == index;
              Color? tileColor;
              Icon? trailingIcon;

              if (_showFeedback) {
                if (index == currentQuestion.correctAnswerIndex) {
                  tileColor = Colors.green.withOpacity(0.3);
                  trailingIcon = const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                  );
                } else if (isSelected &&
                    index != currentQuestion.correctAnswerIndex) {
                  tileColor = Colors.red.withOpacity(0.3);
                  trailingIcon = const Icon(Icons.cancel, color: Colors.red);
                }
              }

              return Card(
                color: tileColor,
                child: RadioListTile<int>(
                  title: Text(currentQuestion.options[index]),
                  value: index,
                  groupValue: _selectedAnswers[_currentQuestionIndex],
                  onChanged:
                      _showFeedback
                          ? null
                          : (int? value) {
                            // Disable if feedback is shown
                            setState(() {
                              _selectedAnswers[_currentQuestionIndex] = value;
                            });
                          },
                  secondary: trailingIcon,
                ),
              );
            }),
            const Spacer(),
            if (_showFeedback)
              ElevatedButton(
                child: Text(
                  _currentQuestionIndex < questions.length - 1
                      ? 'Next Question'
                      : 'Show Results',
                ),
                onPressed: () {
                  setState(() {
                    _showFeedback = false;
                    if (_currentQuestionIndex < questions.length - 1) {
                      _currentQuestionIndex++;
                    } else {
                      // Navigate to results screen
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => ResultsScreen(
                                questions: questions,
                                selectedAnswers: _selectedAnswers,
                                score: 0,
                                sessionName: '',
                                totalQuestions: 0,
                                onRetry: () {},
                                onFinish: () {},
                              ),
                        ),
                      );
                    }
                  });
                },
              )
            else
              ElevatedButton(
                onPressed:
                    _selectedAnswers[_currentQuestionIndex] == null
                        ? null
                        : () {
                          setState(() {
                            _showFeedback = true;
                          });
                        },
                child: const Text('Submit Answer'),
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
