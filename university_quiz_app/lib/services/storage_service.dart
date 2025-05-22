import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:university_quiz_app/models/training_session.dart';

class StorageService {
  static const _sessionsKey = 'training_sessions_list';

  Future<void> saveTrainingSession(TrainingSession session) async {
    final prefs = await SharedPreferences.getInstance();
    List<TrainingSession> sessions = await loadTrainingSessions();

    // Check if session with same ID exists to update it, otherwise add new
    int existingIndex = sessions.indexWhere((s) => s.id == session.id);
    if (existingIndex != -1) {
      sessions[existingIndex] = session;
    } else {
      sessions.add(session);
    }

    List<String> sessionsJson =
        sessions.map((s) => jsonEncode(s.toJson())).toList();
    await prefs.setStringList(_sessionsKey, sessionsJson);
    print("Saved session: ${session.name}");
  }

  Future<List<TrainingSession>> loadTrainingSessions() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? sessionsJson = prefs.getStringList(_sessionsKey);

    if (sessionsJson == null || sessionsJson.isEmpty) {
      return [];
    }

    try {
      List<TrainingSession> sessions =
          sessionsJson
              .map(
                (sJson) => TrainingSession.fromJson(
                  jsonDecode(sJson) as Map<String, dynamic>,
                ),
              )
              .toList();
      // Sort by creation date, newest first
      sessions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return sessions;
    } catch (e) {
      print("Error loading training sessions: $e");
      // If there's an error, clear corrupted data to prevent future issues
      await prefs.remove(_sessionsKey);
      return [];
    }
  }

  Future<void> deleteTrainingSession(String sessionId) async {
    final prefs = await SharedPreferences.getInstance();
    List<TrainingSession> sessions = await loadTrainingSessions();
    sessions.removeWhere((s) => s.id == sessionId);

    List<String> sessionsJson =
        sessions.map((s) => jsonEncode(s.toJson())).toList();
    await prefs.setStringList(_sessionsKey, sessionsJson);
    print("Deleted session: $sessionId");
  }

  Future<void> renameTrainingSession(String sessionId, String newName) async {
    List<TrainingSession> sessions = await loadTrainingSessions();
    int sessionIndex = sessions.indexWhere((s) => s.id == sessionId);
    if (sessionIndex != -1) {
      sessions[sessionIndex].name = newName;
      // No need to call saveTrainingSession directly, just update the list and save all
      final prefs = await SharedPreferences.getInstance();
      List<String> sessionsJson =
          sessions.map((s) => jsonEncode(s.toJson())).toList();
      await prefs.setStringList(_sessionsKey, sessionsJson);
      print("Renamed session $sessionId to $newName");
    } else {
      print("Session with ID $sessionId not found for renaming.");
    }
  }

  // Optional: Clear all data for testing
  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionsKey);
    print("All training data cleared.");
  }
}
