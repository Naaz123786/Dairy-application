import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppTheme.white : AppTheme.black;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Privacy Policy',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              title: 'Introduction',
              content:
                  'Welcome to Personal Diary. Your privacy is our top priority. This app is designed to be a secure, private space for your thoughts and plans.',
              primaryColor: primaryColor,
            ),
            _buildSection(
              title: 'Data Ownership',
              content:
                  'You own all the data you enter into the app. We do not have access to your diary entries, mood data, or reminders. Your data is yours alone.',
              primaryColor: primaryColor,
            ),
            _buildSection(
              title: 'Offline-First & Encryption',
              content:
                  'Your diary entries are stored locally on your device and are encrypted. This means even if someone gets access to your device files, they cannot read your entries without the app\'s internal security keys.',
              primaryColor: primaryColor,
            ),
            _buildSection(
              title: 'Firebase Authentication',
              content:
                  'We use Firebase Authentication (Google Sign-In or Email/Password) to manage your account and allow you to sync your data across devices. Your login credentials are managed securely by Google.',
              primaryColor: primaryColor,
            ),
            _buildSection(
              title: 'Cloud Sync',
              content:
                  'When you are logged in, your entries are backed up to a secure cloud database (Firestore). This ensures you don\'t lose your data if you lose your phone. This data is tied to your unique user ID and is not accessible by others.',
              primaryColor: primaryColor,
            ),
            _buildSection(
              title: 'Biometric Lock',
              content:
                  'The app provides an optional biometric lock (Fingerprint/FaceID) to prevent unauthorized access. This feature uses your device\'s native security systems and we do not store your biometric data.',
              primaryColor: primaryColor,
            ),
            _buildSection(
              title: 'Contact Us',
              content:
                  'If you have any questions about this Privacy Policy, please contact us at support@minidiary.com.',
              primaryColor: primaryColor,
            ),
            const SizedBox(height: 40),
            Center(
              child: Text(
                'Last Updated: January 2026',
                style: TextStyle(
                  color: primaryColor.withOpacity(0.5),
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String content,
    required Color primaryColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.cyan,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              fontSize: 15,
              color: primaryColor.withOpacity(0.8),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
