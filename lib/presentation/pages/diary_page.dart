import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/diary_entry.dart';
import '../bloc/diary_bloc.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/datasources/local_database.dart';
import '../widgets/pin_lock_view.dart';
import '../../injection_container.dart' as di;

class DiaryPage extends StatefulWidget {
  final bool isActive;
  const DiaryPage({super.key, this.isActive = true});

  @override
  State<DiaryPage> createState() => _DiaryPageState();
}

class _DiaryPageState extends State<DiaryPage> {
  bool _isUnlocked = false;
  bool _isSettingUp = false;
  late final LocalDatabase _localDb;

  @override
  void initState() {
    super.initState();
    _localDb = di.sl<LocalDatabase>();
    _isUnlocked = !_localDb.hasDiaryPin();
    context.read<DiaryBloc>().add(LoadDiaryEntries());
  }

  @override
  void didUpdateWidget(covariant DiaryPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Auto-lock when switching back to Diary tab if a PIN exists
    if (widget.isActive && !oldWidget.isActive && _localDb.hasDiaryPin()) {
      setState(() {
        _isUnlocked = false;
        _isSettingUp = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Diary',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.cyan,
          ),
        ),
        elevation: 0,
        actions: [
          if (_isUnlocked && !_isSettingUp) ...[
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                // TODO: Implement search
              },
            ),
            IconButton(
              icon: Icon(
                  _localDb.hasDiaryPin() ? Icons.lock_outline : Icons.security),
              onPressed: () {
                if (_localDb.hasDiaryPin()) {
                  setState(() => _isUnlocked = false);
                } else {
                  setState(() => _isSettingUp = true);
                }
              },
            ),
          ] else if (_isSettingUp)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() => _isSettingUp = false);
              },
            ),
        ],
      ),
      floatingActionButton: _isUnlocked && !_isSettingUp
          ? FloatingActionButton.extended(
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
            )
          : null,
      body: _buildBody(isDark),
    );
  }

  Widget _buildBody(bool isDark) {
    if (!_isUnlocked || _isSettingUp) {
      return PinLockView(
        isSetup: _isSettingUp,
        savedPin: _localDb.getDiaryPin(),
        onCorrectPin: (pin) async {
          if (_isSettingUp) {
            await _localDb.setDiaryPin(pin);
          }
          setState(() {
            _isUnlocked = true;
            _isSettingUp = false;
          });
        },
      );
    }

    return BlocBuilder<DiaryBloc, DiaryState>(
      builder: (context, state) {
        if (state is DiaryLoading) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Colors.grey),
            ),
          );
        }

        if (state is DiaryError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64),
                const SizedBox(height: 16),
                Text(state.message),
              ],
            ),
          );
        }

        if (state is DiaryLoaded) {
          if (state.entries.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.book_outlined,
                    size: 80,
                    color: isDark
                        ? AppTheme.white.withOpacity(0.2)
                        : AppTheme.black.withOpacity(0.2),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No diary entries yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.cyan,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the Write button to create your first entry',
                    style: TextStyle(
                      color: isDark
                          ? AppTheme.white.withOpacity(0.5)
                          : AppTheme.black.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.entries.length,
            itemBuilder: (context, index) {
              final entry = state.entries[index];
              return _buildDiaryCard(context, entry, isDark);
            },
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
              ? Colors.cyan.withOpacity(0.3)
              : Colors.cyan.withOpacity(0.5), // Visible Cyan in Light Mode
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
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        entry.title,
                        style: const TextStyle(
                          fontSize: 20,
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
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppTheme.white.withOpacity(0.1)
                              : AppTheme.black.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark
                                ? AppTheme.white.withOpacity(0.2)
                                : AppTheme.black.withOpacity(0.1),
                          ),
                        ),
                        child: Text(
                          entry.mood,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  DateFormat('EEEE, d MMMM y').format(entry.date),
                  style: TextStyle(
                    color: isDark
                        ? AppTheme.white.withOpacity(0.5)
                        : AppTheme.black.withOpacity(0.5),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  entry.content,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: isDark
                        ? AppTheme.white.withOpacity(0.8)
                        : AppTheme.black.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon:
                          const Icon(Icons.edit, size: 20, color: Colors.blue),
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
                    IconButton(
                      icon: const Icon(Icons.delete_outline,
                          size: 20, color: Colors.red),
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
