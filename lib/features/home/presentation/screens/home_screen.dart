import 'package:bite_front_end/core/theme/app_colors.dart';
import 'package:bite_front_end/core/widgets/bite_app_shell.dart';
import 'package:bite_front_end/core/widgets/bite_logo.dart';
import 'package:bite_front_end/features/auth/presentation/providers/auth_provider.dart';
import 'package:bite_front_end/features/chat/presentation/screens/chat_screen.dart';
import 'package:bite_front_end/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:bite_front_end/features/meals/presentation/screens/meal_ingestion_screen.dart';
import 'package:bite_front_end/features/profile/presentation/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    MealIngestionScreen(),
    ChatScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.valueOrNull;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: isDark
            ? AppColors.darkSurface
            : AppColors.lightSurface,
        elevation: 0,
        centerTitle: false,
        title: Row(
          children: [
            const BiteLogo(size: 36, showText: true),
            if (user != null) ...[
              const Spacer(),
              Text(
                'Hi, ${user.displayName ?? 'Foodie'} 👋',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
            ],
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.logout_outlined,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
              size: 22,
            ),
            tooltip: 'Log Out',
            onPressed: () {
              ref.read(authNotifierProvider.notifier).logout();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BiteAppShell(
        selectedIndex: _currentIndex,
        onTabSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        onQuickLogPressed: () {
          setState(() {
            _currentIndex = 1; // Switch to Meals tab
          });
        },
        children: _screens,
      ),
    );
  }
}
