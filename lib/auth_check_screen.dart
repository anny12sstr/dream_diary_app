// lib/auth_check_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart'; 
import 'providers/dream_provider.dart'; 
import 'login_screen.dart';
import 'home_screen.dart';

class AuthCheckScreen extends StatelessWidget {
  final VoidCallback toggleTheme;

  const AuthCheckScreen(this.toggleTheme, {super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          // Користувач залогінений
          return ChangeNotifierProvider(
            create: (_) => DreamProvider(),
            child: HomeScreen(toggleTheme),
          );
        } else {
          // Не залогінений
          return LoginScreen(toggleTheme);
        }
      },
    );
  }
}