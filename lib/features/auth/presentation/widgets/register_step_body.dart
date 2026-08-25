import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class RegisterStepBody extends StatelessWidget {
  final TextEditingController ageController;
  final TextEditingController heightController;
  final TextEditingController weightController;
  final String gender;
  final ValueChanged<String> onGenderChanged;

  const RegisterStepBody({
    super.key,
    required this.ageController,
    required this.heightController,
    required this.weightController,
    required this.gender,
    required this.onGenderChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Physical Profile',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.lightTextPrimary,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Used to accurately calculate your BMR, TDEE, and daily macro targets.',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.lightTextSecondary,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 24),
        TextFormField(
          controller: ageController,
          keyboardType: TextInputType.number,
          style: const TextStyle(
            color: AppColors.lightTextPrimary,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            labelText: 'Age (years)',
            labelStyle: const TextStyle(
              color: AppColors.lightTextSecondary,
              fontWeight: FontWeight.bold,
            ),
            hintText: '25',
            prefixIcon: const Icon(
              Icons.cake_outlined,
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
              return 'Please enter your age';
            }
            final ageNum = int.tryParse(value);
            if (ageNum == null || ageNum <= 0 || ageNum > 120) {
              return 'Please enter a valid age';
            }
            return null;
          },
        ),
        const SizedBox(height: 18),
        const Text(
          'Gender',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.lightTextPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _GenderChip(
              label: 'Male',
              value: 'male',
              selectedGroup: gender,
              onSelected: onGenderChanged,
            ),
            const SizedBox(width: 8),
            _GenderChip(
              label: 'Female',
              value: 'female',
              selectedGroup: gender,
              onSelected: onGenderChanged,
            ),
            const SizedBox(width: 8),
            _GenderChip(
              label: 'Other',
              value: 'other',
              selectedGroup: gender,
              onSelected: onGenderChanged,
            ),
          ],
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: heightController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                style: const TextStyle(
                  color: AppColors.lightTextPrimary,
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  labelText: 'Height (cm)',
                  labelStyle: const TextStyle(
                    color: AppColors.lightTextSecondary,
                    fontWeight: FontWeight.bold,
                  ),
                  hintText: '175.0',
                  prefixIcon: const Icon(
                    Icons.height,
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
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 2,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Required';
                  }
                  final h = double.tryParse(value);
                  if (h == null || h <= 0 || h > 300) {
                    return 'Invalid height';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: weightController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                style: const TextStyle(
                  color: AppColors.lightTextPrimary,
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  labelText: 'Weight (kg)',
                  labelStyle: const TextStyle(
                    color: AppColors.lightTextSecondary,
                    fontWeight: FontWeight.bold,
                  ),
                  hintText: '70.0',
                  prefixIcon: const Icon(
                    Icons.monitor_weight_outlined,
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
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 2,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Required';
                  }
                  final w = double.tryParse(value);
                  if (w == null || w <= 0 || w > 500) {
                    return 'Invalid weight';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _GenderChip extends StatelessWidget {
  final String label;
  final String value;
  final String selectedGroup;
  final ValueChanged<String> onSelected;

  const _GenderChip({
    required this.label,
    required this.value,
    required this.selectedGroup,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == selectedGroup;

    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected
              ? AppColors.primaryDark
              : AppColors.lightTextPrimary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
        ),
      ),
      selected: isSelected,
      onSelected: (_) => onSelected(value),
      selectedColor: AppColors.primaryContainer,
      backgroundColor: AppColors.inputFill,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: isSelected ? AppColors.primary : AppColors.inputBorder,
          width: isSelected ? 2 : 1.5,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    );
  }
}
