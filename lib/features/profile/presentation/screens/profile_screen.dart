import 'package:bite_front_end/core/theme/app_colors.dart';
import 'package:bite_front_end/core/widgets/bite_fade_slide.dart';
import 'package:bite_front_end/features/auth/presentation/providers/auth_provider.dart';
import 'package:bite_front_end/features/profile/data/models/user_profile_response_model.dart';
import 'package:bite_front_end/features/profile/presentation/providers/profile_provider.dart';
import 'package:bite_front_end/features/profile/presentation/widgets/bmr_tdee_card.dart';
import 'package:bite_front_end/features/profile/presentation/widgets/edit_profile_bottom_sheet.dart';
import 'package:bite_front_end/features/profile/presentation/widgets/profile_header_card.dart';
import 'package:bite_front_end/features/profile/presentation/widgets/target_macros_card.dart';
import 'package:bite_front_end/features/profile/presentation/widgets/user_info_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileNotifierProvider.notifier).fetchProfile();
    });
  }

  void _openEditBottomSheet(
    BuildContext context,
    UserProfileResponseModel profile,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditProfileBottomSheet(profile: profile),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileNotifierProvider);

    final topPadding =
        (kToolbarHeight + 14.0 + MediaQuery.of(context).padding.top + 8.0) *
        0.65;

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: profileAsync.when(
        data: (profile) {
          return RefreshIndicator(
            onRefresh: () async {
              await ref.read(profileNotifierProvider.notifier).fetchProfile();
            },
            color: AppColors.secondary,
            backgroundColor: Colors.white,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.only(
                top: topPadding,
                bottom: 95,
                left: 16,
                right: 16,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Column(
                    children: [
                      // Section Header Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Profile & Goals',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF0F172A),
                                  letterSpacing: -0.3,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Personal Metabolic & Physical Metrics',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.refresh_rounded,
                              color: AppColors.secondary,
                            ),
                            tooltip: 'Refresh Profile',
                            onPressed: () {
                              ref
                                  .read(profileNotifierProvider.notifier)
                                  .fetchProfile();
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Header Card
                      BiteFadeSlide(
                        delay: Duration.zero,
                        child: ProfileHeaderCard(
                          profile: profile,
                          onEditPressed: () =>
                              _openEditBottomSheet(context, profile),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // BMR & TDEE Calculations Card
                      BiteFadeSlide(
                        delay: const Duration(milliseconds: 80),
                        child: BmrTdeeCard(profile: profile),
                      ),
                      const SizedBox(height: 16),

                      // Target Macros Split Card
                      BiteFadeSlide(
                        delay: const Duration(milliseconds: 160),
                        child: TargetMacrosCard(profile: profile),
                      ),
                      const SizedBox(height: 16),

                      // User Info & Attributes Card
                      BiteFadeSlide(
                        delay: const Duration(milliseconds: 240),
                        child: UserInfoCard(profile: profile),
                      ),
                      const SizedBox(height: 16),

                      // Account Settings & Logout
                      BiteFadeSlide(
                        delay: const Duration(milliseconds: 320),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: const Color(0xFFE2E8F0),
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'ACCOUNT & PREFERENCES',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.2,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 14),
                              InkWell(
                                onTap: () {
                                  ref
                                      .read(profileNotifierProvider.notifier)
                                      .fetchProfile();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Profile synced successfully',
                                      ),
                                    ),
                                  );
                                },
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: const Color(0xFFE2E8F0),
                                    ),
                                  ),
                                  child: const Row(
                                    children: [
                                      Icon(
                                        Icons.sync_rounded,
                                        color: AppColors.secondary,
                                        size: 20,
                                      ),
                                      SizedBox(width: 12),
                                      Text(
                                        'Sync Metabolic Profile',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF0F172A),
                                        ),
                                      ),
                                      Spacer(),
                                      Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        size: 14,
                                        color: Color(0xFF94A3B8),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              InkWell(
                                onTap: () {
                                  ref
                                      .read(authNotifierProvider.notifier)
                                      .logout();
                                },
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFEF2F2),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: const Color(0xFFFCA5A5),
                                    ),
                                  ),
                                  child: const Row(
                                    children: [
                                      Icon(
                                        Icons.logout_rounded,
                                        color: Color(0xFFEF4444),
                                        size: 20,
                                      ),
                                      SizedBox(width: 12),
                                      Text(
                                        'Sign Out',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w900,
                                          color: Color(0xFFEF4444),
                                        ),
                                      ),
                                      Spacer(),
                                      Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        size: 14,
                                        color: Color(0xFFEF4444),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondary),
          ),
        ),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  size: 48,
                  color: AppColors.error,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Failed to load profile',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  err.toString(),
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    ref.read(profileNotifierProvider.notifier).fetchProfile();
                  },
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Try Again'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
