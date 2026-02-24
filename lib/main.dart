import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'services/storage_service.dart';
import 'providers/phrase_provider.dart';
import 'providers/transcription_provider.dart';
import 'screens/home_screen.dart';
import 'utils/app_theme.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive storage
  await StorageService.initialize();

  // Run the app
  runApp(const DhikrifyApp());
}

class DhikrifyApp extends StatelessWidget {
  const DhikrifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Phrase provider for managing Zikr phrases
        ChangeNotifierProvider(
          create: (_) => PhraseProvider(),
        ),

        // Transcription provider for speech recognition
        ChangeNotifierProxyProvider<PhraseProvider, TranscriptionProvider>(
          create: (context) => TranscriptionProvider(
            Provider.of<PhraseProvider>(context, listen: false),
          ),
          update: (context, phraseProvider, previous) =>
              previous ?? TranscriptionProvider(phraseProvider),
        ),
      ],
      child: WithForegroundTask(
        child: MaterialApp(
          title: 'Dhikrify',
          theme: AppTheme.theme,
          home: const HomeScreen(),
          debugShowCheckedModeBanner: false,
          // Support RTL for Arabic text
          builder: (context, child) {
            return Directionality(
              textDirection: TextDirection.ltr, // Default to LTR for app structure
              child: child!,
            );
          },
        ),
      ),
    );
  }
}
