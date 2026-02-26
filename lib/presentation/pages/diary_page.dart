import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/diary_entry.dart';
import '../../core/util/json_utils.dart';
import '../bloc/diary_bloc.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/datasources/local_database.dart';
import '../../injection_container.dart' as di;
import '../../core/services/pdf_service.dart';
import '../../core/util/guest_limits.dart';

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
  final Set<String> _selectedMoods = {};
  Set<String> _favoriteIds = {};

  @override
  void initState() {
    super.initState();
    _localDb = di.sl<LocalDatabase>();
    _favoriteIds = _localDb.getFavoriteEntryIds();
    context.read<DiaryBloc>().add(LoadDiaryEntries());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openNewDiaryEntry(BuildContext context) {
    if (FirebaseAuth.instance.currentUser != null) {
      Navigator.pushNamed(context, AppRoutes.diaryEdit);
      return;
    }
    final state = context.read<DiaryBloc>().state;
    if (state is DiaryLoaded &&
        state.entries.length >= GuestLimits.maxDiaryEntries) {
      _showGuestLimitDialog(
        context,
        'You can add up to ${GuestLimits.maxDiaryEntries} diary entries as guest. Login to add more.',
      );
      return;
    }
    Navigator.pushNamed(context, AppRoutes.diaryEdit);
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
        onPressed: () => _openNewDiaryEntry(context),
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

  /// Extracts plain readable text from a Quill delta JSON string.
  String _extractPlainText(String quillJson) {
    try {
      final content = quillJson.trim();
      if (content.isEmpty) return '';

      // If it doesn't look like JSON, return as is (plain text)
      if (!content.startsWith('[') && !content.startsWith('{')) {
        return content;
      }

      final decoded = JsonUtils.safeDecode(content);
      final ops = JsonUtils.getOps(decoded);

      if (ops != null) {
        final buffer = StringBuffer();
        for (final op in ops) {
          if (op is Map && op['insert'] is String) {
            buffer.write(op['insert']);
          }
        }
        return buffer.toString();
      }
      return content;
    } catch (_) {
      return quillJson;
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

  Widget _buildMoodFilterBar(List<String> moods, bool isDark) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: moods.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final mood = moods[index];
          final isSelected = _selectedMoods.contains(mood);

          return FilterChip(
            label: Text(mood),
            selected: isSelected,
            onSelected: (selected) {
              setState(() {
                if (selected) {
                  _selectedMoods.add(mood);
                } else {
                  _selectedMoods.remove(mood);
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

  Widget _buildStatsRow({
    required bool isDark,
    required int total,
    required int today,
    required int week,
  }) {
    Widget statCard(String label, String value, IconData icon) {
      return Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: isDark
                ? AppTheme.white.withValues(alpha: 0.06)
                : AppTheme.black.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark
                  ? AppTheme.white.withValues(alpha: 0.08)
                  : AppTheme.black.withValues(alpha: 0.06),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.cyan.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.cyan, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark
                            ? AppTheme.white.withValues(alpha: 0.55)
                            : AppTheme.black.withValues(alpha: 0.55),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Row(
        children: [
          statCard('Today', '$today', Icons.today),
          const SizedBox(width: 10),
          statCard('This week', '$week', Icons.date_range),
          const SizedBox(width: 10),
          statCard('Total', '$total', Icons.menu_book),
        ],
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

          final allMoods = state.entries
              .map((e) => e.mood)
              .where((m) => m.trim().isNotEmpty)
              .toSet()
              .toList()
            ..sort();

          final now = DateTime.now();
          final startOfToday = DateTime(now.year, now.month, now.day);
          final startOfWeek = startOfToday.subtract(
            Duration(days: (startOfToday.weekday - DateTime.monday)),
          );

          final filteredEntries = state.entries.where((entry) {
            final plainContent = _extractPlainText(entry.content).toLowerCase();
            final matchesSearch = _searchQuery.isEmpty ||
                entry.title.toLowerCase().contains(_searchQuery) ||
                plainContent.contains(_searchQuery) ||
                entry.tags.any((t) => t.toLowerCase().contains(_searchQuery));

            final matchesTags = _selectedTags.isEmpty ||
                _selectedTags.every((tag) => entry.tags.contains(tag));

            final matchesMoods = _selectedMoods.isEmpty ||
                _selectedMoods.contains(entry.mood);

            return matchesSearch && matchesTags && matchesMoods;
          }).toList();

          filteredEntries.sort((a, b) {
            final aFav = _favoriteIds.contains(a.id);
            final bFav = _favoriteIds.contains(b.id);
            if (aFav != bFav) return aFav ? -1 : 1;
            return b.date.compareTo(a.date);
          });

          if (state.entries.isEmpty) {
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
                      child: const Icon(
                        Icons.edit_note,
                        size: 48,
                        color: Colors.cyan,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Your diary is empty',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppTheme.white : AppTheme.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Start with a small note — you can always add more later.',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? AppTheme.white.withValues(alpha: 0.6)
                            : AppTheme.black.withValues(alpha: 0.6),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 18),
                    FilledButton.icon(
                      onPressed: () => _openNewDiaryEntry(context),
                      icon: const Icon(Icons.create),
                      label: const Text('Write your first entry'),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.cyan,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final todayCount =
              state.entries.where((e) => e.date.isAfter(startOfToday)).length;
          final weekCount =
              state.entries.where((e) => e.date.isAfter(startOfWeek)).length;

          return Column(
            children: [
              _buildStatsRow(
                isDark: isDark,
                total: state.entries.length,
                today: todayCount,
                week: weekCount,
              ),
              if (allMoods.isNotEmpty) _buildMoodFilterBar(allMoods, isDark),
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
                                    _selectedMoods.clear();
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
    final isFavorite = _favoriteIds.contains(entry.id);
    final trimmedTitle = entry.title.trim();
    final leadingChar =
        trimmedTitle.isEmpty ? '•' : trimmedTitle.substring(0, 1).toUpperCase();
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
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
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: Colors.cyan.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.cyan.withValues(alpha: 0.22),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        leadingChar,
                        style: const TextStyle(
                          color: Colors.cyan,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
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
                    IconButton(
                      tooltip: isFavorite ? 'Unfavorite' : 'Favorite',
                      onPressed: () async {
                        final next = !isFavorite;
                        setState(() {
                          if (next) {
                            _favoriteIds.add(entry.id);
                          } else {
                            _favoriteIds.remove(entry.id);
                          }
                        });
                        await _localDb.setEntryFavorite(entry.id, next);
                      },
                      icon: Icon(
                        isFavorite ? Icons.star : Icons.star_border,
                        color: isFavorite
                            ? Colors.amber
                            : (isDark ? Colors.white54 : Colors.black45),
                        size: 20,
                      ),
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(
                          isDark
                              ? Colors.white.withValues(alpha: 0.06)
                              : Colors.black.withValues(alpha: 0.04),
                        ),
                        padding:
                            WidgetStateProperty.all(const EdgeInsets.all(8)),
                        shape: WidgetStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_month,
                      size: 14,
                      color: isDark
                          ? AppTheme.white.withValues(alpha: 0.45)
                          : AppTheme.black.withValues(alpha: 0.45),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        DateFormat('EEEE, d MMMM y').format(entry.date),
                        style: TextStyle(
                          color: isDark
                              ? AppTheme.white.withValues(alpha: 0.55)
                              : AppTheme.black.withValues(alpha: 0.55),
                          fontSize: 12,
                        ),
                      ),
                    ),
                    if (entry.images.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.06)
                              : Colors.black.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.08)
                                : Colors.black.withValues(alpha: 0.06),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.photo, size: 14, color: Colors.cyan),
                            const SizedBox(width: 6),
                            Text(
                              '${entry.images.length}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    if (entry.mood.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.cyan.withValues(alpha: 0.22),
                              Colors.cyan.withValues(alpha: 0.10),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.cyan.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Text(
                          entry.mood,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                  ],
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
                    _buildActionChip(
                      icon: Icons.edit,
                      label: 'Edit',
                      color: Colors.blue,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.diaryEdit,
                          arguments: entry,
                        );
                      },
                    ),
                    const SizedBox(width: 10),
                    _buildActionChip(
                      icon: Icons.picture_as_pdf,
                      label: 'PDF',
                      color: Colors.green,
                      onTap: () => _exportToPdf(entry),
                    ),
                    const SizedBox(width: 10),
                    _buildActionChip(
                      icon: Icons.delete_outline,
                      label: 'Delete',
                      color: Colors.red,
                      onTap: () => _showDeleteDialog(context, entry),
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

  /// Compact action buttons that look consistent across cards.
  /// Kept local to avoid over-coupling with global theme.
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
