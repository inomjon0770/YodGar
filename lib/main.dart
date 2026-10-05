import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';
import 'screens/onboarding_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase initialization with platform options
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization notice: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
      ],
      child: const YodgarApp(),
    ),
  );
}

class YodgarApp extends StatefulWidget {
  const YodgarApp({super.key});

  @override
  State<YodgarApp> createState() => _YodgarAppState();
}

class _YodgarAppState extends State<YodgarApp> {
  bool _completedOnboarding = false;

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);

    // Ensure persistent accounts and settings are fully loaded before rendering screens
    if (!state.isLoaded) {
      return MaterialApp(
        title: 'YODGAR — So\'zlarni oson yodlang',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: state.isDayMode ? ThemeMode.light : ThemeMode.dark,
        home: const Scaffold(
          body: Center(
            child: CircularProgressIndicator(color: AppColors.primaryBlue),
          ),
        ),
      );
    }

    Widget initialScreen;
    if (!state.completedOnboarding && !_completedOnboarding) {
      initialScreen = OnboardingScreen(
        onComplete: () {
          state.completeOnboarding();
          setState(() => _completedOnboarding = true);
        },
      );
    } else if (!state.isAuthenticated || (state.currentAccount.role == 'admin' && !state.isAdminLoggedIn)) {
      initialScreen = AuthScreen(
        onLoginSuccess: () {
          // state.isAuthenticated is handled by AppState
        },
      );
    } else {
      initialScreen = const MainScreen();
    }

    return MaterialApp(
      title: 'YODGAR — So\'zlarni oson yodlang',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: state.isDayMode ? ThemeMode.light : ThemeMode.dark,
      home: initialScreen,
    );
  }
}
