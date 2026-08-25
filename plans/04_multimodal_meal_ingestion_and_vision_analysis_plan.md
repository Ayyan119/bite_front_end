# Implementation Plan: Multimodal Meal Ingestion & Vision Analysis (Task 04)

## Goal Description
Implement the **Multimodal Meal Ingestion & Vision Analysis** feature for Bite Flutter application based on [`specs/04_multimodal_meal_ingestion_and_vision_analysis.md`](file:///home/jiggra/BiteFrontEnd/specs/04_multimodal_meal_ingestion_and_vision_analysis.md).

This feature allows users to:
1. Capture food photos (via device camera or gallery picker using `image_picker`) or input text captions (e.g. *"2 bananas with 1 cup milk"*).
2. Submit multimodal payloads to `POST /api/v1/meals/analyze` via `Dio` (`multipart/form-data` or `application/json`).
3. Review AI-detected food items on an interactive review screen (`MealReviewScreen`).
4. Modify portion amounts, update unit dropdowns, delete misidentified items, or manually add missing food items with real-time macro recalculations.
5. Commit confirmed meals to `POST /api/v1/meals/confirm` and immediately invalidate/refresh the daily dashboard state.
6. Experience fluid micro-interactions: Hero image morphs, scanning radar overlays during vision processing, spring quantity steppers, macro count-up interpolations, and success pulse checkmarks.

---

## User Review Required

> [!IMPORTANT]
> **Image Picker & Web Support**: Device camera/gallery picking uses the standard `image_picker` package. For Web/Chrome target, image selection uses browser file upload (`XFile.readAsBytes()`). Both file path and raw byte uploads are handled seamlessly by `MealsRemoteDataSource`.

> [!NOTE]
> **Dashboard Provider Integration**: Upon successful `POST /meals/confirm`, the notifier will execute `ref.invalidate(dailyDashboardProvider)`, which causes the Dashboard screen to instantly refetch today's totals and trigger progress ring animations.

---

## Proposed Changes

### Data Layer (`lib/features/meals/data`)

#### [NEW] `lib/features/meals/data/datasources/meals_remote_data_source.dart`
- Create `MealsRemoteDataSource` class using `Dio`.
- Method `analyzeMeal({XFile? file, String? imageUrl, String? userCaption, String? mealType})`:
  - Builds `FormData` if `file` is provided (handling both path for mobile and `MultipartFile.fromBytes` for web).
  - Sends JSON `MealAnalyzeRequestModel` if `imageUrl` is provided.
  - Endpoint: `POST /api/v1/meals/analyze`.
  - Parses response into `MealAnalysisResponseModel`.
- Method `confirmMeal(MealConfirmRequestModel request)`:
  - Endpoint: `POST /api/v1/meals/confirm`.
  - Returns `MealConfirmResponseModel`.

#### [NEW] `lib/features/meals/data/repositories/meals_repository.dart`
- Create `MealsRepository` interface and implementation.
- Catches `DioException` and maps to `ServerFailure` / `NetworkFailure`.

---

### State Management & Logic (`lib/features/meals/presentation/providers`)

#### [NEW] `lib/features/meals/presentation/providers/meal_analysis_notifier.dart`
- Define `MealAnalysisStatus` enum (`initial`, `analyzing`, `review`, `committing`, `success`, `failure`).
- Define `MealAnalysisState` class with:
  - `status`, `selectedImagePath`, `selectedImageBytes`, `userCaption`, `selectedMealType`, `items`, `errorMessage`, `lastConfirmedMeal`.
  - Derived getters: `totalCalories`, `totalProtein`, `totalCarbs`, `totalFat`.
- Define `MealAnalysisNotifier extends StateNotifier<MealAnalysisState>`:
  - `setImage(XFile file)`
  - `setCaption(String caption)`
  - `setMealType(String mealType)`
  - `analyzeMeal()`
  - `updateItemPortion(int index, double newAmount)`
  - `removeItem(int index)`
  - `addItem(DetectedItemModel item)`
  - `confirmMeal()`
  - `reset()`

#### [NEW] `lib/features/meals/presentation/providers/meal_providers.dart`
- `mealsRemoteDataSourceProvider`: Riverpod `Provider<MealsRemoteDataSource>`.
- `mealsRepositoryProvider`: Riverpod `Provider<MealsRepository>`.
- `mealAnalysisNotifierProvider`: `StateNotifierProvider<MealAnalysisNotifier, MealAnalysisState>`.

---

### UI Components & Screens (`lib/features/meals/presentation`)

#### [NEW] `lib/features/meals/presentation/widgets/camera_preview_card.dart`
- Photo selection card with Camera and Gallery buttons.
- Displays selected image thumbnail with `Hero(tag: 'meal-image-preview')`.

#### [NEW] `lib/features/meals/presentation/widgets/vision_scanning_overlay.dart`
- Explicit `AnimationController` driving a scanning laser line and pulsing aura over the food photo during `analyzing` status.
- Wrapped in `RepaintBoundary` for high-fps performance.

#### [NEW] `lib/features/meals/presentation/widgets/meal_type_selector.dart`
- Horizontal choice chip bar (`Breakfast`, `Lunch`, `Dinner`, `Snack`).
- Uses `AnimatedContainer` for smooth pill sliding and scale feedback (`1.05`).

#### [NEW] `lib/features/meals/presentation/widgets/macro_summary_bar.dart`
- Summary bar displaying Total Calories, Protein, Carbs, Fat.
- Uses `TweenAnimationBuilder<double>` for count-up/down animations when macro values change.

#### [NEW] `lib/features/meals/presentation/widgets/detected_item_card.dart`
- Food item card showing food name, portion unit, and macro badges.
- Includes inline `-` / `+` quantity stepper with spring tap animation (`Transform.scale`).
- Includes delete button with smooth collapse transition (`AnimatedSize` + `AnimatedOpacity`).

#### [NEW] `lib/features/meals/presentation/widgets/add_item_dialog.dart`
- Dialog to input food name, portion amount, unit, and estimated calories/macros manually.

#### [NEW] `lib/features/meals/presentation/screens/meal_ingestion_screen.dart`
- Main screen with `CameraPreviewCard`, text caption input field, `MealTypeSelector`, and primary *"Analyze Meal with AI"* button.

#### [NEW] `lib/features/meals/presentation/screens/meal_review_screen.dart`
- Review screen with Hero image, `MacroSummaryBar`, staggered list of `DetectedItemCard`s, *"Add Item"* button, and *"Confirm & Log Meal"* button with checkmark pulse animation on success.

---

### Router & App Shell Integration (`lib/core/router/app_router.dart`)

#### [MODIFY] `lib/core/router/app_router.dart`
- Add routes for meal logging:
  - `/meals/log` -> `MealIngestionScreen`
  - `/meals/review` -> `MealReviewScreen`

---

## Verification Plan

### Automated Tests
1. **Unit & Repository Tests**:
   - `test/features/meals/data/datasources/meals_remote_data_source_test.dart`
   - `test/features/meals/data/repositories/meals_repository_test.dart`
2. **State & Provider Tests**:
   - `test/features/meals/presentation/providers/meal_analysis_notifier_test.dart`
     - Test `analyzeMeal()` success & error paths.
     - Test `updateItemPortion()` scales calories and macros proportionally.
     - Test `removeItem()` and `addItem()` update totals.
3. **Static Analysis & Formatting**:
   - `dart format .`
   - `flutter analyze`

### Manual Verification
1. Launch app in Chrome / Mobile device.
2. Select a food image and/or enter a caption ("2 bananas with 1 cup milk").
3. Tap "Analyze Meal with AI" and verify vision scanning overlay appears.
4. Verify transition to `MealReviewScreen` with Hero animation.
5. Tap quantity steppers (`+`/`-`) and verify animated count-up macro updates.
6. Tap "Confirm & Log Meal" and verify green checkmark pulse and automatic return to Dashboard with updated macro progress ring.
