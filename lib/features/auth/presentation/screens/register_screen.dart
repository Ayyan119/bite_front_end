import 'dart:ui';
import 'package:bite_front_end/core/theme/app_colors.dart';
import 'package:bite_front_end/core/theme/app_radius.dart';
import 'package:bite_front_end/core/theme/app_spacing.dart';
import 'package:bite_front_end/core/widgets/bite_fade_slide.dart';
import 'package:bite_front_end/core/widgets/bite_logo.dart';
import 'package:bite_front_end/features/auth/data/models/register_request_model.dart';
import 'package:bite_front_end/features/auth/presentation/providers/auth_provider.dart';
import 'package:bite_front_end/features/auth/presentation/widgets/register_step_account.dart';
import 'package:bite_front_end/features/auth/presentation/widgets/register_step_body.dart';
import 'package:bite_front_end/features/auth/presentation/widgets/register_step_goals.dart';
import 'package:bite_front_end/features/home/presentation/providers/home_tab_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();

  // Step 1 Controllers & FocusNodes
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailFocusNode = FocusNode();

  // Step 2 Controllers & State (Empty by default)
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  String? _gender;

  // Step 3 State (Empty by default)
  String? _activityLevel;
  String? _primaryGoal;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authNotifierProvider.notifier).clearError();
    });
    _emailController.addListener(_onFieldChanged);
    _passwordController.addListener(_onFieldChanged);
    _confirmPasswordController.addListener(_onFieldChanged);
    _nameController.addListener(_onFieldChanged);
    _ageController.addListener(_onFieldChanged);
    _heightController.addListener(_onFieldChanged);
    _weightController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    if (ref.read(authNotifierProvider).hasError) {
      ref.read(authNotifierProvider.notifier).clearError();
    }
  }

  @override
  void dispose() {
    _emailController.removeListener(_onFieldChanged);
    _passwordController.removeListener(_onFieldChanged);
    _confirmPasswordController.removeListener(_onFieldChanged);
    _nameController.removeListener(_onFieldChanged);
    _ageController.removeListener(_onFieldChanged);
    _heightController.removeListener(_onFieldChanged);
    _weightController.removeListener(_onFieldChanged);
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _emailFocusNode.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_currentStep < 2) {
        setState(() {
          _currentStep++;
        });
      } else {
        _submitRegistration();
      }
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  Future<void> _submitRegistration() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final ageStr = _ageController.text.trim();
    final heightStr = _heightController.text.trim();
    final weightStr = _weightController.text.trim();

    final age = ageStr.isNotEmpty ? int.tryParse(ageStr) : null;
    final height = heightStr.isNotEmpty ? double.tryParse(heightStr) : null;
    final weight = weightStr.isNotEmpty ? double.tryParse(weightStr) : null;

    final request = RegisterRequestModel(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      displayName: _nameController.text.trim(),
      age: age,
      heightCm: height,
      weightKg: weight,
      gender: _gender,
      activityLevel: _activityLevel,
      primaryGoal: _primaryGoal,
    );

    ref.read(homeTabIndexProvider.notifier).state = 0;
    await ref.read(authNotifierProvider.notifier).register(request);

    if (mounted && ref.read(authNotifierProvider).hasError) {
      setState(() {
        _currentStep = 0;
      });
    }
  }

  bool _isAlreadyRegisteredError(dynamic error) {
    if (error == null) return false;
    final lower = error.toString().toLowerCase();
    return lower.contains('already') ||
        lower.contains('exist') ||
        lower.contains('registered') ||
        lower.contains('duplicate') ||
        lower.contains('in use') ||
        lower.contains('taken') ||
        lower.contains('409') ||
        lower.contains('400');
  }

  String _formatErrorMessage(dynamic error) {
    if (error == null) return '';
    String str = error
        .toString()
        .replaceAll('ServerException: ', '')
        .replaceAll('Exception: ', '')
        .trim();

    str = str.replaceAll(RegExp(r'\s*\(status:\s*\d+\)'), '').trim();

    if (_isAlreadyRegisteredError(error)) {
      return 'An account with this email address already exists. Please log in to your account or sign up with another email.';
    }

    if (str.contains('validateStatus')) {
      return 'Registration error. Please check your details and try again.';
    }
    return str;
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: _currentStep > 0
            ? IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Color(0xFF0F172A),
                  size: 18,
                ),
                onPressed: isLoading ? null : _previousStep,
              )
            : IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Color(0xFF0F172A),
                  size: 18,
                ),
                onPressed: () => context.go('/login'),
              ),
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppRadius.pillBorder,
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: AppColors.secondary.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const BiteLogo(size: 28, showText: true),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Background Ambient Pastel Glows
          Positioned(
            top: -40,
            left: -40,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFFF0E5).withValues(alpha: 0.7),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -60,
            right: -40,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFE2F5EE).withValues(alpha: 0.7),
                ),
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.lg,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Modern 3-Step Progress Bar
                      BiteFadeSlide(
                        delay: Duration.zero,
                        child: Row(
                          children: [
                            _StepProgressPill(
                              stepNumber: 1,
                              label: 'Account',
                              isActive: _currentStep >= 0,
                              isCurrent: _currentStep == 0,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            _StepProgressPill(
                              stepNumber: 2,
                              label: 'Body',
                              isActive: _currentStep >= 1,
                              isCurrent: _currentStep == 1,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            _StepProgressPill(
                              stepNumber: 3,
                              label: 'Goals',
                              isActive: _currentStep >= 2,
                              isCurrent: _currentStep == 2,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // High-Contrast Floating White Card Container
                      BiteFadeSlide(
                        delay: const Duration(milliseconds: 150),
                        child: Container(
                          padding: const EdgeInsets.all(26),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: const Color(0xFFE2E8F0),
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.secondary.withValues(
                                  alpha: 0.08,
                                ),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 12,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 250),
                                  transitionBuilder: (child, anim) =>
                                      FadeTransition(
                                        opacity: anim,
                                        child: ScaleTransition(
                                          scale: Tween<double>(
                                            begin: 0.98,
                                            end: 1.0,
                                          ).animate(anim),
                                          child: child,
                                        ),
                                      ),
                                  child: _currentStep == 0
                                      ? RegisterStepAccount(
                                          key: const ValueKey(0),
                                          emailController: _emailController,
                                          passwordController:
                                              _passwordController,
                                          confirmPasswordController:
                                              _confirmPasswordController,
                                          nameController: _nameController,
                                          emailFocusNode: _emailFocusNode,
                                          onSubmitted: _nextStep,
                                        )
                                      : _currentStep == 1
                                      ? RegisterStepBody(
                                          key: const ValueKey(1),
                                          ageController: _ageController,
                                          heightController: _heightController,
                                          weightController: _weightController,
                                          gender: _gender,
                                          onGenderChanged: (val) =>
                                              setState(() => _gender = val),
                                        )
                                      : RegisterStepGoals(
                                          key: const ValueKey(2),
                                          activityLevel: _activityLevel,
                                          onActivityLevelChanged: (val) =>
                                              setState(
                                                () => _activityLevel = val,
                                              ),
                                          primaryGoal: _primaryGoal,
                                          onPrimaryGoalChanged: (val) =>
                                              setState(
                                                () => _primaryGoal = val,
                                              ),
                                        ),
                                ),
                                if (authState.hasError) ...[
                                  const SizedBox(height: 16),
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFEF2F2),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: const Color(0xFFFCA5A5),
                                        width: 1.2,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(6),
                                              decoration: const BoxDecoration(
                                                color: Color(0xFFFEE2E2),
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.error_outline_rounded,
                                                color: Color(0xFFDC2626),
                                                size: 18,
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Text(
                                                _formatErrorMessage(
                                                  authState.error,
                                                ),
                                                style: const TextStyle(
                                                  fontSize: 12.5,
                                                  color: Color(0xFF991B1B),
                                                  fontWeight: FontWeight.w700,
                                                  height: 1.4,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (_isAlreadyRegisteredError(
                                          authState.error,
                                        )) ...[
                                          const SizedBox(height: 14),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: SizedBox(
                                                  height: 40,
                                                  child: ElevatedButton.icon(
                                                    onPressed: () =>
                                                        context.go('/login'),
                                                    icon: const Icon(
                                                      Icons.login_rounded,
                                                      size: 16,
                                                      color: Colors.white,
                                                    ),
                                                    label: const Text(
                                                      'Log In',
                                                      style: TextStyle(
                                                        fontSize: 12.5,
                                                        fontWeight:
                                                            FontWeight.w900,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor:
                                                          const Color(
                                                            0xFFDC2626,
                                                          ),
                                                      foregroundColor:
                                                          Colors.white,
                                                      elevation: 0,
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 8,
                                                          ),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12,
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: SizedBox(
                                                  height: 40,
                                                  child: OutlinedButton.icon(
                                                    onPressed: () {
                                                      ref
                                                          .read(
                                                            authNotifierProvider
                                                                .notifier,
                                                          )
                                                          .clearError();
                                                      setState(() {
                                                        _currentStep = 0;
                                                      });
                                                      WidgetsBinding.instance
                                                          .addPostFrameCallback((
                                                            _,
                                                          ) {
                                                            _emailFocusNode
                                                                .requestFocus();
                                                          });
                                                    },
                                                    icon: const Icon(
                                                      Icons.edit_rounded,
                                                      size: 16,
                                                      color: Color(0xFFDC2626),
                                                    ),
                                                    label: const Text(
                                                      'Edit Email',
                                                      style: TextStyle(
                                                        fontSize: 12.5,
                                                        fontWeight:
                                                            FontWeight.w900,
                                                        color: Color(
                                                          0xFFDC2626,
                                                        ),
                                                      ),
                                                    ),
                                                    style: OutlinedButton.styleFrom(
                                                      side: const BorderSide(
                                                        color: Color(
                                                          0xFFFCA5A5,
                                                        ),
                                                        width: 1.5,
                                                      ),
                                                      backgroundColor:
                                                          Colors.white,
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 8,
                                                          ),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12,
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 24),

                                // Main Action Buttons Row
                                Column(
                                  children: [
                                    Row(
                                      children: [
                                        if (_currentStep > 0) ...[
                                          Expanded(
                                            child: SizedBox(
                                              height: 48,
                                              child: OutlinedButton(
                                                onPressed: isLoading
                                                    ? null
                                                    : _previousStep,
                                                style: OutlinedButton.styleFrom(
                                                  side: const BorderSide(
                                                    color: Color(0xFFE2E8F0),
                                                    width: 1.2,
                                                  ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        AppRadius.pillBorder,
                                                  ),
                                                  foregroundColor: const Color(
                                                    0xFF64748B,
                                                  ),
                                                ),
                                                child: const Text(
                                                  'Back',
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w800,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                        ],
                                        Expanded(
                                          flex: 2,
                                          child: Container(
                                            height: 48,
                                            decoration: BoxDecoration(
                                              gradient: const LinearGradient(
                                                colors: [
                                                  AppColors.secondary,
                                                  Color(0xFFFF7700),
                                                ],
                                              ),
                                              borderRadius:
                                                  AppRadius.pillBorder,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: AppColors.secondary
                                                      .withValues(alpha: 0.35),
                                                  blurRadius: 14,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ],
                                            ),
                                            child: ElevatedButton(
                                              onPressed: isLoading
                                                  ? null
                                                  : (_currentStep == 2
                                                        ? _submitRegistration
                                                        : _nextStep),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Colors.transparent,
                                                shadowColor: Colors.transparent,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      AppRadius.pillBorder,
                                                ),
                                              ),
                                              child: isLoading
                                                  ? const SizedBox(
                                                      width: 22,
                                                      height: 22,
                                                      child:
                                                          CircularProgressIndicator(
                                                            strokeWidth: 2.5,
                                                            color: Colors.white,
                                                          ),
                                                    )
                                                  : Text(
                                                      _currentStep == 0
                                                          ? 'Create Account'
                                                          : 'Continue',
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w900,
                                                        letterSpacing: 0.5,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    if (_currentStep > 0) ...[
                                      const SizedBox(height: 10),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: TextButton.icon(
                                          onPressed: isLoading
                                              ? null
                                              : () {
                                                  if (_currentStep == 1) {
                                                    // Skip Body profile -> move to Goals step
                                                    setState(() {
                                                      _currentStep = 2;
                                                    });
                                                  } else if (_currentStep ==
                                                      2) {
                                                    // Skip Goals -> submit registration to Dashboard
                                                    _submitRegistration();
                                                  }
                                                },
                                          icon: const Icon(
                                            Icons.fast_forward_rounded,
                                            size: 15,
                                            color: AppColors.secondary,
                                          ),
                                          label: const Text(
                                            'Skip',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w900,
                                              color: AppColors.secondary,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Footer Navigation Link
                      BiteFadeSlide(
                        delay: const Duration(milliseconds: 250),
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            const Text(
                              'Already have an account? ',
                              style: TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => context.go('/login'),
                              child: const Text(
                                'Log In',
                                style: TextStyle(
                                  color: AppColors.secondary,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 14,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepProgressPill extends StatelessWidget {
  final int stepNumber;
  final String label;
  final bool isActive;
  final bool isCurrent;

  const _StepProgressPill({
    required this.stepNumber,
    required this.label,
    required this.isActive,
    required this.isCurrent,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
            height: 6,
            decoration: BoxDecoration(
              gradient: isCurrent || isActive
                  ? const LinearGradient(
                      colors: [AppColors.secondary, Color(0xFFFF7700)],
                    )
                  : null,
              color: isCurrent || isActive ? null : const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(4),
              boxShadow: isCurrent
                  ? [
                      BoxShadow(
                        color: AppColors.secondary.withValues(alpha: 0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : [],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$stepNumber. $label',
            style: TextStyle(
              fontSize: 11,
              fontWeight: isCurrent ? FontWeight.w900 : FontWeight.w700,
              color: isCurrent
                  ? AppColors.secondary
                  : (isActive
                        ? const Color(0xFF0F172A)
                        : const Color(0xFF94A3B8)),
            ),
          ),
        ],
      ),
    );
  }
}
