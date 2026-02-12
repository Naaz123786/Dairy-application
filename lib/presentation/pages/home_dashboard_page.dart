import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import '../../core/theme/app_theme.dart';
import '../bloc/diary_bloc.dart';
import '../bloc/reminder_bloc.dart';
import '../../domain/entities/reminder.dart';
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
            _buildBirthdaySection(isDark),
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
              AppRoutes.diaryEdit,
            ),
            const SizedBox(height: 12),
            _buildQuickActionCard(
              context,
              isDark,
              'Add a Routine',
              'Build better habits',
              Icons.schedule,
              AppRoutes.planner,
            ),
            const SizedBox(height: 12),
            _buildQuickActionCard(
              context,
              isDark,
              'Add Birthday',
              'Never forget special days',
              Icons.cake,
              AppRoutes.calendar,
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildBirthdaySection(bool isDark) {
    return BlocBuilder<ReminderBloc, ReminderState>(
      builder: (context, state) {
        List<Reminder> birthdays = [];
        if (state is ReminderLoaded) {
          birthdays = state.reminders
              .where((r) =>
                  r.category == 'birthday' ||
                  r.recurrenceType == 'Yearly' ||
                  r.isRecurring ||
                  r.title.toLowerCase().contains('birthday'))
              .toList()
            ..sort((a, b) {
              // Simple sort by day/month for upcoming
              final now = DateTime.now();
              final aDate = DateTime(
                  now.year, a.scheduledTime.month, a.scheduledTime.day);
              final bDate = DateTime(
                  now.year, b.scheduledTime.month, b.scheduledTime.day);
              return aDate.compareTo(bDate);
            });
        }

        if (birthdays.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Upcoming Birthdays',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.cyan,
              ),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: min(3, birthdays.length),
              itemBuilder: (context, index) {
                final bd = birthdays[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.darkGrey : AppTheme.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.cyan.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.cake, color: Colors.cyan),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              bd.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              DateFormat('MMMM d').format(bd.scheduledTime),
                              style: TextStyle(
                                color: isDark
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        );
      },
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
                        r.recurrenceType == 'Yearly' ||
                        r.isRecurring ||
                        r.title.toLowerCase().contains('birthday'),
                  )
                  .length;
            }

            return Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        context,
                        isDark,
                        'Routines',
                        routinesCount.toString(),
                        Icons.schedule,
                        onTap: () =>
                            Navigator.pushNamed(context, AppRoutes.planner),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        isDark,
                        'Exams',
                        examsCount.toString(),
                        Icons.school,
                        onTap: () =>
                            Navigator.pushNamed(context, AppRoutes.planner),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        context,
                        isDark,
                        'Entries',
                        entriesCount.toString(),
                        Icons.book,
                        onTap: () =>
                            Navigator.pushNamed(context, AppRoutes.diary),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        isDark,
                        'Birthdays',
                        birthdaysCount.toString(),
                        Icons.cake,
                        onTap: () =>
                            Navigator.pushNamed(context, AppRoutes.calendar),
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

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.userChanges(),
      initialData: FirebaseAuth.instance.currentUser,
      builder: (context, snapshot) {
        final user = snapshot.data;
        final name = user != null
            ? (user.displayName != null && user.displayName!.isNotEmpty)
                ? user.displayName!.split(' ')[0]
                : (user.email != null ? user.email!.split('@')[0] : 'Guest')
            : 'Guest';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Colors.cyan, Colors.lightBlueAccent],
              ).createShader(bounds),
              child: Text(
                '$greeting, $name',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                  color: Colors.white,
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
      },
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
    BuildContext context,
    bool isDark,
    String title,
    String value,
    IconData icon, {
    required VoidCallback onTap,
  }) {
    return Container(
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.cyan.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 24, color: Colors.cyan),
                ),
                const SizedBox(height: 16),
                Text(
                  value,
                  style: const TextStyle(
                      fontSize: 32, fontWeight: FontWeight.bold),
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
          ),
        ),
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
    return Container(
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
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
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.cyan.withOpacity(0.1),
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
        ),
      ),
    );
  }
}
