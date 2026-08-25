import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
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
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.lightSurface,
            borderRadius: BorderRadius.circular(20),
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
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // High Contrast Step Indicator
                  Row(
                    children: [
                      _StepProgressPill(
                        stepNumber: 1,
                        label: 'Account',
                        isActive: _currentStep >= 0,
                        isCurrent: _currentStep == 0,
                      ),
                      const SizedBox(width: 8),
                      _StepProgressPill(
                        stepNumber: 2,
                        label: 'Body',
                        isActive: _currentStep >= 1,
                        isCurrent: _currentStep == 1,
                      ),
                      const SizedBox(width: 8),
                      _StepProgressPill(
                        stepNumber: 3,
                        label: 'Goals',
                        isActive: _currentStep >= 2,
                        isCurrent: _currentStep == 2,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // White Form Card
                  Container(
                    padding: const EdgeInsets.all(28.0),
                    decoration: BoxDecoration(
                      color: AppColors.lightSurface,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: AppColors.inputBorder,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (_currentStep == 0)
                            RegisterStepAccount(
                              emailController: _emailController,
                              passwordController: _passwordController,
                              nameController: _nameController,
                            )
                          else if (_currentStep == 1)
                            RegisterStepBody(
                              ageController: _ageController,
                              heightController: _heightController,
                              weightController: _weightController,
                              gender: _gender,
                              onGenderChanged: (val) =>
                                  setState(() => _gender = val),
                            )
                          else
                            RegisterStepGoals(
                              activityLevel: _activityLevel,
                              onActivityLevelChanged: (val) =>
                                  setState(() => _activityLevel = val),
                              primaryGoal: _primaryGoal,
                              onPrimaryGoalChanged: (val) =>
                                  setState(() => _primaryGoal = val),
                            ),
                          if (authState.hasError) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.errorContainer,
                                borderRadius: BorderRadius.circular(12),
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
                                  const SizedBox(width: 8),
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
                          const SizedBox(height: 28),
                          Row(
                            children: [
                              if (_currentStep > 0) ...[
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: isLoading ? null : _previousStep,
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      side: const BorderSide(
                                        color: AppColors.inputBorder,
                                        width: 1.5,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    child: const Text(
                                      'Back',
                                      style: TextStyle(
                                        color: AppColors.lightTextSecondary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                              ],
                              Expanded(
                                flex: 2,
                                child: ElevatedButton(
                                  onPressed: isLoading ? null : _nextStep,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 2,
                                  ),
                                  child: isLoading
                                      ? const SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            color: Colors.white,
                                          ),
                                        )
                                      : Text(
                                          _currentStep == 2
                                              ? 'Create Account'
                                              : 'Continue',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
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
          const SizedBox(height: 6),
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
