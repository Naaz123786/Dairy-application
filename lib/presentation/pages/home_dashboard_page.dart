import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import '../../core/theme/app_theme.dart';
import '../bloc/diary_bloc.dart';
import '../bloc/reminder_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/routes/app_routes.dart';

class HomeDashboardPage extends StatelessWidget {
  const HomeDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Home',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.cyan,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGreeting(isDark),
            const SizedBox(height: 24),
            _buildQuoteCard(isDark),
            const SizedBox(height: 32),
            const Text(
              'Quick Stats',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.cyan,
              ),
            ),
            const SizedBox(height: 16),
            _buildStatsRow(isDark),
            const SizedBox(height: 32),
            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.cyan,
              ),
            ),
            const SizedBox(height: 16),
            _buildQuickActionCard(
              context,
              isDark,
              'Write a Diary Entry',
              'Capture your thoughts',
              Icons.edit_note,
              '/diary/edit',
            ),
            const SizedBox(height: 12),
            _buildQuickActionCard(
              context,
              isDark,
              'Add a Routine',
              'Build better habits',
              Icons.schedule,
              null,
            ),
            const SizedBox(height: 12),
            _buildQuickActionCard(
              context,
              isDark,
              'Add Birthday',
              'Never forget special days',
              Icons.cake,
              null,
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(bool isDark) {
    return BlocBuilder<DiaryBloc, DiaryState>(
      builder: (context, diaryState) {
        return BlocBuilder<ReminderBloc, ReminderState>(
          builder: (context, reminderState) {
            int entriesCount = 0;
            int routinesCount = 0;
            int examsCount = 0;
            int birthdaysCount = 0;

            if (diaryState is DiaryLoaded) {
              entriesCount = diaryState.entries.length;
            }

            if (reminderState is ReminderLoaded) {
              routinesCount = reminderState.reminders
                  .where((r) => r.category == 'routine')
                  .length;
              examsCount = reminderState.reminders
                  .where((r) => r.category == 'exam')
                  .length;
              birthdaysCount = reminderState.reminders
                  .where(
                    (r) =>
                        r.category == 'birthday' ||
                        r.recurrenceType == 'Yearly',
                  )
                  .length;
            }

            return Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        isDark,
                        'Routines',
                        routinesCount.toString(),
                        Icons.schedule,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        isDark,
                        'Exams',
                        examsCount.toString(),
                        Icons.school,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        isDark,
                        'Entries',
                        entriesCount.toString(),
                        Icons.book,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        isDark,
                        'Birthdays',
                        birthdaysCount.toString(),
                        Icons.cake,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildGreeting(bool isDark) {
    final hour = DateTime.now().hour;
    String greeting = 'Good Morning';

    if (hour >= 12 && hour < 17) {
      greeting = 'Good Afternoon';
    }
    if (hour >= 17) {
      greeting = 'Good Evening';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Colors.cyan, Colors.lightBlueAccent],
          ).createShader(bounds),
          child: Text(
            greeting,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
              color: Colors.white, // Required for ShaderMask
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          DateFormat.yMMMMEEEEd().format(DateTime.now()),
          style: TextStyle(
            fontSize: 15,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildQuoteCard(bool isDark) {
    final quotes = [
      "Believe you can and you're halfway there.",
      "The only way to do great work is to love what you do.",
      "Your time is limited, don't waste it living someone else's life.",
      "Success is not final, failure is not fatal: It is the courage to continue that counts.",
      "The future belongs to those who believe in the beauty of their dreams.",
      "Dream big, work hard, stay focused.",
      "Every day is a new beginning.",
    ];
    final randomQuote = quotes[Random().nextInt(quotes.length)];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkGrey : AppTheme.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? Colors.cyan.withOpacity(0.3)
              : Colors.cyan.withOpacity(0.5),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.cyan.withOpacity(0.1)
                  : Colors.cyan.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.format_quote,
              color: Colors.cyan,
              size: 28,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            randomQuote,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    bool isDark,
    String title,
    String value,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkGrey : AppTheme.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.cyan.withOpacity(0.3)
              : Colors.cyan.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.cyan.withOpacity(0.1)
                  : Colors.cyan.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 24, color: Colors.cyan),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context,
    bool isDark,
    String title,
    String subtitle,
    IconData icon,
    String? route,
  ) {
    // ... inside _buildQuickActionCard ...
    return GestureDetector(
      onTap: () {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          Navigator.pushNamed(context, AppRoutes.login);
          return;
        }

        if (route != null) {
          Navigator.pushNamed(context, route);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkGrey : AppTheme.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark
                ? Colors.cyan.withOpacity(0.3)
                : Colors.cyan.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.cyan.withOpacity(0.1)
                    : Colors.cyan.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 24, color: Colors.cyan),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 18),
          ],
        ),
      ),
    );
  }
}
