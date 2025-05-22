import 'package:flutter/material.dart';
import 'package:university_quiz_app/models/true_false_question.dart';
import 'package:university_quiz_app/screens/results_screen.dart';

class TrueFalseQuizScreen extends StatefulWidget {
  final List<TrueFalseQuestion> questions;
  final String sessionName;

  const TrueFalseQuizScreen({
    super.key,
    required this.questions,
    required this.sessionName,
  });

  @override
  State<TrueFalseQuizScreen> createState() => _TrueFalseQuizScreenState();
}

class _TrueFalseQuizScreenState extends State<TrueFalseQuizScreen> {
  int _currentQuestionIndex = 0;
  Map<int, bool?> _selectedAnswers =
      {}; // questionIndex -> selectedAnswer (true/false)
  bool _showFeedback = false;

  void _selectAnswer(bool answer) {
    if (!_showFeedback) {
      setState(() {
        _selectedAnswers[_currentQuestionIndex] = answer;
      });
    }
  }

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
        int score = 0;
        _selectedAnswers.forEach((index, selectedAnswer) {
          if (selectedAnswer == widget.questions[index].correctAnswer) {
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
                    Navigator.pop(context);
                    setState(() {
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

  Widget _buildAnswerButton(
    BuildContext context,
    bool answerValue,
    String text,
  ) {
    final theme = Theme.of(context);
    bool isSelected = _selectedAnswers[_currentQuestionIndex] == answerValue;
    Color buttonColor = theme.colorScheme.surface;
    Color textColor = theme.colorScheme.onSurface;
    Color borderColor = Colors.grey[300]!;

    if (_showFeedback) {
      final correctAnswer =
          widget.questions[_currentQuestionIndex].correctAnswer;
      if (answerValue == correctAnswer) {
        buttonColor = Colors.green.withOpacity(0.2);
        borderColor = Colors.green;
        textColor = Colors.green[800]!;
      } else if (isSelected && answerValue != correctAnswer) {
        buttonColor = Colors.red.withOpacity(0.2);
        borderColor = Colors.red;
        textColor = Colors.red[800]!;
      }
    } else if (isSelected) {
      buttonColor = theme.colorScheme.primary.withOpacity(0.1);
      borderColor = theme.colorScheme.primary;
      textColor = theme.colorScheme.primary;
    }

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: OutlinedButton(
          onPressed: _showFeedback ? null : () => _selectAnswer(answerValue),
          style: OutlinedButton.styleFrom(
            backgroundColor: buttonColor,
            side: BorderSide(color: borderColor, width: 1.5),
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (widget.questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('True/False Quiz: ${widget.sessionName}')),
        body: const Center(child: Text('No True/False questions available.')),
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
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 3,
                child: Center(
                  child: Card(
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text(
                        currentQuestion.questionText,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (_showFeedback)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    _selectedAnswers[_currentQuestionIndex] ==
                            currentQuestion.correctAnswer
                        ? 'Correct!'
                        : 'Incorrect. The answer was ${currentQuestion.correctAnswer ? "True" : "False"}.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color:
                          _selectedAnswers[_currentQuestionIndex] ==
                                  currentQuestion.correctAnswer
                              ? Colors.green[700]
                              : Colors.red[700],
                    ),
                  ),
                ),
              Expanded(
                flex: 2,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildAnswerButton(context, true, 'TRUE'),
                    _buildAnswerButton(context, false, 'FALSE'),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
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
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
