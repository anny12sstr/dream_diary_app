// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; 
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'login_screen.dart';
import 'signup_screen.dart';
import 'home_screen.dart';
import 'add_dream_screen.dart';
import 'analytics_screen.dart';
import 'auth_check_screen.dart';
import 'constants/app_strings.dart';
import 'verify_email_screen.dart';
import 'providers/dream_provider.dart'; 

Future<void> main() async {
  await SentryFlutter.init(
    (options) {
      options.dsn = 'https://78bf79a9e06aba703411a4a66838ac95@o4510228111884288.ingest.de.sentry.io/4510228170473552';
      options.tracesSampleRate = 1.0;
    },
    appRunner: () async {
      WidgetsFlutterBinding.ensureInitialized();

      final prefs = await SharedPreferences.getInstance();
      final isDarkTheme = prefs.getBool('isDarkTheme') ?? false;

      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      runApp(MyApp(isDarkTheme: isDarkTheme));
    },
  );
}

class MyApp extends StatefulWidget {
  final bool isDarkTheme;
  const MyApp({super.key, required this.isDarkTheme});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late bool _isDarkTheme;

  @override
  void initState() {
    super.initState();
    _isDarkTheme = widget.isDarkTheme;
  }

  void _toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkTheme = !_isDarkTheme;
      prefs.setBool('isDarkTheme', _isDarkTheme);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DreamProvider()),
      ],
      child: MaterialApp(
        title: AppStrings.appTitle,
        theme: ThemeData(
          primarySwatch: Colors.purple,
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: const AppBarTheme(backgroundColor: Colors.white),
          inputDecorationTheme: const InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderSide: BorderSide.none),
          ),
        ),
        darkTheme: ThemeData.dark().copyWith(
          primaryColor: const Color(0xFF5B4DE0),
          scaffoldBackgroundColor: const Color(0xFF1E1E2F),
          appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF121224)),
          textTheme: ThemeData.dark().textTheme.apply(
            bodyColor: Colors.white,
            displayColor: Colors.white,
          ),
          inputDecorationTheme: const InputDecorationTheme(
            filled: true,
            border: OutlineInputBorder(borderSide: BorderSide.none),
          ),
        ),
        themeMode: _isDarkTheme ? ThemeMode.dark : ThemeMode.light,
        initialRoute: '/auth_check',
        routes: {
          '/auth_check': (context) => AuthCheckScreen(_toggleTheme),
          '/login': (context) => LoginScreen(_toggleTheme),
          '/signup': (context) => SignUpScreen(_toggleTheme),
          '/home': (context) => HomeScreen(_toggleTheme),
          '/add_dream': (context) => AddDreamScreen(_toggleTheme),
          '/analytics': (context) => AnalyticsScreen(_toggleTheme),
          '/verify_email': (context) => VerifyEmailScreen(_toggleTheme),
        },
      ),
    );
  }
}