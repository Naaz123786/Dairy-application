import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/diary_entry.dart';
import '../bloc/diary_bloc.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/datasources/local_database.dart';
import '../../injection_container.dart' as di;
import '../../core/services/pdf_service.dart';

class DiaryPage extends StatefulWidget {
  final bool isActive;
  const DiaryPage({super.key, this.isActive = true});

  @override
  State<DiaryPage> createState() => _DiaryPageState();
}

class _DiaryPageState extends State<DiaryPage> {
  late final LocalDatabase _localDb;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final Set<String> _selectedTags = {};

  @override
  void initState() {
    super.initState();
    _localDb = di.sl<LocalDatabase>();
    context.read<DiaryBloc>().add(LoadDiaryEntries());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.cyan),
                decoration: const InputDecoration(
                  hintText: 'Search entries...',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
              )
            : const Text(
                'My Diary',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.cyan,
                ),
              ),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  _searchQuery = '';
                }
              });
            },
          ),
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            icon: Icon(
                _localDb.hasDiaryPin() ? Icons.lock_outline : Icons.security),
            tooltip: 'Security Settings',
            onSelected: (value) async {
              if (value == 'lock') {
                // Now handled by MainPage, but keeping for manual re-lock if needed
                Navigator.pushNamed(context, AppRoutes.security);
              } else if (value == 'setup') {
                Navigator.pushNamed(context, AppRoutes.security);
              }
            },
            itemBuilder: (context) => [
              if (_localDb.hasDiaryPin()) ...[
                const PopupMenuItem(
                  value: 'lock',
                  child: ListTile(
                    leading: Icon(Icons.security),
                    title: Text('Security Settings'),
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  ),
                ),
              ] else ...[
                const PopupMenuItem(
                  value: 'setup',
                  child: ListTile(
                    leading: Icon(Icons.security),
                    title: Text('Setup Privacy Lock'),
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'diary_fab',
        onPressed: () {
          final user = FirebaseAuth.instance.currentUser;
          if (user == null) {
            Navigator.pushNamed(context, AppRoutes.login);
            return;
          }
          Navigator.pushNamed(context, AppRoutes.diaryEdit);
        },
        label: const Text('Write'),
        icon: const Icon(Icons.create),
      ),
      body: _buildBody(isDark),
    );
  }

  Future<void> _exportToPdf(DiaryEntry entry) async {
    try {
      final pdfService = PdfService();

      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: Colors.cyan),
        ),
      );

      // Generate PDF
      final pdfBytes = await pdfService.generateEntryPdf(entry);

      // Close loading dialog
      if (mounted) Navigator.pop(context);

      // Show options dialog
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Export PDF'),
            content: const Text('Choose an action:'),
            actions: [
              TextButton.icon(
                onPressed: () async {
                  Navigator.pop(context);
                  await pdfService.sharePdf(pdfBytes, entry.title);
                },
                icon: const Icon(Icons.share),
                label: const Text('Share'),
              ),
              TextButton.icon(
                onPressed: () async {
                  Navigator.pop(context);
                  await pdfService.printPdf(pdfBytes);
                },
                icon: const Icon(Icons.print),
                label: const Text('Print'),
              ),
              TextButton.icon(
                onPressed: () async {
                  Navigator.pop(context);
                  final path = await pdfService.savePdfToDevice(
                    pdfBytes,
                    entry.title,
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Saved to: $path')),
                    );
                  }
                },
                icon: const Icon(Icons.save),
                label: const Text('Save'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading if open
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Widget _buildTagFilterBar(List<String> tags, bool isDark) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: tags.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final tag = tags[index];
          final isSelected = _selectedTags.contains(tag);

          return FilterChip(
            label: Text('#$tag'),
            selected: isSelected,
            onSelected: (selected) {
              setState(() {
                if (selected) {
                  _selectedTags.add(tag);
                } else {
                  _selectedTags.remove(tag);
                }
              });
            },
            backgroundColor: isDark
                ? AppTheme.darkGrey
                : AppTheme.black.withValues(alpha: 0.05),
            selectedColor: Colors.cyan.withValues(alpha: 0.2),
            checkmarkColor: Colors.cyan,
            labelStyle: TextStyle(
              color: isSelected
                  ? Colors.cyan
                  : (isDark ? AppTheme.white : AppTheme.black),
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: isSelected
                    ? Colors.cyan
                    : (isDark
                        ? AppTheme.white.withValues(alpha: 0.1)
                        : AppTheme.black.withValues(alpha: 0.1)),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(bool isDark) {
    return BlocBuilder<DiaryBloc, DiaryState>(
      builder: (context, state) {
        if (state is DiaryLoading) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Colors.cyan),
            ),
          );
        }

        if (state is DiaryError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(state.message),
              ],
            ),
          );
        }

        if (state is DiaryLoaded) {
          // Extract all unique tags
          final allTags = state.entries.expand((e) => e.tags).toSet().toList()
            ..sort();

          final filteredEntries = state.entries.where((entry) {
            final matchesSearch = entry.title
                    .toLowerCase()
                    .contains(_searchQuery) ||
                entry.content.toLowerCase().contains(_searchQuery) ||
                entry.tags.any((t) => t.toLowerCase().contains(_searchQuery));

            final matchesTags = _selectedTags.isEmpty ||
                _selectedTags.every((tag) => entry.tags.contains(tag));

            return matchesSearch && matchesTags;
          }).toList();

          if (state.entries.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.book_outlined,
                    size: 80,
                    color: isDark
                        ? AppTheme.white.withValues(alpha: 0.2)
                        : AppTheme.black.withValues(alpha: 0.2),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No diary entries yet',
                    style: TextStyle(
                      color: isDark
                          ? AppTheme.white.withValues(alpha: 0.5)
                          : AppTheme.black.withValues(alpha: 0.5),
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              if (allTags.isNotEmpty) _buildTagFilterBar(allTags, isDark),
              Expanded(
                child: filteredEntries.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color:
                                  isDark ? Colors.grey[700] : Colors.grey[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No entries match your search/filters',
                              style: TextStyle(
                                color: isDark
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                              ),
                            ),
                            if (_selectedTags.isNotEmpty ||
                                _searchQuery.isNotEmpty)
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _selectedTags.clear();
                                    _searchQuery = '';
                                    _searchController.clear();
                                  });
                                },
                                child: const Text('Clear Filters',
                                    style: TextStyle(color: Colors.cyan)),
                              ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredEntries.length,
                        itemBuilder: (context, index) {
                          final entry = filteredEntries[index];
                          return _buildDiaryCard(context, entry, isDark);
                        },
                      ),
              ),
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildDiaryCard(BuildContext context, DiaryEntry entry, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkGrey : AppTheme.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.cyan.withValues(alpha: 0.3)
              : Colors.cyan.withValues(alpha: 0.5),
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
            Navigator.pushNamed(context, AppRoutes.diaryEdit, arguments: entry);
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        entry.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.cyan,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (entry.mood.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppTheme.white.withValues(alpha: 0.1)
                              : AppTheme.black.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isDark
                                ? AppTheme.white.withValues(alpha: 0.2)
                                : AppTheme.black.withValues(alpha: 0.1),
                          ),
                        ),
                        child: Text(
                          entry.mood,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('EEEE, d MMMM y').format(entry.date),
                  style: TextStyle(
                    color: isDark
                        ? AppTheme.white.withValues(alpha: 0.5)
                        : AppTheme.black.withValues(alpha: 0.5),
                    fontSize: 12,
                  ),
                ),
                if (entry.tags.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: entry.tags.map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.cyan.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: Colors.cyan.withValues(alpha: 0.2)),
                        ),
                        child: Text(
                          '#$tag',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.cyan,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon:
                          const Icon(Icons.edit, size: 18, color: Colors.blue),
                      onPressed: () {
                        if (FirebaseAuth.instance.currentUser == null) {
                          Navigator.pushNamed(context, AppRoutes.login);
                          return;
                        }
                        Navigator.pushNamed(
                          context,
                          AppRoutes.diaryEdit,
                          arguments: entry,
                        );
                      },
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(Icons.picture_as_pdf,
                          size: 18, color: Colors.green),
                      onPressed: () => _exportToPdf(entry),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(Icons.delete_outline,
                          size: 18, color: Colors.red),
                      onPressed: () {
                        if (FirebaseAuth.instance.currentUser == null) {
                          Navigator.pushNamed(context, AppRoutes.login);
                          return;
                        }
                        _showDeleteDialog(context, entry);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, DiaryEntry entry) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Entry'),
        content: const Text(
          'Are you sure you want to delete this diary entry?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<DiaryBloc>().add(DeleteDiaryEntry(entry.id));
              Navigator.pop(ctx);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
