# Feature Specification: Daily Macro Dashboard & Analytics

**Feature Branch**: `feature/03-daily-macro-dashboard-analytics`  
**Specification Path**: `specs/03_daily_macro_dashboard_analytics.md`  
**Target Milestone**: Phase 3 - Feature 2: Daily Macro Dashboard & Analytics  
**Theme & Aesthetics**: Light Theme only, featuring vibrant food & health colors (Emerald Mint, Citrus Sunset, Ocean Protein Blue, Honey Carbs Gold, Crisp White Cards, Soft Slate Porcelain Background).

---

## 1. Overview & Goal

The **Daily Macro Dashboard & Analytics** feature serves as the primary central hub of the **Bite Frontend** application. It enables users to view their daily nutritional progress, calorie breakdown, macro targets (Protein, Carbs, Fat), today's logged meals summary, top micronutrients, and multi-day historical nutrition analytics.

### Key Objectives:
1. **Daily Calorie & Macro Visualization**: Provide a high-impact, animated **Calorie Progress Ring** displaying target vs. consumed vs. remaining calories, alongside distinct **Macro Breakdown Cards** for Protein, Carbs, and Fat with progress bars and percentage metrics.
2. **Interactive Date Navigation**: Allow users to seamlessly navigate between past, present, and future dates (`Today`, `Previous Day`, `Next Day`, or via an interactive calendar `DatePicker`).
3. **Today's Logged Meals Summary**: Display a detailed chronological list of logged meals (Breakfast, Lunch, Dinner, Snack) with thumbnail images, food captions, timestamps, calories, and macro metrics.
4. **Top Micronutrient Insights**: Render key micronutrients (e.g., Fiber, Calcium, Iron, Vitamin C) logged throughout the day.
5. **Historical Analytics & Trends**: Provide a 7-day or 30-day historical analytics view with interactive trend bars, meal counts, and goal status badges (`under`, `met`, `over`).
6. **Polished Light Theme UI**: Adhere strictly to the Bite Light Theme with vibrant natural food colors, high-contrast typography (`GoogleFonts.inter`), rounded cards (`#FFFFFF`), and responsive layout constraints (`maxWidth: 600`).

---

## 2. API & Data Contracts

All dashboard endpoints require HTTP Bearer authentication (`Authorization: Bearer <access_token>`).

### 2.1 Endpoint Specifications

#### 1. Daily Dashboard Summary Endpoint
* **HTTP Method**: `GET`
* **Path**: `/api/v1/dashboard/daily`
* **Query Parameters**:
  - `target_date` (`String`, optional `YYYY-MM-DD`, defaults to current date)
* **Headers**: `Authorization: Bearer <access_token>`, `Accept: application/json`
* **Response DTO (`DailyDashboardResponseModel` - `200 OK`)**:
  ```json
  {
    "date": "2026-08-25",
    "target_calories": 2400.0,
    "consumed_calories": 1872.0,
    "remaining_calories": 528.0,
    "protein": {
      "target": 180.0,
      "consumed": 75.0,
      "remaining": 105.0
    },
    "carbs": {
      "target": 250.0,
      "consumed": 243.6,
      "remaining": 6.4
    },
    "fat": {
      "target": 70.0,
      "consumed": 37.5,
      "remaining": 32.5
    },
    "meals": [
      {
        "meal_id": "c1f7b8e0-1234-4567-89ab-cdef01234567",
        "meal_type": "snack",
        "user_caption": "Banana Snack",
        "image_url": "https://example.com/banana.jpg",
        "calories": 210.04,
        "protein_g": 2.57,
        "carbs_g": 53.81,
        "fat_g": 0.78,
        "logged_at": "2026-08-25 15:30:00+00"
      }
    ],
    "top_micronutrients": {
      "Fiber, total dietary (g)": 37.2,
      "Calcium, Ca (mg)": 750.0
    }
  }
  ```

#### 2. Historical Analytics Breakdown Endpoint
* **HTTP Method**: `GET`
* **Path**: `/api/v1/dashboard/history`
* **Query Parameters**:
  - `days` (`int`, optional `1-365`, default: `30`)
