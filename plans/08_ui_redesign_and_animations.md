# Implementation Plan: Task 08 - Full UI Redesign, Floating Navigation Bar & Micro-Animations

## Overview
This document details the step-by-step implementation plan for Task 08 (**Full UI Redesign, Date Selector, Macro Cards & Micro-Animations**), based on [specs/08_ui_redesign_and_animations.md](file:///home/jiggra/BiteFrontEnd/specs/08_ui_redesign_and_animations.md).

No production code modifications will be executed in this step; this plan outlines the architecture, file creation sequence, state management workflow, adaptive UI widget hierarchy, and verification steps.

---

## 🏗 Architecture & File Structure

```text
lib/
├── core/
│   ├── theme/
│   │   ├── app_colors.dart                    # Enhanced porcelain background (#F1F5F9) & rich macro palette
│   │   └── app_radius.dart                    # Border radius constants
│   └── widgets/
│       ├── bite_floating_nav_bar.dart         # Custom floating animated bottom navigation bar
│       ├── bite_shimmer.dart                  # Sweeping gradient loading shimmer widget
│       ├── bite_fade_slide.dart               # Staggered card entrance animation wrapper
│       ├── app_button.dart                    # Press scale(0.97) feedback button
│       └── app_card.dart                      # Elevated porcelain card container
└── features/
    ├── dashboard/
    │   └── presentation/
    │       ├── widgets/
    │       │   ├── date_selector_bar.dart      # Redesigned date navigation bar with chevrons
    │       │   ├── calorie_ring_card.dart      # Calorie goal ring with smooth progress animation
    │       │   └── macro_cards_grid.dart       # Rich Protein, Carbs, Fat cards with tinted backdrops
    │       └── screens/
    │           └── dashboard_screen.dart       # Redesigned dashboard screen with high-contrast surfaces
    └── home/
        └── presentation/
            └── screens/
                └── home_screen.dart           # Integrated with BiteFloatingNavBar & BiteOfflineBanner
```

---

## 🗓 Sequential Implementation Roadmap

### Phase 1: Enhanced Palette & Core Micro-Animation Widgets
* **Target Files**:
  * [MODIFY] `lib/core/theme/app_colors.dart` (Add porcelain background `#F1F5F9`, macro tint colors)
  * [NEW] `lib/core/widgets/bite_shimmer.dart`
  * [NEW] `lib/core/widgets/bite_fade_slide.dart`
  * [NEW] `lib/core/widgets/bite_floating_nav_bar.dart`
  * [NEW] `test/core/widgets/bite_floating_nav_bar_test.dart`
* **Tasks**:
  1. Enhance `AppColors`: Porcelain slate background `#F1F5F9`, crisp card surfaces `#FFFFFF`, Protein tint `#EFF6FF`, Carbs tint `#FFFBEB`, Fat tint `#ECFDF5`.
  2. Implement `BiteShimmer`: Sweeping linear gradient loading skeleton for cards and placeholders.
  3. Implement `BiteFadeSlide`: Staggered slide-up & fade-in card entrance wrapper (250ms `Curves.easeOutCubic`).
  4. Implement `BiteFloatingNavBar`: Floating bottom navigation pill with animated sliding indicator, scale press feedback, and elevated camera FAB.

---

### Phase 2: Redesigned Dashboard Components (`DateSelectorBar`, `MacroCardsGrid`, `CalorieRingCard`)
* **Target Files**:
  * [NEW] `lib/features/dashboard/presentation/widgets/date_selector_bar.dart`
  * [NEW] `lib/features/dashboard/presentation/widgets/macro_cards_grid.dart`
  * [NEW] `lib/features/dashboard/presentation/widgets/calorie_ring_card.dart`
  * [MODIFY] `lib/features/dashboard/presentation/screens/dashboard_screen.dart`
  * [NEW] `test/features/dashboard/presentation/widgets/date_selector_bar_test.dart`
  * [NEW] `test/features/dashboard/presentation/widgets/macro_cards_grid_test.dart`
* **Tasks**:
  1. Implement `DateSelectorBar`: Pill container with styled chevrons (`Icons.chevron_left_rounded`, `Icons.chevron_right_rounded`), calendar badge, and bold typography.
  2. Implement `MacroCardsGrid`: Rich Protein (blue `#2563EB`), Carbs (gold `#D97706`), Fat (emerald `#059669`) cards with tinted background cards and progress rings.
  3. Implement `CalorieRingCard`: Elevated card container with animated progress ring.
  4. Update `DashboardScreen` to assemble redesigned components inside `BiteFadeSlide` wrappers with `BiteShimmer` loading states.

---

### Phase 3: HomeScreen Integration & App Shell Connection
* **Target Files**:
  * [MODIFY] `lib/features/home/presentation/screens/home_screen.dart`
* **Tasks**:
  1. Replace standard navigation bar in `HomeScreen` with `BiteFloatingNavBar`.
  2. Wire up center FAB quick camera action.

---

### Phase 4: Final Verification & Quality Assurance
* **Tasks**:
  1. `dart format --output=none --set-exit-if-changed .`
  2. `flutter analyze`
  3. `flutter test`
