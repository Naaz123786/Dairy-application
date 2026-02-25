import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../bloc/reminder_bloc.dart';
import '../../domain/entities/reminder.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/routes/app_routes.dart';

class PlannerPage extends StatelessWidget {
  const PlannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlannerView();
  }
}

class PlannerView extends StatelessWidget {
  const PlannerView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Planner'),
          actions: const [
            SizedBox(width: 8),
          ],
          elevation: 0,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(64),
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF161616) : Colors.white,
                borderRadius: BorderRadius.circular(18),
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
                ],
              ),
              child: TabBar(
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: LinearGradient(
                    colors: [
                      Colors.cyan.withValues(alpha: 0.95),
                      Colors.lightBlueAccent.withValues(alpha: 0.95),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                labelColor: Colors.white,
                unselectedLabelColor:
                    isDark ? Colors.white70 : Colors.black87,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                tabs: const [
                  Tab(icon: Icon(Icons.schedule), text: 'Routine'),
                  Tab(icon: Icon(Icons.school), text: 'Exams'),
                ],
              ),
            ),
          ),
        ),
        body: const TabBarView(children: [RoutineTab(), ExamsTab()]),
      ),
    );
  }
}

class RoutineTab extends StatelessWidget {
  const RoutineTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        BlocBuilder<ReminderBloc, ReminderState>(
          builder: (context, state) {
            if (state is ReminderLoaded) {
              final routines =
                  state.reminders.where((r) => r.category == 'routine').toList()
                    ..sort(
                      (a, b) =>
                          a.scheduledTime.hour.compareTo(b.scheduledTime.hour),
                    );

              if (routines.isEmpty) {
                return _buildEmptyState(
                  'No routines yet. Add your daily habits!',
                  icon: Icons.schedule,
                  actionLabel: 'Add Routine',
                  onAction: () {
                    final user = FirebaseAuth.instance.currentUser;
                    if (user == null) {
                      Navigator.pushNamed(context, AppRoutes.login);
                      return;
                    }
                    _showRoutineDialog(context);
                  },
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.only(bottom: 80),
                itemCount: routines.length,
                itemBuilder: (context, index) {
                  final routine = routines[index];
                  return _buildGradientCard(
                    context,
                    title: routine.title,
                    subtitle: DateFormat.jm().format(routine.scheduledTime),
                    icon: Icons.access_time,
                    onTap: () {
                      if (FirebaseAuth.instance.currentUser == null) {
                        Navigator.pushNamed(context, AppRoutes.login);
                        return;
                      }
                      _showRoutineDialog(context, reminder: routine);
                    },
                    onDelete: () {
                      if (FirebaseAuth.instance.currentUser == null) {
                        Navigator.pushNamed(context, AppRoutes.login);
                        return;
                      }
                      context.read<ReminderBloc>().add(
                            DeleteReminder(routine.id),
                          );
                    },
                    trailingActions: [
                      _buildActionChip(
                        icon: Icons.edit,
                        label: 'Edit',
                        color: Colors.blue,
                        onTap: () {
                          if (FirebaseAuth.instance.currentUser == null) {
                            Navigator.pushNamed(context, AppRoutes.login);
                            return;
                          }
                          _showRoutineDialog(context, reminder: routine);
                        },
                      ),
                    ],
                  );
                },
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton.extended(
            heroTag: 'planner_routine_fab',
            onPressed: () {
              final user = FirebaseAuth.instance.currentUser;
              if (user == null) {
                Navigator.pushNamed(context, AppRoutes.login);
                return;
              }
              _showRoutineDialog(context);
            },
            label: const Text('Add Routine'),
            icon: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }

  void _showRoutineDialog(BuildContext parentContext, {Reminder? reminder}) {
    final titleController = TextEditingController(text: reminder?.title ?? '');
    TimeOfDay selectedTime = reminder != null
        ? TimeOfDay(
            hour: reminder.scheduledTime.hour,
            minute: reminder.scheduledTime.minute,
          )
        : TimeOfDay.now();

    showDialog(
      context: parentContext,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                reminder == null ? 'New Daily Routine' : 'Edit Routine',
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Task Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: selectedTime,
                      );
                      if (picked != null) {
                        setState(() => selectedTime = picked);
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Time',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.access_time),
                      ),
                      child: Text(selectedTime.format(context)),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    if (titleController.text.isNotEmpty) {
                      final now = DateTime.now();
                      final dt = DateTime(
                        now.year,
                        now.month,
                        now.day,
                        selectedTime.hour,
                        selectedTime.minute,
                      );

                      final newReminder = Reminder(
                        id: reminder?.id ?? const Uuid().v4(),
                        title: titleController.text,
                        scheduledTime: dt,
                        category: 'routine',
                        isRecurring: true,
                        recurrenceType: 'Daily',
                      );

                      if (reminder == null) {
                        parentContext.read<ReminderBloc>().add(
                              AddReminder(newReminder),
                            );
                      } else {
                        parentContext.read<ReminderBloc>().add(
                              UpdateReminder(newReminder),
                            );
                      }
                      Navigator.pop(context);
                    }
                  },
                  child: Text(reminder == null ? 'Add' : 'Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class ExamsTab extends StatelessWidget {
  const ExamsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        BlocBuilder<ReminderBloc, ReminderState>(
          builder: (context, state) {
            if (state is ReminderLoaded) {
              final exams =
                  state.reminders.where((r) => r.category == 'exam').toList()
                    ..sort(
                      (a, b) => a.scheduledTime.compareTo(b.scheduledTime),
                    );

              if (exams.isEmpty) {
                return _buildEmptyState(
                  'No exams added. Good luck!',
                  icon: Icons.school,
                  actionLabel: 'Add Exam',
                  onAction: () {
                    final user = FirebaseAuth.instance.currentUser;
                    if (user == null) {
                      Navigator.pushNamed(context, AppRoutes.login);
                      return;
                    }
                    _showExamDialog(context);
                  },
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.only(bottom: 80),
                itemCount: exams.length,
                itemBuilder: (context, index) {
                  final exam = exams[index];
                  final daysLeft =
                      exam.scheduledTime.difference(DateTime.now()).inDays;
                  final isUrgent = daysLeft < 7;
                  final boxColor = isUrgent ? Colors.red : Colors.cyan;
                  final isDark =
                      Theme.of(context).brightness == Brightness.dark;
                  final leadingColor = isDark ? Colors.white : Colors.black;

                  return _buildGradientCard(
                    context,
                    title: exam.title,
                    subtitle: DateFormat.yMMMd().format(exam.scheduledTime),
                    customLeading: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: boxColor.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.school, color: boxColor, size: 20),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: boxColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '$daysLeft',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: leadingColor,
                                ),
                              ),
                              Text(
                                'Days',
                                style: TextStyle(
                                  fontSize: 8,
                                  color: leadingColor.withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                      if (FirebaseAuth.instance.currentUser == null) {
                        Navigator.pushNamed(context, AppRoutes.login);
                        return;
                      }
                      _showExamDialog(context, reminder: exam);
                    },
                    onDelete: () {
                      if (FirebaseAuth.instance.currentUser == null) {
                        Navigator.pushNamed(context, AppRoutes.login);
                        return;
                      }
                      context.read<ReminderBloc>().add(DeleteReminder(exam.id));
                    },
                    trailingActions: [
                      _buildActionChip(
                        icon: Icons.edit,
                        label: 'Edit',
                        color: Colors.blue,
                        onTap: () {
                          if (FirebaseAuth.instance.currentUser == null) {
                            Navigator.pushNamed(context, AppRoutes.login);
                            return;
                          }
                          _showExamDialog(context, reminder: exam);
                        },
                      ),
                    ],
                  );
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton.extended(
            heroTag: 'planner_exam_fab',
            onPressed: () {
              final user = FirebaseAuth.instance.currentUser;
              if (user == null) {
                Navigator.pushNamed(context, AppRoutes.login);
                return;
              }
              _showExamDialog(context);
            },
            label: const Text('Add Exam'),
            icon: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }

  void _showExamDialog(BuildContext parentContext, {Reminder? reminder}) {
    final titleController = TextEditingController(text: reminder?.title ?? '');
    DateTime selectedDate = reminder != null
        ? reminder.scheduledTime
        : DateTime.now().add(const Duration(days: 1));

    showDialog(
      context: parentContext,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(reminder == null ? 'New Exam' : 'Edit Exam'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Subject (e.g. Mathematics)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.school),
                    ),
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) {
                        setState(() => selectedDate = picked);
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Exam Date',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.event),
                      ),
                      child: Text(DateFormat.yMMMd().format(selectedDate)),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    if (titleController.text.isNotEmpty) {
                      final newReminder = Reminder(
                        id: reminder?.id ?? const Uuid().v4(),
                        title: titleController.text,
                        scheduledTime: selectedDate,
                        category: 'exam',
                        isRecurring: false,
                      );

                      if (reminder == null) {
                        parentContext.read<ReminderBloc>().add(
                              AddReminder(newReminder),
                            );
                      } else {
                        parentContext.read<ReminderBloc>().add(
                              UpdateReminder(newReminder),
                            );
                      }
                      Navigator.pop(context);
                    }
                  },
                  child: Text(reminder == null ? 'Add Exam' : 'Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

Widget _buildGradientCard(
  BuildContext context, {
  required String title,
  required String subtitle,
  IconData? icon,
  Widget? customLeading,
  required VoidCallback onTap,
  required VoidCallback onDelete,
  List<Widget>? trailingActions,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
          blurRadius: 18,
          offset: const Offset(0, 10),
        ),
        BoxShadow(
          color: Colors.cyan.withValues(alpha: isDark ? 0.06 : 0.05),
          blurRadius: 18,
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
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              if (customLeading != null)
                customLeading
              else if (icon != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.cyan.withValues(alpha: 0.25),
                        Colors.cyan.withValues(alpha: 0.10),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.cyan.withValues(alpha: 0.18),
                    ),
                  ),
                  child: Icon(icon, color: Colors.cyan),
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.60)
                            : Colors.black.withValues(alpha: 0.60),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailingActions != null) ...trailingActions,
              const SizedBox(width: 10),
              _buildActionChip(
                icon: Icons.delete_outline,
                label: 'Delete',
                color: Colors.red,
                onTap: onDelete,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget _buildEmptyState(
  String message, {
  IconData icon = Icons.list_alt,
  String? actionLabel,
  VoidCallback? onAction,
}) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 92,
            height: 92,
            decoration: BoxDecoration(
              color: Colors.cyan.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: Colors.cyan.withValues(alpha: 0.18),
              ),
            ),
            child: Icon(icon, size: 46, color: Colors.cyan),
          ),
          const SizedBox(height: 14),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.add),
              label: Text(actionLabel),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.cyan,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ],
      ),
    ),
  );
}

Widget _buildActionChip({
  required IconData icon,
  required String label,
  required Color color,
  required VoidCallback onTap,
}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(14),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    ),
  );
}
