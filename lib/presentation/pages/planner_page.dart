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
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'My Planner',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.cyan,
            ),
          ),
          elevation: 0,
          bottom: TabBar(
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorColor: Colors.cyan,
            labelColor: Colors.cyan,
            unselectedLabelColor: Colors.grey,
            tabs: const [
              Tab(icon: Icon(Icons.schedule), text: 'Daily Routine'),
              Tab(icon: Icon(Icons.school), text: 'Exams'),
            ],
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
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
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
                            color: boxColor.withOpacity(0.1),
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
                            color: boxColor.withOpacity(0.1),
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
                                  color: leadingColor.withOpacity(0.7),
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
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
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
      color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
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
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              if (customLeading != null)
                customLeading
              else if (icon != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[800] : Colors.grey[200],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon),
                ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailingActions != null) ...trailingActions,
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget _buildEmptyState(String message, {IconData icon = Icons.list_alt}) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 64, color: Colors.grey),
        const SizedBox(height: 16),
        Text(message, style: const TextStyle(color: Colors.grey)),
      ],
    ),
  );
}
