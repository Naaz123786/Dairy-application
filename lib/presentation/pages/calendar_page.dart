import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../bloc/reminder_bloc.dart';
import '../../domain/entities/reminder.dart';

class CalendarPage extends StatelessWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const CalendarView();
  }
}

class CalendarView extends StatefulWidget {
  const CalendarView({super.key});

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  List<Reminder> _getRemindersForDay(
    DateTime day,
    List<Reminder> allReminders,
  ) {
    return allReminders.where((reminder) {
      // Filter out routines and exams, keep only calendar/birthdays
      if (reminder.category != 'calendar') return false;

      if (reminder.recurrenceType == 'Yearly') {
        return reminder.scheduledTime.month == day.month &&
            reminder.scheduledTime.day == day.day;
      }
      return isSameDay(reminder.scheduledTime, day);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reminders & Birthdays')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showReminderDialog(context),
        label: const Text('Add Reminder'),
        icon: const Icon(Icons.add_alarm),
      ),
      body: BlocBuilder<ReminderBloc, ReminderState>(
        builder: (context, state) {
          List<Reminder> allReminders = [];
          if (state is ReminderLoaded) {
            allReminders = state.reminders;
          }

          final selectedReminders = _getRemindersForDay(
            _selectedDay!,
            allReminders,
          );

          return Column(
            children: [
              TableCalendar<Reminder>(
                firstDay: DateTime.utc(2020, 10, 16),
                lastDay: DateTime.utc(2030, 3, 14),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                eventLoader: (day) => _getRemindersForDay(day, allReminders),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                calendarStyle: CalendarStyle(
                  markerDecoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              _buildReminderList(selectedReminders),
            ],
          );
        },
      ),
    );
  }

  Widget _buildReminderList(List<Reminder> reminders) {
    if (reminders.isEmpty) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.event, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 8),
              Text(
                'No reminders for this day',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }
    return Expanded(
      child: ListView.builder(
        itemCount: reminders.length,
        itemBuilder: (context, index) {
          final reminder = reminders[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: reminder.recurrenceType == 'Yearly'
                    ? Colors.pink.shade100
                    : Colors.blue.shade100,
                child: Icon(
                  reminder.recurrenceType == 'Yearly'
                      ? Icons.cake
                      : Icons.notifications,
                  color: reminder.recurrenceType == 'Yearly'
                      ? Colors.pink
                      : Colors.blue,
                ),
              ),
              title: Text(
                reminder.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                reminder.recurrenceType == 'Yearly'
                    ? 'Birthday'
                    : DateFormat.jm().format(reminder.scheduledTime),
              ),
              onTap: () => _showReminderDialog(context, reminder: reminder),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () {
                  context.read<ReminderBloc>().add(DeleteReminder(reminder.id));
                },
              ),
            ),
          );
        },
      ),
    );
  }

  void _showReminderDialog(BuildContext parentContext, {Reminder? reminder}) {
    showDialog(
      context: parentContext,
      builder: (context) {
        final titleController = TextEditingController(
          text: reminder?.title ?? '',
        );
        DateTime selectedDate =
            reminder?.scheduledTime ?? _selectedDay ?? DateTime.now();
        bool isBirthday = reminder?.isRecurring ?? false;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(reminder == null ? 'Add Reminder' : 'Edit Reminder'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title (e.g. Mom\'s Birthday)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Is this a Birthday?'),
                    subtitle: const Text('Repeats yearly'),
                    value: isBirthday,
                    onChanged: (val) => setState(() => isBirthday = val),
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() => selectedDate = picked);
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Date',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
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
                        isRecurring: isBirthday,
                        recurrenceType: isBirthday ? 'Yearly' : 'None',
                        category: 'calendar',
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
