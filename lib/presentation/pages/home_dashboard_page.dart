import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

import '../../core/theme/app_theme.dart';
import '../bloc/diary_bloc.dart';
import '../bloc/reminder_bloc.dart';
import '../../domain/entities/reminder.dart';
import '../../core/routes/app_routes.dart';
import '../../data/datasources/local_database.dart';
import 'lock_screen.dart';

class HomeDashboardPage extends StatefulWidget {
  const HomeDashboardPage({super.key});

  @override
  State<HomeDashboardPage> createState() => _HomeDashboardPageState();
}

class _HomeDashboardPageState extends State<HomeDashboardPage> {
  BoxDecoration _premiumCardDecoration(
    bool isDark, {
    Color accent = Colors.cyan,
    double radius = 22,
  }) {
    return BoxDecoration(
      color: isDark ? const Color(0xFF161616) : Colors.white,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: isDark
            ? Colors.white.withValues(alpha: 0.10)
            : Colors.black.withValues(alpha: 0.06),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.08),
          blurRadius: 18,
          offset: const Offset(0, 10),
        ),
        BoxShadow(
          color: accent.withValues(alpha: isDark ? 0.06 : 0.05),
          blurRadius: 18,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }

  Widget _sectionHeader(
    bool isDark, {
    required String title,
    required IconData icon,
    String? caption,
    VoidCallback? onTap,
    IconData? trailingIcon,
  }) {
    final header = Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: Colors.cyan.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.cyan.withValues(alpha: 0.20)),
          ),
          child: Icon(icon, color: Colors.cyan, size: 20),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.cyan,
                ),
              ),
              if (caption != null) ...[
                const SizedBox(height: 2),
                Text(
                  caption,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ],
          ),
        ),
        if (trailingIcon != null)
          Icon(trailingIcon,
              size: 18,
              color: isDark ? Colors.white54 : Colors.black45),
      ],
    );

    if (onTap == null) return header;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: header,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // Ensure data is loaded when dashboard is shown
    context.read<DiaryBloc>().add(LoadDiaryEntries());
    context.read<ReminderBloc>().add(LoadReminders());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGreeting(isDark),
            const SizedBox(height: 16),
            _buildAffirmationCard(isDark),
            const SizedBox(height: 24),
            _buildOnThisDaySection(isDark),
            const SizedBox(height: 32),
            _sectionHeader(
              isDark,
              title: 'Quick Stats',
              icon: Icons.insights,
              caption: 'Your routines, exams, entries & birthdays at a glance',
            ),
            const SizedBox(height: 16),
            _buildStatsRow(isDark),
            const SizedBox(height: 32),
            _buildMoodAnalytics(context, isDark),
            const SizedBox(height: 32),
            _buildBirthdaySection(isDark),
            const SizedBox(height: 32),
            _sectionHeader(
              isDark,
              title: 'Quick Actions',
              icon: Icons.bolt,
              caption: 'Jump into what you want to do next',
            ),
            const SizedBox(height: 16),
            _buildQuickActionsGrid(context, isDark),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsGrid(BuildContext context, bool isDark) {
    final actions = [
      (
        'Write',
        'Diary entry',
        Icons.edit_note,
        AppRoutes.diaryEdit,
        Colors.cyan,
      ),
      (
        'Routine',
        'Planner',
        Icons.schedule,
        AppRoutes.planner,
        Colors.teal,
      ),
      (
        'Birthday',
        'Calendar',
        Icons.cake,
        AppRoutes.calendar,
        Colors.pink,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: actions.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2.2,
      ),
      itemBuilder: (context, index) {
        final a = actions[index];
        return _buildQuickActionTile(
          context,
          isDark,
          title: a.$1,
          subtitle: a.$2,
          icon: a.$3,
          route: a.$4,
          accent: a.$5,
        );
      },
    );
  }

  Widget _buildOnThisDaySection(bool isDark) {
    return BlocBuilder<DiaryBloc, DiaryState>(
      builder: (context, state) {
        if (state is! DiaryLoaded) return const SizedBox.shrink();

        final now = DateTime.now();
        final todayEntries = state.entries
            .where((e) =>
                e.date.month == now.month &&
                e.date.day == now.day &&
                e.date.year < now.year)
            .toList()
          ..sort((a, b) => b.date.year.compareTo(a.date.year));

        if (todayEntries.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('📅', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                const Text(
                  'On This Day',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.cyan,
                  ),
                ),
                const Spacer(),
                Text(
                  '${todayEntries.length} memor${todayEntries.length == 1 ? 'y' : 'ies'}',
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...todayEntries.take(3).map((entry) {
              final yearsAgo = now.year - entry.date.year;
              return GestureDetector(
                onTap: () => Navigator.pushNamed(
                  context,
                  AppRoutes.diaryEdit,
                  arguments: entry,
                ),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.purple.withValues(alpha: 0.3),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purple.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.purple.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            const Text('🕰️', style: TextStyle(fontSize: 18)),
                            Text(
                              '$yearsAgo yr${yearsAgo > 1 ? 's' : ''}',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.purple,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              DateFormat('EEEE, MMMM d, y').format(entry.date),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            if (entry.mood.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.cyan.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  entry.mood,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.cyan,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        );
      },
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
            _sectionHeader(
              isDark,
              title: 'Upcoming Birthdays',
              icon: Icons.cake,
              caption: 'So you never miss a special day',
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
                      color: Colors.cyan.withValues(alpha: 0.3),
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

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [
                          const Color(0xFF0E2B2E),
                          const Color(0xFF121212),
                        ]
                      : [
                          Colors.cyan.withValues(alpha: 0.10),
                          Colors.white,
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: Colors.cyan.withValues(alpha: isDark ? 0.22 : 0.18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.08),
                    blurRadius: 22,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: ShaderMask(
                                shaderCallback: (bounds) =>
                                    const LinearGradient(
                                  colors: [
                                    Colors.cyan,
                                    Colors.lightBlueAccent,
                                  ],
                                ).createShader(bounds),
                                child: Text(
                                  '$greeting, $name',
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: -0.3,
                                    color: Colors.white,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('EEEE, d MMMM y').format(DateTime.now()),
                          style: TextStyle(
                            fontSize: 13,
                            color:
                                isDark ? Colors.white70 : Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          streak > 0
                              ? 'Keep your streak alive today'
                              : 'Start a new streak with one entry',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.65)
                                : Colors.black.withValues(alpha: 0.60),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  _buildStreakBadge(streak, isDark),
                ],
              ),
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

    // If latest entry is older than yesterday, streak is broken
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
    final hasStreak = streak > 0;
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 10, vertical: 6), // Reduced from 16, 8
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: hasStreak
              ? [Colors.orange.shade400, Colors.red.shade400]
              : [Colors.grey.shade400, Colors.grey.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16), // Reduced from 20
        boxShadow: [
          BoxShadow(
            color: (hasStreak ? Colors.orange : Colors.grey)
                .withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            hasStreak ? '🔥' : '❄️',
            style: const TextStyle(fontSize: 14), // Reduced from 18
          ),
          const SizedBox(width: 6),
          Text(
            hasStreak
                ? '$streak'
                : '0', // Just show number if it's too long, or "No"
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12, // Reduced from 14
            ),
          ),
          if (hasStreak) ...[
            const SizedBox(width: 2),
            const Text(
              'Days',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkGrey : AppTheme.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.cyan.withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.cyan.withValues(alpha: 0.05),
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
              Icon(Icons.spa,
                  color: Colors.cyan.withValues(alpha: 0.5), size: 18),
              const SizedBox(width: 8),
              Text(
                'DAILY AFFIRMATION',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2,
                  color: Colors.cyan.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.spa,
                  color: Colors.cyan.withValues(alpha: 0.5), size: 18),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            randomAffirmation,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w400,
              fontStyle: FontStyle.italic,
              height: 1.5,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 3,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.cyan.withValues(alpha: 0.2),
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
        color: isDark ? const Color(0xFF161616) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.10)
              : Colors.black.withValues(alpha: 0.06),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.08),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.cyan.withValues(alpha: isDark ? 0.06 : 0.05),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.cyan.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.cyan.withValues(alpha: 0.18),
                        ),
                      ),
                      child: Icon(icon, size: 22, color: Colors.cyan),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.60)
                        : Colors.black.withValues(alpha: 0.60),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionTile(
    BuildContext context,
    bool isDark, {
    required String title,
    required String subtitle,
    required IconData icon,
    required String? route,
    required Color accent,
  }) {
    return Container(
      decoration: _premiumCardDecoration(isDark, accent: accent, radius: 20),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (route == null) return;

            // Special handling for Diary quick action (Write):
            // respect diary lock the same way as bottom tab.
            if (route == AppRoutes.diaryEdit) {
              final localDb = GetIt.I<LocalDatabase>();
              final isGlobalLockActive = localDb.isAppLockEnabled();
              final isDiaryLockActive = localDb.isDiaryLockEnabled();
              final hasPin = localDb.hasDiaryPin();

              if (!isGlobalLockActive && isDiaryLockActive && hasPin) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LockScreen(
                      isAppLock: false,
                      onUnlocked: () {
                        Navigator.pushReplacementNamed(
                            context, AppRoutes.diaryEdit);
                      },
                    ),
                  ),
                );
                return;
              }
            }

            Navigator.pushNamed(context, route);
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        accent.withValues(alpha: 0.30),
                        accent.withValues(alpha: 0.12),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: accent.withValues(alpha: 0.22)),
                  ),
                  child: Icon(icon, color: accent, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: isDark ? Colors.white38 : Colors.black38,
                ),
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
        return _buildEmptyStateCard(
          isDark,
          'Mood Analytics',
          'No diary entries yet. Write your first entry to see your mood patterns!',
          Icons.bar_chart,
        );
      }

      // Get entries from the last 7 days
      final now = DateTime.now();
      final sevenDaysAgo = now.subtract(const Duration(days: 7));
      final recentEntries = state.entries
          .where((entry) => entry.date.isAfter(sevenDaysAgo))
          .toList();

      if (recentEntries.isEmpty) {
        return _buildEmptyStateCard(
          isDark,
          'Mood Analytics',
          'No mood data for the last 7 days. Start writing to see your patterns!',
          Icons.bar_chart,
        );
      }

      // Count moods
      final moodCounts = <String, int>{};
      for (var entry in recentEntries) {
        if (entry.mood.isNotEmpty) {
          moodCounts[entry.mood] = (moodCounts[entry.mood] ?? 0) + 1;
        }
      }

      if (moodCounts.isEmpty) {
        return _buildEmptyStateCard(
          isDark,
          'Mood Analytics',
          'Add mood tags to your entries to see your emotional trends!',
          Icons.mood,
        );
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
          _sectionHeader(
            isDark,
            title: 'Mood Analytics',
            icon: Icons.bar_chart,
            caption: 'Your last 7 days mood trend',
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkGrey : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.cyan.withValues(alpha: 0.3),
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
                }),
                const SizedBox(height: 8),
                Divider(color: Colors.cyan.withValues(alpha: 0.2)),
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

  Widget _buildEmptyStateCard(
    bool isDark,
    String title,
    String message,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.cyan,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkGrey : AppTheme.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.cyan.withValues(alpha: 0.1),
            ),
          ),
          child: Column(
            children: [
              Icon(icon, size: 48, color: Colors.cyan.withValues(alpha: 0.2)),
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
