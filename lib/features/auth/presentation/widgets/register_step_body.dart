import 'package:bite_front_end/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class RegisterStepBody extends StatelessWidget {
  final TextEditingController ageController;
  final TextEditingController heightController;
  final TextEditingController weightController;
  final String? gender;
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
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Used to calculate your BMR, TDEE, and daily macro targets. (Optional)',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF64748B),
            height: 1.35,
          ),
        ),
        const SizedBox(height: 22),

        // Age Field (Empty by default)
        TextFormField(
          controller: ageController,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          keyboardType: TextInputType.number,
          style: const TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
          decoration: InputDecoration(
            labelText: 'Age (years)',
            labelStyle: const TextStyle(
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
            hintText: 'e.g. 25',
            prefixIcon: const Icon(
              Icons.cake_outlined,
              color: AppColors.secondary,
              size: 20,
            ),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Color(0xFFE2E8F0),
                width: 1.2,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Color(0xFFE2E8F0),
                width: 1.2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: AppColors.secondary,
                width: 2,
              ),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return null; // Optional if skipped
            }
            final ageNum = int.tryParse(value.trim());
            if (ageNum == null || ageNum < 10 || ageNum > 120) {
              return 'Age must be 10 – 120 yrs';
            }
            return null;
          },
        ),
        const SizedBox(height: 18),

        const Text(
          'Gender (Optional)',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _GenderChip(
                label: 'Male',
                value: 'male',
                selectedGroup: gender,
                onSelected: onGenderChanged,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: _GenderChip(
                label: 'Female',
                value: 'female',
                selectedGroup: gender,
                onSelected: onGenderChanged,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: _GenderChip(
                label: 'Other',
                value: 'other',
                selectedGroup: gender,
                onSelected: onGenderChanged,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),

        // Height & Weight Side by Side (Empty by default)
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: heightController,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 14,
                  ),
                  labelText: 'Height (cm)',
                  labelStyle: const TextStyle(
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                  hintText: 'e.g. 175.0',
                  prefixIcon: const Icon(
                    Icons.straighten_rounded,
                    color: AppColors.secondary,
                    size: 18,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: Color(0xFFE2E8F0),
                      width: 1.2,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: Color(0xFFE2E8F0),
                      width: 1.2,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: AppColors.secondary,
                      width: 2,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return null; // Optional if skipped
                  }
                  final h = double.tryParse(value.trim());
                  if (h == null) {
                    return 'Enter height in cm';
                  }
                  if (h < 50.0 || h > 250.0) {
                    if (h < 50.0) {
                      return 'Must be in cm (50–250 cm)';
                    }
                    return 'Must be 50–250 cm';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                controller: weightController,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 14,
                  ),
                  labelText: 'Weight (kg)',
                  labelStyle: const TextStyle(
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                  hintText: 'e.g. 70.0',
                  prefixIcon: const Icon(
                    Icons.monitor_weight_outlined,
                    color: AppColors.secondary,
                    size: 18,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: Color(0xFFE2E8F0),
                      width: 1.2,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: Color(0xFFE2E8F0),
                      width: 1.2,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: AppColors.secondary,
                      width: 2,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return null; // Optional if skipped
                  }
                  final w = double.tryParse(value.trim());
                  if (w == null) {
                    return 'Enter weight in kg';
                  }
                  if (w < 20.0 || w > 300.0) {
                    return 'Must be 20–300 kg';
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
  final String? selectedGroup;
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
      label: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColors.secondary : const Color(0xFF0F172A),
              fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ),
      ),
      selected: isSelected,
      onSelected: (_) => onSelected(value),
      selectedColor: const Color(0xFFFFF7ED),
      backgroundColor: const Color(0xFFF8FAFC),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: isSelected ? AppColors.secondary : const Color(0xFFE2E8F0),
          width: isSelected ? 2 : 1.2,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
    );
  }
}
