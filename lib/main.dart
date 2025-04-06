import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login.dart';
import 'surveypage.dart';
import 'homepage.dart';
import 'onboardingscreen.dart';
import 'splashscreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print("Firebase initialization error: $e");
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  @override
  _AuthWrapperState createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _surveyCompleted = false;
  bool _isLoading = true;
  bool _isFirstTimeUser = false;

  @override
  void initState() {
    super.initState();
    _checkSurveyStatus();
  }

  // Check if the user has completed the survey and if it's their first time
  Future<void> _checkSurveyStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool surveyCompleted = prefs.getBool('surveyCompleted') ?? false;
    bool isFirstTimeUser = prefs.getBool('isFirstTimeUser') ?? true;

    if (FirebaseAuth.instance.currentUser != null) {
      setState(() {
        _surveyCompleted = surveyCompleted;
      });
    }

    setState(() {
      _isLoading = false;
      _isFirstTimeUser = isFirstTimeUser;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return SplashScreen();
    }

    final user = FirebaseAuth.instance.currentUser;

    // Check if user is logged in and whether it's their first time using the app
    if (_isFirstTimeUser) {
      // Navigate to OnboardingScreen if it's the user's first time
      return OnboardingScreen();
    } else if (user == null) {
      // If user is not logged in, show login page
      return LoginPage();
    } else if (!_surveyCompleted) {
      // If the survey is not completed, show the SurveyScreen
      return SurveyScreen();
    } else {
      // Otherwise, show the HomePage
      return HomePage();
    }
  }
}
