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
import '../../core/util/guest_limits.dart';

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

  BoxDecoration _premiumCardDecoration(
    bool isDark, {
    Color accent = Colors.cyan,
    double radius = 24,
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
        title: const Text('Calendar'),
        actions: const [],
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'calendar_fab',
        onPressed: () => _tryAddCalendarReminder(context),
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
                decoration: _premiumCardDecoration(isDark, radius: 24),
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
                    headerStyle: HeaderStyle(
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
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: Colors.cyan.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.cyan.withValues(alpha: 0.20),
                        ),
                      ),
                      child:
                          const Icon(Icons.event, size: 18, color: Colors.cyan),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat('EEEE, d MMMM').format(_selectedDay!),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Events & birthdays',
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ],
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
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: () => _tryAddCalendarReminder(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Add event'),
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

    final accent = isBirthday ? Colors.cyan : Colors.purple;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: _premiumCardDecoration(isDark, accent: accent, radius: 22),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showReminderDialog(context, reminder: reminder),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        accent.withValues(alpha: 0.30),
                        accent.withValues(alpha: 0.12),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: accent.withValues(alpha: 0.22)),
                  ),
                  child: Icon(
                    isBirthday ? Icons.cake : Icons.event,
                    color: accent,
                    size: 22,
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
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isBirthday
                            ? '🎂 Birthday'
                            : DateFormat.jm().format(reminder.scheduledTime),
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
                _buildActionChip(
                  icon: Icons.edit_outlined,
                  label: 'Edit',
                  color: Colors.blue,
                  onTap: () => _showReminderDialog(context, reminder: reminder),
                ),
                const SizedBox(width: 10),
                _buildActionChip(
                  icon: Icons.delete_outline,
                  label: 'Delete',
                  color: Colors.red,
                  onTap: () => context.read<ReminderBloc>().add(
                        DeleteReminder(reminder.id),
                      ),
                ),
              ],
            ),
          ),
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

  void _tryAddCalendarReminder(BuildContext context) {
    if (FirebaseAuth.instance.currentUser != null) {
      _showReminderDialog(context);
      return;
    }
    final state = context.read<ReminderBloc>().state;
    if (state is ReminderLoaded) {
      final birthdayCount =
          state.reminders.where((r) => r.category == 'birthday').length;
      final calendarCount =
          state.reminders.where((r) => r.category == 'calendar').length;
      if (birthdayCount >= GuestLimits.maxBirthdayEntries &&
          calendarCount >= GuestLimits.maxCalendarEntries) {
        _showGuestLimitDialog(
          context,
          'You can add up to ${GuestLimits.maxBirthdayEntries} birthdays and ${GuestLimits.maxCalendarEntries} reminders as guest. Login to add more.',
        );
        return;
      }
    }
    _showReminderDialog(context);
  }

  void _showGuestLimitDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Login to add more'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushNamed(context, AppRoutes.login);
            },
            child: const Text('Login'),
          ),
        ],
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
                          selectedColor: Colors.cyan.withValues(alpha: 0.2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ChoiceChip(
                          label: const Text('🔔 Reminder'),
                          selected: !isBirthday,
                          onSelected: (val) =>
                              setState(() => isBirthday = false),
                          selectedColor: Colors.cyan.withValues(alpha: 0.2),
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
                        setState(() => selectedDate = DateTime(
                          picked.year, picked.month, picked.day,
                          selectedDate.hour, selectedDate.minute,
                        ));
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
                  if (!isBirthday) ...[
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay(
                            hour: selectedDate.hour,
                            minute: selectedDate.minute,
                          ),
                        );
                        if (picked != null) {
                          setState(() => selectedDate = DateTime(
                            selectedDate.year, selectedDate.month, selectedDate.day,
                            picked.hour, picked.minute,
                          ));
                        }
                      },
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Time',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          suffixIcon: const Icon(Icons.access_time),
                        ),
                        child: Text(DateFormat.jm().format(selectedDate)),
                      ),
                    ),
                  ],
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
                    if (titleController.text.isEmpty) return;
                    if (reminder == null &&
                        FirebaseAuth.instance.currentUser == null) {
                      final state =
                          parentContext.read<ReminderBloc>().state;
                      if (state is ReminderLoaded) {
                        final birthdayCount = state.reminders
                            .where((r) => r.category == 'birthday')
                            .length;
                        final calendarCount = state.reminders
                            .where((r) => r.category == 'calendar')
                            .length;
                        if (isBirthday &&
                            birthdayCount >=
                                GuestLimits.maxBirthdayEntries) {
                          Navigator.pop(context);
                          _showGuestLimitDialog(
                            parentContext,
                            'You can add up to ${GuestLimits.maxBirthdayEntries} birthdays as guest. Login to add more.',
                          );
                          return;
                        }
                        if (!isBirthday &&
                            calendarCount >=
                                GuestLimits.maxCalendarEntries) {
                          Navigator.pop(context);
                          _showGuestLimitDialog(
                            parentContext,
                            'You can add up to ${GuestLimits.maxCalendarEntries} reminders as guest. Login to add more.',
                          );
                          return;
                        }
                      }
                    }
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
