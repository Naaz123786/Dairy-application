import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_quill/flutter_quill.dart';
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
  late final QuillController _quillController;
  final _focusNode = FocusNode();
  final _scrollController = ScrollController();
  DateTime _selectedDate = DateTime.now();
  String? _selectedMood;
  List<String> _attachedImages = [];
  final List<String> _tags = [];
  final _tagController = TextEditingController();
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
    _initQuillController();
    if (widget.entry != null) {
      _titleController.text = widget.entry!.title;
      _selectedMood = widget.entry!.mood;
      _selectedDate = widget.entry!.date;
      _attachedImages = List.from(widget.entry!.images);
      _tags.addAll(widget.entry!.tags);
    }
  }

  void _initQuillController() {
    if (widget.entry != null && widget.entry!.content.isNotEmpty) {
      try {
        final content = widget.entry!.content;
        if (content.trim().startsWith('[') || content.trim().startsWith('{')) {
          final doc = Document.fromJson(jsonDecode(content));
          _quillController = QuillController(
            document: doc,
            selection: const TextSelection.collapsed(offset: 0),
          );
        } else {
          // Plain text fallback
          final doc = Document()..insert(0, content);
          _quillController = QuillController(
            document: doc,
            selection: const TextSelection.collapsed(offset: 0),
          );
        }
      } catch (e) {
        debugPrint('Error parsing quill content: $e');
        final doc = Document()..insert(0, widget.entry!.content);
        _quillController = QuillController(
          document: doc,
          selection: const TextSelection.collapsed(offset: 0),
        );
      }
    } else {
      _quillController = QuillController.basic();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _quillController.dispose();
    _tagController.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        String imagePath = image.path;

        if (kIsWeb) {
          // On Web, we must convert the image to Base64 for persistence
          // because blob URLs are temporary and expires on reload.
          final bytes = await image.readAsBytes();
          imagePath = 'data:image/png;base64,${base64Encode(bytes)}';
        }

        setState(() {
          _attachedImages.add(imagePath);
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      if (!mounted) return;
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
            Text(
              'Tags (Optional)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? AppTheme.white : AppTheme.black,
              ),
            ),
            const SizedBox(height: 12),
            _buildTagInput(isDark),
            const SizedBox(height: 24),
            const Text(
              'How are you feeling?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildMoodSelector(isDark),
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

  // ... (Other build methods stay same)

  Widget _buildTagInput(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _tagController,
          decoration: InputDecoration(
            hintText: 'Add a tag (e.g. travel, food)...',
            prefixIcon: const Icon(Icons.label_outline),
            suffixIcon: IconButton(
              icon: const Icon(Icons.add_circle),
              onPressed: _addTag,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            filled: true,
            fillColor: isDark
                ? AppTheme.darkGrey
                : AppTheme.black.withValues(alpha: 0.05),
          ),
          onSubmitted: (_) => _addTag(),
        ),
        if (_tags.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: _tags.map((tag) {
              return Chip(
                label: Text(tag),
                onDeleted: () {
                  setState(() {
                    _tags.remove(tag);
                  });
                },
                deleteIcon: const Icon(Icons.close, size: 14),
                backgroundColor: isDark
                    ? AppTheme.white.withValues(alpha: 0.1)
                    : AppTheme.black.withValues(alpha: 0.05),
                labelStyle: TextStyle(
                  color: isDark ? AppTheme.white : AppTheme.black,
                  fontSize: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: isDark
                        ? AppTheme.white.withValues(alpha: 0.2)
                        : AppTheme.black.withValues(alpha: 0.1),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  void _addTag() {
    final text = _tagController.text.trim().toLowerCase();
    if (text.isNotEmpty) {
      if (!_tags.contains(text)) {
        setState(() {
          _tags.add(text);
          _tagController.clear();
        });
      } else {
        _tagController.clear();
      }
    }
  }

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
                ? AppTheme.white.withValues(alpha: 0.5)
                : AppTheme.black.withValues(alpha: 0.5),
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
                          ? AppTheme.white.withValues(alpha: 0.5)
                          : AppTheme.black.withValues(alpha: 0.5),
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
            isDark ? AppTheme.darkGrey : AppTheme.black.withValues(alpha: 0.05),
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
                      : AppTheme.black.withValues(alpha: 0.05)),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? (isDark ? AppTheme.white : AppTheme.black)
                    : (isDark
                        ? AppTheme.white.withValues(alpha: 0.1)
                        : AppTheme.black.withValues(alpha: 0.1)),
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
    return Column(
      children: [
        // Quill Toolbar
        Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkGrey : AppTheme.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? AppTheme.white.withValues(alpha: 0.1)
                  : AppTheme.black.withValues(alpha: 0.1),
            ),
          ),
          child: QuillSimpleToolbar(
            controller: _quillController,
            config: QuillSimpleToolbarConfig(
              showFontFamily: false,
              showFontSize: false,
              showBoldButton: true,
              showItalicButton: true,
              showUnderLineButton: true,
              showStrikeThrough: false,
              showColorButton: true,
              showBackgroundColorButton: false,
              showListNumbers: true,
              showListBullets: true,
              showListCheck: true,
              showCodeBlock: false,
              showQuote: true,
              showIndent: false,
              showLink: true,
              showUndo: true,
              showRedo: true,
              showAlignmentButtons: false,
              showSearchButton: false,
              showSubscript: false,
              showSuperscript: false,
            ),
          ),
        ),
        Container(
          constraints: const BoxConstraints(
            minHeight: 200,
            maxHeight: 400,
          ),
          decoration: BoxDecoration(
            color: isDark
                ? AppTheme.darkGrey
                : AppTheme.black.withValues(alpha: 0.02),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark
                  ? AppTheme.white.withValues(alpha: 0.1)
                  : AppTheme.black.withValues(alpha: 0.1),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Rich Editor
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: QuillEditor.basic(
                    controller: _quillController,
                    focusNode: _focusNode,
                    scrollController: _scrollController,
                    config: QuillEditorConfig(
                      placeholder: 'Dear Diary,\n\nToday was...',
                      expands: false,
                      padding: EdgeInsets.zero,
                      autoFocus: false,
                      scrollable: true,
                    ),
                  ),
                ),
              ),

              // Divider
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Divider(
                  height: 1,
                  color: isDark
                      ? AppTheme.white.withValues(alpha: 0.05)
                      : AppTheme.black.withValues(alpha: 0.05),
                ),
              ),

              // Media Section Header within the box
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Media',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppTheme.white.withValues(alpha: 0.5)
                            : AppTheme.black.withValues(alpha: 0.5),
                      ),
                    ),
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDark ? AppTheme.white : AppTheme.black,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.add_photo_alternate_rounded,
                              size: 14,
                              color: isDark ? AppTheme.black : AppTheme.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Add',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppTheme.black : AppTheme.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Images Grid View
              if (_attachedImages.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildMediaGrid(context, isDark),
                )
              else
                const SizedBox(height: 12),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMediaGrid(BuildContext context, bool isDark) {
    final count = _attachedImages.length;
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = width * 0.6;

          if (count == 1) {
            return _buildImageItem(context, 0, width, height, isDark);
          } else if (count == 2) {
            return SizedBox(
              height: height,
              child: Row(
                children: [
                  Expanded(
                      child: _buildImageItem(context, 0, null, height, isDark)),
                  const SizedBox(width: 4),
                  Expanded(
                      child: _buildImageItem(context, 1, null, height, isDark)),
                ],
              ),
            );
          } else if (count == 3) {
            return SizedBox(
              height: height,
              child: Row(
                children: [
                  Expanded(
                      child: _buildImageItem(context, 0, null, height, isDark)),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(
                            child: _buildImageItem(
                                context, 1, null, null, isDark)),
                        const SizedBox(height: 4),
                        Expanded(
                            child: _buildImageItem(
                                context, 2, null, null, isDark)),
                      ],
                    ),
                  ),
                ],
              ),
            );
          } else {
            return SizedBox(
              height: height,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(
                            child: _buildImageItem(
                                context, 0, null, null, isDark)),
                        const SizedBox(height: 4),
                        Expanded(
                            child: _buildImageItem(
                                context, 1, null, null, isDark)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(
                            child: _buildImageItem(
                                context, 2, null, null, isDark)),
                        const SizedBox(height: 4),
                        Stack(
                          fit: StackFit.expand,
                          children: [
                            _buildImageItem(context, 3, null, null, isDark),
                            if (count > 4)
                              Container(
                                color: Colors.black54,
                                child: Center(
                                  child: Text(
                                    '+${count - 4}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  ImageProvider _getImageProvider(String path) {
    if (path.startsWith('data:image')) {
      final base64String = path.split(',').last;
      return MemoryImage(base64Decode(base64String));
    } else if (path.startsWith('http')) {
      return NetworkImage(path);
    } else {
      if (kIsWeb) {
        return NetworkImage(path);
      }
      return FileImage(File(path));
    }
  }

  Widget _buildImageItem(
    BuildContext context,
    int index,
    double? width,
    double? height,
    bool isDark,
  ) {
    final path = _attachedImages[index];

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: () => _showFullScreenImage(context, index),
            child: Image(
              image: _getImageProvider(path),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.grey[300],
                child: const Icon(Icons.error_outline),
              ),
            ),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => _removeImage(index),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 12, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  void _showFullScreenImage(BuildContext context, int initialIndex) {
    final PageController controller = PageController(initialPage: initialIndex);

    showDialog(
      context: context,
      builder: (context) => Dialog.fullscreen(
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            PageView.builder(
              controller: controller,
              itemCount: _attachedImages.length,
              itemBuilder: (context, index) {
                final path = _attachedImages[index];
                return InteractiveViewer(
                  child: Center(
                    child: Image(
                      image: _getImageProvider(path),
                      errorBuilder: (context, error, stackTrace) => Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.broken_image,
                              color: Colors.white, size: 64),
                          const SizedBox(height: 16),
                          Text(
                            'Image not found locally.\n(It might be on another device)',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7)),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Align(
                alignment: Alignment.center,
                child: AnimatedBuilder(
                  animation: controller,
                  builder: (context, child) {
                    final currentPage = controller.hasClients
                        ? controller.page?.round()
                        : initialIndex;
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${(currentPage ?? 0) + 1} / ${_attachedImages.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveEntry() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title')),
      );
      return;
    }

    // Convert Quill document to JSON string
    final contentJson =
        jsonEncode(_quillController.document.toDelta().toJson());

    final entry = DiaryEntry(
      id: widget.entry?.id ?? const Uuid().v4(),
      title: _titleController.text,
      content: contentJson,
      date: _selectedDate,
      mood: _selectedMood ?? '',
      createdAt: widget.entry?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
      images:
          _attachedImages, // Assuming _images should be _attachedImages based on context
      tags: _tags,
    );

    context.read<DiaryBloc>().add(
          widget.entry == null ? AddDiaryEntry(entry) : UpdateDiaryEntry(entry),
        );

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
