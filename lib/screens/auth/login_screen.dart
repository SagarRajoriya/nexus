import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _nameCtrl     = TextEditingController();
  final _formKey      = GlobalKey<FormState>();
  bool _isSignUp  = false;
  bool _loading   = false;
  bool _obscure   = true;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final t  = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // Logo
                    Container(
                      width: 56, height: 56,
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.hub_rounded,
                          color: Colors.white, size: 30),
                    ).animate().fadeIn(duration: 300.ms).scale(
                        begin: const Offset(.8,.8), end: const Offset(1,1)),
                    const SizedBox(height: 24),

                    Text('Nexus', style: t.displayMedium)
                        .animate().fadeIn(delay: 100.ms, duration: 300.ms),
                    Text(
                      _isSignUp
                          ? 'Create an account to connect your devices'
                          : 'Sign in to access all your devices',
                      style: t.bodyLarge?.copyWith(
                          color: cs.onSurface.withOpacity(0.55)),
                    ).animate().fadeIn(delay: 150.ms, duration: 300.ms),
                    const SizedBox(height: 40),

                    // Name field (sign up only)
                    if (_isSignUp) ...[
                      TextFormField(
                        controller: _nameCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Your name',
                          prefixIcon: Icon(Icons.person_outline_rounded),
                        ),
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'Enter your name' : null,
                      ).animate().fadeIn(duration: 200.ms),
                      const SizedBox(height: 14),
                    ],

                    // Email
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email address',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (v) => v == null || !v.contains('@')
                          ? 'Enter a valid email' : null,
                    ).animate().fadeIn(delay: 200.ms, duration: 300.ms),
                    const SizedBox(height: 14),

                    // Password
                    TextFormField(
                      controller: _passwordCtrl,
                      obscureText: _obscure,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                        suffixIcon: IconButton(
                          icon: Icon(_obscure
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                      validator: (v) => v == null || v.length < 6
                          ? 'At least 6 characters' : null,
                    ).animate().fadeIn(delay: 250.ms, duration: 300.ms),
                    const SizedBox(height: 8),

                    // Error message
                    if (_error != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.danger.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppTheme.danger.withOpacity(0.3)),
                        ),
                        child: Row(children: [
                          const Icon(Icons.error_outline_rounded,
                              color: AppTheme.danger, size: 16),
                          const SizedBox(width: 8),
                          Expanded(child: Text(_error!,
                              style: t.bodySmall?.copyWith(color: AppTheme.danger))),
                        ]),
                      ).animate().fadeIn(duration: 200.ms).shakeX(),
                    const SizedBox(height: 16),

                    // Submit button
                    FilledButton(
                      onPressed: _loading ? null : _submit,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        minimumSize: const Size.fromHeight(52),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: _loading
                          ? const SizedBox(width: 22, height: 22,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2.5, color: Colors.white))
                          : Text(_isSignUp ? 'Create account' : 'Sign in',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600)),
                    ).animate().fadeIn(delay: 300.ms, duration: 300.ms),
                    const SizedBox(height: 20),

                    // Toggle
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text(
                        _isSignUp
                            ? 'Already have an account? '
                            : "Don't have an account? ",
                        style: t.bodyMedium,
                      ),
                      GestureDetector(
                        onTap: () => setState(() {
                          _isSignUp = !_isSignUp;
                          _error = null;
                        }),
                        child: Text(
                          _isSignUp ? 'Sign in' : 'Sign up',
                          style: t.bodyMedium?.copyWith(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ]),

                    const SizedBox(height: 40),
                    // What this does
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.07),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
                      ),
                      child: Column(children: [
                        for (final item in [
                          (Icons.devices_rounded,   'One account, all your devices'),
                          (Icons.swap_horiz_rounded,'Transfer files instantly on LAN'),
                          (Icons.cast_rounded,      'Stream apps between devices'),
                          (Icons.lock_rounded,      'Private — no data leaves your network'),
                        ])
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(children: [
                              Icon(item.$1, size: 16, color: AppTheme.primary),
                              const SizedBox(width: 10),
                              Text(item.$2, style: t.bodySmall?.copyWith(
                                  color: cs.onSurface.withOpacity(0.7))),
                            ]),
                          ),
                      ]),
                    ).animate().fadeIn(delay: 400.ms, duration: 300.ms),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    try {
      final auth = ref.read(authServiceProvider);
      if (_isSignUp) {
        await auth.signUp(_emailCtrl.text.trim(),
            _passwordCtrl.text, _nameCtrl.text.trim());
      } else {
        await auth.signIn(_emailCtrl.text.trim(), _passwordCtrl.text);
      }
      if (mounted) context.go('/');
    } on FirebaseAuthException catch (e) {
      setState(() => _error = _friendlyError(e.code));
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _friendlyError(String code) => switch (code) {
    'user-not-found'       => 'No account found with this email',
    'wrong-password'       => 'Incorrect password',
    'email-already-in-use' => 'An account with this email already exists',
    'weak-password'        => 'Password is too weak — use at least 6 characters',
    'invalid-email'        => 'Please enter a valid email address',
    'network-request-failed' => 'No internet connection',
    _                      => 'Something went wrong. Please try again.',
  };
}
