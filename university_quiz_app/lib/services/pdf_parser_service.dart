import 'dart:io';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class PdfParserService {
  Future<String?> extractTextFromPdf(String filePath) async {
    try {
      final File file = File(filePath);
      if (!await file.exists()) {
        print("Error: PDF file does not exist at path: $filePath");
        return null;
      }
      final List<int> bytes = await file.readAsBytes();
      final PdfDocument document = PdfDocument(inputBytes: bytes);
      final PdfTextExtractor extractor = PdfTextExtractor(document);
      String text = extractor.extractText();
      document.dispose();

      if (text.trim().isNotEmpty) {
        return text.trim();
      } else {
        print("Extracted text is empty from PDF: $filePath");
        return ""; // Return empty string for empty PDFs to distinguish from null (error)
      }
    } catch (e) {
      print("Error parsing PDF with Syncfusion: $e");
      return null;
    }
  }
}
