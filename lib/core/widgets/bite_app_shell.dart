import 'package:bite_front_end/core/theme/app_colors.dart';
import 'package:bite_front_end/core/widgets/bite_offline_banner.dart';
import 'package:bite_front_end/features/home/presentation/widgets/app_navigation_rail.dart';
import 'package:flutter/material.dart';

class BiteAppShell extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;
  final List<Widget> children;
  final VoidCallback? onQuickLogPressed;

  const BiteAppShell({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
    required this.children,
    this.onQuickLogPressed,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktopOrTablet = width >= 600;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      body: Column(
        children: [
          const BiteOfflineBanner(),
          Expanded(
            child: isDesktopOrTablet
                ? Row(
                    children: [
                      AppNavigationRail(
                        selectedIndex: selectedIndex,
                        onDestinationSelected: onTabSelected,
                      ),
                      const VerticalDivider(thickness: 1, width: 1),
                      Expanded(
                        child: IndexedStack(
                          index: selectedIndex,
                          children: children,
                        ),
                      ),
                    ],
                  )
                : IndexedStack(index: selectedIndex, children: children),
          ),
        ],
      ),
      floatingActionButton: (!isDesktopOrTablet && onQuickLogPressed != null)
          ? FloatingActionButton(
              onPressed: onQuickLogPressed,
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              tooltip: 'Quick Log Meal',
              child: const Icon(Icons.add_a_photo_outlined),
            )
          : null,
      bottomNavigationBar: isDesktopOrTablet
          ? null
          : NavigationBar(
              selectedIndex: selectedIndex,
              onDestinationSelected: onTabSelected,
              backgroundColor: isDark
                  ? AppColors.darkSurface
                  : AppColors.lightSurface,
              indicatorColor: AppColors.primaryContainer,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(
                    Icons.dashboard,
                    color: AppColors.primaryDark,
                  ),
                  label: 'Dashboard',
                ),
                NavigationDestination(
                  icon: Icon(Icons.camera_alt_outlined),
                  selectedIcon: Icon(
                    Icons.camera_alt,
                    color: AppColors.primaryDark,
                  ),
                  label: 'Meals',
                ),
                NavigationDestination(
                  icon: Icon(Icons.chat_bubble_outline),
                  selectedIcon: Icon(
                    Icons.chat_bubble,
                    color: AppColors.primaryDark,
                  ),
                  label: 'AI Assistant',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(
                    Icons.person,
                    color: AppColors.primaryDark,
                  ),
                  label: 'Profile',
                ),
              ],
            ),
    );
  }
}
