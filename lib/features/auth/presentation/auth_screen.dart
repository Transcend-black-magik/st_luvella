import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/tokens.dart';
import '../../../core/state/store_state.dart';
import '../../../core/widgets/editorial_widgets.dart';

enum AuthMode { login, register, forgot }

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key, required this.mode, this.redirectTo});
  final AuthMode mode;
  final String? redirectTo;
  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  bool hidden = true;
  bool consent = false;
  bool sent = false;

  @override
  Widget build(BuildContext context) {
    final title = widget.mode == AuthMode.login
        ? 'Welcome back.'
        : widget.mode == AuthMode.register
        ? 'Create your account.'
        : 'Reset your password.';
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: context.pagePadding.copyWith(top: 64, bottom: 84),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 490),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Center(
                      child: Eyebrow('st.luvella / Private account'),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.mode == AuthMode.login
                          ? 'Sign in to view saved fits, orders and private styling sessions.'
                          : widget.mode == AuthMode.register
                          ? 'Save your wardrobe, fitting profile and orders in one place.'
                          : 'We’ll send a secure reset link to your email address.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.muted),
                    ),
                    const SizedBox(height: 34),
                    if (sent) ...[
                      Container(
                        color: AppColors.white,
                        padding: const EdgeInsets.all(22),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.mark_email_read_outlined,
                              color: AppColors.success,
                            ),
                            SizedBox(width: 15),
                            Expanded(
                              child: Text(
                                'Reset instructions sent. Check your inbox.',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                    const TextField(
                      key: Key('auth-email'),
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: [AutofillHints.email],
                      decoration: InputDecoration(labelText: 'Email address'),
                    ),
                    const SizedBox(height: 14),
                    if (widget.mode != AuthMode.forgot) ...[
                      TextField(
                        key: const Key('auth-password'),
                        obscureText: hidden,
                        autofillHints: const [AutofillHints.password],
                        decoration: InputDecoration(
                          labelText: 'Password',
                          suffixIcon: IconButton(
                            onPressed: () => setState(() => hidden = !hidden),
                            icon: Icon(
                              hidden
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (widget.mode == AuthMode.login)
                        Align(
                          alignment: Alignment.centerRight,
                          child: UnderlineLink(
                            'Forgot password?',
                            onTap: () => context.go('/forgot-password'),
                          ),
                        ),
                      if (widget.mode == AuthMode.register)
                        CheckboxListTile(
                          value: consent,
                          contentPadding: EdgeInsets.zero,
                          controlAffinity: ListTileControlAffinity.leading,
                          onChanged: (v) =>
                              setState(() => consent = v ?? false),
                          title: const Text(
                            'I agree to the terms and privacy notice.',
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                    ],
                    const SizedBox(height: 16),
                    ElevatedButton(
                      key: const Key('auth-submit'),
                      onPressed: _submit,
                      child: Text(
                        widget.mode == AuthMode.login
                            ? 'SIGN IN'
                            : widget.mode == AuthMode.register
                            ? 'CREATE ACCOUNT'
                            : 'SEND RESET LINK',
                      ),
                    ),
                    if (widget.mode != AuthMode.forgot) ...[
                      const SizedBox(height: 22),
                      Row(
                        children: [
                          const Expanded(child: Divider()),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              'OR',
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                          ),
                          const Expanded(child: Divider()),
                        ],
                      ),
                      const SizedBox(height: 22),
                      OutlinedButton.icon(
                        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Google sign-in will connect through Firebase Authentication.',
                            ),
                          ),
                        ),
                        icon: const Icon(Icons.g_mobiledata, size: 28),
                        label: const Text('CONTINUE WITH GOOGLE'),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () =>
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Phone verification integration placeholder.',
                                ),
                              ),
                            ),
                        icon: const Icon(Icons.phone_outlined, size: 19),
                        label: const Text('CONTINUE WITH PHONE'),
                      ),
                    ],
                    const SizedBox(height: 28),
                    Center(
                      child: widget.mode == AuthMode.login
                          ? UnderlineLink(
                              'New here? Create an account',
                              onTap: () => context.go('/register'),
                            )
                          : UnderlineLink(
                              widget.mode == AuthMode.register
                                  ? 'Already have an account? Sign in'
                                  : 'Return to sign in',
                              onTap: () => context.go('/login'),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const AppFooter(),
        ],
      ),
    );
  }

  void _submit() {
    if (widget.mode == AuthMode.forgot) {
      setState(() => sent = true);
      return;
    }
    ref.read(authProvider.notifier).signIn();
    context.go(widget.redirectTo ?? '/profile');
  }
}
