import 'package:flutter/material.dart';

class PinLockView extends StatefulWidget {
  final bool isSetup;
  final Function(String) onCorrectPin;
  final String? savedPin;

  const PinLockView({
    super.key,
    required this.isSetup,
    required this.onCorrectPin,
    this.savedPin,
  });

  @override
  State<PinLockView> createState() => _PinLockViewState();
}

class _PinLockViewState extends State<PinLockView> {
  String _enteredPin = "";
  String _firstEntry = "";
  bool _isConfirming = false;
  String _errorMessage = "";

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
    if (widget.isSetup) {
      if (!_isConfirming) {
        setState(() {
          _firstEntry = _enteredPin;
          _enteredPin = "";
          _isConfirming = true;
        });
      } else {
        if (_enteredPin == _firstEntry) {
          widget.onCorrectPin(_enteredPin);
        } else {
          setState(() {
            _enteredPin = "";
            _errorMessage = "PINs do not match. Try again.";
          });
        }
      }
    } else {
      if (_enteredPin == widget.savedPin) {
        widget.onCorrectPin(_enteredPin);
      } else {
        setState(() {
          _enteredPin = "";
          _errorMessage = "Incorrect PIN. Try again.";
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
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      widget.isSetup ? Icons.security : Icons.lock_outline,
                      size: 64,
                      color: Colors.cyan,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      widget.isSetup
                          ? (_isConfirming
                              ? "Confirm PIN"
                              : "Setup Privacy PIN")
                          : "Enter PIN to Unlock",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.isSetup
                          ? "Create a 4-digit PIN for your diary"
                          : "Your diary is protected",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(4, (index) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: index < _enteredPin.length
                                ? Colors.cyan
                                : (isDark
                                    ? Colors.grey[800]
                                    : Colors.grey[300]),
                          ),
                        );
                      }),
                    ),
                    if (_errorMessage.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ],
                    const SizedBox(height: 32),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 300),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
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
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
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
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
