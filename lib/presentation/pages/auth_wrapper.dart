import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart';
import 'main_page.dart';

/// Authentication wrapper that handles navigation based on auth state
/// Shows LoginPage when user is not authenticated
/// Shows MainPage when user is authenticated
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show loading indicator while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Show MainPage if user is authenticated
        if (snapshot.hasData && snapshot.data != null) {
          return const MainPage();
        }

        // Show LoginPage if user is not authenticated
        return const LoginPage();
      },
    );
  }
}
