import 'package:flutter/material.dart';
import 'package:university_quiz_app/models/quiz_question.dart';
import 'package:university_quiz_app/screens/results_screen.dart';

class McqQuizScreen extends StatefulWidget {
  final List<QuizQuestion> questions;
  final String sessionName;

  const McqQuizScreen({
    super.key,
    required this.questions,
    required this.sessionName,
  });

  @override
  State<McqQuizScreen> createState() => _McqQuizScreenState();
}

class _McqQuizScreenState extends State<McqQuizScreen> {
  int _currentQuestionIndex = 0;
  Map<int, int?> _selectedAnswers = {}; // questionIndex -> selectedOptionIndex
  bool _showFeedback = false;

  void _submitAnswer() {
    if (_selectedAnswers[_currentQuestionIndex] != null) {
      setState(() {
        _showFeedback = true;
      });
    }
  }

  void _nextQuestionOrResults() {
    setState(() {
      _showFeedback = false;
      if (_currentQuestionIndex < widget.questions.length - 1) {
        _currentQuestionIndex++;
      } else {
        // Calculate score
        int score = 0;
        _selectedAnswers.forEach((index, selectedOption) {
          if (selectedOption == widget.questions[index].correctAnswerIndex) {
            score++;
          }
        });
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (context) => ResultsScreen(
                  score: score,
                  totalQuestions: widget.questions.length,
                  sessionName: widget.sessionName,
                  onRetry: () {
                    Navigator.pop(context); // Pop results screen
                    setState(() {
                      // Reset quiz state
                      _currentQuestionIndex = 0;
                      _selectedAnswers = {};
                      _showFeedback = false;
                    });
                  },
                  onFinish: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  questions: [],
                  selectedAnswers: {},
                ),
          ),
        );
      }
    });
  }

  Future<bool> _onWillPop() async {
    return (await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Exit Quiz?'),
                content: const Text(
                  'Your progress will be lost. Are you sure?',
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Exit'),
                  ),
                ],
              ),
        )) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (widget.questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('MCQ Quiz: ${widget.sessionName}')),
        body: const Center(
          child: Text('No questions available for this quiz.'),
        ),
      );
    }

    final currentQuestion = widget.questions[_currentQuestionIndex];

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Question ${_currentQuestionIndex + 1}/${widget.questions.length}',
          ),
          // leading: IconButton( // Replaced by WillPopScope for confirmation
          //   icon: Icon(Icons.close),
          //   onPressed: () => Navigator.of(context).pop(),
          // ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    currentQuestion.questionText,
                    style: theme.textTheme.titleLarge?.copyWith(height: 1.4),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: currentQuestion.options.length,
                  itemBuilder: (context, index) {
                    bool isSelected =
                        _selectedAnswers[_currentQuestionIndex] == index;
                    Color? tileColor = theme.cardTheme.color;
                    Color borderColor = Colors.transparent;
                    Icon? trailingIcon;

                    if (_showFeedback) {
                      if (index == currentQuestion.correctAnswerIndex) {
                        tileColor = Colors.green.withOpacity(0.2);
                        borderColor = Colors.green;
                        trailingIcon = const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                        );
                      } else if (isSelected &&
                          index != currentQuestion.correctAnswerIndex) {
                        tileColor = Colors.red.withOpacity(0.2);
                        borderColor = Colors.red;
                        trailingIcon = const Icon(
                          Icons.cancel,
                          color: Colors.red,
                        );
                      }
                    } else if (isSelected) {
                      tileColor = theme.colorScheme.primary.withOpacity(0.1);
                      borderColor = theme.colorScheme.primary;
                    }

                    return Card(
                      elevation: 1,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: borderColor,
                          width: _showFeedback || isSelected ? 1.5 : 0.5,
                        ),
                      ),
                      color: tileColor,
                      child: RadioListTile<int>(
                        title: Text(
                          currentQuestion.options[index],
                          style: theme.textTheme.bodyLarge,
                        ),
                        value: index,
                        groupValue: _selectedAnswers[_currentQuestionIndex],
                        onChanged:
                            _showFeedback
                                ? null // Disable if feedback is shown
                                : (int? value) {
                                  setState(() {
                                    _selectedAnswers[_currentQuestionIndex] =
                                        value;
                                  });
                                },
                        secondary: trailingIcon,
                        activeColor: theme.colorScheme.primary,
                      ),
                    );
                  },
                ),
              ),
              // const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  onPressed:
                      _showFeedback
                          ? _nextQuestionOrResults
                          : (_selectedAnswers[_currentQuestionIndex] == null
                              ? null
                              : _submitAnswer),
                  child: Text(
                    _showFeedback
                        ? (_currentQuestionIndex < widget.questions.length - 1
                            ? 'Next Question'
                            : 'Show Results')
                        : 'Submit Answer',
                    style: theme.textTheme.labelLarge,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
