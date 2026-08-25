# Implementation Plan: Task 07 - App Shell, Navigation & Final Polish

## Overview
This document details the step-by-step implementation plan for Task 07 (**App Shell, Navigation & Final Polish**), based on [specs/07_app_shell_navigation_and_final_polish.md](file:///home/jiggra/BiteFrontEnd/specs/07_app_shell_navigation_and_final_polish.md).

No production code modifications will be executed in this step; this plan outlines the architecture, file creation sequence, state management workflow, adaptive UI widget hierarchy, and verification steps.

---

## 🏗 Architecture & File Structure

```text
lib/
├── core/
│   ├── network/
│   │   ├── dio_provider.dart                 # Network interceptors for global error snackbars
│   │   └── connectivity_provider.dart        # StreamProvider monitoring device network connectivity status
│   ├── router/
│   │   └── app_router.dart                    # GoRouter configuration with route preservation
│   └── widgets/
│       ├── bite_empty_state.dart              # Reusable empty state UI component
│       ├── bite_error_state.dart              # Reusable error boundary UI component with retry
│       ├── bite_offline_banner.dart           # Top-aligned floating network connectivity status banner
│       └── bite_app_shell.dart                # Adaptive bottom nav & side rail shell container
└── features/
    └── home/
        └── presentation/
            ├── screens/
            │   └── home_screen.dart           # Main responsive home screen container
            └── widgets/
                └── app_navigation_rail.dart   # Tablet/Desktop side navigation rail component
```

---

## 🗓 Sequential Implementation Roadmap

### Phase 1: System Feedback & Connectivity Components (`lib/core/widgets/`)
* **Goal**: Build standardized reusable UI components for empty states, error boundaries, and offline connection status.
* **Target Files**:
  * [NEW] `lib/core/network/connectivity_provider.dart`
  * [NEW] `lib/core/widgets/bite_empty_state.dart`
  * [NEW] `lib/core/widgets/bite_error_state.dart`
  * [NEW] `lib/core/widgets/bite_offline_banner.dart`
  * [NEW] `test/core/widgets/bite_empty_state_test.dart`
  * [NEW] `test/core/widgets/bite_error_state_test.dart`
* **Tasks**:
  1. `connectivityProvider`: Create `StreamProvider<bool>` for network status.
  2. `BiteEmptyState`: Implement reusable widget accepting `title`, `message`, `icon`, and optional `onActionPressed` button.
  3. `BiteErrorState`: Implement reusable error boundary accepting `message`, `onRetry` callback.
  4. `BiteOfflineBanner`: Implement floating warning banner when device is offline.
  5. Write unit & widget tests for feedback components.

---

### Phase 2: Adaptive App Shell & Navigation (`lib/core/widgets/bite_app_shell.dart`)
* **Goal**: Implement adaptive container rendering Bottom Navigation Bar on mobile (`< 600dp`) vs Navigation Rail on tablet/desktop (`>= 600dp`).
* **Target Files**:
  * [NEW] `lib/core/widgets/bite_app_shell.dart`
  * [NEW] `lib/features/home/presentation/widgets/app_navigation_rail.dart`
  * [MODIFY] `lib/features/home/presentation/screens/home_screen.dart`
  * [NEW] `test/core/widgets/bite_app_shell_test.dart`
* **Tasks**:
  1. Implement `BiteAppShell`:
     * Mobile (`< 600dp`): `NavigationBar` with 4 destinations: **Dashboard**, **Meals**, **AI Assistant**, **Profile**.
     * Tablet / Desktop (`>= 600dp`): `NavigationRail` with expanded text labels and high-contrast indicators (`#D1FAE5` active container, `#047857` icon).
     * Floating Action Button (FAB): Quick 1-tap shortcut to camera vision meal logging (`/meals/log`).
     * Tab preservation using `IndexedStack` to retain scroll states.
  2. Integrate `BiteAppShell` and `BiteOfflineBanner` inside `HomeScreen`.
  3. Write widget tests for `BiteAppShell` breakpoint switching and tab selection.

---

### Phase 3: Global Network Error Interceptor & Theme Alignment
* **Goal**: Add network error handling in `DioProvider` and verify theme consistency.
* **Target Files**:
  * [MODIFY] `lib/core/network/dio_provider.dart`
  * [MODIFY] `lib/core/router/app_router.dart`
* **Tasks**:
  1. Configure Dio `InterceptorsWrapper` to emit user-facing error snackbars on network timeout or 500 server errors.
  2. Verify GoRouter redirect logic and route contracts.

---

### Phase 4: Final Verification & Quality Assurance
* **Goal**: Ensure zero warnings or errors across formatting, static analysis, and full test suite execution.
* **Tasks**:
  1. `dart format --output=none --set-exit-if-changed .`
  2. `flutter analyze`
  3. `flutter test`
