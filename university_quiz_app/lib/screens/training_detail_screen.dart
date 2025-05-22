import 'package:flutter/material.dart';
import 'package:university_quiz_app/models/training_session.dart';
import 'package:university_quiz_app/screens/flashcard_view_screen.dart';
import 'package:university_quiz_app/screens/mcq_quiz_screen.dart';
import 'package:university_quiz_app/screens/true_false_quiz_screen.dart';

class TrainingDetailScreen extends StatelessWidget {
  final TrainingSession session;

  const TrainingDetailScreen({super.key, required this.session});

  Widget _buildOptionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback? onTap,
    required bool isEnabled,
  }) {
    final theme = Theme.of(context);
    return Card(
      elevation: isEnabled ? 3 : 1,
      color: isEnabled ? theme.cardColor : theme.cardColor.withOpacity(0.5),
      child: InkWell(
        onTap: isEnabled ? onTap : null,
        borderRadius: BorderRadius.circular(12), // From AppTheme
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(
                icon,
                size: 40,
                color: isEnabled ? theme.colorScheme.primary : Colors.grey[400],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color:
                            isEnabled
                                ? theme.textTheme.titleLarge?.color
                                : Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color:
                            isEnabled
                                ? theme.textTheme.bodyMedium?.color
                                : Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              if (isEnabled)
                Icon(
                  Icons.arrow_forward_ios,
                  size: 18,
                  color: Colors.grey[400],
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    bool hasMcqs = session.mcqs.isNotEmpty;
    bool hasTf = session.trueFalseQuestions.isNotEmpty;
    bool hasFlashcards = session.flashcards.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(session.name, overflow: TextOverflow.ellipsis),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Original PDF: ${session.pdfFileName}',
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 24),
            _buildOptionCard(
              context,
              title: 'Multiple Choice Quiz',
              subtitle:
                  hasMcqs
                      ? '${session.mcqs.length} questions'
                      : 'No MCQs generated',
              icon: Icons.list_alt_rounded,
              isEnabled: hasMcqs,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => McqQuizScreen(
                          questions: session.mcqs,
                          sessionName: session.name,
                        ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildOptionCard(
              context,
              title: 'True/False Quiz',
              subtitle:
                  hasTf
                      ? '${session.trueFalseQuestions.length} questions'
                      : 'No True/False generated',
              icon: Icons.check_circle_outline_rounded,
              isEnabled: hasTf,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => TrueFalseQuizScreen(
                          questions: session.trueFalseQuestions,
                          sessionName: session.name,
                        ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildOptionCard(
              context,
              title: 'View Flashcards',
              subtitle:
                  hasFlashcards
                      ? '${session.flashcards.length} cards'
                      : 'No flashcards generated',
              icon: Icons.style_outlined,
              isEnabled: hasFlashcards,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => FlashcardViewScreen(
                          flashcards: session.flashcards,
                          sessionName: session.name,
                        ),
                  ),
                );
              },
            ),
            if (!hasMcqs && !hasTf && !hasFlashcards)
              Padding(
                padding: const EdgeInsets.only(top: 30.0),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.sentiment_dissatisfied_outlined,
                        size: 60,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "No content available for this session.",
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        "It seems no questions or flashcards were generated or found.",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
