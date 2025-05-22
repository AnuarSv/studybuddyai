import 'package:flutter/material.dart';
import 'package:university_quiz_app/models/quiz_question.dart';

class ResultsScreen extends StatelessWidget {
  final int score;
  final int totalQuestions;
  final String sessionName;
  final VoidCallback onRetry;
  final VoidCallback onFinish; // To go back to home or training detail

  const ResultsScreen({
    super.key,
    required this.score,
    required this.totalQuestions,
    required this.sessionName,
    required this.onRetry,
    required this.onFinish,
    required List<QuizQuestion> questions,
    required Map<int, int?> selectedAnswers,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final double percentage =
        totalQuestions > 0 ? (score / totalQuestions) * 100 : 0;
    String remark;
    Color remarkColor;

    if (percentage >= 80) {
      remark = 'Excellent!';
      remarkColor = Colors.green.shade700;
    } else if (percentage >= 60) {
      remark = 'Good Job!';
      remarkColor = Colors.blue.shade700;
    } else if (percentage >= 40) {
      remark = 'Keep Practicing!';
      remarkColor = Colors.orange.shade700;
    } else {
      remark = 'Needs Improvement.';
      remarkColor = Colors.red.shade700;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz Results: $sessionName'),
        automaticallyImplyLeading: false, // No back button
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                remark,
                textAlign: TextAlign.center,
                style: theme.textTheme.displaySmall?.copyWith(
                  color: remarkColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Text(
                        'Your Score:',
                        style: theme.textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '$score / $totalQuestions',
                        style: theme.textTheme.displayMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${percentage.toStringAsFixed(1)}%',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: theme.colorScheme.secondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                icon: const Icon(Icons.replay_outlined),
                label: const Text('Retry Quiz'),
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  textStyle: theme.textTheme.labelLarge,
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                icon: const Icon(Icons.home_outlined),
                label: const Text('Finish & Go Home'),
                onPressed: onFinish,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  textStyle: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                  side: BorderSide(color: theme.colorScheme.primary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
