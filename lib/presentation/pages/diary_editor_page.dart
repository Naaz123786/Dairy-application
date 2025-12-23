import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/diary_entry.dart';
import '../bloc/diary_bloc.dart';

class DiaryEditorPage extends StatefulWidget {
  final DiaryEntry? entry;

  const DiaryEditorPage({super.key, this.entry});

  @override
  State<DiaryEditorPage> createState() => _DiaryEditorPageState();
}

class _DiaryEditorPageState extends State<DiaryEditorPage> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String? _selectedMood;
  final List<String> _moods = [
    'Happy',
    'Sad',
    'Excited',
    'Tired',
    'Neutral',
    'Angry',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.entry != null) {
      _titleController.text = widget.entry!.title;
      _contentController.text = widget.entry!.content;
      _selectedMood = widget.entry!.mood;
      _selectedDate = widget.entry!.date;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.entry == null ? 'New Entry' : 'Edit Entry'),
        actions: [
          IconButton(icon: const Icon(Icons.check), onPressed: _saveEntry),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildDatePicker(),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _moods.length,
                itemBuilder: (context, index) {
                  final mood = _moods[index];
                  final isSelected = mood == _selectedMood;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(mood),
                      selected: isSelected,

                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedMood = mood;
                          } else {
                            _selectedMood = null;
                          }
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: _contentController,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: const InputDecoration(
                  labelText: 'Dear Diary...',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveEntry() {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in both title and content')),
      );
      return;
    }

    final entry = DiaryEntry(
      id: widget.entry?.id ?? const Uuid().v4(),
      title: _titleController.text,
      content: _contentController.text,
      date: _selectedDate,
      mood: _selectedMood ?? '',
      createdAt: widget.entry?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    context.read<DiaryBloc>().add(AddDiaryEntry(entry));
    Navigator.pop(context);
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: _pickDate,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).colorScheme.outline),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_month,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Text(
              DateFormat('EEEE, d MMMM y').format(_selectedDate),
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
            ),
            const Spacer(),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2050),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }
}
