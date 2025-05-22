const String geminiApiKey =
    'GEMINI_API'; // Replace with your actual Gemini API Key

void checkApiKey() {
  if (geminiApiKey == 'YOUR_API_KEY') {
    throw AssertionError(
      'Please replace "YOUR_API_KEY" with your actual Gemini API Key in lib/utils/constants.dart',
    );
  }
}
