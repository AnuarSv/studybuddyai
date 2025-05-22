import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:university_quiz_app/models/flashcard.dart';
import 'package:university_quiz_app/models/quiz_question.dart';
import 'package:university_quiz_app/models/training_session.dart';
import 'package:university_quiz_app/models/true_false_question.dart';
import 'package:university_quiz_app/services/gemini_service.dart';
import 'package:university_quiz_app/services/pdf_parser_service.dart';
import 'package:university_quiz_app/services/storage_service.dart';
import 'package:path/path.dart' as p;

enum GenerationState {
  initial,
  pickingFile,
  filePicked,
  parsingPdf,
  generatingContent,
  success,
  error,
}

class GenerationProvider with ChangeNotifier {
  final GeminiService _geminiService;
  final PdfParserService _pdfParserService = PdfParserService();
  final StorageService _storageService = StorageService();

  GenerationProvider(String apiKey) : _geminiService = GeminiService(apiKey);

  GenerationState _state = GenerationState.initial;
  GenerationState get state => _state;

  String? _filePath;
  String? get filePath => _filePath;
  String? _fileName;
  String? get fileName => _fileName;

  String? _pdfTextContent;
  String? get pdfTextContent => _pdfTextContent;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String _progressMessage = "";
  String get progressMessage => _progressMessage;

  void _setState(GenerationState newState, {String? msg, String? errorMsg}) {
    _state = newState;
    if (msg != null) _progressMessage = msg;
    if (errorMsg != null) _errorMessage = errorMsg;
    notifyListeners();
  }

  Future<void> pickPdf() async {
    _errorMessage = null;
    _setState(GenerationState.pickingFile, msg: "Opening file picker...");
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.path != null) {
        _filePath = result.files.single.path!;
        _fileName = p.basename(_filePath!); // Using path package
        _pdfTextContent = null; // Reset content if a new file is picked
        _setState(GenerationState.filePicked, msg: "PDF selected: $_fileName");
      } else {
        _setState(GenerationState.initial, errorMsg: "No PDF file selected.");
      }
    } catch (e) {
      _setState(GenerationState.error, errorMsg: "Error picking file: $e");
    }
  }

  Future<bool> generateTrainingSession({
    required String trainingName,
    required int numMcq,
    required int numTrueFalse,
    required int numFlashcards,
  }) async {
    if (_filePath == null) {
      _setState(
        GenerationState.error,
        errorMsg: "Please select a PDF file first.",
      );
      return false;
    }
    if (trainingName.trim().isEmpty) {
      _setState(
        GenerationState.error,
        errorMsg: "Please enter a name for the training session.",
      );
      return false;
    }
    if (numMcq == 0 && numTrueFalse == 0 && numFlashcards == 0) {
      _setState(
        GenerationState.error,
        errorMsg: "Please specify at least one type of content to generate.",
      );
      return false;
    }

    _errorMessage = null;
    _setState(GenerationState.parsingPdf, msg: "Parsing PDF...");

    _pdfTextContent = await _pdfParserService.extractTextFromPdf(_filePath!);
    if (_pdfTextContent == null) {
      _setState(
        GenerationState.error,
        errorMsg:
            "Could not extract text from PDF. The file might be corrupted, password-protected, or image-based.",
      );
      return false;
    }
    if (_pdfTextContent!.trim().isEmpty) {
      _setState(
        GenerationState.error,
        errorMsg:
            "The PDF appears to be empty or contains no extractable text.",
      );
      return false;
    }

    _setState(
      GenerationState.generatingContent,
      msg: "Generating content with AI... This may take a moment.",
    );

    List<QuizQuestion> mcqs = [];
    List<TrueFalseQuestion> trueFalseQuestions = [];
    List<Flashcard> flashcards = [];

    try {
      if (numMcq > 0) {
        _progressMessage = "Generating Multiple Choice Questions...";
        notifyListeners();
        mcqs = await _geminiService.generateMcqQuestions(
          _pdfTextContent!,
          numQuestions: numMcq,
        );
        if (mcqs.isEmpty && numMcq > 0) {
          print("Warning: Gemini returned no MCQs despite being requested.");
          // Not necessarily an error if other types succeed
        }
      }

      if (numTrueFalse > 0) {
        _progressMessage = "Generating True/False Questions...";
        notifyListeners();
        trueFalseQuestions = await _geminiService.generateTrueFalseQuestions(
          _pdfTextContent!,
          numQuestions: numTrueFalse,
        );
        if (trueFalseQuestions.isEmpty && numTrueFalse > 0) {
          print(
            "Warning: Gemini returned no T/F questions despite being requested.",
          );
        }
      }

      if (numFlashcards > 0) {
        _progressMessage = "Generating Flashcards...";
        notifyListeners();
        flashcards = await _geminiService.generateFlashcards(
          _pdfTextContent!,
          numFlashcards: numFlashcards,
        );
        if (flashcards.isEmpty && numFlashcards > 0) {
          print(
            "Warning: Gemini returned no Flashcards despite being requested.",
          );
        }
      }

      if (mcqs.isEmpty &&
          trueFalseQuestions.isEmpty &&
          flashcards.isEmpty &&
          (numMcq > 0 || numTrueFalse > 0 || numFlashcards > 0)) {
        _setState(
          GenerationState.error,
          errorMsg:
              "Failed to generate any content. The AI might not have found enough information or there was an API issue. Check console for details.",
        );
        return false;
      }

      TrainingSession newSession = TrainingSession(
        name: trainingName,
        pdfFileName: _fileName ?? p.basename(_filePath!),
        mcqs: mcqs,
        trueFalseQuestions: trueFalseQuestions,
        flashcards: flashcards,
      );

      await _storageService.saveTrainingSession(newSession);
      _setState(
        GenerationState.success,
        msg: "Training session '$trainingName' created successfully!",
      );
      return true;
    } catch (e) {
      print("Error during content generation or saving: $e");
      _setState(
        GenerationState.error,
        errorMsg: "An unexpected error occurred: ${e.toString()}",
      );
      return false;
    }
  }

  void reset() {
    _filePath = null;
    _fileName = null;
    _pdfTextContent = null;
    _errorMessage = null;
    _progressMessage = "";
    _setState(GenerationState.initial);
  }
}
