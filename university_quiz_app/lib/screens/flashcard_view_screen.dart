import 'dart:math';
import 'package:flutter/material.dart';
import 'package:university_quiz_app/models/flashcard.dart';

class FlashcardViewScreen extends StatefulWidget {
  final List<Flashcard> flashcards;
  final String sessionName;

  const FlashcardViewScreen({
    super.key,
    required this.flashcards,
    required this.sessionName,
  });

  @override
  State<FlashcardViewScreen> createState() => _FlashcardViewScreenState();
}

class _FlashcardViewScreenState extends State<FlashcardViewScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  bool _isFlipped = false;
  late AnimationController _controller;
  late Animation<double> _animation;
  List<Flashcard> _currentFlashcards = [];

  @override
  void initState() {
    super.initState();
    _currentFlashcards = List.from(widget.flashcards); // Make a mutable copy

    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  void _flipCard() {
    if (_controller.isCompleted || _controller.isDismissed) {
      setState(() {
        _isFlipped = !_isFlipped;
      });
      if (_isFlipped) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  void _nextCard() {
    if (_currentIndex < _currentFlashcards.length - 1) {
      setState(() {
        _currentIndex++;
        if (_isFlipped) _flipCard(); // Reset to front face
      });
    }
  }

  void _previousCard() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        if (_isFlipped) _flipCard(); // Reset to front face
      });
    }
  }

  void _shuffleCards() {
    setState(() {
      _currentFlashcards.shuffle();
      _currentIndex = 0;
      if (_isFlipped) _flipCard(); // Reset to front face
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Flashcards shuffled!"),
          duration: Duration(seconds: 1),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (_currentFlashcards.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('Flashcards: ${widget.sessionName}')),
        body: const Center(child: Text('No flashcards available.')),
      );
    }

    final currentFlashcard = _currentFlashcards[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('Flashcards: ${widget.sessionName}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shuffle_rounded),
            tooltip: 'Shuffle Cards',
            onPressed: _shuffleCards,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Card ${_currentIndex + 1} of ${_currentFlashcards.length}',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GestureDetector(
                onTap: _flipCard,
                child: AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    final angle = _animation.value * pi;
                    final transform =
                        Matrix4.identity()
                          ..setEntry(3, 2, 0.001) // Perspective
                          ..rotateY(angle);
                    return Transform(
                      transform: transform,
                      alignment: Alignment.center,
                      child:
                          _animation.value <= 0.5
                              ? _buildCardFace(
                                context,
                                currentFlashcard.term,
                                true,
                              )
                              : Transform(
                                // Second half of flip
                                transform:
                                    Matrix4.identity()..rotateY(
                                      pi,
                                    ), // Flip back to show content correctly
                                alignment: Alignment.center,
                                child: _buildCardFace(
                                  context,
                                  currentFlashcard.definition,
                                  false,
                                ),
                              ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.arrow_back_ios_new),
                  label: const Text('Prev'),
                  onPressed: _currentIndex > 0 ? _previousCard : null,
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.flip_rounded),
                  label: const Text('Flip'),
                  onPressed: _flipCard,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.secondary,
                  ),
                ),
                ElevatedButton.icon(
                  label: const Text('Next'),
                  icon: const Icon(Icons.arrow_forward_ios_rounded),
                  onPressed:
                      _currentIndex < _currentFlashcards.length - 1
                          ? _nextCard
                          : null,
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCardFace(BuildContext context, String text, bool isTerm) {
    final theme = Theme.of(context);
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        padding: const EdgeInsets.all(24.0),
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                isTerm ? "Term/Concept:" : "Definition/Explanation:",
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.secondary,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                text,
                textAlign: TextAlign.center,
                style:
                    isTerm
                        ? theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        )
                        : theme.textTheme.titleLarge?.copyWith(height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
