import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../data/datasources/local_database.dart';
import '../../core/security/security_service.dart';
import 'package:get_it/get_it.dart';

class SecuritySettingsPage extends StatefulWidget {
  const SecuritySettingsPage({super.key});

  @override
  State<SecuritySettingsPage> createState() => _SecuritySettingsPageState();
}

class _SecuritySettingsPageState extends State<SecuritySettingsPage> {
  final _localDb = GetIt.I<LocalDatabase>();
  final _securityService = GetIt.I<SecurityService>();

  late bool _appLockEnabled;
  late bool _diaryLockEnabled;
  late bool _biometricEnabled;
  bool _canCheckBiometrics = false;

  @override
  void initState() {
    super.initState();
    _appLockEnabled = _localDb.isAppLockEnabled();
    _diaryLockEnabled = _localDb.isDiaryLockEnabled();
    _biometricEnabled = _localDb.isBiometricEnabled();
    _checkBiometricSupport();
  }

  Future<void> _checkBiometricSupport() async {
    final support = await _securityService.canCheckBiometrics();
    if (mounted) {
      setState(() {
        _canCheckBiometrics = support;
      });
    }
  }

  void _showPinDialog() {
    final controller = TextEditingController(text: _localDb.getDiaryPin());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Security PIN'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'This PIN will be used for both App Lock and Diary Lock.',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Enter 4-6 digit PIN',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.lock_outline, color: Colors.cyan),
              ),
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 6,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              if (controller.text.length >= 4) {
                await _localDb.setDiaryPin(controller.text);
                if (mounted) Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('PIN updated successfully')),
                );
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.cyan,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Save PIN'),
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
        title: const Text('Security Settings'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('Lock Options'),
          _buildSettingTile(
            title: 'Global App Lock',
            subtitle: 'Require authentication on app launch',
            icon: Icons.phonelink_lock,
            value: _appLockEnabled,
            onChanged: (val) async {
              if (val && !_localDb.hasDiaryPin()) {
                _showPinDialog();
                return;
              }
              await _localDb.setAppLockEnabled(val);
              setState(() => _appLockEnabled = val);
            },
            isDark: isDark,
          ),
          _buildSettingTile(
            title: 'Individual Diary Lock',
            subtitle: 'Secure the Diary section only',
            icon: Icons.book_online_outlined,
            value: _diaryLockEnabled,
            onChanged: (val) async {
              if (val && !_localDb.hasDiaryPin()) {
                _showPinDialog();
                return;
              }
              await _localDb.setDiaryLockEnabled(val);
              setState(() => _diaryLockEnabled = val);
            },
            isDark: isDark,
          ),
          const SizedBox(height: 16),
          _buildSectionHeader('Authentication'),
          if (_canCheckBiometrics)
            _buildSettingTile(
              title: 'Use Biometrics',
              subtitle: 'Fingerprint or FaceID',
              icon: Icons.fingerprint,
              value: _biometricEnabled,
              onChanged: (val) async {
                await _localDb.setBiometricEnabled(val);
                setState(() => _biometricEnabled = val);
              },
              isDark: isDark,
            ),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.cyan.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.password, color: Colors.cyan),
            ),
            title: const Text('Security PIN'),
            subtitle: Text(_localDb.hasDiaryPin()
                ? 'Change existing PIN'
                : 'Set a new PIN'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showPinDialog,
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.cyan.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.cyan.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.cyan, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Your security data is stored only on this device and is never uploaded to our servers.',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8, top: 16),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.cyan,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkGrey : Colors.grey[100],
        borderRadius: BorderRadius.circular(15),
      ),
      child: SwitchListTile(
        secondary: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.cyan.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.cyan),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        value: value,
        onChanged: onChanged,
        activeColor: Colors.cyan,
      ),
    );
  }
}
