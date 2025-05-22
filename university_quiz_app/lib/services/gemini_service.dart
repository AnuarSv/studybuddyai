import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:university_quiz_app/models/flashcard.dart';
import 'package:university_quiz_app/models/quiz_question.dart';
import 'package:university_quiz_app/models/true_false_question.dart';

class GeminiService {
  final String apiKey;
  late final GenerativeModel _model;
  static const int _maxTextLength =
      150000; // Gemini 1.5 Flash context window is large, but be mindful of costs/tokens

  GeminiService(this.apiKey) {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash', // Use the latest flash model
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        // temperature: 0.7, // Adjust for creativity vs. factualness
      ),
    );
  }

  String _truncateText(String text) {
    if (text.length > _maxTextLength) {
      return text.substring(0, _maxTextLength);
    }
    return text;
  }

  Future<List<QuizQuestion>> generateMcqQuestions(
    String textContent, {
    int numQuestions = 5,
  }) async {
    if (numQuestions <= 0) return [];
    final truncatedText = _truncateText(textContent);

    final prompt = [
      Content.text("""
        Based on the following text content from a university lecture PDF, please generate $numQuestions multiple-choice questions.
        Each question MUST have exactly 4 options.
        Clearly indicate the correct answer index (0-indexed).
        Format the output STRICTLY as a JSON array of objects. Each object must have:
        - "questionText": "The text of the question" (string)
        - "options": ["Option A", "Option B", "Option C", "Option D"] (array of 4 strings)
        - "correctAnswerIndex": N (integer, 0, 1, 2, or 3)

        Example of one question object:
        {
          "questionText": "What is the capital of France?",
          "options": ["Berlin", "Madrid", "Paris", "Rome"],
          "correctAnswerIndex": 2
        }

        Ensure the entire output is ONLY a valid JSON array. Do not include any other text, explanations, or markdown like ```json.

        Text content:
        ---
        $truncatedText
        ---
        JSON Array:
        """),
    ];

    try {
      final response = await _model.generateContent(prompt);
      print("Gemini Raw MCQ Response: ${response.text}");
      if (response.text != null && response.text!.trim().isNotEmpty) {
        return parseQuizQuestions(response.text!);
      } else {
        print("Gemini MCQ response was null or empty.");
        return [];
      }
    } catch (e) {
      print("Error calling Gemini API for MCQs: $e");
      if (e is GenerativeAIException) {
        print("Gemini API Exception details for MCQs: ${e.message}");
      }
      return [];
    }
  }

  Future<List<TrueFalseQuestion>> generateTrueFalseQuestions(
    String textContent, {
    int numQuestions = 5,
  }) async {
    if (numQuestions <= 0) return [];
    final truncatedText = _truncateText(textContent);

    final prompt = [
      Content.text("""
        Based on the following text content from a university lecture PDF, please generate $numQuestions true/false questions.
        For each question, provide the question text and whether the correct answer is true or false.
        Format the output STRICTLY as a JSON array of objects. Each object must have:
        - "questionText": "The statement or question" (string)
        - "correctAnswer": true OR false (boolean)

        Example of one question object:
        {
          "questionText": "The Earth is flat.",
          "correctAnswer": false
        }

        Ensure the entire output is ONLY a valid JSON array. Do not include any other text, explanations, or markdown like ```json.

        Text content:
        ---
        $truncatedText
        ---
        JSON Array:
        """),
    ];

    try {
      final response = await _model.generateContent(prompt);
      print("Gemini Raw T/F Response: ${response.text}");
      if (response.text != null && response.text!.trim().isNotEmpty) {
        return parseTrueFalseQuestions(response.text!);
      } else {
        print("Gemini T/F response was null or empty.");
        return [];
      }
    } catch (e) {
      print("Error calling Gemini API for T/F questions: $e");
      if (e is GenerativeAIException) {
        print("Gemini API Exception details for T/F: ${e.message}");
      }
      return [];
    }
  }

  Future<List<Flashcard>> generateFlashcards(
    String textContent, {
    int numFlashcards = 5,
  }) async {
    if (numFlashcards <= 0) return [];
    final truncatedText = _truncateText(textContent);

    final prompt = [
      Content.text("""
        Based on the following text content from a university lecture PDF, please generate $numFlashcards flashcards.
        Each flashcard should consist of a "term" (a key concept, name, or short question) and a "definition" (a concise explanation or answer related to the term).
        Focus on extracting key theoretical points, definitions, or important facts.
        Format the output STRICTLY as a JSON array of objects. Each object must have:
        - "term": "The key concept or question" (string)
        - "definition": "The concise explanation or answer" (string)

        Example of one flashcard object:
        {
          "term": "Photosynthesis",
          "definition": "The process by which green plants use sunlight, water, and carbon dioxide to create their own food and release oxygen."
        }

        Ensure the entire output is ONLY a valid JSON array. Do not include any other text, explanations, or markdown like ```json.

        Text content:
        ---
        $truncatedText
        ---
        JSON Array:
        """),
    ];

    try {
      final response = await _model.generateContent(prompt);
      print("Gemini Raw Flashcard Response: ${response.text}");
      if (response.text != null && response.text!.trim().isNotEmpty) {
        return parseFlashcards(response.text!);
      } else {
        print("Gemini Flashcard response was null or empty.");
        return [];
      }
    } catch (e) {
      print("Error calling Gemini API for Flashcards: $e");
      if (e is GenerativeAIException) {
        print("Gemini API Exception details for Flashcards: ${e.message}");
      }
      return [];
    }
  }

  generateQuizFromText(String s, {required int numQuestions}) {}
}
