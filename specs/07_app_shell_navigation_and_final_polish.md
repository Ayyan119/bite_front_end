# Feature Specification: Task 07 - App Shell, Navigation & Final Polish

## 1. Overview & Goal

The **App Shell, Navigation & Final Polish** feature establishes the unified application shell, adaptive navigation system (mobile bottom navigation bar vs tablet/desktop navigation rail), global error boundaries, offline network resilience indicators, standardized empty state components, and final UI/UX polish across the Bite Flutter application.

### Key Objectives:
* **Adaptive Navigation Shell**:
  * **Mobile Navigation Bar**: Modern Material 3 bottom navigation bar (`NavigationBar`) with 4 main destinations: **Dashboard**, **Meals**, **AI Assistant**, and **Profile**.
  * **Tablet / Desktop Navigation Rail**: Side navigation rail (`NavigationRail`) for viewports `>= 600dp` width.
  * **Quick Meal Log FAB**: Floating Action Button on the shell container enabling 1-tap navigation to camera/vision meal logging.
  * **State Preservation**: Tab state caching preserving scroll position and user context across tab switches.
* **Reusable System Feedback Components**:
  * **`BiteEmptyState`**: Standardized empty state component for empty chat sessions, meal logs, or historical analytics.
  * **`BiteErrorState`**: Standardized error boundary component with error icons, detailed messages, and retry callbacks.
  * **`BiteOfflineBanner`**: Floating animated network connectivity status banner notifying users when device is offline.
* **Global Network Error Interceptor**:
  * Dio network interceptor displaying user-friendly toast/snackbar alerts for global API errors (e.g., 500 internal server errors, connection timeouts).
* **Design & UX Polish**:
  * Complete alignment with Emerald Design System ([DESIGN_REFERENCE.md](file:///home/jiggra/BiteFrontEnd/DESIGN_REFERENCE.md)): `#059669` primary green, `#EA580C` calories, `#2563EB` protein, `#D97706` carbs, `#059669` fat.
  * Minimum 48dp touch targets across all buttons and destinations.

---

## 2. API & Data Contracts

Wraps and orchestrates all backend endpoints defined in [api_docs.md](file:///home/jiggra/BiteFrontEnd/api_docs.md):
* `/api/v1/auth/*` (Authentication & Session Restoration)
* `/api/v1/dashboard/*` (Daily Nutrition Summary & Historical Analytics)
* `/api/v1/meals/*` (Image Vision Meal Analysis & Confirmation)
* `/api/v1/chat/*` (Real-Time SSE AI Assistant & Chat Sessions)
* `/api/v1/profile` (Physical Metrics & Mifflin-St Jeor Macro Targets)

---

## 3. Layered Architecture Breakdown

```text
lib/
├── core/
│   ├── network/
│   │   ├── dio_provider.dart                 # Dio instance with network error interceptor
│   │   └── connectivity_provider.dart        # StreamProvider monitoring device network connectivity
│   ├── router/
│   │   └── app_router.dart                    # App routing configuration with shell branch routes
│   └── widgets/
│       ├── bite_app_shell.dart                # Adaptive bottom nav & side rail shell container
│       ├── bite_empty_state.dart              # Standardized empty state UI component
│       ├── bite_error_state.dart              # Standardized error boundary UI component with retry
│       └── bite_offline_banner.dart           # Floating animated network connection status banner
└── features/
    └── home/
        └── presentation/
            ├── screens/
            │   └── home_screen.dart           # Integrated home screen utilizing BiteAppShell
            └── widgets/
                └── app_navigation_rail.dart   # Tablet/Desktop side navigation rail component
```

---

## 4. State Management Design

### 4.1 Riverpod Providers
* `currentTabProvider`: `StateProvider<int>` managing selected shell tab index (0: Dashboard, 1: Meals, 2: AI Assistant, 3: Profile).
* `connectivityProvider`: `StreamProvider<bool>` streaming device network connectivity status (online vs offline).
* `authNotifierProvider`: Global authentication notifier handling session expiration and redirect triggers.

---

## 5. UI & Responsive Layout Guidelines

Aligned with [DESIGN_REFERENCE.md](file:///home/jiggra/BiteFrontEnd/DESIGN_REFERENCE.md):
* **Adaptive Viewport Breakpoints**:
  * Mobile Viewport (`< 600dp` width): Bottom Navigation Bar (`NavigationBar`) with 4 destinations + floating Quick Log action.
  * Tablet / Desktop Viewport (`>= 600dp` width): Side Navigation Rail (`NavigationRail`) with expanded text labels and high-contrast indicators (`#D1FAE5` active background, `#047857` active icon).
* **Component Specifications**:
  * **`BiteEmptyState`**: Centered layout with custom icon/illustration, bold title (`titleMedium`), subtitle message (`bodyMedium`), and optional primary action button (`ElevatedButton`).
  * **`BiteErrorState`**: Alert container with red warning icon (`Icons.error_outline_rounded`), error description, and primary "Try Again" retry button.
  * **`BiteOfflineBanner`**: Top-aligned banner with subtle amber warning fill (`#D97706`), offline icon, and text *"No Internet Connection - Showing cached data"*.

---

## 6. Testing & Verification Checklist

### 6.1 Unit & Widget Tests
* **`BiteAppShellTest`**: Test tab switching, navigation destination rendering, and breakpoint adaptation (mobile bottom bar vs desktop nav rail).
* **`BiteEmptyStateTest`**: Test rendering of empty state titles, messages, and action button taps.
* **`BiteErrorStateTest`**: Test error message rendering and retry button execution callback.
* **`BiteOfflineBannerTest`**: Test offline status display when network connectivity drops.

### 6.2 Static Analysis & Quality Verification
```bash
# Code formatting check
dart format --output=none --set-exit-if-changed .

# Static analysis
flutter analyze

# Full test suite execution
flutter test
```
