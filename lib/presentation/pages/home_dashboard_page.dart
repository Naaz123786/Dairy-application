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
            _buildAffirmationCard(isDark),
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
            _buildMoodAnalytics(context, isDark),
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

        return BlocBuilder<DiaryBloc, DiaryState>(
          builder: (context, state) {
            int streak = 0;
            if (state is DiaryLoaded) {
              streak = _calculateStreak(state.entries);
            }

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
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
                  ),
                ),
                if (streak > 0) _buildStreakBadge(streak, isDark),
              ],
            );
          },
        );
      },
    );
  }

  int _calculateStreak(List<dynamic> entries) {
    if (entries.isEmpty) return 0;

    final dates = entries
        .map((e) => DateTime(e.date.year, e.date.month, e.date.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (dates.first.isBefore(yesterday)) return 0;

    int streak = 1;
    for (int i = 1; i < dates.length; i++) {
      if (dates[i - 1].difference(dates[i]).inDays == 1) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  Widget _buildStreakBadge(int streak, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade400, Colors.red.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '🔥',
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(width: 8),
          Text(
            '$streak Day Streak',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAffirmationCard(bool isDark) {
    final affirmations = [
      "I am capable of achieving anything I set my mind to.",
      "Today is a gift, and I will make the most of it.",
      "I choose to focus on the positive and let go of the rest.",
      "My potential is limitless, and I am growing every day.",
      "I am worthy of love, happiness, and all good things.",
      "I believe in myself and my ability to succeed.",
      "I am grateful for the progress I've made and the person I'm becoming.",
      "Every challenge I face is an opportunity for growth.",
      "I have the power to create the life I want.",
      "I am at peace with my past and excited about my future.",
    ];
    final randomAffirmation =
        affirmations[Random().nextInt(affirmations.length)];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkGrey : AppTheme.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Colors.cyan.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.cyan.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.spa, color: Colors.cyan.withOpacity(0.5), size: 18),
              const SizedBox(width: 8),
              Text(
                'DAILY AFFIRMATION',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                  color: Colors.cyan.withOpacity(0.8),
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.spa, color: Colors.cyan.withOpacity(0.5), size: 18),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            randomAffirmation,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              height: 1.4,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            height: 3,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.cyan.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2),
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

  Widget _buildMoodAnalytics(BuildContext context, bool isDark) {
    return BlocBuilder<DiaryBloc, DiaryState>(builder: (context, state) {
      if (state is! DiaryLoaded || state.entries.isEmpty) {
        return const SizedBox.shrink();
      }

      // Get entries from the last 7 days
      final now = DateTime.now();
      final sevenDaysAgo = now.subtract(const Duration(days: 7));
      final recentEntries = state.entries
          .where((entry) => entry.date.isAfter(sevenDaysAgo))
          .toList();

      if (recentEntries.isEmpty) {
        return const SizedBox.shrink();
      }

      // Count moods
      final moodCounts = <String, int>{};
      for (var entry in recentEntries) {
        if (entry.mood.isNotEmpty) {
          moodCounts[entry.mood] = (moodCounts[entry.mood] ?? 0) + 1;
        }
      }

      if (moodCounts.isEmpty) {
        return const SizedBox.shrink();
      }

      // Get mood colors
      final moodColors = {
        'Happy': Colors.amber,
        'Sad': Colors.blue,
        'Excited': Colors.purple,
        'Tired': Colors.grey,
        'Neutral': Colors.teal,
        'Angry': Colors.red,
      };

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mood Analytics',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.cyan,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkGrey : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.cyan.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Last 7 Days',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 16),
                ...moodCounts.entries.map((entry) {
                  final percentage =
                      (entry.value / recentEntries.length * 100).round();
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: moodColors[entry.key] ?? Colors.cyan,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  entry.key,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '$percentage%',
                              style: TextStyle(
                                color: isDark
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: entry.value / recentEntries.length,
                            backgroundColor:
                                isDark ? Colors.grey[800] : Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation(
                              moodColors[entry.key] ?? Colors.cyan,
                            ),
                            minHeight: 8,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                const SizedBox(height: 8),
                Divider(color: Colors.cyan.withOpacity(0.2)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Entries',
                      style: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                    Text(
                      '${recentEntries.length}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.cyan,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      );
    });
  }
}
