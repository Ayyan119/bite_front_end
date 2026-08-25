import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/bite_logo.dart';
import '../../data/models/register_request_model.dart';
import '../providers/auth_provider.dart';
import '../widgets/register_step_account.dart';
import '../widgets/register_step_body.dart';
import '../widgets/register_step_goals.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();

  // Step 1 Controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  // Step 2 Controllers & State
  final _ageController = TextEditingController(text: '25');
  final _heightController = TextEditingController(text: '175.0');
  final _weightController = TextEditingController(text: '70.0');
  String _gender = 'male';

  // Step 3 State
  String _activityLevel = 'moderate';
  String _primaryGoal = 'maintenance';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
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
    final age = int.tryParse(_ageController.text.trim()) ?? 25;
    final height = double.tryParse(_heightController.text.trim()) ?? 175.0;
    final weight = double.tryParse(_weightController.text.trim()) ?? 70.0;

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

    await ref.read(authNotifierProvider.notifier).register(request);
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
        leading: _currentStep > 0
            ? IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: AppColors.lightTextPrimary,
                  size: 20,
                ),
                onPressed: isLoading ? null : _previousStep,
              )
            : null,
        title: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: AppColors.lightSurface,
            borderRadius: AppRadius.pillBorder,
            border: Border.all(color: AppColors.inputBorder),
          ),
          child: const BiteLogo(size: 32, showText: true),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xxl,
              vertical: AppSpacing.lg,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Step Progress Indicator
                  Row(
                    children: [
                      _StepProgressPill(
                        stepNumber: 1,
                        label: 'Account',
                        isActive: _currentStep >= 0,
                        isCurrent: _currentStep == 0,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      _StepProgressPill(
                        stepNumber: 2,
                        label: 'Body',
                        isActive: _currentStep >= 1,
                        isCurrent: _currentStep == 1,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      _StepProgressPill(
                        stepNumber: 3,
                        label: 'Goals',
                        isActive: _currentStep >= 2,
                        isCurrent: _currentStep == 2,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // High-Contrast White Card Container
                  AppCard(
                    padding: const EdgeInsets.all(AppSpacing.xxl),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            child: _currentStep == 0
                                ? RegisterStepAccount(
                                    key: const ValueKey(0),
                                    emailController: _emailController,
                                    passwordController: _passwordController,
                                    nameController: _nameController,
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
                                        setState(() => _activityLevel = val),
                                    primaryGoal: _primaryGoal,
                                    onPrimaryGoalChanged: (val) =>
                                        setState(() => _primaryGoal = val),
                                  ),
                          ),
                          if (authState.hasError) ...[
                            const SizedBox(height: AppSpacing.lg),
                            Container(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              decoration: BoxDecoration(
                                color: AppColors.errorContainer,
                                borderRadius: AppRadius.mdBorder,
                                border: Border.all(
                                  color: AppColors.error.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.error_outline,
                                    color: AppColors.error,
                                    size: 20,
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  Expanded(
                                    child: Text(
                                      authState.error.toString().replaceAll(
                                        'ServerException: ',
                                        '',
                                      ),
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: AppColors.error,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: AppSpacing.xxl),
                          Row(
                            children: [
                              if (_currentStep > 0) ...[
                                Expanded(
                                  child: AppButton(
                                    label: 'Back',
                                    isLoading: isLoading,
                                    onPressed: _previousStep,
                                    variant: AppButtonVariant.outline,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),
                              ],
                              Expanded(
                                flex: 2,
                                child: AppButton(
                                  label: _currentStep == 2
                                      ? 'Create Account'
                                      : 'Continue',
                                  isLoading: isLoading,
                                  onPressed: _nextStep,
                                  variant: AppButtonVariant.primary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      const Text(
                        'Already have an account? ',
                        style: TextStyle(
                          color: AppColors.lightTextSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.go('/login'),
                        child: const Text(
                          'Log In',
                          style: TextStyle(
                            color: AppColors.primaryDark,
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
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
              color: isCurrent
                  ? AppColors.primary
                  : (isActive ? AppColors.primaryLight : AppColors.inputBorder),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '$stepNumber. $label',
            style: TextStyle(
              fontSize: 12,
              fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
              color: isCurrent
                  ? AppColors.primaryDark
                  : AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
