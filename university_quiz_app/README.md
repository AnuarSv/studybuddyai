# Study Buddy AI (or TrueLearn) - Flutter Final Project

## Table of Contents
1. [Introduction](#introduction)
2. [Aim of the Application](#aim-of-the-application)
3. [Features](#features)
4. [Tech Stack & Architecture](#tech-stack--architecture)
    - [Core Technologies](#core-technologies)
    - [Architecture: MVVM](#architecture-mvvm)
5. [Project Structure](#project-structure)
6. [Setup and Installation](#setup-and-installation)
    - [Prerequisites](#prerequisites)
    - [API Key Configuration](#api-key-configuration)
    - [Building and Running](#building-and-running)
7. [Methodology / How it Works](#methodology--how-it-works)
8. [Relevance & Benefits](#relevance--benefits)
9. [Screenshots (Placeholder)](#screenshots-placeholder)
10. [Future Enhancements (Optional)](#future-enhancements-optional)
11. [Conclusion](#conclusion)
12. [Author](#author)

---

## 1. Introduction
Study Buddy AI is a Flutter-based mobile application designed exclusively for Android OS. It aims to revolutionize how students prepare for exams and learn from their lecture materials. By leveraging the power of Google's Gemini AI, this application transforms static PDF lecture notes into interactive and engaging study tools.

---

## 2. Aim of the Application
The primary goal of Study Buddy AI is to empower students by:
-   Providing a tool to easily create personalized study materials from their PDF lectures.
-   Generating diverse learning aids such as flashcards, multiple-choice questions (MCQs), and true/false questions.
-   Offering an efficient and active learning experience, moving beyond passive reading.
-   Saving all generated content locally for offline access and convenient review.

---

## 3. Features
-   **PDF Upload & Processing:** Users can upload their lecture PDF files.
-   **AI-Powered Content Generation:** Utilizes the Gemini API to:
    -   Create **Flashcards** (for theory and key concepts).
    -   Generate **Multiple Choice Questions (MCQs)** with 4 options and a correct answer.
    -   Generate **True/False Questions**.
-   **Customizable Generation:** Users can specify the number of questions/flashcards they want for each type.
-   **Local Storage:**
    -   All generated quizzes and flashcards are saved into "Training Sessions" (folders) on the device.
    -   Users can view, open, and review these sessions anytime.
-   **Session Management:**
    -   Rename existing training sessions.
    -   Delete training sessions.
-   **Interactive Quizzing:**
    -   Engaging UI for taking MCQs and True/False quizzes.
    -   Immediate feedback on answers.
    -   Results screen showing score and performance.
-   **Flashcard Viewer:**
    -   Interactive flashcard viewer with flip animation.
    -   Ability to shuffle flashcards.
-   **User-Friendly Design:** Smooth, beautiful, and intuitive user interface.

---

## 4. Tech Stack & Architecture

### Core Technologies
-   **Flutter:** Cross-platform UI toolkit for building natively compiled applications. (Targeted for Android in this project).
-   **Dart:** Programming language used with Flutter.
-   **Google Gemini API:** For AI-powered content generation from PDF text.
-   **Syncfusion Flutter PDF:** For parsing and extracting text content from PDF files.
-   **Provider:** For state management, implementing the ViewModel layer.
-   **File Picker:** To allow users to select PDF files from their device.
-   **Shared Preferences:** For simple local storage of training session metadata. (Could be upgraded to SQLite/Hive for more complex needs).
-   **Path Provider:** To manage file system paths.
-   **UUID:** For generating unique IDs for training sessions.
-   **Flutter Slidable:** For swipe actions (rename/delete) on list items.

### Architecture: MVVM (Model-View-ViewModel)
The application follows the MVVM architectural pattern to ensure a clear separation of concerns, leading to a more maintainable, testable, and scalable codebase.

-   **Model:** Represents the data and business logic.
    -   Data Objects: `TrainingSession`, `QuizQuestion`, `TrueFalseQuestion`, `Flashcard`.
    -   Services: `PdfParserService`, `GeminiService`, `StorageService`.
-   **View:** The UI elements that the user interacts with.
    -   Screens: `HomeScreen`, `CreateTrainingScreen`, `McqQuizScreen`, `FlashcardViewScreen`, etc.
-   **ViewModel (Implemented using Flutter Providers):** Acts as a bridge between the Model and the View.
    -   Providers: `HomeProvider`, `GenerationProvider`.
    -   Manages UI state and handles user interactions by communicating with the Model.

---

## 5. Project Structure
The project is organized into logical directories for better maintainability:

lib/

├── main.dart # App entry point

├── models/ # Data models (QuizQuestion, Flashcard, etc.)

├── providers/ # State management (ViewModels for MVVM)

├── screens/ # UI screens/pages

├── services/ # Business logic (Gemini, PDF parsing, Storage)

├── utils/ # Utility classes (Constants, Theme)

└── widgets/ # Reusable UI components (if any)

---

## 6. Setup and Installation

### Prerequisites
-   Flutter SDK (Latest stable version recommended)
-   Android Studio or VS Code with Flutter and Dart plugins
-   An Android Emulator or a physical Android device (OS version compatible with app's minSDK)

### API Key Configuration
1.  Obtain a Gemini API Key from [Google AI Studio](https://aistudio.google.com/app/apikey).
2.  Open the file `lib/utils/constants.dart`.
3.  Replace the placeholder `YOUR_API_KEY` with your actual Gemini API Key:
    ```dart
    const String geminiApiKey = 'YOUR_ACTUAL_GEMINI_API_KEY';
    ```
    **Important:** Do not commit your actual API key to a public repository. For this student project, ensure your teacher is aware if it's hardcoded.

### Building and Running
1.  **Clone the repository (if applicable):**
    ```bash
    git clone https://github.com/AnuarSv/studybuddyai
    cd studybuddyai/
    ```
2.  **Get dependencies:**
    ```bash
    flutter pub get
    ```
3.  **Ensure an Android emulator is running or a device is connected.**
4.  **Run the application:**
    ```bash
    flutter run
    ```
5.  **To build an APK:**
    ```bash
    flutter build apk --release
    # The APK will be located in build/app/outputs/flutter-apk/app-release.apk
    ```

---

## 7. Methodology / How it Works
1.  **User Interaction:** The user launches the app and navigates to the "Create New Training" screen.
2.  **PDF Selection:** The user selects a PDF lecture file from their device storage.
3.  **Configuration:** The user specifies a name for the training session and the desired number of MCQs, True/False questions, and Flashcards.
4.  **PDF Parsing:** The `PdfParserService` extracts the raw text content from the selected PDF.
5.  **AI Content Generation:**
    -   The extracted text and user's quantity preferences are sent to the `GeminiService`.
    -   The `GeminiService` crafts specific prompts for each content type (MCQs, T/F, Flashcards) and sends them to the Gemini API.
    -   The Gemini API processes the text and returns the generated content in JSON format.
6.  **Data Parsing & Modeling:** The JSON responses are parsed and converted into structured Dart objects (`QuizQuestion`, `TrueFalseQuestion`, `Flashcard`).
7.  **Local Storage:** The newly created `TrainingSession` (containing all generated content, PDF name, and creation date) is saved locally on the device using the `StorageService`.
8.  **Access & Review:** Users can access their saved training sessions from the `HomeScreen` to take quizzes or review flashcards.

---

## 8. Relevance & Benefits
-   **Active Learning:** Transforms passive PDF consumption into an active and engaging learning process.
-   **Personalization:** Study materials are generated directly from the student's own lecture notes, making them highly relevant.
-   **Efficiency:** Helps students quickly identify key concepts and test their understanding.
-   **Convenience:** All materials are stored locally for offline access, perfect for studying on the go.
-   **Improved Retention:** Interactive quizzing and flashcard repetition are proven methods for better knowledge retention.
-   **Modern Tool:** Leverages cutting-edge AI to provide a smart study assistant.

---

## 9. Screenshots
-   **Home Screen:** Showing a list of existing training sessions or an empty state.
-   **Create Training Screen:** Showing PDF selection, training name input, and quantity selectors for questions/flashcards.
  ![image](https://github.com/user-attachments/assets/f0b72be9-f146-4e9c-825c-9e104b52c83e)
-   **MCQ Quiz Screen:** An example of a multiple-choice question.
-   **True/False Quiz Screen:** An example of a true/false question.
-   **Flashcard View Screen:** A flashcard showing the term and definition.
-   **Results Screen:** Displaying the quiz score.

---

## 10. Future Enhancements (Optional)
-   Support for other file types (e.g., .docx, .pptx).
-   Cloud synchronization of training sessions.
-   Spaced repetition system (SRS) for flashcards.
-   Ability to edit generated questions/flashcards.
-   Advanced analytics on quiz performance.
-   Option to export quizzes/flashcards.
-   Dark mode support.

---

## 11. Conclusion
Study Buddy AI is a powerful and practical tool designed to enhance the learning experience for students. By integrating advanced AI capabilities with a user-friendly interface, it provides an effective way to convert lecture PDFs into valuable, interactive study aids, ultimately aiming to improve academic performance and understanding.

---

## 12. Author
-   AnuarSv, twaise
-   sultanbekov1706@gmail.com
-   https://github.com/AnuarSv

---
