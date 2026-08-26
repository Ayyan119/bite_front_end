# Feature Specification: Task 08 - Full UI Redesign, Date Selector, Macro Cards & Micro-Animations

## 1. Overview & Goal

The **Full UI Redesign & Micro-Animations** feature transforms the Bite Flutter application into a modern, visually stunning, and vibrant mobile food & nutrition app. Based on direct user feedback and UI inspiration:
* **Background & Card Contrast Overhaul**: Fix monochromatic white-on-white by establishing a slate porcelain background (`#F1F5F9`) with elevated white cards (`#FFFFFF`), subtle shadows (`0px 4px 20px rgba(0,0,0,0.06)`), and crisp borders.
* **Redesigned Date Selector Header**: Replace basic text inputs with a premium date navigation bar featuring rounded chevron buttons (`Icons.chevron_left_rounded`, `Icons.chevron_right_rounded`), a calendar badge, and elegant typography (`GoogleFonts.plusJakartaSans` / `GoogleFonts.inter`).
* **Vibrant Macro Cards (Protein, Carbs, Fats)**: Upgrade macro cards with rich gradient backdrops, distinct nutrition color accents (Protein `#2563EB` blue, Carbs `#D97706` amber, Fat `#059669` emerald), progress rings, and visual food badges.
* **Custom Floating Animated Navigation Bar (`BiteFloatingNavBar`)**: Floating bottom navigation shell with smooth sliding tab indicators (200ms `Curves.easeOutCubic`), scale press feedback, and an elevated center Quick Log camera FAB in a warm citrus gradient container (`#FF5722`).
* **Loading Shimmers (`BiteShimmer`) & Entrance Motion (`BiteFadeSlide`)**: Replace standard spinners with a sweeping linear shimmer and staggered slide-up card entrances (250ms `Curves.easeOutCubic`).

---

## 2. Layered Architecture Breakdown

```text
lib/
├── core/
│   ├── theme/
│   │   ├── app_colors.dart                    # Enhanced slate background & rich macro palette
│   │   └── app_radius.dart                    # Rounded border radius constants
│   └── widgets/
│       ├── bite_floating_nav_bar.dart         # Custom floating animated navigation bar
│       ├── bite_shimmer.dart                  # Sweeping gradient loading shimmer widget
│       ├── bite_fade_slide.dart               # Staggered card entrance animation wrapper
│       ├── app_button.dart                    # Press scale(0.97) feedback button
│       └── app_card.dart                      # Elevated porcelain card container
└── features/
    ├── dashboard/
    │   └── presentation/
    │       ├── widgets/
    │       │   ├── date_selector_bar.dart      # Redesigned date navigation bar with chevrons
    │       │   ├── calorie_ring_card.dart      # Calorie goal ring with smooth animation
    │       │   └── macro_cards_grid.dart       # Vibrant Protein, Carbs, Fat cards with backgrounds
    │       └── screens/
    │           └── dashboard_screen.dart       # Redesigned dashboard screen with rich contrast
    ├── home/
    │   └── presentation/
    │       └── screens/
    │           └── home_screen.dart           # Integrated with BiteFloatingNavBar & BiteOfflineBanner
    ├── meals/
    │   └── presentation/
    │       └── screens/
    │           └── meal_ingestion_screen.dart  # Redesigned food logging UI with food cards
    ├── chat/
    │   └── presentation/
    │       └── screens/
    │           └── chat_screen.dart           # Enhanced AI assistant bubbles with animations
    └── profile/
        └── presentation/
            └── screens/
                └── profile_screen.dart        # Enhanced profile view with animated cards
```

---

## 3. Component & UI Specifications

### 3.1 Date Selector Bar (`DateSelectorBar`)
* Rounded pill bar with soft background tint (`#E2E8F0`).
* Chevrons: `IconButton` with `Icon(Icons.chevron_left_rounded)` and `Icon(Icons.chevron_right_rounded)` with 48dp minimum touch target.
* Center Date Badge: Calendar icon container (`Icons.calendar_today_rounded`) + date string formatted with `GoogleFonts.inter` bold weight.

### 3.2 Macro Cards (`MacroCardsGrid`)
* **Protein Card**: Deep blue gradient background tint (`#EFF6FF`), progress indicator, protein icon, and target grams.
* **Carbs Card**: Warm amber gradient background tint (`#FFFBEB`), progress indicator, carbs icon, and target grams.
* **Fat Card**: Fresh mint emerald gradient background tint (`#ECFDF5`), progress indicator, fat icon, and target grams.

### 3.3 Floating Navigation Bar (`BiteFloatingNavBar`)
* Positioned with `Margin(horizontal: 16, bottom: 16)`.
* Rounded floating pill (`AppRadius.pillBorder`) with backdrop blur and drop shadow.
* Active tab indicator sliding pill with smooth animation (`AnimatedContainer`, 200ms `Curves.easeOutCubic`).
* Center Floating Action Button with warm citrus/emerald gradient background (`#FF5722` -> `#EA580C`) and camera icon.

### 3.4 Shimmer & Staggered Motion (`BiteShimmer`, `BiteFadeSlide`)
* Sweep gradient loading skeleton (`BiteShimmer`) for image/card placeholders.
* Staggered card entrance animation (`BiteFadeSlide`, 250ms `Curves.easeOutCubic`, `delay: 30ms * index`).

---

## 4. Testing & Verification Checklist

### 4.1 Unit & Widget Tests
* **`DateSelectorBarTest`**: Test chevron taps (previous/next day) and date label formatting.
* **`MacroCardsGridTest`**: Test Protein, Carbs, Fat macro values and progress bar rendering.
* **`BiteFloatingNavBarTest`**: Test tab selection, active indicator sliding, and FAB callback.
* **`BiteShimmerTest`**: Test shimmer loading state rendering.

### 4.2 Quality Verification
```bash
# Code formatting check
dart format --output=none --set-exit-if-changed .

# Static analysis
flutter analyze

# Full test suite execution
flutter test
```
