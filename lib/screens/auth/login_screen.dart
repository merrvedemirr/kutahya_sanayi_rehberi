import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sanayi_websites/core/constants/app_colors.dart';
import 'package:sanayi_websites/core/constants/app_text_styles.dart';
import 'package:sanayi_websites/core/constants/image_extensions.dart';
import 'package:sanayi_websites/core/routing/route_utils.dart';
import 'package:sanayi_websites/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginScreen extends StatefulWidget {
  final String? redirectTo;
  const LoginScreen({super.key, this.redirectTo});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _showSnack(String msg, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: AppTextStyles.bodySmall.copyWith(
            color: isError ? Colors.white : Colors.black,
          ),
        ),
        backgroundColor: isError ? AppColors.accentDark : AppColors.accent,
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
    );
  }

  String? _validateEmail(String? v) {
    final value = (v ?? '').trim();
    if (value.isEmpty) return 'Email gerekli';
    if (!value.contains('@') || !value.contains('.')) return 'Email geçersiz';
    return null;
  }

  String? _validatePassword(String? v) {
    final value = v ?? '';
    if (value.isEmpty) return 'Şifre gerekli';
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final auth = AuthService();
      await auth.signInWithEmail(
        email: _emailCtrl.text,
        password: _passwordCtrl.text,
      );

      final redirectTo = RouteUtils.safeRedirect(widget.redirectTo);
      if (mounted) {
        context.go(redirectTo ?? '/user');
      }
    } on AuthException catch (e) {
      _showSnack(e.message);
    } catch (e) {
      _showSnack('Hata: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final redirectTo = widget.redirectTo;
    final registerUrl = redirectTo?.isNotEmpty == true
        ? '/register?redirect=${Uri.encodeComponent(redirectTo!)}'
        : '/register';

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        automaticallyImplyLeading: false,
        title: Text('GİRİŞ YAP', style: AppTextStyles.headlineMedium),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: Container(height: 2, color: AppColors.accent),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Form(
            key: _formKey,
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: AppColors.surface2,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 24,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 100,
                          child: Image.asset(ImageItems.homebanner.imagePath),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Hesabına giriş yap',
                          style: AppTextStyles.displayMedium.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Dükkan eklemek için giriş gerekir.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 18),
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      style: AppTextStyles.bodyMedium,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        hintText: 'ornek@mail.com',
                      ),
                      validator: _validateEmail,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _passwordCtrl,
                      obscureText: true,
                      style: AppTextStyles.bodyMedium,
                      decoration: const InputDecoration(labelText: 'Şifre'),
                      validator: _validatePassword,
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _submit,
                        child: _loading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'GİRİŞ YAP',
                                style: AppTextStyles.cardTitle.copyWith(
                                  color: Colors.black,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => context.push(registerUrl),
                      child: Text(
                        'Hesabın yok mu? Kayıt ol',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.accent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
