import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class RegisterStepAccount extends StatefulWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController nameController;

  const RegisterStepAccount({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.nameController,
  });

  @override
  State<RegisterStepAccount> createState() => _RegisterStepAccountState();
}

class _RegisterStepAccountState extends State<RegisterStepAccount> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Account Details',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.lightTextPrimary,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Enter your credentials to create your personal Bite profile.',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.lightTextSecondary,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 24),
        TextFormField(
          controller: widget.nameController,
          textCapitalization: TextCapitalization.words,
          style: const TextStyle(
            color: AppColors.lightTextPrimary,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            labelText: 'Full Name / Display Name',
            labelStyle: const TextStyle(
              color: AppColors.lightTextSecondary,
              fontWeight: FontWeight.bold,
            ),
            hintText: 'Jane Smith',
            prefixIcon: const Icon(
              Icons.person_outline,
              color: AppColors.primary,
            ),
            filled: true,
            fillColor: AppColors.inputFill,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: AppColors.inputBorder,
                width: 1.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: AppColors.inputBorder,
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter your display name';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: widget.emailController,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(
            color: AppColors.lightTextPrimary,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            labelText: 'Email Address',
            labelStyle: const TextStyle(
              color: AppColors.lightTextSecondary,
              fontWeight: FontWeight.bold,
            ),
            hintText: 'jane@example.com',
            prefixIcon: const Icon(
              Icons.email_outlined,
              color: AppColors.primary,
            ),
            filled: true,
            fillColor: AppColors.inputFill,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: AppColors.inputBorder,
                width: 1.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: AppColors.inputBorder,
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter your email';
            }
            if (!value.contains('@') || !value.contains('.')) {
              return 'Please enter a valid email address';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: widget.passwordController,
          obscureText: _obscurePassword,
          style: const TextStyle(
            color: AppColors.lightTextPrimary,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            labelText: 'Password',
            labelStyle: const TextStyle(
              color: AppColors.lightTextSecondary,
              fontWeight: FontWeight.bold,
            ),
            prefixIcon: const Icon(
              Icons.lock_outline,
              color: AppColors.primary,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: AppColors.lightTextSecondary,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
            filled: true,
            fillColor: AppColors.inputFill,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: AppColors.inputBorder,
                width: 1.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: AppColors.inputBorder,
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a password';
            }
            if (value.length < 6) {
              return 'Password must be at least 6 characters long';
            }
            return null;
          },
        ),
      ],
    );
  }
}
