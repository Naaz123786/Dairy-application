import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../bloc/reminder_bloc.dart';
import '../../domain/entities/reminder.dart';
import '../../core/theme/app_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/routes/app_routes.dart';

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
      if (reminder.category != 'calendar' && reminder.category != 'birthday') {
        return false;
      }

      if (reminder.recurrenceType == 'Yearly') {
        return reminder.scheduledTime.month == day.month &&
            reminder.scheduledTime.day == day.day;
      }
      return isSameDay(reminder.scheduledTime, day);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Reminders & Birthdays',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.cyan,
          ),
        ),
        actions: const [],
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'calendar_fab',
        onPressed: () {
          final user = FirebaseAuth.instance.currentUser;
          if (user == null) {
            Navigator.pushNamed(context, AppRoutes.login);
            return;
          }
          _showReminderDialog(context);
        },
        label: const Text('Add Birthday'),
        icon: const Icon(Icons.cake),
        backgroundColor: Colors.cyan,
        foregroundColor: Colors.white,
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
              Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkGrey : AppTheme.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark
                        ? Colors.cyan.withOpacity(0.3)
                        : Colors.cyan.withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: TableCalendar<Reminder>(
                    firstDay: DateTime.utc(2020, 10, 16),
                    lastDay: DateTime.utc(2030, 3, 14),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    eventLoader: (day) =>
                        _getRemindersForDay(day, allReminders),
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                    },
                    calendarStyle: CalendarStyle(
                      todayDecoration: BoxDecoration(
                        color: isDark ? Colors.grey[700] : Colors.grey[300],
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: BoxDecoration(
                        color: isDark ? AppTheme.white : AppTheme.black,
                        shape: BoxShape.circle,
                      ),
                      markerDecoration: BoxDecoration(
                        color: isDark ? AppTheme.white : AppTheme.black,
                        shape: BoxShape.circle,
                      ),
                      todayTextStyle: TextStyle(
                        color: isDark ? AppTheme.white : AppTheme.black,
                        fontWeight: FontWeight.bold,
                      ),
                      selectedTextStyle: TextStyle(
                        color: isDark ? AppTheme.black : AppTheme.white,
                        fontWeight: FontWeight.bold,
                      ),
                      weekendTextStyle: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                    headerStyle: const HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      titleTextStyle: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Icon(Icons.event, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat.yMMMMd().format(_selectedDay!),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildReminderList(selectedReminders, isDark),
            ],
          );
        },
      ),
    );
  }

  Widget _buildReminderList(List<Reminder> reminders, bool isDark) {
    if (reminders.isEmpty) {
      return Expanded(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.darkGrey : AppTheme.lightGrey,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.cake_outlined,
                    size: 48,
                    color: Colors.cyan,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'No events for this day',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap + to add a birthday or reminder',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 80, left: 16, right: 16),
        itemCount: reminders.length,
        itemBuilder: (context, index) {
          final reminder = reminders[index];
          return _buildReminderCard(context, reminder, isDark);
        },
      ),
    );
  }

  Widget _buildReminderCard(
    BuildContext context,
    Reminder reminder,
    bool isDark,
  ) {
    final isBirthday = reminder.category == 'birthday' ||
        reminder.isRecurring ||
        reminder.recurrenceType == 'Yearly' ||
        reminder.title.toLowerCase().contains('birthday');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
            if (FirebaseAuth.instance.currentUser == null) {
              Navigator.pushNamed(context, AppRoutes.login);
              return;
            }
            _showReminderDialog(context, reminder: reminder);
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.white : AppTheme.black,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isBirthday ? Icons.cake : Icons.event,
                    color: isBirthday
                        ? Colors.cyan
                        : (isDark ? AppTheme.black : AppTheme.white),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reminder.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isBirthday
                            ? '🎂 Birthday'
                            : DateFormat.jm().format(reminder.scheduledTime),
                        style: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                  onPressed: () {
                    if (FirebaseAuth.instance.currentUser == null) {
                      Navigator.pushNamed(context, AppRoutes.login);
                      return;
                    }
                    _showReminderDialog(context, reminder: reminder);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () {
                    if (FirebaseAuth.instance.currentUser == null) {
                      Navigator.pushNamed(context, AppRoutes.login);
                      return;
                    }
                    context.read<ReminderBloc>().add(
                          DeleteReminder(reminder.id),
                        );
                  },
                ),
              ],
            ),
          ),
        ),
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
        DateTime selectedDate = reminder?.scheduledTime ?? DateTime.now();
        bool isBirthday = reminder?.category == 'birthday' || reminder == null;
        bool isYearlyRepeat = reminder?.isRecurring ?? true;
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.white : AppTheme.black,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.cake,
                      color: Colors.cyan,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(reminder == null ? 'Add Birthday' : 'Edit Birthday'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      hintText: "e.g. Naaz",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Event Type',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: const Text('🎂 Birthday'),
                          selected: isBirthday,
                          onSelected: (val) =>
                              setState(() => isBirthday = true),
                          selectedColor: Colors.cyan.withOpacity(0.2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ChoiceChip(
                          label: const Text('🔔 Reminder'),
                          selected: !isBirthday,
                          onSelected: (val) =>
                              setState(() => isBirthday = false),
                          selectedColor: Colors.cyan.withOpacity(0.2),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(1900),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() => selectedDate = picked);
                      }
                    },
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Date',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        suffixIcon: const Icon(Icons.calendar_today),
                      ),
                      child: Text(DateFormat.yMMMd().format(selectedDate)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (isBirthday)
                    SwitchListTile(
                      title: const Text('Repeat Yearly'),
                      subtitle: const Text('Notify every year on this date'),
                      value: isYearlyRepeat,
                      activeColor: Colors.cyan,
                      onChanged: (val) => setState(() => isYearlyRepeat = val),
                      contentPadding: EdgeInsets.zero,
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
                        isRecurring: isBirthday && isYearlyRepeat,
                        recurrenceType:
                            (isBirthday && isYearlyRepeat) ? 'Yearly' : 'None',
                        category: isBirthday ? 'birthday' : 'calendar',
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
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.cyan,
                    foregroundColor: Colors.white,
                  ),
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
