// lib/features/0_auth/view/register_screen.dart

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gsports/config/router/route_names.dart';
import 'package:gsports/core/utils/validator.dart'; // Kita akan buat file ini
import 'package:gsports/features/0_auth/controller/auth_controller.dart';
import 'package:gsports/shared_widgets/custom_button.dart';
import 'package:gsports/shared_widgets/custom_textfield.dart';

/// `RegisterScreen` adalah `ConsumerStatefulWidget`.
/// `ConsumerStatefulWidget` adalah kombinasi dari `StatefulWidget` dan `ConsumerWidget`,
/// memungkinkan kita untuk mengelola state lokal (seperti `_isObscure`)
/// sekaligus mengakses provider Riverpod.
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  // GlobalKey untuk mengelola state dan validasi dari Form.
  final _formKey = GlobalKey<FormState>();

  // Controller untuk setiap text field.
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // State lokal untuk mengontrol visibilitas password.
  bool _isObscurePassword = true;
  bool _isObscureConfirmPassword = true;

  // Pastikan untuk melepaskan controller saat widget dihancurkan
  // untuk mencegah kebocoran memori.
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Fungsi yang dipanggil saat tombol "Daftar" ditekan.
  void _onSignUp() {
    // `validate()` akan menjalankan semua fungsi validator di TextFormField.
    // Jika semua valid, ia akan mengembalikan `true`.
    if (_formKey.currentState!.validate()) {
      // Panggil method signUp dari AuthController.
      // `ref.read` digunakan di dalam callback seperti ini untuk memanggil fungsi.
      ref.read(authControllerProvider.notifier).signUp(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
            name: _nameController.text.trim(),
            context: context,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Mengawasi state `isLoading` dari AuthController.
    // `ref.watch` digunakan di dalam method `build` agar UI
    // secara otomatis membangun ulang saat state ini berubah.
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
                Text(
                  'Buat Akun Baru',
                  style: theme.textTheme.headlineLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Mulai petualangan olahragamu bersama Gsports!',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.textTheme.bodySmall?.color,
                  ),
                ),
                const SizedBox(height: 48),

                // --- Form Fields ---
                CustomTextField(
                  controller: _nameController,
                  hintText: 'Nama Lengkap',
                  prefixIcon: Icons.person_outline,
                  validator: (value) => Validator.validateName(value),
                ),
                const SizedBox(height: 16),
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
                  isObscure: _isObscurePassword,
                  validator: (value) => Validator.validatePassword(value),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isObscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                    onPressed: () {
                      setState(() {
                        _isObscurePassword = !_isObscurePassword;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _confirmPasswordController,
                  hintText: 'Konfirmasi Kata Sandi',
                  prefixIcon: Icons.lock_outline,
                  isObscure: _isObscureConfirmPassword,
                  validator: (value) => Validator.validateConfirmPassword(
                    value,
                    _passwordController.text,
                  ),
                   suffixIcon: IconButton(
                    icon: Icon(
                      _isObscureConfirmPassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                    onPressed: () {
                      setState(() {
                        _isObscureConfirmPassword = !_isObscureConfirmPassword;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 32),

                // --- Tombol Aksi ---
                CustomButton(
                  text: 'Daftar',
                  isLoading: isLoading,
                  onPressed: _onSignUp,
                ),
                const SizedBox(height: 24),

                // --- Link Navigasi ke Login ---
                Align(
                  alignment: Alignment.center,
                  child: Text.rich(
                    TextSpan(
                      text: 'Sudah punya akun? ',
                      style: theme.textTheme.bodyMedium,
                      children: [
                        TextSpan(
                          text: 'Login di sini',
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                          // `recognizer` membuat bagian teks ini bisa di-tap.
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              // Gunakan GoRouter untuk navigasi yang aman.
                              context.goNamed(RouteNames.login);
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