* **Headers**: `Authorization: Bearer <access_token>`, `Accept: application/json`
* **Response DTO (`HistoricalAnalyticsResponseModel` - `200 OK`)**:
  ```json
  {
    "user_id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
    "total_days_logged": 14,
    "history": [
      {
        "date": "2026-08-25",
        "meal_count": 3,
        "total_calories": 1872.0,
        "target_calories": 2400.0,
        "total_protein_g": 75.0,
        "target_protein_g": 180.0,
        "total_carbs_g": 243.6,
        "target_carbs_g": 250.0,
        "total_fat_g": 37.5,
        "target_fat_g": 70.0,
        "goal_status": "under"
      }
    ]
  }
  ```

---

## 3. Layered Architecture Breakdown

Following the project's **Feature-First Lightweight Architecture** guidelines:

```text
lib/features/dashboard/
├── data/
│   ├── datasources/
│   │   └── dashboard_remote_data_source.dart      # Dio HTTP requests (/dashboard/daily, /dashboard/history)
│   ├── models/
│   │   ├── daily_dashboard_response_model.dart    # DTO for daily summary, macro progress, logged meal summary
│   │   └── historical_analytics_response_model.dart # DTO for historical trend items & goal status
│   └── repositories/
│       └── dashboard_repository.dart               # Data access orchestration & caching layer
├── presentation/
│   ├── providers/
│   │   └── dashboard_provider.dart                 # Riverpod providers for date state, daily dashboard, and history
│   ├── screens/
│   │   └── dashboard_screen.dart                   # Main dashboard screen container with pull-to-refresh
│   └── widgets/
│       ├── date_selector_bar.dart                  # Date navigation header (Prev/Next date buttons, DatePicker trigger)
│       ├── calorie_progress_ring.dart              # Custom painted circular ring (Target vs Consumed vs Remaining)
│       ├── macro_card_grid.dart                    # Protein, Carbs, Fat progress cards with color coding
│       ├── logged_meals_list.dart                  # Today's meal cards list (Breakfast, Lunch, Dinner, Snack)
│       ├── top_micronutrients_card.dart            # Key micronutrients progress & breakdown chip list
│       └── historical_analytics_chart.dart         # Interactive multi-day bar chart & historical trend cards
```

---

## 4. State Management Design

### 4.1 Riverpod Providers Definition

State is managed cleanly via Riverpod providers in `lib/features/dashboard/presentation/providers/dashboard_provider.dart`:

```dart
// Currently selected date state (defaults to today)
final selectedDashboardDateProvider = StateProvider<DateTime>((ref) {
  return DateTime.now();
});

// Currently selected historical range in days (7 or 30 days)
final historicalRangeDaysProvider = StateProvider<int>((ref) => 7);

// Family FutureProvider for Daily Dashboard data based on selected date string (YYYY-MM-DD)
final dailyDashboardProvider = FutureProvider.family<DailyDashboardResponseModel, String>((ref, dateStr) async {
  final repository = ref.watch(dashboardRepositoryProvider);
  return repository.getDailyDashboard(dateStr);
});

// Family FutureProvider for Historical Analytics based on days parameter
final historicalAnalyticsProvider = FutureProvider.family<HistoricalAnalyticsResponseModel, int>((ref, days) async {
  final repository = ref.watch(dashboardRepositoryProvider);
  return repository.getHistoricalAnalytics(days);
});
```

### 4.2 Error & Loading State Handling Flow

1. **Loading State**: Render skeletal shimmering loading placeholders for Calorie Ring, Macro Cards, and Logged Meals.
2. **Success State**: Render animated ring progress, macro indicators, meal cards list, and micronutrient chips.
3. **Empty State**: When `meals` list is empty for the selected date, display a friendly placeholder card: *"No meals logged for this date yet. Tap the camera button below to log your first meal!"*
4. **Error State**: Render a clean alert banner with a **"Retry"** button to re-fetch dashboard data.

---

## 5. UI & Light Theme Guidelines (Vibrant Food & Health Palette)

