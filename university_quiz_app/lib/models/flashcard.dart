import 'dart:convert';

class Flashcard {
  final String term;
  final String definition;

  Flashcard({required this.term, required this.definition});

  factory Flashcard.fromJson(Map<String, dynamic> json) {
    return Flashcard(
      term: json['term'] as String,
      definition: json['definition'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'term': term, 'definition': definition};
  }
}

List<Flashcard> parseFlashcards(String jsonString) {
  try {
    final regex = RegExp(r"```json\s*([\s\S]*?)\s*```");
    final match = regex.firstMatch(jsonString);
    if (match != null && match.groupCount > 0) {
      jsonString = match.group(1)!;
    }
    jsonString = jsonString.trim();

    final List<dynamic> parsedJson = jsonDecode(jsonString) as List<dynamic>;
    return parsedJson
        .map((jsonItem) => Flashcard.fromJson(jsonItem as Map<String, dynamic>))
        .toList();
  } catch (e) {
    print("Error parsing Flashcard JSON: $e");
    if (!jsonString.trim().startsWith('[')) {
      try {
        final fixedJsonString = "[$jsonString]";
        final List<dynamic> parsedJson =
            jsonDecode(fixedJsonString) as List<dynamic>;
        return parsedJson
            .map(
              (jsonItem) =>
                  Flashcard.fromJson(jsonItem as Map<String, dynamic>),
            )
            .toList();
      } catch (e2) {
        print("Error parsing Flashcard JSON even after attempting fix: $e2");
      }
    }
    return [];
  }
}
