import 'dart:convert';

class TrueFalseQuestion {
  final String questionText;
  final bool correctAnswer;

  TrueFalseQuestion({required this.questionText, required this.correctAnswer});

  factory TrueFalseQuestion.fromJson(Map<String, dynamic> json) {
    return TrueFalseQuestion(
      questionText: json['questionText'] as String,
      correctAnswer: json['correctAnswer'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {'questionText': questionText, 'correctAnswer': correctAnswer};
  }
}

List<TrueFalseQuestion> parseTrueFalseQuestions(String jsonString) {
  try {
    final regex = RegExp(r"```json\s*([\s\S]*?)\s*```");
    final match = regex.firstMatch(jsonString);
    if (match != null && match.groupCount > 0) {
      jsonString = match.group(1)!;
    }
    jsonString = jsonString.trim();

    final List<dynamic> parsedJson = jsonDecode(jsonString) as List<dynamic>;
    return parsedJson
        .map(
          (jsonItem) =>
              TrueFalseQuestion.fromJson(jsonItem as Map<String, dynamic>),
        )
        .toList();
  } catch (e) {
    print("Error parsing True/False JSON: $e");
    if (!jsonString.trim().startsWith('[')) {
      try {
        final fixedJsonString = "[$jsonString]";
        final List<dynamic> parsedJson =
            jsonDecode(fixedJsonString) as List<dynamic>;
        return parsedJson
            .map(
              (jsonItem) =>
                  TrueFalseQuestion.fromJson(jsonItem as Map<String, dynamic>),
            )
            .toList();
      } catch (e2) {
        print("Error parsing T/F JSON even after attempting fix: $e2");
      }
    }
    return [];
  }
}
