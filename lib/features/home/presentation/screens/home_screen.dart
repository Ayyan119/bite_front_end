import 'package:bite_front_end/core/theme/app_colors.dart';
import 'package:bite_front_end/core/widgets/bite_blur_app_bar.dart';
import 'package:bite_front_end/core/utils/app_preloader.dart';
import 'package:bite_front_end/core/widgets/bite_app_shell.dart';
import 'package:bite_front_end/core/widgets/bite_logo.dart';
import 'package:bite_front_end/features/auth/presentation/providers/auth_provider.dart';
import 'package:bite_front_end/features/chat/presentation/screens/chat_screen.dart';
import 'package:bite_front_end/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:bite_front_end/features/meals/presentation/screens/meal_ingestion_screen.dart';
import 'package:bite_front_end/features/profile/presentation/providers/profile_provider.dart';
import 'package:bite_front_end/features/profile/presentation/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/home_tab_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final List<Widget> _screens = const [
    DashboardScreen(),
    MealIngestionScreen(),
    ChatScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      preloadAppData(ref);
      if (mounted) {
        final location = GoRouterState.of(context).matchedLocation;
        if (location == '/chat') {
          ref.read(homeTabIndexProvider.notifier).state = 2;
        } else if (location == '/profile') {
          ref.read(homeTabIndexProvider.notifier).state = 3;
        } else if (location == '/meals/log') {
          ref.read(homeTabIndexProvider.notifier).state = 1;
        } else if (location == '/dashboard') {
          ref.read(homeTabIndexProvider.notifier).state = 0;
        }
      }
    });
  }

  String _getFirstName(String? fullName) {
    if (fullName == null || fullName.trim().isEmpty) return '';
    final parts = fullName.trim().split(' ');
    return parts.first;
  }

  String _getTimeBasedGreeting(String firstName) {
    final hour = DateTime.now().hour;
    final nameSuffix = firstName.isNotEmpty ? ', $firstName' : '';
    if (hour >= 5 && hour < 12) {
      return 'Good morning$nameSuffix ☀️';
    } else if (hour >= 12 && hour < 17) {
      return 'Good afternoon$nameSuffix 🌤️';
    } else if (hour >= 17 && hour < 22) {
      return 'Good evening$nameSuffix 🌆';
    } else {
      return 'Good night$nameSuffix 🌙';
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(homeTabIndexProvider);
    final authState = ref.watch(authNotifierProvider).value;
    final profileState = ref.watch(profileNotifierProvider).value;

    final rawName = profileState?.displayName.isNotEmpty == true
        ? profileState!.displayName
        : (authState?.displayName ?? authState?.email ?? '');
    final firstName = _getFirstName(rawName);

    return PopScope(
      canPop: currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (currentIndex != 0) {
          ref.read(homeTabIndexProvider.notifier).state = 0;
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.lightBackground,
        extendBodyBehindAppBar: true,
        appBar: currentIndex == 2
            ? null
            : AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                scrolledUnderElevation: 0,
                toolbarHeight: kToolbarHeight + 14.0,
                flexibleSpace: const BiteBlurAppBarBackground(),
                centerTitle: false,
                titleSpacing: 12,
                title: Row(
                  children: [
                    const BiteLogo(size: 28, showText: true),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFF7ED), Color(0xFFFFEDD5)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.secondary.withValues(alpha: 0.25),
                            width: 1.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.secondary.withValues(alpha: 0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          _getTimeBasedGreeting(firstName),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF9A3412),
                            letterSpacing: -0.2,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
                actions: [
                  GestureDetector(
                    onTap: () {
                      ref.read(homeTabIndexProvider.notifier).state = 3;
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 16),
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF7ED),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.secondary.withValues(alpha: 0.35),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.secondary.withValues(alpha: 0.12),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          firstName.isNotEmpty
                              ? firstName[0].toUpperCase()
                              : '👤',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: AppColors.secondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
        body: BiteAppShell(
          selectedIndex: currentIndex,
          onTabSelected: (index) {
            ref.read(homeTabIndexProvider.notifier).state = index;
          },
          onQuickLogPressed: () {
            ref.read(homeTabIndexProvider.notifier).state = 1;
          },
          children: _screens,
        ),
      ),
    );
  }
}
