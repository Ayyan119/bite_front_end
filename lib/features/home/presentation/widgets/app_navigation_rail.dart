import 'package:bite_front_end/core/theme/app_colors.dart';
import 'package:bite_front_end/core/widgets/bite_logo.dart';
import 'package:flutter/material.dart';

class AppNavigationRail extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const AppNavigationRail({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return NavigationRail(
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      labelType: NavigationRailLabelType.all,
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      indicatorColor: AppColors.primaryContainer,
      leading: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: const BiteLogo(size: 32, showText: false),
      ),
      destinations: const [
        NavigationRailDestination(
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard, color: AppColors.primaryDark),
          label: Text('Dashboard'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.camera_alt_outlined),
          selectedIcon: Icon(Icons.camera_alt, color: AppColors.primaryDark),
          label: Text('Log Meal'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.chat_bubble_outline),
          selectedIcon: Icon(Icons.chat_bubble, color: AppColors.primaryDark),
          label: Text('AI Assistant'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person, color: AppColors.primaryDark),
          label: Text('Profile'),
        ),
      ],
    );
  }
}
