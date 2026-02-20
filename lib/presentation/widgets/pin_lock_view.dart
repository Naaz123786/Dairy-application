import 'package:flutter/material.dart';

class PinLockView extends StatefulWidget {
  final bool isSetup;
  final String initialLockType;
  final Function(String, String) onCorrectPin; // (secret, type)
  final String? savedPin;

  const PinLockView({
    super.key,
    required this.isSetup,
    this.initialLockType = 'pin',
    required this.onCorrectPin,
    this.savedPin,
  });

  @override
  State<PinLockView> createState() => _PinLockViewState();
}

class _PinLockViewState extends State<PinLockView> {
  late String _lockType;
  String _enteredPin = "";
  String _firstEntry = "";
  bool _isConfirming = false;
  String _errorMessage = "";
  late final TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _lockType = widget.initialLockType;
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void _handlePress(String val) {
    if (_enteredPin.length < 4) {
      setState(() {
        _enteredPin += val;
        _errorMessage = "";
      });
    }

    if (_enteredPin.length == 4) {
      _processPin();
    }
  }

  void _processPin() {
    final secret = _lockType == 'pin' ? _enteredPin : _passwordController.text;

    if (widget.isSetup) {
      if (!_isConfirming) {
        if (secret.isEmpty) {
          setState(() => _errorMessage =
              "Please enter a ${_lockType == 'pin' ? 'PIN' : 'password'}.");
          return;
        }
        setState(() {
          _firstEntry = secret;
          _enteredPin = "";
          _passwordController.clear();
          _isConfirming = true;
          _errorMessage = "";
        });
      } else {
        if (secret == _firstEntry) {
          widget.onCorrectPin(secret, _lockType);
        } else {
          setState(() {
            _enteredPin = "";
            _passwordController.clear();
            _errorMessage = "Secrets do not match. Try again.";
          });
        }
      }
    } else {
      if (secret == widget.savedPin) {
        widget.onCorrectPin(secret, _lockType);
      } else {
        setState(() {
          _enteredPin = "";
          _passwordController.clear();
          _errorMessage = "Incorrect ${_lockType.toUpperCase()}. Try again.";
        });
      }
    }
  }

  void _handleBackspace() {
    if (_enteredPin.isNotEmpty) {
      setState(() {
        _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: Center(
            child: Container(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      widget.isSetup ? Icons.security : Icons.lock_outline,
                      size: 48,
                      color: Colors.cyan,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.isSetup
                          ? (_isConfirming
                              ? "Confirm ${_lockType == 'pin' ? 'PIN' : 'Password'}"
                              : "Setup Privacy Lock")
                          : "Enter ${_lockType == 'pin' ? 'PIN' : 'Password'} to Unlock",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (widget.isSetup && !_isConfirming) ...[
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _lockType = _lockType == 'pin' ? 'password' : 'pin';
                            _enteredPin = "";
                            _passwordController.clear();
                            _errorMessage = "";
                          });
                        },
                        icon: Icon(_lockType == 'pin'
                            ? Icons.keyboard
                            : Icons.dialpad),
                        label: Text(
                            "Use ${_lockType == 'pin' ? 'Password' : 'PIN'} instead"),
                        style:
                            TextButton.styleFrom(foregroundColor: Colors.cyan),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      widget.isSetup
                          ? "Secure your diary entries"
                          : "Your diary is protected",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (_lockType == 'pin')
                      _buildPinDots(isDark)
                    else
                      _buildPasswordField(isDark),
                    if (_errorMessage.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ],
                    const SizedBox(height: 24),
                    if (_lockType == 'pin') _buildNumericKeypad(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPinDots(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index < _enteredPin.length
                ? Colors.cyan
                : (isDark ? Colors.grey[800] : Colors.grey[300]),
          ),
        );
      }),
    );
  }

  Widget _buildPasswordField(bool isDark) {
    return Column(
      children: [
        TextField(
          controller: _passwordController,
          obscureText: true,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 24, letterSpacing: 8),
          decoration: InputDecoration(
            hintText: "••••••••",
            hintStyle: TextStyle(
                color: isDark ? Colors.grey[800] : Colors.grey[300],
                letterSpacing: 8),
            enabledBorder: UnderlineInputBorder(
                borderSide:
                    BorderSide(color: Colors.cyan.withValues(alpha: 0.5))),
            focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.cyan, width: 2)),
          ),
          onSubmitted: (_) => _processPin(),
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: _processPin,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(200, 50),
            backgroundColor: Colors.cyan,
            foregroundColor: Colors.white,
          ),
          child: Text(widget.isSetup
              ? (_isConfirming ? "Confirm" : "Set Password")
              : "Unlock"),
        ),
      ],
    );
  }

  Widget _buildNumericKeypad() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 260),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.0,
        ),
        itemCount: 12,
        itemBuilder: (context, index) {
          if (index == 9) return const SizedBox.shrink();
          if (index == 11) {
            return _buildKey("⌫", onPressed: _handleBackspace);
          }
          final number = index == 10 ? 0 : index + 1;
          return _buildKey(number.toString(), onPressed: () {
            _handlePress(number.toString());
          });
        },
      ),
    );
  }

  Widget _buildKey(String label, {required VoidCallback onPressed}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(40),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
