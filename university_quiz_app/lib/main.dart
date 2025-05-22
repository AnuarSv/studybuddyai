import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:university_quiz_app/providers/generation_provider.dart';
import 'package:university_quiz_app/providers/home_provider.dart';
import 'package:university_quiz_app/screens/home_screen.dart';
import 'package:university_quiz_app/utils/app_theme.dart';
import 'package:university_quiz_app/utils/constants.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    checkApiKey();
  } catch (e) {
    print('ERROR: ${e.toString()}');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => GenerationProvider(geminiApiKey),
        ),
        ChangeNotifierProvider(create: (context) => HomeProvider()),
      ],
      child: MaterialApp(
        title: 'Study Buddy AI',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        home: const HomeScreen(),
      ),
    );
  }
}
