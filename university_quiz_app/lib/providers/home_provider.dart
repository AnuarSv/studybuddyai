import 'package:flutter/material.dart';
import 'package:university_quiz_app/models/training_session.dart';
import 'package:university_quiz_app/services/storage_service.dart';

enum HomeState { initial, loading, loaded, error }

class HomeProvider with ChangeNotifier {
  final StorageService _storageService = StorageService();

  HomeState _state = HomeState.initial;
  HomeState get state => _state;

  List<TrainingSession> _trainingSessions = [];
  List<TrainingSession> get trainingSessions => _trainingSessions;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> loadTrainingSessions() async {
    _state = HomeState.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      _trainingSessions = await _storageService.loadTrainingSessions();
      _state = HomeState.loaded;
    } catch (e) {
      _errorMessage = "Failed to load training sessions: $e";
      _state = HomeState.error;
    }
    notifyListeners();
  }

  Future<void> deleteTrainingSession(String sessionId) async {
    try {
      await _storageService.deleteTrainingSession(sessionId);
      await loadTrainingSessions(); // Refresh the list
    } catch (e) {
      // Handle error, maybe show a snackbar
      print("Error deleting session: $e");
      _errorMessage = "Failed to delete session.";
      notifyListeners(); // To show error if UI is designed for it
    }
  }

  Future<void> renameTrainingSession(String sessionId, String newName) async {
    try {
      await _storageService.renameTrainingSession(sessionId, newName);
      await loadTrainingSessions(); // Refresh the list
    } catch (e) {
      print("Error renaming session: $e");
      _errorMessage = "Failed to rename session.";
      notifyListeners();
    }
  }

  Future<void> clearAllDataForTesting() async {
    await _storageService.clearAllData();
    await loadTrainingSessions();
  }
}
