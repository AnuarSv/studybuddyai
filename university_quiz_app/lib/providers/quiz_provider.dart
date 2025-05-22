import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:university_quiz_app/models/quiz_question.dart';
import 'package:university_quiz_app/services/gemini_service.dart';
import 'package:university_quiz_app/services/pdf_parser_service.dart';

enum QuizLoadingState {
  initial,
  pickingFile,
  parsingPdf,
  generatingQuiz,
  loaded,
  error,
}

class QuizProvider with ChangeNotifier {
  final String _apiKey;
  late final GeminiService _geminiService;
  final PdfParserService _pdfParserService = PdfParserService();

  QuizProvider(this._apiKey) {
    _geminiService = GeminiService(_apiKey);
  }

  QuizLoadingState _loadingState = QuizLoadingState.initial;
  QuizLoadingState get loadingState => _loadingState;

  String? _filePath;
  String? get filePath => _filePath;

  String? _pdfTextContent;
  String? get pdfTextContent => _pdfTextContent;

  List<QuizQuestion> _questions = [];
  List<QuizQuestion> get questions => _questions;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> pickAndProcessPdf() async {
    _errorMessage = null;
    _questions = []; // Clear previous questions

    _setLoadingState(QuizLoadingState.pickingFile);
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      _filePath = result.files.single.path!;
      _setLoadingState(QuizLoadingState.parsingPdf);

      _pdfTextContent = await _pdfParserService.extractTextFromPdf(_filePath!);
      if (_pdfTextContent == null || _pdfTextContent!.trim().isEmpty) {
        _errorMessage = "Could not extract text from PDF or PDF is empty.";
        _setLoadingState(QuizLoadingState.error);
        return;
      }

      // Optional: Show a snippet of extracted text for debugging
      // print("Extracted text (first 500 chars): ${_pdfTextContent!.substring(0,_pdfTextContent!.length > 500 ? 500 : _pdfTextContent!.length)}");

      _setLoadingState(QuizLoadingState.generatingQuiz);
      _questions = await _geminiService.generateQuizFromText(
        _pdfTextContent!,
        numQuestions: 5,
      );

      if (_questions.isEmpty) {
        _errorMessage =
            "Failed to generate quiz. The AI might not have found enough content or there was an API issue. Check console for details.";
        _setLoadingState(QuizLoadingState.error);
      } else {
        _setLoadingState(QuizLoadingState.loaded);
      }
    } else {
      _errorMessage = "No PDF file selected.";
      _setLoadingState(QuizLoadingState.initial); // Or error if you prefer
    }
  }

  void _setLoadingState(QuizLoadingState state) {
    _loadingState = state;
    notifyListeners();
  }

  void reset() {
    _loadingState = QuizLoadingState.initial;
    _filePath = null;
    _pdfTextContent = null;
    _questions = [];
    _errorMessage = null;
    notifyListeners();
  }
}
