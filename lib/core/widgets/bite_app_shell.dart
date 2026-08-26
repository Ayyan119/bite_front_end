import 'package:bite_front_end/core/theme/app_colors.dart';
import 'package:bite_front_end/core/widgets/bite_floating_nav_bar.dart';
import 'package:bite_front_end/core/widgets/bite_offline_banner.dart';
import 'package:bite_front_end/features/home/presentation/widgets/app_navigation_rail.dart';
import 'package:flutter/material.dart';

class BiteAppShell extends StatefulWidget {
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
  State<BiteAppShell> createState() => _BiteAppShellState();
}

class _BiteAppShellState extends State<BiteAppShell> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.selectedIndex);
  }

  @override
  void didUpdateWidget(covariant BiteAppShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      FocusManager.instance.primaryFocus?.unfocus();
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          widget.selectedIndex,
          duration: const Duration(milliseconds: 380),
          curve: Curves.fastOutSlowIn,
        );
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktopOrTablet = width >= 600;
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    final wrappedChildren = widget.children
        .map((child) => _KeepAliveWrapper(child: child))
        .toList();

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: Column(
        children: [
          const BiteOfflineBanner(),
          Expanded(
            child: isDesktopOrTablet
                ? Row(
                    children: [
                      AppNavigationRail(
                        selectedIndex: widget.selectedIndex,
                        onDestinationSelected: widget.onTabSelected,
                      ),
                      const VerticalDivider(thickness: 1, width: 1),
                      Expanded(
                        child: PageView(
                          controller: _pageController,
                          physics: const NeverScrollableScrollPhysics(),
                          children: wrappedChildren,
                        ),
                      ),
                    ],
                  )
                : Stack(
                    children: [
                      Positioned.fill(
                        child: PageView(
                          controller: _pageController,
                          physics: const NeverScrollableScrollPhysics(),
                          children: wrappedChildren,
                        ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: AnimatedSlide(
                          offset: isKeyboardOpen
                              ? const Offset(0, 1.5)
                              : Offset.zero,
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOutCubic,
                          child: BiteFloatingNavBar(
                            selectedIndex: widget.selectedIndex,
                            onTabSelected: widget.onTabSelected,
                            onQuickLogPressed: widget.onQuickLogPressed,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _KeepAliveWrapper extends StatefulWidget {
  final Widget child;
  const _KeepAliveWrapper({required this.child});

  @override
  State<_KeepAliveWrapper> createState() => _KeepAliveWrapperState();
}

class _KeepAliveWrapperState extends State<_KeepAliveWrapper>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
