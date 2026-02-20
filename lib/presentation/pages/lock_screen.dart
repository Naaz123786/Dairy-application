import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../data/datasources/local_database.dart';
import '../../core/security/security_service.dart';
import 'package:get_it/get_it.dart';

class LockScreen extends StatefulWidget {
  final bool isAppLock; // True for Global Lock, False for section lock
  final VoidCallback onUnlocked;

  const LockScreen({
    super.key,
    required this.isAppLock,
    required this.onUnlocked,
  });

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final _localDb = GetIt.I<LocalDatabase>();
  final _securityService = GetIt.I<SecurityService>();
  final _pinController = TextEditingController();
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    if (_localDb.isBiometricEnabled()) {
      _authenticateWithBiometrics();
    }
  }

  Future<void> _authenticateWithBiometrics() async {
    final success = await _securityService.authenticate();
    if (success) {
      widget.onUnlocked();
    }
  }

  void _onPinChanged(String val) {
    if (val.length == _localDb.getDiaryPin()?.length) {
      if (val == _localDb.getDiaryPin()) {
        widget.onUnlocked();
      } else {
        setState(() {
          _isError = true;
          _pinController.clear();
        });
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) setState(() => _isError = false);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.black : AppTheme.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.isAppLock ? Icons.security : Icons.lock_outline,
                size: 80,
                color: Colors.cyan,
              ),
              const SizedBox(height: 24),
              Text(
                widget.isAppLock ? 'App Locked' : 'Diary Locked',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Enter PIN to continue',
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 48),
              _buildPinDots(),
              const SizedBox(height: 48),
              _buildNumpad(),
              if (_localDb.isBiometricEnabled()) ...[
                const SizedBox(height: 24),
                IconButton(
                  icon: const Icon(Icons.fingerprint,
                      size: 48, color: Colors.cyan),
                  onPressed: _authenticateWithBiometrics,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPinDots() {
    final pinLength = _localDb.getDiaryPin()?.length ?? 4;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(pinLength, (index) {
        final isFilled = _pinController.text.length > index;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _isError
                ? Colors.red
                : (isFilled ? Colors.cyan : Colors.grey.withValues(alpha: 0.3)),
          ),
        );
      }),
    );
  }

  Widget _buildNumpad() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        childAspectRatio: 1.5,
      ),
      itemCount: 12,
      itemBuilder: (context, index) {
        if (index == 9) return const SizedBox();
        if (index == 11) {
          return _buildNumpadButton(
            const Icon(Icons.backspace_outlined),
            onPressed: () {
              if (_pinController.text.isNotEmpty) {
                setState(() => _pinController.text = _pinController.text
                    .substring(0, _pinController.text.length - 1));
              }
            },
          );
        }
        final number = index == 10 ? 0 : index + 1;
        return _buildNumpadButton(
          Text(
            '$number',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          onPressed: () {
            if (_pinController.text.length <
                (_localDb.getDiaryPin()?.length ?? 6)) {
              setState(() => _pinController.text += '$number');
              _onPinChanged(_pinController.text);
            }
          },
        );
      },
    );
  }

  Widget _buildNumpadButton(Widget child, {required VoidCallback onPressed}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(15),
        child: Center(child: child),
      ),
    );
  }
}
