import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sanayi_websites/core/constants/app_colors.dart';
import 'package:sanayi_websites/core/constants/app_text_styles.dart';
import 'package:sanayi_websites/core/constants/image_extensions.dart';
import 'package:sanayi_websites/core/routing/route_utils.dart';
import 'package:sanayi_websites/services/auth_service.dart';
import 'package:sanayi_websites/services/user_profile_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterScreen extends StatefulWidget {
  final String? redirectTo;
  const RegisterScreen({super.key, this.redirectTo});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _password2Ctrl = TextEditingController();

  bool _loading = false;

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _password2Ctrl.dispose();
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
    if (value.length < 6) return 'Şifre en az 6 karakter olmalı';
    return null;
  }

  String? _validateNamePart(String? v, {required String label}) {
    final value = (v ?? '').trim();
    if (value.isEmpty) return '$label gerekli';
    if (value.length < 2) return '$label en az 2 karakter olmalı';
    if (value.length > 30) return '$label çok uzun';
    final ok = RegExp(r"^[A-Za-zÇĞİÖŞÜçğıöşü'\- ]+$").hasMatch(value);
    if (!ok) return '$label sadece harf içermeli';
    if (value.contains('  ')) return '$label içinde çift boşluk olmasın';
    return null;
  }

  String _fullName() {
    final first = _firstNameCtrl.text.trim();
    final last = _lastNameCtrl.text.trim();
    return '$first $last'.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_passwordCtrl.text != _password2Ctrl.text) {
      _showSnack('Şifreler eşleşmiyor');
      return;
    }

    setState(() => _loading = true);
    try {
      final fullName = _fullName();
      final auth = AuthService();
      final res = await auth.signUpWithEmail(
        username: fullName,
        email: _emailCtrl.text,
        password: _passwordCtrl.text,
      );

      final session =
          res.session ?? Supabase.instance.client.auth.currentSession;
      if (session == null) {
        _showSnack(
          'Hesap oluşturuldu. Giriş yapmanız gerekebilir.',
          isError: false,
        );
        if (mounted) context.go('/login');
        return;
      }

      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        await UserProfileService().upsertMyProfile(
          userId: user.id,
          username: fullName,
          email: user.email,
        );
      }

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
    final loginUrl = redirectTo?.isNotEmpty == true
        ? '/login?redirect=${Uri.encodeComponent(redirectTo!)}'
        : '/login';

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        automaticallyImplyLeading: false,
        title: Text('KAYIT OL', style: AppTextStyles.headlineMedium),
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
                          'Hesap oluştur',
                          style: AppTextStyles.displayMedium.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Dükkan eklemek için hesap gerekir.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 18),
                    LayoutBuilder(
                      builder: (context, c) {
                        final isWide = c.maxWidth >= 420;

                        final firstField = Expanded(
                          child: TextFormField(
                            controller: _firstNameCtrl,
                            style: AppTextStyles.bodyMedium,
                            decoration: const InputDecoration(
                              labelText: 'İsim',
                              hintText: 'Örn: Mehmet',
                            ),
                            validator: (v) =>
                                _validateNamePart(v, label: 'İsim'),
                            textInputAction: TextInputAction.next,
                          ),
                        );

                        final lastField = Expanded(
                          child: TextFormField(
                            controller: _lastNameCtrl,
                            style: AppTextStyles.bodyMedium,
                            decoration: const InputDecoration(
                              labelText: 'Soyisim',
                              hintText: 'Örn: Yılmaz',
                            ),
                            validator: (v) =>
                                _validateNamePart(v, label: 'Soyisim'),
                            textInputAction: TextInputAction.next,
                          ),
                        );

                        if (!isWide) {
                          return Column(
                            children: [
                              firstField,
                              const SizedBox(height: 10),
                              lastField,
                            ],
                          );
                        }

                        return Row(
                          children: [
                            firstField,
                            const SizedBox(width: 10),
                            lastField,
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 10),
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
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _password2Ctrl,
                      obscureText: true,
                      style: AppTextStyles.bodyMedium,
                      decoration: const InputDecoration(
                        labelText: 'Şifre (tekrar)',
                      ),
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
                                'KAYIT OL',
                                style: AppTextStyles.cardTitle.copyWith(
                                  color: Colors.black,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => context.push(loginUrl),
                      child: Text(
                        'Zaten hesabın var mı? Giriş yap',
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
