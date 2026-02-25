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
import '../../core/util/json_utils.dart';

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
  bool _isToolbarExpanded = false;
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
    _focusNode.addListener(() {
      if (mounted) setState(() {});
    });
    if (widget.entry != null) {
      _titleController.text = widget.entry!.title;
      _selectedMood = widget.entry!.mood;
      _selectedDate = widget.entry!.date;
      _attachedImages = List.from(widget.entry!.images);
      _tags.addAll(widget.entry!.tags);
    }
  }

  void _initQuillController() {
    try {
      if (widget.entry != null && widget.entry!.content.isNotEmpty) {
        final content = widget.entry!.content;
        // Check if content is valid JSON for Quill
        if (content.trim().startsWith('[') || content.trim().startsWith('{')) {
          final decoded = JsonUtils.safeDecode(content);
          final ops = JsonUtils.getOps(decoded);

          if (ops != null) {
            final doc = Document.fromJson(ops);
            _quillController = QuillController(
              document: doc,
              selection: const TextSelection.collapsed(offset: 0),
            );
            return;
          }
        }

        // Fallback for plain text or unexpected format
        final doc = Document()..insert(0, content);
        _quillController = QuillController(
          document: doc,
          selection: const TextSelection.collapsed(offset: 0),
        );
      } else {
        _quillController = QuillController.basic();
      }
    } catch (e) {
      debugPrint('Error parsing quill content: $e');
      // Final fallback to ensure controller is never uninitialized
      _quillController = QuillController.basic();
      if (widget.entry != null && widget.entry!.content.isNotEmpty) {
        _quillController.document.insert(0, widget.entry!.content);
      }
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
          'Write Entry',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        actions: [
          // Writing Prompts button
          IconButton(
            icon: const Icon(Icons.lightbulb_outline, color: Colors.amber),
            tooltip: 'Writing Prompts',
            onPressed: () => _showWritingPrompts(isDark),
          ),
          // Templates button (available for both new + edit)
          IconButton(
            icon:
                const Icon(Icons.dashboard_customize_outlined, color: Colors.cyan),
            tooltip: 'Entry Templates',
            onPressed: () => _showTemplates(isDark),
          ),
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
            _buildDetailsCard(isDark),
            const SizedBox(height: 22),
            _buildSectionLabel(
              icon: Icons.edit_note,
              title: 'Write your thoughts',
              isDark: isDark,
            ),
            const SizedBox(height: 10),
            _buildContentField(isDark),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel({
    required IconData icon,
    required String title,
    required bool isDark,
  }) {
    return Row(
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
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? AppTheme.white : AppTheme.black,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161616) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark
              ? AppTheme.white.withValues(alpha: 0.10)
              : AppTheme.black.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.08),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionLabel(
            icon: Icons.tune,
            title: 'Details',
            isDark: isDark,
          ),
          const SizedBox(height: 14),
          _buildDatePicker(isDark),
          const SizedBox(height: 16),
          _buildTitleField(isDark),
          const SizedBox(height: 16),
          Text(
            'Tags',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isDark
                  ? AppTheme.white.withValues(alpha: 0.7)
                  : AppTheme.black.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 10),
          _buildTagInput(isDark),
          const SizedBox(height: 16),
          Text(
            'Mood',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isDark
                  ? AppTheme.white.withValues(alpha: 0.7)
                  : AppTheme.black.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 10),
          _buildMoodSelector(isDark),
        ],
      ),
    );
  }

  // ─────────────────────────── Writing Prompts ───────────────────────────

  void _showWritingPrompts(bool isDark) {
    final prompts = {
      'Gratitude ✨': [
        'What are 3 things you are grateful for today?',
        'Who made you smile today, and why?',
        'What simple pleasure did you enjoy today?',
        'Describe a moment today that made you feel at peace.',
        'What is something you take for granted that you appreciate today?',
      ],
      'Reflection 🌙': [
        'What was the highlight of your day?',
        'What challenged you today and how did you handle it?',
        'What would you do differently if you could re-live today?',
        'What did you learn about yourself today?',
        'How did today compare to your expectations?',
      ],
      'Emotions 💭': [
        'How are you truly feeling right now, beneath the surface?',
        'What emotion has been dominant today and what triggered it?',
        'Write a letter to your future self about how you feel today.',
        'What fear did you face (or avoid) today?',
        'What made your heart feel heavy today? What lightened it?',
      ],
      'Goals & Dreams 🚀': [
        'What goal did you make progress on today?',
        'What is one small step you can take tomorrow towards your dream?',
        'What does your ideal life look like in 5 years?',
        'What habit are you proud of building recently?',
        'What is one thing you keep procrastinating on, and why?',
      ],
      'Creativity 🎨': [
        'If today were a colour, what colour would it be and why?',
        'Write about a place you would love to visit and why.',
        'Describe your day as if it were a chapter in a novel.',
        'What song defines how you feel right now?',
        'If you could have dinner with anyone, who and why?',
      ],
      'Mindfulness 🧘': [
        'What sensations are you aware of in your body right now?',
        'What thoughts keep repeating in your mind today?',
        'Describe something beautiful you noticed today.',
        'What does silence mean to you today?',
        'What are you holding onto that you could let go of?',
      ],
    };

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          maxChildSize: 0.95,
          minChildSize: 0.4,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Icon(Icons.lightbulb, color: Colors.amber, size: 24),
                        SizedBox(width: 10),
                        Text(
                          'Writing Prompts',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Spacer(),
                        Text(
                          'Tap to use',
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.all(16),
                      children: prompts.entries.map((category) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 4),
                              child: Text(
                                category.key,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Colors.cyan,
                                ),
                              ),
                            ),
                            ...category.value.map((prompt) {
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(
                                    color: Colors.amber.withValues(alpha: 0.2),
                                  ),
                                ),
                                child: ListTile(
                                  title: Text(
                                    prompt,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  trailing: const Icon(
                                    Icons.add_circle_outline,
                                    color: Colors.amber,
                                    size: 20,
                                  ),
                                  onTap: () {
                                    Navigator.pop(context);
                                    _insertPrompt(prompt);
                                  },
                                ),
                              );
                            }),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _insertPrompt(String prompt) {
    final index = _quillController.selection.baseOffset;
    final safeIndex = index < 0 ? 0 : index;
    _quillController.document.insert(safeIndex, '$prompt\n');
    _quillController.updateSelection(
      TextSelection.collapsed(offset: safeIndex + prompt.length + 1),
      ChangeSource.local,
    );
  }

  // ─────────────────────────── Entry Templates ───────────────────────────

  void _showTemplates(bool isDark) {
    final templates = [
      {
        'name': 'Gratitude Journal',
        'emoji': '🙏',
        'description': 'Count your blessings today',
        'title':
            'Gratitude — ${DateFormat('d MMM yyyy').format(DateTime.now())}',
        'content': [
          {'insert': 'Three things I am grateful for today:\n'},
          {'insert': '1. '},
          {'insert': '\n'},
          {'insert': '2. '},
          {'insert': '\n'},
          {'insert': '3. '},
          {'insert': '\n\n'},
          {'insert': 'One person I appreciate today:\n'},
          {'insert': '\n\n'},
          {'insert': 'A small moment that made me smile:\n'},
          {'insert': '\n'},
        ],
      },
      {
        'name': 'Dream Log',
        'emoji': '🌙',
        'description': 'Record your dream before it fades',
        'title': 'Dream — ${DateFormat('d MMM yyyy').format(DateTime.now())}',
        'content': [
          {'insert': 'What I dreamed about:\n'},
          {'insert': '\n\n'},
          {'insert': 'Key symbols or feelings:\n'},
          {'insert': '\n\n'},
          {'insert': 'What it might mean:\n'},
          {'insert': '\n'},
        ],
      },
      {
        'name': 'Study Notes',
        'emoji': '📚',
        'description': 'Document what you learned today',
        'title': 'Study — ${DateFormat('d MMM yyyy').format(DateTime.now())}',
        'content': [
          {'insert': 'Subject / Topic:\n'},
          {'insert': '\n\n'},
          {'insert': 'Key things I learned:\n'},
          {'insert': '• \n'},
          {'insert': '• \n'},
          {'insert': '• \n\n'},
          {'insert': 'Questions I still have:\n'},
          {'insert': '\n\n'},
          {'insert': 'Action for tomorrow:\n'},
          {'insert': '\n'},
        ],
      },
      {
        'name': 'Daily Reflection',
        'emoji': '🌅',
        'description': 'End-of-day review',
        'title':
            'Reflection — ${DateFormat('d MMM yyyy').format(DateTime.now())}',
        'content': [
          {'insert': 'Highlight of my day:\n'},
          {'insert': '\n\n'},
          {'insert': 'What challenged me:\n'},
          {'insert': '\n\n'},
          {'insert': 'How I handled it:\n'},
          {'insert': '\n\n'},
          {'insert': 'What I would do differently:\n'},
          {'insert': '\n\n'},
          {'insert': 'Tomorrow I will focus on:\n'},
          {'insert': '\n'},
        ],
      },
      {
        'name': 'Mood Check-in',
        'emoji': '💙',
        'description': 'Check in with your emotions',
        'title':
            'Mood Check-in — ${DateFormat('d MMM yyyy').format(DateTime.now())}',
        'content': [
          {'insert': 'Right now I feel:\n'},
          {'insert': '\n\n'},
          {'insert': 'What triggered this feeling:\n'},
          {'insert': '\n\n'},
          {'insert': 'What my body is telling me:\n'},
          {'insert': '\n\n'},
          {'insert': 'What I need right now:\n'},
          {'insert': '\n'},
        ],
      },
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const Row(
                children: [
                  Icon(Icons.dashboard_customize, color: Colors.cyan, size: 22),
                  SizedBox(width: 10),
                  Text(
                    'Entry Templates',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Choose a template to get started',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 16),
              ...templates.map((t) {
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 4),
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.cyan.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        t['emoji'] as String,
                        style: const TextStyle(fontSize: 22),
                      ),
                    ),
                  ),
                  title: Text(
                    t['name'] as String,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    t['description'] as String,
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios,
                      size: 14, color: Colors.grey),
                  onTap: () {
                    Navigator.pop(context);
                    _applyTemplateFromUi(t);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Future<void> _applyTemplateFromUi(Map<String, dynamic> template) async {
    if (widget.entry != null) {
      final shouldReplace = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Apply template?'),
          content: const Text(
            'This will replace the current title and content of this entry.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Replace'),
            ),
          ],
        ),
      );
      if (shouldReplace != true) return;
    }

    _applyTemplate(template);
  }

  void _applyTemplate(Map<String, dynamic> template) {
    // Set the title
    _titleController.text = template['title'] as String;

    // Build Quill delta document from the template's content list
    final ops = template['content'] as List<Map<String, dynamic>>;
    final deltaJson = {'ops': ops};
    final document = Document.fromJson(deltaJson['ops'] as List);
    setState(() {
      _quillController = QuillController(
        document: document,
        selection: const TextSelection.collapsed(offset: 0),
      );
    });
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
    final hasFocus = _focusNode.hasFocus;

    final baseToolbarOptions = QuillSimpleToolbarButtonOptions(
      base: QuillToolbarBaseButtonOptions(
        iconSize: 16,
        iconButtonFactor: 1.7,
        iconTheme: QuillIconTheme(
          iconButtonSelectedData: IconButtonData(
            color: Colors.cyan,
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints.tightFor(width: 40, height: 40),
            visualDensity: VisualDensity.compact,
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.resolveWith(
                (states) => Colors.cyan.withValues(alpha: 0.20),
              ),
              foregroundColor: WidgetStateProperty.all(Colors.cyan),
              overlayColor: WidgetStateProperty.all(Colors.transparent),
              shadowColor: WidgetStateProperty.all(Colors.transparent),
              surfaceTintColor: WidgetStateProperty.all(Colors.transparent),
              splashFactory: NoSplash.splashFactory,
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          iconButtonUnselectedData: IconButtonData(
            color: isDark ? Colors.white70 : Colors.black87,
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints.tightFor(width: 40, height: 40),
            visualDensity: VisualDensity.compact,
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(Colors.transparent),
              overlayColor: WidgetStateProperty.all(Colors.transparent),
              splashFactory: NoSplash.splashFactory,
              shadowColor: WidgetStateProperty.all(Colors.transparent),
              surfaceTintColor: WidgetStateProperty.all(Colors.transparent),
            ),
          ),
        ),
      ),
      // Default is `Icons.color_lens` (a big filled circle) which is visually
      // distracting on dark toolbars.
      color: QuillToolbarColorButtonOptions(
        iconData: Icons.palette_outlined,
      ),
      // Header dropdown ("Normal") needs more width than icon-only buttons.
      selectHeaderStyleDropdownButton:
          QuillToolbarSelectHeaderStyleDropdownButtonOptions(
        iconTheme: QuillIconTheme(
          iconButtonSelectedData: IconButtonData(
            color: Colors.cyan,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            constraints: const BoxConstraints.tightFor(width: 110, height: 40),
            visualDensity: VisualDensity.compact,
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.resolveWith(
                (states) => Colors.cyan.withValues(alpha: 0.20),
              ),
              foregroundColor: WidgetStateProperty.all(Colors.cyan),
              overlayColor: WidgetStateProperty.all(Colors.transparent),
              shadowColor: WidgetStateProperty.all(Colors.transparent),
              surfaceTintColor: WidgetStateProperty.all(Colors.transparent),
              splashFactory: NoSplash.splashFactory,
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          iconButtonUnselectedData: IconButtonData(
            color: isDark ? Colors.white70 : Colors.black87,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            constraints: const BoxConstraints.tightFor(width: 110, height: 40),
            visualDensity: VisualDensity.compact,
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(Colors.transparent),
              overlayColor: WidgetStateProperty.all(Colors.transparent),
              splashFactory: NoSplash.splashFactory,
              shadowColor: WidgetStateProperty.all(Colors.transparent),
              surfaceTintColor: WidgetStateProperty.all(Colors.transparent),
            ),
          ),
        ),
      ),
    );

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
            boxShadow: isDark
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
          ),
          child: Stack(
            children: [
              Padding(
                padding:
                    EdgeInsets.fromLTRB(6, 6, 44, _isToolbarExpanded ? 6 : 6),
                child: QuillSimpleToolbar(
                  controller: _quillController,
                  config: QuillSimpleToolbarConfig(
                    // Collapsed: single-row toolbar (arrow-indicated list).
                    // Expanded: multi-row full toolbar.
                    multiRowsDisplay: _isToolbarExpanded,
                    toolbarRunSpacing: _isToolbarExpanded ? 6 : 0,
                    toolbarSectionSpacing: _isToolbarExpanded ? 4 : 2,
                    buttonOptions: baseToolbarOptions,
                    showFontFamily: false,
                    showFontSize: false,
                    showHeaderStyle: _isToolbarExpanded,
                    showBoldButton: true,
                    showItalicButton: true,
                    showUnderLineButton: true,
                    showStrikeThrough: false,
                    showColorButton: _isToolbarExpanded,
                    showBackgroundColorButton: false,
                    showListNumbers: true,
                    showListBullets: true,
                    showListCheck: true,
                    showCodeBlock: false,
                    showQuote: _isToolbarExpanded,
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
              Positioned(
                right: 6,
                top: 6,
                child: IconButton(
                  tooltip:
                      _isToolbarExpanded ? 'Collapse toolbar' : 'Expand toolbar',
                  onPressed: () {
                    setState(() => _isToolbarExpanded = !_isToolbarExpanded);
                  },
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(
                      Colors.black.withValues(alpha: 0.12),
                    ),
                    overlayColor: WidgetStateProperty.all(Colors.transparent),
                    splashFactory: NoSplash.splashFactory,
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  icon: Icon(
                    _isToolbarExpanded ? Icons.expand_less : Icons.expand_more,
                    color: isDark ? Colors.white70 : Colors.black87,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          constraints: const BoxConstraints(
            minHeight: 60, // Small starting height (approx 1-2 lines)
            maxHeight: 400,
          ),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF161616)
                : AppTheme.black.withValues(alpha: 0.02),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: hasFocus
                  ? Colors.cyan.withValues(alpha: isDark ? 0.45 : 0.35)
                  : (isDark
                      ? AppTheme.white.withValues(alpha: 0.10)
                      : AppTheme.black.withValues(alpha: 0.10)),
              width: hasFocus ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.08),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
              if (hasFocus)
                BoxShadow(
                  color: Colors.cyan.withValues(alpha: isDark ? 0.10 : 0.12),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Rich Editor (Removed Expanded for dynamic height)
              Padding(
                padding: const EdgeInsets.all(12),
                child: QuillEditor.basic(
                  controller: _quillController,
                  focusNode: _focusNode,
                  scrollController: _scrollController,
                  config: QuillEditorConfig(
                    // flutter_quill (web) builds JSON from placeholder; keep it single-line.
                    placeholder: 'Dear Diary… Today was…',
                    expands: false,
                    padding: EdgeInsets.zero,
                    autoFocus: false,
                    scrollable: true,
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
                            if (_attachedImages.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.black.withValues(alpha: 0.18)
                                      : Colors.white.withValues(alpha: 0.20),
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                    color: isDark
                                        ? Colors.black.withValues(alpha: 0.18)
                                        : Colors.white.withValues(alpha: 0.24),
                                  ),
                                ),
                                child: Text(
                                  '${_attachedImages.length}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: isDark
                                        ? AppTheme.black
                                        : AppTheme.white,
                                  ),
                                ),
                              ),
                            ],
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
