import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../core/theme/app_theme.dart';
import '../../presentation/bloc/diary_bloc.dart';
import '../../presentation/bloc/reminder_bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isSignUp = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      _checkRedirectResult();
    }
  }

  Future<void> _checkRedirectResult() async {
    try {
      final userCred = await FirebaseAuth.instance.getRedirectResult();
      if (userCred.user != null) {
        // Reload user to get latest profile data including displayName
        await userCred.user!.reload();
        if (context.mounted) {
          context.read<DiaryBloc>().add(LoadDiaryEntries());

          // Wait a bit for auth state to update
          await Future.delayed(const Duration(milliseconds: 100));

          if (!context.mounted) return;

          // Only pop if we can, otherwise let AuthWrapper handle navigation
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          } else {
            // If we can't pop, navigate to home
            Navigator.of(context).pushNamedAndRemoveUntil(
              '/',
              (route) => false,
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Redirect Result Error: $e');
    }
  }

  Future<void> _signInWithGoogle() async {
    if (!mounted) return;

    setState(() => _isLoading = true);
    debugPrint('=== Starting Google Sign In ===');

    try {
      if (kIsWeb) {
        // Use signInWithRedirect for Web to solve COOP issues
        debugPrint('Web platform detected, using redirect');
        final GoogleAuthProvider authProvider = GoogleAuthProvider();
        authProvider.setCustomParameters({'prompt': 'select_account'});
        await FirebaseAuth.instance.signInWithRedirect(authProvider);
        return; // Execution stops here as page redirects
      } else {
        // Use Google Sign-In plugin for Mobile
        debugPrint('Mobile platform detected, using Google Sign-In plugin');
        final GoogleSignIn googleSignIn = GoogleSignIn(
          scopes: ['email', 'profile'],
        );

        debugPrint('Opening Google Sign-In dialog...');
        GoogleSignInAccount? googleUser;
        try {
          googleUser = await googleSignIn.signIn();
          debugPrint('Google Sign-In dialog closed');
        } catch (e) {
          debugPrint('❌ ERROR: Google Sign-In dialog failed: $e');
          debugPrint('Error type: ${e.runtimeType}');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Google Sign-In failed: ${e.toString()}'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 5),
              ),
            );
          }
          rethrow;
        }

        debugPrint(
            'Google Sign In result: ${googleUser != null ? "Success - User selected" : "Cancelled - User cancelled"}');

        // Check if user cancelled the sign-in
        if (googleUser == null) {
          // User cancelled the sign-in
          debugPrint('❌ User cancelled Google Sign In');
          if (mounted) {
            setState(() => _isLoading = false);
          }
          return;
        }

        debugPrint('✅ Google User selected:');
        debugPrint('   Email: ${googleUser.email}');
        debugPrint('   Name: ${googleUser.displayName}');
        debugPrint('   Photo: ${googleUser.photoUrl}');

        // Get authentication details from Google
        debugPrint('Getting authentication tokens from Google...');
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        debugPrint('Tokens received:');
        debugPrint(
            '   AccessToken: ${googleAuth.accessToken != null ? "Present" : "NULL"}');
        debugPrint(
            '   IDToken: ${googleAuth.idToken != null ? "Present" : "NULL"}');

        // Check if we have the required tokens
        if (googleAuth.accessToken == null || googleAuth.idToken == null) {
          final errorMsg = 'Failed to get authentication tokens from Google. '
              'AccessToken: ${googleAuth.accessToken != null}, '
              'IDToken: ${googleAuth.idToken != null}';
          debugPrint('❌ $errorMsg');
          throw Exception(errorMsg);
        }

        // Create credential
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        // Sign in to Firebase with Google credential
        debugPrint('🔐 Signing in to Firebase with Google credential...');
        UserCredential userCredential;
        try {
          userCredential =
              await FirebaseAuth.instance.signInWithCredential(credential);
        } catch (e) {
          debugPrint('❌ Firebase signInWithCredential failed: $e');
          rethrow;
        }

        // Verify user was created/signed in
        if (userCredential.user == null) {
          debugPrint('❌ Firebase Sign In failed: User is null');
          throw Exception('Failed to sign in: User is null');
        }

        debugPrint('✅ Firebase Sign In successful!');
        debugPrint('   User ID: ${userCredential.user?.uid}');
        debugPrint('   Email: ${userCredential.user?.email}');
        debugPrint('   Display Name: ${userCredential.user?.displayName}');
        debugPrint('   Photo URL: ${userCredential.user?.photoURL}');

        // Reload user to get latest profile data including displayName
        debugPrint('🔄 Reloading user data...');
        await userCredential.user!.reload();

        // Get updated user data
        final updatedUser = FirebaseAuth.instance.currentUser;
        debugPrint('Current user after reload:');
        debugPrint('   Email: ${updatedUser?.email}');
        debugPrint('   Display Name: ${updatedUser?.displayName}');
        debugPrint('   Photo URL: ${updatedUser?.photoURL}');

        if (updatedUser != null) {
          // Update displayName and photoURL if they are null
          if ((updatedUser.displayName == null ||
                  updatedUser.displayName!.isEmpty) &&
              googleUser.displayName != null) {
            debugPrint('📝 Updating profile with Google data...');
            await updatedUser.updateProfile(
              displayName: googleUser.displayName,
              photoURL: googleUser.photoUrl,
            );
            await updatedUser.reload();
            debugPrint('✅ Profile updated successfully');
            debugPrint('   New Display Name: ${updatedUser.displayName}');
            debugPrint('   New Photo URL: ${updatedUser.photoURL}');
          }
        }

        // Verify authentication was successful
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser == null) {
          debugPrint('❌ Authentication failed: No current user');
          throw Exception('Authentication failed: No current user');
        }

        debugPrint('✅✅✅ Google Sign In COMPLETE! ✅✅✅');
        debugPrint('   Final User Email: ${currentUser.email}');
        debugPrint('   Final Display Name: ${currentUser.displayName}');
        debugPrint('   Final Photo URL: ${currentUser.photoURL}');

        // Success - load data
        if (context.mounted) {
          debugPrint('📊 Loading diary entries...');
          context.read<DiaryBloc>().add(LoadDiaryEntries());

          // Wait for auth state to propagate
          debugPrint('⏳ Waiting for auth state to propagate...');
          await Future.delayed(const Duration(milliseconds: 500));

          // Verify user is still authenticated
          final verifiedUser = FirebaseAuth.instance.currentUser;
          debugPrint('🔍 Verifying user after delay...');
          debugPrint(
              '   Verified User: ${verifiedUser != null ? "Present" : "NULL"}');
          debugPrint('   Verified Email: ${verifiedUser?.email}');

          if (verifiedUser != null && context.mounted) {
            debugPrint('✅ User verified, starting navigation...');

            // Only pop if we can, otherwise navigate to home
            if (Navigator.canPop(context)) {
              debugPrint('🚪 Navigation: Popping current route');
              Navigator.pop(context);
            } else {
              debugPrint(
                  '🚪 Navigation: Cannot pop, using pushNamedAndRemoveUntil');
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/',
                (route) => false,
              );
            }
            debugPrint('✅ Navigation complete!');
          } else {
            debugPrint('❌ Navigation failed: User not verified after delay');
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                      'Login successful but navigation failed. Please restart the app.'),
                  backgroundColor: Colors.orange,
                ),
              );
            }
          }
        }
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('❌❌❌ Firebase Auth Exception ❌❌❌');
      debugPrint('   Code: ${e.code}');
      debugPrint('   Message: ${e.message}');
      debugPrint('   Email: ${e.email}');
      debugPrint('   Credential: ${e.credential}');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Firebase Error: ${e.code}\n${e.message ?? 'Google Sign In Failed'}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e, stackTrace) {
      debugPrint('❌❌❌ General Exception ❌❌❌');
      debugPrint('   Error: $e');
      debugPrint('   Type: ${e.runtimeType}');
      debugPrint('   Stack Trace: $stackTrace');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      debugPrint('=== Google Sign In process ended ===');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _submit() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      if (_isSignUp) {
        final userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        if (userCredential.user != null && _nameController.text.isNotEmpty) {
          await userCredential.user!
              .updateProfile(displayName: _nameController.text.trim());
          await userCredential.user!.reload();
        }
      } else {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      }
      if (context.mounted) {
        // Trigger data load immediately
        context.read<DiaryBloc>().add(LoadDiaryEntries());
        context.read<ReminderBloc>().add(LoadReminders());

        // Wait a bit for auth state to update
        await Future.delayed(const Duration(milliseconds: 100));

        if (!context.mounted) return;

        // Only pop if we can, otherwise navigate to home
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        } else {
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/',
            (route) => false,
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Authentication Failed')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppTheme.white : AppTheme.black;
    final secondaryColor = isDark ? AppTheme.black : AppTheme.white;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isSignUp ? 'Sign Up' : 'Login',
          style:
              const TextStyle(fontWeight: FontWeight.bold, color: Colors.cyan),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(Icons.lock_outline, size: 80, color: primaryColor),
              const SizedBox(height: 32),
              if (_isSignUp) ...[
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.person),
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),
              ],
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: primaryColor.withValues(alpha: 0.6),
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                obscureText: _obscurePassword,
              ),
              const SizedBox(height: 24),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else ...[
                FilledButton(
                  onPressed: _submit,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: primaryColor,
                    foregroundColor: secondaryColor,
                  ),
                  child: Text(
                    _isSignUp ? 'Create Account' : 'Sign In',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _signInWithGoogle,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(color: primaryColor),
                    foregroundColor: primaryColor,
                  ),
                  icon: const Icon(Icons.g_mobiledata, size: 28),
                  label: const Text(
                    'Continue with Google',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isSignUp = !_isSignUp;
                      _emailController.clear();
                      _passwordController.clear();
                    });
                  },
                  child: Text(
                    _isSignUp
                        ? 'Already have an account? Sign In'
                        : 'Need an account? Sign Up',
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
