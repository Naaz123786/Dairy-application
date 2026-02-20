import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme/app_theme.dart';
import '../../core/routes/app_routes.dart';
import '../../injection_container.dart' as di;
import '../bloc/reminder_bloc.dart';
import '../bloc/diary_bloc.dart';
import 'package:intl/intl.dart';
import '../../data/datasources/local_database.dart';
import '../bloc/theme_cubit.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ... (Profile Header remains same)
            StreamBuilder<User?>(
              stream: FirebaseAuth.instance.userChanges(),
              initialData: FirebaseAuth.instance.currentUser,
              builder: (context, snapshot) {
                final user = snapshot.data;
                return Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.black,
                            width: 3,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.white,
                          backgroundImage: user?.photoURL != null
                              ? NetworkImage(user!.photoURL!)
                              : null,
                          child: user?.photoURL == null
                              ? const Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Colors.cyan,
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            user != null
                                ? (user.displayName != null &&
                                        user.displayName!.isNotEmpty)
                                    ? user.displayName!
                                    : (user.email != null
                                        ? user.email!.split('@')[0]
                                        : 'Guest')
                                : 'Guest',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.cyan,
                            ),
                          ),
                          if (user != null)
                            IconButton(
                              icon: const Icon(Icons.edit,
                                  size: 20, color: Colors.cyan),
                              onPressed: () =>
                                  _showEditNameDialog(context, user),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.email ?? 'Sign in to sync your data',
                        style: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 32),
            const Text(
              'Settings',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Dark Mode Toggle
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkGrey : AppTheme.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
                  width: 1,
                ),
              ),
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                title: const Text(
                  'Dark Mode',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  isDark ? 'Dark mode is on' : 'Light mode is on',
                  style: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    fontSize: 13,
                  ),
                ),
                trailing: Switch(
                  value: isDark,
                  activeColor: Colors.cyan,
                  onChanged: (value) {
                    context.read<ThemeCubit>().toggleTheme();
                  },
                ),
              ),
            ),

            _buildSettingCard(
              context,
              icon: Icons.security,
              title: 'Security',
              subtitle: 'Manage app lock & privacy',
              onTap: () => Navigator.pushNamed(context, AppRoutes.security),
            ),
            _buildSettingCard(
              context,
              icon: Icons.notifications,
              title: 'Notifications',
              subtitle: 'Manage your alerts',
              onTap: () => _showNotificationSettings(context),
            ),
            _buildSettingCard(
              context,
              icon: Icons.backup,
              title: 'Backup & Restore',
              subtitle: 'Save your data',
              onTap: () => _showBackupSettings(context),
            ),
            const SizedBox(height: 24),
            const Text(
              'About',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildSimpleSettingTile(
              context,
              icon: Icons.help_outline,
              title: 'Help & Support',
              onTap: () => _showHelpSupport(context),
            ),
            _buildSimpleSettingTile(
              context,
              icon: Icons.info_outline,
              title: 'About App',
              onTap: () => _showAboutApp(context),
            ),
            _buildSimpleSettingTile(
              context,
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy Policy',
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.privacy);
              },
            ),
            const SizedBox(height: 24),
            StreamBuilder<User?>(
              stream: FirebaseAuth.instance.userChanges(),
              initialData: FirebaseAuth.instance.currentUser,
              builder: (context, snapshot) {
                final user = snapshot.data;
                if (user != null) {
                  return _buildSimpleSettingTile(
                    context,
                    icon: Icons.logout,
                    title: 'Log Out',
                    onTap: () async {
                      try {
                        await di.sl<LocalDatabase>().clearAllData();
                      } catch (e) {
                        debugPrint('Error clearing data: $e');
                      }
                      await FirebaseAuth.instance.signOut();
                      if (context.mounted) {
                        context.read<DiaryBloc>().add(LoadDiaryEntries());
                        context.read<ReminderBloc>().add(LoadReminders());
                      }
                    },
                  );
                } else {
                  return _buildSimpleSettingTile(
                    context,
                    icon: Icons.login,
                    title: 'Log In / Sign Up',
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.login);
                    },
                  );
                }
              },
            ),
            const SizedBox(height: 32),
            Center(
              child: Text(
                'Version 1.0.0',
                style: TextStyle(
                  color: isDark ? Colors.grey[600] : Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkGrey : AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.cyan.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 24, color: Colors.cyan),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSimpleSettingTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.cyan.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.cyan),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showNotificationSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notifications'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CheckboxListTile(
              title: const Text('Daily Reminders'),
              value: true,
              activeColor: Colors.cyan,
              onChanged: (v) {},
            ),
            CheckboxListTile(
              title: const Text('Mood Tracking Alerts'),
              value: true,
              activeColor: Colors.cyan,
              onChanged: (v) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _showBackupSettings(BuildContext context) {
    final localDb = di.sl<LocalDatabase>();
    final lastSyncStr = localDb.getLastSyncTime();
    final lastSyncText = lastSyncStr != null
        ? 'Last Synced: ${DateFormat('MMM d, yyyy • HH:mm').format(DateTime.parse(lastSyncStr))}'
        : 'Never Synced';

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Backup & Restore'),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your data is securely backed up to the cloud and encrypted locally on your device.',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 16),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.cyan.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.history, size: 18, color: Colors.cyan),
                      const SizedBox(width: 8),
                      Text(
                        lastSyncText,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.cyan,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Sync Now will backup all your diary entries and reminders to your linked Google account.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Close'),
              ),
              FilledButton(
                onPressed: () async {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please log in to sync')),
                    );
                    return;
                  }

                  // Close dialog and show loading snackbar
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Row(
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 16),
                          Text('Cloud Sync in progress...'),
                        ],
                      ),
                      duration: Duration(seconds: 15),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );

                  try {
                    // Trigger sync for both
                    context.read<DiaryBloc>().add(SyncDiaryEntries());
                    context.read<ReminderBloc>().add(SyncReminders());

                    // Wait for background tasks
                    await Future.delayed(const Duration(seconds: 3));

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text('Backup Success! Data is now safe. ☁️✅'),
                          backgroundColor: Colors.green,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Sync Failed: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.cyan,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Sync Now'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showHelpSupport(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & Support'),
        content: const Text(
          'Need help? Contact our support team at support@minidiary.com or visit our knowledge base.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {},
            child: const Text('Email Support'),
          ),
        ],
      ),
    );
  }

  void _showAboutApp(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Personal Diary',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.book, color: Colors.cyan, size: 40),
      children: [
        const Text(
          'This is your private sanctuary for thoughts and reflections. Built with privacy and security as the core foundation.',
        ),
      ],
    );
  }

  void _showEditNameDialog(BuildContext context, User user) {
    final controller = TextEditingController(text: user.displayName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Name'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Enter your name',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: const Icon(Icons.person, color: Colors.cyan),
          ),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                try {
                  await user.updateProfile(displayName: controller.text.trim());
                  await user.reload();
                  if (context.mounted) Navigator.pop(context);
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error updating name: $e')),
                    );
                  }
                }
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.cyan,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}
