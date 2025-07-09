// lib/features/0_auth/view/login_screen.dart

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gsports/config/router/route_names.dart';
import 'package:gsports/core/utils/validator.dart';
import 'package:gsports/features/0_auth/controller/auth_controller.dart';
import 'package:gsports/shared_widgets/custom_button.dart';
import 'package:gsports/shared_widgets/custom_textfield.dart';

/// `LoginScreen` adalah `ConsumerStatefulWidget` karena kita perlu mengelola
/// state lokal untuk visibilitas password (`_isObscure`) dan juga
/// perlu mengakses provider Riverpod untuk state `isLoading` dan aksi login.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  // GlobalKey untuk form.
  final _formKey = GlobalKey<FormState>();

  // Controller untuk text fields.
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // State lokal untuk visibilitas password.
  bool _isObscure = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Fungsi yang dipanggil saat tombol "Login" ditekan.
  void _onLogin() {
    // Validasi form terlebih dahulu.
    if (_formKey.currentState!.validate()) {
      // Panggil method login dari AuthController.
      ref.read(authControllerProvider.notifier).login(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
            context: context,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Mengawasi state `isLoading` dari AuthController.
    final isLoading = ref.watch(authControllerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // --- Header ---
                // Anda bisa menambahkan logo di sini jika mau
                // const FlutterLogo(size: 80), 
                const SizedBox(height: 48),
                Text(
                  'Selamat Datang Kembali',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Login untuk melanjutkan ke Gsports.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.textTheme.bodySmall?.color,
                  ),
                ),
                const SizedBox(height: 48),

                // --- Form Fields ---
                CustomTextField(
                  controller: _emailController,
                  hintText: 'Alamat Email',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) => Validator.validateEmail(value),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _passwordController,
                  hintText: 'Kata Sandi',
                  prefixIcon: Icons.lock_outline,
                  isObscure: _isObscure,
                  validator: (value) => Validator.validatePassword(value),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isObscure
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                    onPressed: () {
                      setState(() {
                        _isObscure = !_isObscure;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // TODO: Implementasi Lupa Kata Sandi (setelah MVP)
                    },
                    child: Text(
                      'Lupa Kata Sandi?',
                      style: TextStyle(color: theme.colorScheme.primary),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // --- Tombol Aksi ---
                CustomButton(
                  text: 'Login',
                  isLoading: isLoading,
                  onPressed: _onLogin,
                ),
                const SizedBox(height: 24),

                // --- Link Navigasi ke Register ---
                Align(
                  alignment: Alignment.center,
                  child: Text.rich(
                    TextSpan(
                      text: 'Belum punya akun? ',
                      style: theme.textTheme.bodyMedium,
                      children: [
                        TextSpan(
                          text: 'Daftar di sini',
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              context.goNamed(RouteNames.register);
                            },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}