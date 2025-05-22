import 'dart:convert';

class QuizQuestion {
  final String questionText;
  final List<String> options;
  final int correctAnswerIndex;

  QuizQuestion({
    required this.questionText,
    required this.options,
    required this.correctAnswerIndex,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      questionText: json['questionText'] as String,
      options: List<String>.from(json['options'] as List),
      correctAnswerIndex: json['correctAnswerIndex'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'questionText': questionText,
      'options': options,
      'correctAnswerIndex': correctAnswerIndex,
    };
  }
}

// Helper to parse a list of questions from JSON string
// This can stay here or be moved into GeminiService if it's only used there.
List<QuizQuestion> parseQuizQuestions(String jsonString) {
  try {
    // Remove potential markdown ```json ... ```
    final regex = RegExp(r"```json\s*([\s\S]*?)\s*```");
    final match = regex.firstMatch(jsonString);
    if (match != null && match.groupCount > 0) {
      jsonString = match.group(1)!;
    }
    jsonString = jsonString.trim();

    final List<dynamic> parsedJson = jsonDecode(jsonString) as List<dynamic>;
    return parsedJson
        .map(
          (jsonItem) => QuizQuestion.fromJson(jsonItem as Map<String, dynamic>),
        )
        .toList();
  } catch (e) {
    print("Error parsing quiz JSON: $e");
    // Attempt to fix common Gemini formatting issues (e.g., not a valid JSON array at the root)
    if (!jsonString.trim().startsWith('[')) {
      try {
        final fixedJsonString = "[$jsonString]";
        final List<dynamic> parsedJson =
            jsonDecode(fixedJsonString) as List<dynamic>;
        return parsedJson
            .map(
              (jsonItem) =>
                  QuizQuestion.fromJson(jsonItem as Map<String, dynamic>),
            )
            .toList();
      } catch (e2) {
        print("Error parsing quiz JSON even after attempting fix: $e2");
      }
    }
    return []; // Return empty list on error
  }
}
