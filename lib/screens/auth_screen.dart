import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../utils/app_validators.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  
  bool _isLogin = true;
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();

    try {
      if (_isLogin) {
        final result = await _authService.signIn(
          email: email,
          password: password,
        );
        
        if (result is ManualUserCredential && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Identity Verified via Firestore Sync!'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
        }
      } else {
        await _authService.signUp(
          email: email,
          password: password,
          name: name,
        );
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = e.toString();
        // Clean up common error strings
        if (errorMessage.contains('Exception: ')) errorMessage = errorMessage.replaceFirst('Exception: ', '');
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage), 
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }


  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      await _authService.signInWithGoogle();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Custom 'Instant' Reset Dialog - Step by Step
  Future<void> _showForgotPasswordDialog() async {
    final emailController = TextEditingController();
    final newPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    int step = 1;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(step == 1 ? 'Find Account' : 'Set New Password'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (step == 1) ...[
                    const Text('Enter your registered email to search for your account.'),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email', 
                        border: OutlineInputBorder(),
                        errorMaxLines: 5,
                      ),
                      validator: AppValidators.validateEmail,
                    ),
                  ] else ...[
                    const Text('Account found! Enter your new password below.'),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: newPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'New Password', 
                        border: OutlineInputBorder(),
                        errorMaxLines: 5,
                      ),
                      validator: AppValidators.validatePassword,
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                
                final email = emailController.text.trim();
                final password = newPasswordController.text.trim();

                if (step == 1) {
                  // Verify if account exists before proceeding
                  final exists = await _authService.checkUserExists(email);
                  if (!exists) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Account not found with this email.'),
                          backgroundColor: Colors.red,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                    return;
                  }
                  setStateDialog(() => step = 2);
                } else {
                  try {
                    await _authService.updateFirestorePassword(email, password);
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('✅ Password updated! Logging you in...'), 
                          backgroundColor: Colors.green,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      // No need to call _handleSubmit() anymore.
                      // AuthService.updateFirestorePassword now establishes the session automatically.
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(e.toString()), 
                          backgroundColor: Colors.red,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  }
                }
              },
              child: Text(step == 1 ? 'Next' : 'Reset Now'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [colorScheme.primary, colorScheme.secondary, colorScheme.tertiary.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 30, offset: const Offset(0, 10))],
                  ),
                  padding: const EdgeInsets.all(32),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(colors: [colorScheme.primary, colorScheme.secondary]),
                            boxShadow: [BoxShadow(color: colorScheme.primary.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 8))],
                          ),
                          child: const Icon(Icons.checkroom, size: 48, color: Colors.white),
                        ),
                        const SizedBox(height: 16),
                        Text('Grace Tailor Studio', textAlign: TextAlign.center, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: colorScheme.onBackground)),
                        const SizedBox(height: 8),
                        Text(_isLogin ? 'Welcome back!' : 'Create your account', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.grey[700])),
                        const SizedBox(height: 32),

                        if (!_isLogin) ...[
                          TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person), border: OutlineInputBorder()), validator: AppValidators.validateName),
                          const SizedBox(height: 16),
                        ],

                        TextFormField(controller: _emailController, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email), border: OutlineInputBorder()), validator: AppValidators.validateEmail),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock),
                            suffixIcon: IconButton(icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off), onPressed: () => setState(() => _obscurePassword = !_obscurePassword)),
                            border: const OutlineInputBorder(),
                          ),
                          validator: (v) => (v == null || v.isEmpty) ? 'Enter password' : null,
                        ),
                        
                        if (_isLogin)
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(onPressed: _isLoading ? null : _showForgotPasswordDialog, child: Text('Forgot Password?', style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.w500, fontSize: 14))),
                          ),
                        
                        const SizedBox(height: 8),

                        _buildButton(_isLogin ? 'Login' : 'Sign Up', _handleSubmit, _isLogin ? [colorScheme.primary, colorScheme.secondary] : [const Color(0xFF14B8A6), const Color(0xFF0D9488)]),
                        const SizedBox(height: 16),

                        TextButton(onPressed: _isLoading ? null : () => setState(() => _isLogin = !_isLogin), child: Text(_isLogin ? "Don't have an account? Sign Up" : 'Already have an account? Login', style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.w600, fontSize: 15))),
                        
                        const SizedBox(height: 24),
                        Row(children: [Expanded(child: Divider(color: Colors.grey[400])), const Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('OR', style: TextStyle(color: Color(0xFF757575), fontWeight: FontWeight.w600))), Expanded(child: Divider(color: Colors.grey[400]))]),
                        const SizedBox(height: 24),
                        
                        // Enhanced Google Sign-In Button
                        _buildGoogleButton(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButton(String text, VoidCallback onTap, List<Color> colors) {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: colors[0].withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isLoading ? null : onTap,
          borderRadius: BorderRadius.circular(14),
          child: Center(
            child: _isLoading ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation<Color>(Colors.white))) : Text(text, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ),
      ),
    );
  }

  Widget _buildGoogleButton() {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isLoading ? null : _handleGoogleSignIn,
          borderRadius: BorderRadius.circular(14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(padding: const EdgeInsets.all(8), decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle), child: Image.network('https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg', height: 24, width: 24)),
              const SizedBox(width: 8),
              const Text('Register and Login with Google', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF4285F4))),
            ],
          ),
        ),
      ),
    );
  }
}
