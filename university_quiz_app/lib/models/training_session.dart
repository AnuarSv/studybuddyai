// lib/models/training_session.dart
import 'package:university_quiz_app/models/flashcard.dart';
import 'package:university_quiz_app/models/quiz_question.dart';
import 'package:university_quiz_app/models/true_false_question.dart';
import 'package:uuid/uuid.dart';

class TrainingSession {
  String id;
  String name;
  String pdfFileName;
  DateTime createdAt;
  List<QuizQuestion> mcqs;
  List<TrueFalseQuestion> trueFalseQuestions;
  List<Flashcard> flashcards;

  TrainingSession({
    String? id,
    required this.name,
    required this.pdfFileName,
    DateTime? createdAt,
    this.mcqs = const [],
    this.trueFalseQuestions = const [],
    this.flashcards = const [],
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();

  factory TrainingSession.fromJson(Map<String, dynamic> json) {
    return TrainingSession(
      id: json['id'] as String,
      name: json['name'] as String,
      pdfFileName: json['pdfFileName'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      mcqs:
          (json['mcqs'] as List<dynamic>)
              .map(
                (item) => QuizQuestion.fromJson(item as Map<String, dynamic>),
              )
              .toList(),
      trueFalseQuestions:
          (json['trueFalseQuestions'] as List<dynamic>)
              .map(
                (item) =>
                    TrueFalseQuestion.fromJson(item as Map<String, dynamic>),
              )
              .toList(),
      flashcards:
          (json['flashcards'] as List<dynamic>)
              .map((item) => Flashcard.fromJson(item as Map<String, dynamic>))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'pdfFileName': pdfFileName,
      'createdAt': createdAt.toIso8601String(),
      'mcqs': mcqs.map((item) => item.toJson()).toList(),
      'trueFalseQuestions':
          trueFalseQuestions.map((item) => item.toJson()).toList(),
      'flashcards': flashcards.map((item) => item.toJson()).toList(),
    };
  }
}
