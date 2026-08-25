# Feature Implementation Plan: 03 - Daily Macro Dashboard & Analytics

**Target Feature**: Daily Macro Dashboard & Analytics  
**Branch Name**: `feature/03-daily-macro-dashboard-analytics`  
**Specification Reference**: [`specs/03_daily_macro_dashboard_analytics.md`](file:///home/jiggra/BiteFrontEnd/specs/03_daily_macro_dashboard_analytics.md)  
**Theme**: Light Theme (Soft Slate Porcelain `#F1F5F9`, Crisp White Cards, Citrus Sunset `#EA580C`, Protein Blue `#2563EB`, Carbs Honey Gold `#D97706`, Fat Avocado Green `#059669`)  

---

## 📋 Executive Summary

This implementation plan outlines the development of **Feature 03: Daily Macro Dashboard & Analytics** in 6 sequential execution steps. The dashboard serves as the central landing page of the application, rendering animated calorie progress rings, macro target progress grids, logged meal cards, top micronutrient chips, interactive date selection, and historical trend analytics.

---

## 🎯 Step-by-Step Implementation Roadmap

### Step 1: Data Layer Implementation (`lib/features/dashboard/data/`)
* **Goal**: Implement HTTP client endpoints and repository orchestration for fetching daily summaries and historical analytics.
* **Tasks**:
  1. Create `DashboardRemoteDataSource` in `lib/features/dashboard/data/datasources/dashboard_remote_data_source.dart`:
     - `getDailyDashboard(String dateStr)` -> `GET /api/v1/dashboard/daily?target_date=YYYY-MM-DD`
     - `getHistoricalAnalytics(int days)` -> `GET /api/v1/dashboard/history?days=30`
     - Handle `DioException` and throw `ServerException`.
  2. Create `DashboardRepository` interface & `DashboardRepositoryImpl` in `lib/features/dashboard/data/repositories/dashboard_repository.dart`:
     - Coordinate calls with `DashboardRemoteDataSource`.
     - Export `dashboardRemoteDataSourceProvider` and `dashboardRepositoryProvider`.

---

### Step 2: State Management & Riverpod Providers (`lib/features/dashboard/presentation/providers/`)
* **Goal**: Build reactive providers for date state, daily summary data, and historical trend analytics.
* **Tasks**:
  1. Create `selectedDashboardDateProvider` (`StateProvider<DateTime>`) defaulting to `DateTime.now()`.
  2. Create `historicalRangeDaysProvider` (`StateProvider<int>`) defaulting to `7` days.
  3. Create `dailyDashboardProvider` (`FutureProvider.family<DailyDashboardResponseModel, String>`):
     - Watches `selectedDashboardDateProvider` formatted as `YYYY-MM-DD`.
  4. Create `historicalAnalyticsProvider` (`FutureProvider.family<HistoricalAnalyticsResponseModel, int>`):
     - Fetches 7 or 30-day analytics summary.
  5. Export all providers in `lib/features/dashboard/presentation/providers/dashboard_provider.dart`.

---

### Step 3: Core UI Widgets Construction (`lib/features/dashboard/presentation/widgets/`)
* **Goal**: Build high-contrast, responsive Light Theme UI widgets using Bite design tokens (`AppSpacing`, `AppRadius`, `AppColors`, `AppCard`, `AppButton`).
* **Tasks**:
  1. `DateSelectorBar` (`date_selector_bar.dart`):
     - Prev day button (`<`), Next day button (`>`), formatted date string (`Today, Aug 25`), and calendar icon triggering `showDatePicker`.
  2. `CalorieProgressRing` (`calorie_progress_ring.dart`):
     - Custom painted double ring (track + animated citrus gradient arc).
     - Central text: Consumed calories (`1,872`), Target (`2,400 kcal`), and remaining pill badge (`528 kcal remaining`).
  3. `MacroCardGrid` (`macro_card_grid.dart`):
     - 3 macro cards (Protein `#2563EB`, Carbs `#D97706`, Fat `#059669`) with icons, target vs consumed labels, and progress bars.
  4. `LoggedMealsList` (`logged_meals_list.dart`):
     - Chronological meal summary cards (Breakfast, Lunch, Dinner, Snack).
     - Thumbnail image placeholder/network image, caption, timestamp, total calories, and macro pills.
     - Empty state card when `meals.isEmpty`.
  5. `TopMicronutrientsCard` (`top_micronutrients_card.dart`):
     - Grid/chip breakdown of top logged micronutrients (Fiber, Calcium, Iron, Vitamin C).
  6. `HistoricalAnalyticsChart` (`historical_analytics_chart.dart`):
     - Toggle between 7-day and 30-day view.
     - Bar chart comparing total calories vs target, and goal status badges (`under` green, `met` blue, `over` red).

---

### Step 4: `DashboardScreen` Assembly & Screen Integration (`lib/features/dashboard/presentation/screens/`)
* **Goal**: Assemble all widgets into `DashboardScreen` and integrate into `HomeScreen` bottom navigation.
* **Tasks**:
  1. Create `DashboardScreen` in `lib/features/dashboard/presentation/screens/dashboard_screen.dart`:
     - Wrap in `RefreshIndicator` for pull-to-refresh.
     - ConstrainedBox layout (`maxWidth: 600`) for responsive mobile/tablet displays.
     - Render `DateSelectorBar`, `CalorieProgressRing`, `MacroCardGrid`, `LoggedMealsList`, `TopMicronutrientsCard`, and `HistoricalAnalyticsChart`.
  2. Update `HomeScreen` (`lib/features/home/presentation/screens/home_screen.dart`) to render `DashboardScreen` as the primary home tab.

---

### Step 5: Unit, Provider & Widget Testing (`test/features/dashboard/`)
* **Goal**: Ensure thorough automated test coverage across data, state, and presentation layers.
* **Tasks**:
  1. Data Source & Repository Tests:
     - `dashboard_remote_data_source_test.dart`: Mock Dio calls for `/dashboard/daily` and `/dashboard/history`.
     - `dashboard_repository_test.dart`: Test data parsing and error handling.
  2. Provider Tests:
     - `dashboard_provider_test.dart`: Test date state updates and provider data fetching.
  3. Widget Tests:
     - `dashboard_screen_test.dart`: Test dashboard rendering, date selection interactions, empty states, and pull-to-refresh.

---

### Step 6: Formatting, Static Analysis & Verification
* **Goal**: Ensure clean analysis, zero warnings, and 100% passing tests.
* **Tasks**:
  1. Execute `dart format .`.
  2. Execute `flutter analyze` to ensure 0 errors/warnings.
  3. Execute `flutter test` to ensure all tests pass.

---

## 🎨 Design System & Color Alignment

| Metric / Component | Primary Color | Container / Background |
| :--- | :--- | :--- |
| **Screen Background** | `#F1F5F9` (Soft Slate Porcelain) | Global Scaffold |
| **Card Surface** | `#FFFFFF` (Crisp White) | `AppCard` with `#CBD5E1` border |
| **Calorie Progress** | `#EA580C` (Citrus Sunset) | `#FFEDD5` Citrus Container |
| **Protein Macro** | `#2563EB` (Ocean Blue) | `#DBEAFE` Blue Container |
| **Carbs Macro** | `#D97706` (Honey Gold) | `#FEF3C7` Amber Container |
| **Fat Macro** | `#059669` (Avocado Green) | `#D1FAE5` Mint Container |

---

## ⚙️ Verification Checklist

- [ ] `DashboardRemoteDataSource` fetches `/dashboard/daily` and `/dashboard/history`.
- [ ] `DashboardRepository` maps network responses to `DailyDashboardResponseModel` and `HistoricalAnalyticsResponseModel`.
- [ ] `selectedDashboardDateProvider` updates state when user clicks Prev/Next or uses `DatePicker`.
- [ ] `CalorieProgressRing` animates and calculates remaining calories accurately.
- [ ] `MacroCardGrid` displays color-coded bars for Protein, Carbs, and Fat.
- [ ] `LoggedMealsList` displays meal summary cards and friendly empty state when no meals exist.
- [ ] `HistoricalAnalyticsChart` renders 7-day / 30-day trends with goal status badges.
- [ ] `DashboardScreen` integrated into `HomeScreen`.
- [ ] `flutter analyze` passes with 0 issues.
- [ ] `flutter test` passes 100%.
