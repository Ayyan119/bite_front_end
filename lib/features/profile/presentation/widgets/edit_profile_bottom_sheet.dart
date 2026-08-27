import 'package:bite_front_end/core/theme/app_colors.dart';
import 'package:bite_front_end/core/theme/app_radius.dart';
import 'package:bite_front_end/features/profile/data/models/user_profile_response_model.dart';
import 'package:bite_front_end/features/profile/data/models/user_profile_update_model.dart';
import 'package:bite_front_end/features/profile/presentation/providers/profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EditProfileBottomSheet extends ConsumerStatefulWidget {
  final UserProfileResponseModel profile;

  const EditProfileBottomSheet({super.key, required this.profile});

  @override
  ConsumerState<EditProfileBottomSheet> createState() =>
      _EditProfileBottomSheetState();
}

class _EditProfileBottomSheetState
    extends ConsumerState<EditProfileBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;

  late String _selectedGender;
  late String _selectedActivityLevel;
  late String _selectedPrimaryGoal;
  bool _isSaving = false;

  String _normalizeGender(String raw) {
    final val = raw.toLowerCase().trim();
    if (val.startsWith('f') || val.contains('female')) return 'female';
    return 'male';
  }

  String _normalizeActivityLevel(String raw) {
    final val = raw.toLowerCase().trim();
    if (val.contains('sedentary')) return 'sedentary';
    if (val.contains('light')) return 'light';
    if (val.contains('moderate')) return 'moderate';
    if (val.contains('very')) return 'very_active';
    if (val.contains('active')) return 'active';
    return 'moderate';
  }

  String _normalizePrimaryGoal(String raw) {
    final val = raw.toLowerCase().trim();
    if (val.contains('weight') || val.contains('fat') || val.contains('loss')) {
      return 'weight_loss';
    }
    if (val.contains('muscle') || val.contains('gain')) return 'muscle_gain';
    return 'maintenance';
  }

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.displayName);
    _ageController = TextEditingController(text: widget.profile.age.toString());
    _heightController = TextEditingController(
      text: widget.profile.heightCm.round().toString(),
    );
    _weightController = TextEditingController(
      text: widget.profile.weightKg.toStringAsFixed(1),
    );

    _selectedGender = _normalizeGender(widget.profile.gender);
    _selectedActivityLevel = _normalizeActivityLevel(
      widget.profile.activityLevel,
    );
    _selectedPrimaryGoal = _normalizePrimaryGoal(widget.profile.primaryGoal);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    final updateModel = UserProfileUpdateModel(
      displayName: _nameController.text.trim(),
      age: int.tryParse(_ageController.text.trim()),
      heightCm: double.tryParse(_heightController.text.trim()),
      weightKg: double.tryParse(_weightController.text.trim()),
      gender: _selectedGender,
      activityLevel: _selectedActivityLevel,
      primaryGoal: _selectedPrimaryGoal,
    );

    final success = await ref
        .read(profileNotifierProvider.notifier)
        .updateProfile(updateModel);

    if (mounted) {
      setState(() {
        _isSaving = false;
      });

      if (success) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile & metabolic targets updated!'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update profile. Please try again.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Edit Profile Metrics',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Color(0xFF64748B),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Display Name
              TextFormField(
                controller: _nameController,
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontWeight: FontWeight.w700,
                ),
                decoration: InputDecoration(
                  labelText: 'Display Name',
                  prefixIcon: const Icon(
                    Icons.person_outline,
                    color: AppColors.secondary,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                ),
                validator: (val) =>
                    val == null || val.trim().isEmpty ? 'Name required' : null,
              ),
              const SizedBox(height: 14),

              // Age, Height, Weight Row
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _ageController,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontWeight: FontWeight.w700,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Age',
                        suffixText: 'yrs',
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: Color(0xFFE2E8F0),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: Color(0xFFE2E8F0),
                          ),
                        ),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Required';
                        }
                        final age = int.tryParse(val.trim());
                        if (age == null || age < 10 || age > 120) {
                          return '10–120 yrs';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _heightController,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontWeight: FontWeight.w700,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Height',
                        suffixText: 'cm',
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: Color(0xFFE2E8F0),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: Color(0xFFE2E8F0),
                          ),
                        ),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Required';
                        }
                        final h = double.tryParse(val.trim());
                        if (h == null) return 'In cm';
                        if (h < 50.0 || h > 250.0) {
                          if (h < 50.0) return 'In cm (50+)';
                          return '50–250 cm';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _weightController,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontWeight: FontWeight.w700,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Weight',
                        suffixText: 'kg',
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: Color(0xFFE2E8F0),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: Color(0xFFE2E8F0),
                          ),
                        ),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Required';
                        }
                        final w = double.tryParse(val.trim());
                        if (w == null) return 'In kg';
                        if (w < 20.0 || w > 300.0) {
                          return '20–300 kg';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Gender Selector
              const Text(
                'Gender',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith<Color>((
                    states,
                  ) {
                    if (states.contains(WidgetState.selected)) {
                      return AppColors.secondary;
                    }
                    return const Color(0xFFF8FAFC);
                  }),
                  foregroundColor: WidgetStateProperty.resolveWith<Color>((
                    states,
                  ) {
                    if (states.contains(WidgetState.selected)) {
                      return Colors.white;
                    }
                    return const Color(0xFF334155);
                  }),
                  iconColor: WidgetStateProperty.resolveWith<Color>((states) {
                    if (states.contains(WidgetState.selected)) {
                      return Colors.white;
                    }
                    return const Color(0xFF64748B);
                  }),
                  side: WidgetStateProperty.all<BorderSide>(
                    const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  textStyle: WidgetStateProperty.all<TextStyle>(
                    const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                  ),
                ),
                segments: const [
                  ButtonSegment(
                    value: 'male',
                    label: Text('Male'),
                    icon: Icon(Icons.male_rounded),
                  ),
                  ButtonSegment(
                    value: 'female',
                    label: Text('Female'),
                    icon: Icon(Icons.female_rounded),
                  ),
                ],
                selected: {_selectedGender},
                onSelectionChanged: (val) {
                  setState(() {
                    _selectedGender = val.first;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Primary Goal Chips
              const Text(
                'Primary Goal',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  _buildGoalChip('weight_loss', '🔥 Weight Loss'),
                  _buildGoalChip('muscle_gain', '💪 Muscle Gain'),
                  _buildGoalChip('maintenance', '⚖️ Maintenance'),
                ],
              ),
              const SizedBox(height: 16),

              // Activity Level Dropdown
              const Text(
                'Activity Level',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _selectedActivityLevel,
                decoration: InputDecoration(
                  prefixIcon: const Icon(
                    Icons.fitness_center_rounded,
                    color: AppColors.secondary,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'sedentary',
                    child: Text('Sedentary (Little/No exercise)'),
                  ),
                  DropdownMenuItem(
                    value: 'light',
                    child: Text('Lightly Active (1-3 days/wk)'),
                  ),
                  DropdownMenuItem(
                    value: 'moderate',
                    child: Text('Moderately Active (3-5 days/wk)'),
                  ),
                  DropdownMenuItem(
                    value: 'active',
                    child: Text('Active (6-7 days/wk)'),
                  ),
                  DropdownMenuItem(
                    value: 'very_active',
                    child: Text('Very Active (Hard exercise/job)'),
                  ),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedActivityLevel = val;
                    });
                  }
                },
              ),
              const SizedBox(height: 24),

              // Submit Button
              Container(
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.secondary, Color(0xFFFF7700)],
                  ),
                  borderRadius: AppRadius.pillBorder,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.secondary.withValues(alpha: 0.40),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.pillBorder,
                    ),
                    elevation: 0,
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Save Changes',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGoalChip(String value, String label) {
    final isSelected = _selectedPrimaryGoal == value;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: isSelected ? Colors.white : const Color(0xFF334155),
        ),
      ),
      selected: isSelected,
      selectedColor: AppColors.secondary,
      backgroundColor: const Color(0xFFF8FAFC),
      side: BorderSide(
        color: isSelected ? AppColors.secondary : const Color(0xFFE2E8F0),
      ),
      showCheckmark: false,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedPrimaryGoal = value;
          });
        }
      },
    );
  }
}