### 5.1 Color Scheme & Visual Identity
* **Background**: Soft Slate Porcelain (`AppColors.lightBackground` = `#F1F5F9`).
* **Cards & Surfaces**: Pure Crisp White (`#FFFFFF`) with 1.5px slate border (`#CBD5E1`) and soft shadow (`0 8px 24px rgba(5, 150, 105, 0.08)`).
* **Calorie Sunset Accent**: Warm Citrus Orange (`AppColors.calories` = `#EA580C`).
* **Protein Ocean Blue Accent**: Deep Blue (`AppColors.protein` = `#2563EB`) & Blue Container (`#DBEAFE`).
* **Carbs Honey Gold Accent**: Warm Amber (`AppColors.carbs` = `#D97706`) & Amber Container (`#FEF3C7`).
* **Fat Avocado Green Accent**: Organic Emerald (`AppColors.fat` = `#059669`) & Mint Container (`#D1FAE5`).
* **Typography**: Deep Ink Slate (`#0F172A`) for high contrast readability.

### 5.2 Widget Specs

#### 1. `DateSelectorBar`
* **Layout**: Horizontal bar with `[ < Prev ]`, `[ Date Label e.g. "Today, Aug 25" ]`, `[ Next > ]` buttons and a calendar icon button launching Flutter's `showDatePicker`.

#### 2. `CalorieProgressRing`
* **Custom Painter Ring**: Double ring canvas painter:
  - Outer ring track: Light gray background (`#E2E8F0`).
  - Active sweep angle arc: Gradient Warm Citrus (`#EA580C` to `#F97316`).
* **Center Metrics Text**: Large bold calorie count (`1,872`), subtitle `of 2,400 kcal`, and a pill tag `528 kcal remaining`.

#### 3. `MacroCardGrid`
* **3 Equal Width Cards**:
  - **Protein**: Blue icon, `75 / 180g`, progress bar in Ocean Blue (`#2563EB`).
  - **Carbs**: Amber icon, `243.6 / 250g`, progress bar in Honey Gold (`#D97706`).
  - **Fat**: Emerald icon, `37.5 / 70g`, progress bar in Avocado Green (`#059669`).

#### 4. `LoggedMealsList`
* **Card Items**: Styled cards grouped by meal type (`Breakfast 🍳`, `Lunch 🥗`, `Dinner 🥩`, `Snack 🍌`).
* **Item Details**: Thumbnail image, food name/caption, timestamp, calorie count badge, and quick macro pill tags (Protein, Carbs, Fat).

#### 5. `HistoricalAnalyticsChart`
* **Bar Chart / Trend Component**: 7-day or 30-day bar chart comparing daily consumed calories vs target line, with goal status badges (`under` in Mint Green, `met` in Blue, `over` in Citrus Red).

---

## 6. Testing & Verification Checklist

### 6.1 Unit & Data Layer Verification
- [ ] **Data Source Tests**: Verify `DashboardRemoteDataSource` calls `/dashboard/daily` and `/dashboard/history` with correct query parameters and Authorization Bearer headers.
- [ ] **Repository Tests**: Verify `DashboardRepository` returns parsed `DailyDashboardResponseModel` and `HistoricalAnalyticsResponseModel` instances, correctly converting network errors to `ServerException`.

### 6.2 State & Provider Verification
- [ ] **Provider Tests**: Verify `selectedDashboardDateProvider` updates when dates change, and `dailyDashboardProvider` fetches the corresponding date string data.
- [ ] **Historical Range Tests**: Verify `historicalAnalyticsProvider` updates when switching between 7-day and 30-day views.

### 6.3 UI & Widget Verification
- [ ] **Widget Tests**:
  - `DateSelectorBar`: Verify date display text, previous/next date button interactions, and calendar picker callback.
  - `CalorieProgressRing`: Verify rendering of consumed, remaining, and target calorie metrics.
  - `LoggedMealsList`: Verify rendering of logged meal items and empty state card when meals list is empty.
  - `DashboardScreen`: Verify pull-to-refresh behavior and loading/error state displays.

### 6.4 Static Analysis & Formatting
- [ ] Run formatting check: `dart format .`
- [ ] Run static analyzer: `flutter analyze`
- [ ] Execute test suite: `flutter test`
