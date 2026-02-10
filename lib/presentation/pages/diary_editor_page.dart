import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/entities/diary_entry.dart';
import '../bloc/diary_bloc.dart';
import '../../core/theme/app_theme.dart';

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
  List<String> _attachedImages = [];
  final ImagePicker _picker = ImagePicker();

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
      _attachedImages = List.from(widget.entry!.images);
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _attachedImages.add(image.path);
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e')),
      );
    }
  }

  void _removeImage(int index) {
    setState(() {
      _attachedImages.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.entry == null ? 'New Entry' : 'Edit Entry',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: FilledButton.icon(
              onPressed: _saveEntry,
              icon: const Icon(Icons.check, size: 20),
              label: const Text('Save'),
              style: FilledButton.styleFrom(
                backgroundColor: isDark ? AppTheme.white : AppTheme.black,
                foregroundColor: isDark ? AppTheme.black : AppTheme.white,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDatePicker(isDark),
            const SizedBox(height: 24),
            _buildTitleField(isDark),
            const SizedBox(height: 24),
            const Text(
              'How are you feeling?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildMoodSelector(isDark),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Attachments',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.add_photo_alternate),
                  label: const Text('Add Photo'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_attachedImages.isNotEmpty) _buildImageGrid(),
            const SizedBox(height: 24),
            const Text(
              'Write your thoughts',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildContentField(isDark),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildImageGrid() {
    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _attachedImages.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final path = _attachedImages[index];
          return Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: FileImage(File(path)),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                top: -8,
                right: -8,
                child: GestureDetector(
                  onTap: () => _removeImage(index),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child:
                        const Icon(Icons.close, size: 14, color: Colors.white),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ... (Other build methods stay same)

  Widget _buildDatePicker(bool isDark) {
    return InkWell(
      onTap: _pickDate,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkGrey : AppTheme.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? AppTheme.white.withOpacity(0.5)
                : AppTheme.black.withOpacity(0.5),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.white : AppTheme.black,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.calendar_today,
                color: isDark ? AppTheme.black : AppTheme.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Date',
                    style: TextStyle(
                      color: isDark
                          ? AppTheme.white.withOpacity(0.5)
                          : AppTheme.black.withOpacity(0.5),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('EEEE, d MMMM y').format(_selectedDate),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleField(bool isDark) {
    return TextField(
      controller: _titleController,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: 'Title',
        hintText: 'Give your entry a title...',
        prefixIcon: const Icon(Icons.title),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        filled: true,
        fillColor:
            isDark ? AppTheme.darkGrey : AppTheme.black.withOpacity(0.05),
      ),
    );
  }

  Widget _buildMoodSelector(bool isDark) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _moods.map((mood) {
        final isSelected = mood == _selectedMood;

        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedMood = null;
              } else {
                _selectedMood = mood;
              }
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? (isDark ? AppTheme.white : AppTheme.black)
                  : (isDark
                      ? AppTheme.darkGrey
                      : AppTheme.black.withOpacity(0.05)),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? (isDark ? AppTheme.white : AppTheme.black)
                    : (isDark
                        ? AppTheme.white.withOpacity(0.1)
                        : AppTheme.black.withOpacity(0.1)),
                width: 2,
              ),
            ),
            child: Text(
              mood,
              style: TextStyle(
                color: isSelected
                    ? (isDark ? AppTheme.black : AppTheme.white)
                    : (isDark ? AppTheme.white : AppTheme.black),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildContentField(bool isDark) {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkGrey : AppTheme.black.withOpacity(0.02),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? AppTheme.white.withOpacity(0.1)
              : AppTheme.black.withOpacity(0.1),
        ),
      ),
      child: TextField(
        controller: _contentController,
        maxLines: null,
        expands: true,
        textAlignVertical: TextAlignVertical.top,
        style: const TextStyle(fontSize: 16, height: 1.5),
        decoration: InputDecoration(
          hintText: 'Dear Diary,\n\nToday was...',
          hintStyle: TextStyle(
            color: isDark
                ? AppTheme.white.withOpacity(0.3)
                : AppTheme.black.withOpacity(0.3),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(20),
        ),
      ),
    );
  }

  void _saveEntry() {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please fill in both title and content'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
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
      images: _attachedImages,
    );

    context.read<DiaryBloc>().add(AddDiaryEntry(entry));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Entry saved successfully! 📝'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );

    Navigator.pop(context);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2050),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  onSurface: Theme.of(context).brightness == Brightness.dark
                      ? AppTheme.white
                      : AppTheme.black,
                ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }
}
