import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../providers/providers.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/loading_overlay.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _emailSentSuccessfully = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authProvider.notifier).forgotPassword(_emailCtrl.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authProvider);

    ref.listen(authProvider, (_, next) {
      if (next.emailSent && !_emailSentSuccessfully) {
        _emailSentSuccessfully = true;
        showSuccessSnackBar(context, 'Reset link sent! Check your inbox.');
        Future.delayed(const Duration(seconds: 2), () {
          if (context.mounted) context.pop();
        });
      }
      if (next.error != null) {
        showErrorSnackBar(context, next.error!);
        ref.read(authProvider.notifier).clearError();
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Forgot Password')),
      body: LoadingOverlay(
        isLoading: state.isLoading,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: _emailSentSuccessfully
                ? _successView()
                : Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.lock_reset, color: AppColors.primary, size: 28),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Enter your registered email and we\'ll send a password reset link.',
                                  style: TextStyle(fontSize: 14, height: 1.5),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        AppTextField(
                          label: 'Email Address',
                          controller: _emailCtrl,
                          validator: Validators.email,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: state.isLoading ? null : _submit,
                          child: const Text('Send Reset Link'),
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: TextButton(
                            onPressed: () => context.pop(),
                            child: const Text('Back to Login'),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _successView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 60),
        const Icon(Icons.mark_email_read_outlined, size: 80, color: AppColors.primary),
        const SizedBox(height: 24),
        const Text(
          'Check Your Email',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 12),
        Text(
          'We sent a reset link to\n${_emailCtrl.text.trim()}',
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 15, height: 1.5),
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: () => context.pop(),
          child: const Text('Back to Login'),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () {
            setState(() => _emailSentSuccessfully = false);
            ref.read(authProvider.notifier).resetEmailSent();
            ref.read(authProvider.notifier).clearError();
          },
          child: const Text('Resend Email'),
        ),
      ],
    );
  }
}
